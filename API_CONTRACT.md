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
`GET /categories` · `GET /products` · `GET /products/{product}`. Admin CRUD lives under `/admin/categories` and `/admin/products`.

## Orders
`POST /orders` · `GET /orders` · `GET /orders/{order}` · `GET /orders/{order}/tracking` · `GET /orders/{order}/invoice`.
`GET /admin/orders/{order}/invoice` is ADMIN-only.
Checkout sends product IDs, quantities and address data; Laravel resolves prices, availability, fees and totals.

## Delivery
`GET /delivery/requests` · `POST /delivery/assignments/{assignment}/accept` · `POST /delivery/assignments/{assignment}/pickup` · `POST /delivery/assignments/{assignment}/location` · `POST /delivery/assignments/{assignment}/complete`.
Admin uses `/admin/delivery-partners` and `POST /admin/orders/{order}/assign-delivery`.

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
