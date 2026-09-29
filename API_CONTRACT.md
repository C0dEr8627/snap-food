# Snap Foodd — API Contract

Base path: `/api/v1`. Keep this synchronized with Laravel routes and Flutter repositories.

## Conventions
- HTTPS + JSON.
- ISO-8601 timestamps.
- Money uses decimal-safe values or integer minor units.
- Paginate collections where appropriate.
- Server-generated business values are authoritative.

Error shape:
```json
{"message":"Validation failed","errors":{"field":["Invalid value"]},"code":"VALIDATION_FAILED"}
```
Codes: `UNAUTHORIZED`, `FORBIDDEN`, `VALIDATION_FAILED`, `NOT_FOUND`, `CONFLICT`, `RATE_LIMITED`, `ORDER_STATE_CONFLICT`, `SERVER_ERROR`.

## Auth
`POST /auth/google` · `GET /me` · `POST /auth/logout`

## Catalogue
`GET /categories` · `GET /categories/{category}` · `GET /products` · `GET /products/{product}`. ADMIN catalogue writes use `POST /categories`, `PATCH /categories/{category}`, `DELETE /categories/{category}`, `POST /products`, `PATCH /products/{product}` and `DELETE /products/{product}`. Delete operations soft-deactivate records; product deactivation also sets `is_available=false`. Catalogue list responses use `data` containing a Laravel paginator; search uses `search`, product category filtering uses `category_id`, and `per_page` is bounded to 1–100.

## Orders
`POST /orders` · `GET /orders` · `GET /orders/{order}` · `GET /orders/{order}/tracking` · `GET /orders/{order}/invoice`.
`GET /admin/orders/{order}/invoice` is ADMIN-only.
Checkout sends product IDs, quantities and address data; Laravel resolves prices, availability, fees and totals.

## Delivery
Actual delivery-partner API routes are:
- `GET /delivery/assignments` — paginated assignments owned by the authenticated approved/active delivery partner whose order is assigned, picked up or out for delivery.
- `PATCH /delivery/assignments/{assignment}/status` with `{ "status": "PICKED_UP|OUT_FOR_DELIVERY|DELIVERED" }` — advances only the authenticated partner's own order through allowed transitions; invalid transitions return HTTP 409.
- `POST /delivery/assignments/{assignment}/location` with `latitude`, `longitude`, `recorded_at` and optional `accuracy` — stores an active-trip location for the assignment owner.
- ADMIN partner operations: `GET /admin/delivery-partners`, `POST /admin/delivery-partners`, and `PATCH /admin/delivery-partners/{deliveryPartner}/approval` with `{ "approved": true|false }`.
- ADMIN order assignment: `POST /admin/orders/{order}/assignment` with `{ "delivery_partner_id": 123 }`.

There is no separate `/delivery/requests`, `accept`, `pickup` or `complete` endpoint in the current implementation. Pickup and completion are represented by the status PATCH endpoint. Admin web routes are separate session-authenticated routes and are not part of the `/api/v1` contract.

Every endpoint must document auth, authorization, validation, response, errors, side effects and concurrency/idempotency behavior.


## Delivery assignment

### POST /api/v1/admin/orders/{order}/assignment

ADMIN only. Assigns a single approved, active, available delivery partner to an order that is `READY_FOR_PICKUP`. The operation is transactional and returns HTTP 409 with `code: CONFLICT` when the order is no longer eligible, the partner is not eligible, or the order is already assigned.

Request: `{ "delivery_partner_id": 123 }`

On success: HTTP 201 with `data` containing the assignment, delivery partner, assigning admin and order status. The server records the `READY_FOR_PICKUP` → `ASSIGNED` status history with the actor and marks the assigned partner unavailable to prevent concurrent assignment to another order. If eligibility or order state changes before the transaction obtains its row locks, the operation returns HTTP 409 and does not create the assignment.


## Delivery partner lifecycle and tracking

### GET /api/v1/delivery/assignments
DELIVERY_PARTNER only. Lists assignments owned by the authenticated approved/active partner whose order is in ASSIGNED, PICKED_UP or OUT_FOR_DELIVERY.

### PATCH /api/v1/delivery/assignments/{assignment}/status
DELIVERY_PARTNER only. The authenticated partner may advance only its own assignment through PICKED_UP → OUT_FOR_DELIVERY → DELIVERED. Invalid transitions return HTTP 409.

### POST /api/v1/delivery/assignments/{assignment}/location
DELIVERY_PARTNER only. The authenticated approved/active partner may submit latitude/longitude, optional accuracy and an ISO-8601-compatible recorded timestamp for its own assignment while the order is PICKED_UP or OUT_FOR_DELIVERY. Coordinates are bounded to valid ranges and materially future timestamps are rejected with HTTP 409. Each accepted point is persisted as location history.

### GET /api/v1/orders/{order}/tracking
CUSTOMER owner only. Returns the active order status, latest recorded delivery location and is_stale flag. A location older than 120 seconds is considered stale; missing location is also reported as stale. ADMIN API users may use the corresponding /api/v1/admin/orders/{order}/tracking route.


## Invoices

### GET /api/v1/orders/{order}/invoice
CUSTOMER owner only. Generates the invoice on first read for a DELIVERED order and returns the immutable financial/address/item snapshots captured at issuance. Repeated reads return the same invoice and invoice number.

### GET /api/v1/admin/orders/{order}/invoice
ADMIN only. Returns or generates the same invoice for a DELIVERED order.

Invoice numbering decision: `INV-{YYYY}-{order_id padded to 8 digits}`. The order ID is unique and immutable, and the invoice number has a database uniqueness constraint, so generation is deterministic and idempotent without a separate sequence table. Invoice generation is locked on the order row to serialize concurrent requests.
