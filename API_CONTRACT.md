# Snap Foodd — API Contract

Base path: `/api/v1`. Keep this synchronized with Laravel routes and Flutter repositories.

## Conventions
- HTTPS + JSON.
- ISO-8601 timestamps.
- Money uses decimal-safe values or integer minor units.
- Paginate collections where appropriate.
- Server-generated business values are authoritative.

Error shape (API requests return JSON):
```json
{
  "message": "Validation failed.",
  "errors": { "items.0.quantity": ["The items.0.quantity field must be at least 1."] },
  "code": "VALIDATION_FAILED"
}
```

Common HTTP/code mapping: 401 `UNAUTHORIZED` (invalid Google credential uses `INVALID_GOOGLE_CREDENTIAL`); 403 `FORBIDDEN` (or the explicit `ACCOUNT_INACTIVE` response); 404 `NOT_FOUND`; 409 `CONFLICT` or `ORDER_STATE_CONFLICT`; 422 `VALIDATION_FAILED`; 429 `RATE_LIMITED`. Do not depend on framework exception text for UI copy. Validation errors map field names to arrays of messages. Some business errors such as invalid Google credentials and inactive accounts have dedicated codes.

## Auth
`POST /auth/google` · `GET /me` · `POST /auth/logout`

## Catalogue
`GET /categories` · `GET /categories/{category}` · `GET /products` · `GET /products/{product}`. ADMIN catalogue writes use `POST /categories`, `PATCH /categories/{category}`, `DELETE /categories/{category}`, `POST /products`, `PATCH /products/{product}` and `DELETE /products/{product}`. Delete operations soft-deactivate records; product deactivation also sets `is_available=false`. Catalogue list responses use `data` containing a Laravel paginator; search uses `search`, product category filtering uses `category_id`, and `per_page` is bounded to 1–100.

## Orders
`POST /orders` · `GET /orders` · `GET /orders/{order}` · `GET /orders/{order}/tracking` · `GET /orders/{order}/invoice`.
ADMIN operations include `PATCH /admin/orders/{order}/status`, `POST /admin/orders/{order}/assignment`, `GET /admin/orders/{order}/tracking` and `GET /admin/orders/{order}/invoice`.
Checkout sends product IDs, quantities and address data; Laravel resolves prices, availability, fees and totals.

### PATCH /api/v1/admin/orders/{order}/status
ADMIN only. Request body: `{ "status": "ACCEPTED" }`. Allowed requested statuses are `ACCEPTED`, `PREPARING`, `READY_FOR_PICKUP`, `ASSIGNED`, `PICKED_UP`, `OUT_FOR_DELIVERY`, `DELIVERED`, and `CANCELLED`; the order transition service enforces the actual from/to transition graph and returns HTTP 409 when a transition is not allowed. Success returns `{ "data": <updated order> }`. The server records the actor and status history.

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


## Request/response examples

All paths below are relative to `/api/v1`. Unless otherwise noted, successful JSON responses wrap the resource in `data`. Paginated collections wrap Laravel pagination metadata and records under `data`. IDs and model attributes shown are illustrative; optional fields may be null.

### Google sign-in

```http
POST /api/v1/auth/google
Content-Type: application/json
Accept: application/json
```

```json
{ "credential": "<Google ID token returned by Google Sign-In>" }
```

Success (200):

```json
{
  "data": {
    "token": "<Sanctum plaintext token; store securely>",
    "user": {
      "id": 42,
      "name": "Demo Customer",
      "email": "customer@example.test",
      "role": "CUSTOMER",
      "is_active": true
    }
  }
}
```

Send subsequent API calls with `Authorization: Bearer <token>`. The backend validates the Google credential and chooses the role; never send a client-selected role. `POST /auth/logout` revokes the current token. `GET /me` returns `{ "data": { "user": { ... } } }`.

### Catalogue reads

```http
GET /api/v1/products?search=wrap&category_id=3&per_page=20
Authorization: Bearer <token>
Accept: application/json
```

Response shape (abbreviated):

```json
{
  "data": {
    "current_page": 1,
    "data": [
      {
        "id": 15,
        "category_id": 3,
        "name": "Veg Wrap",
        "price": "129.00",
        "is_active": true,
        "is_available": true,
        "category": { "id": 3, "name": "Wraps" }
      }
    ],
    "first_page_url": "...",
    "from": 1,
    "last_page": 1,
    "per_page": 20,
    "to": 1,
    "total": 1
  }
}
```

The nested `data.data` is the record list for paginated endpoints. Customer reads hide inactive/unavailable products and inactive categories. The API clamps `per_page` to 1–100 (default 20). Admin catalogue write operations are role-protected and soft-deactivate records.

### COD checkout

```http
POST /api/v1/orders
Authorization: Bearer <customer-token>
Content-Type: application/json
Accept: application/json
```

```json
{
  "items": [
    { "product_id": 15, "quantity": 2 }
  ],
  "delivery_address": {
    "label": "Home",
    "recipient_name": "Demo Customer",
    "address_line1": "10 Example Road",
    "address_line2": null,
    "city": "Mumbai",
    "state": "Maharashtra",
    "postal_code": "400001",
    "country": "India",
    "latitude": 19.076,
    "longitude": 72.8777
  },
  "payment_method": "COD"
}
```

Success (201): `{ "data": { "id": 1001, "customer_id": 42, "status": "PLACED", "payment_method": "COD", "payment_status": "PENDING", "subtotal": "...", "delivery_fee": "...", "total": "...", "items": [...], "delivery_address_snapshot": {...} } }`. The backend calculates all monetary values and stores order/item/address snapshots. Do not submit client-calculated prices or totals. Checkout accepts 1–50 distinct product lines and quantity 1–99 per line.

### Order and tracking reads

- `GET /orders` — current customer's paginated orders, `per_page` defaults to 20 and is clamped to 1–100.
- `GET /orders/{order}` — order plus items and status history; owner only.
- `GET /orders/{order}/tracking` — current tracking status and latest location for an active assigned trip; customer owner only. Missing/old location is marked stale.
- `GET /orders/{order}/invoice` — invoice for delivered orders; customer owner only.
- `GET /admin/orders/{order}/tracking` and `GET /admin/orders/{order}/invoice` — ADMIN-only API routes.

### Delivery assignment and progression

`POST /admin/orders/{order}/assignment` (ADMIN, 201):

```json
{ "delivery_partner_id": 8 }
```

The response is `{ "data": { ...assignment with order, delivery partner and assigning admin relationships when loaded... } }`. Only a `READY_FOR_PICKUP` order and approved, active, available partner are eligible. Assignment locks the relevant rows, records status history and marks the partner unavailable. Eligibility/state conflicts return 409 `CONFLICT`; retry by refreshing order and partner state rather than blindly replaying.

Delivery partners call `GET /delivery/assignments`, then progress their own assignment using:

```http
PATCH /api/v1/delivery/assignments/123/status
Authorization: Bearer <delivery-partner-token>
Content-Type: application/json
```

```json
{ "status": "PICKED_UP" }
```

Only allowed server-side transitions are accepted. Status options are `PICKED_UP`, `OUT_FOR_DELIVERY`, and `DELIVERED`; invalid transitions return 409. Location writes use `POST /delivery/assignments/{assignment}/location` with `latitude`, `longitude`, `recorded_at` and optional `accuracy`; only the assigned active/approved partner may post while the order is picked up or out for delivery.

### Partner provisioning/approval

ADMIN creates a delivery partner for an existing active non-admin user:

```http
POST /api/v1/admin/delivery-partners
Content-Type: application/json
Authorization: Bearer <admin-token>
```

```json
{ "user_id": 42 }
```

Approval is updated with `PATCH /admin/delivery-partners/{deliveryPartner}/approval` and `{ "approved": true }`. Revocation clears availability. Provisioning is not a public self-service operation.

## Integration checklist

- Include `Accept: application/json` on API calls and `Authorization: Bearer <token>` for protected routes.
- Parse error `code` for application behavior and `errors` for field-level validation; do not parse human-readable `message`.
- Treat `data` as the envelope. Laravel paginator responses are nested as `data.data` plus pagination metadata.
- Keep monetary values decimal-safe; display backend-provided totals, never recalculate authoritative totals in the client.
- Treat 409 as a stale state/business conflict: refresh the affected order/assignment and show a recoverable message.
- A successful assignment is not idempotent by client request key; refresh state before retrying after an uncertain network result.
- Never persist Google ID tokens or bearer tokens in logs. Store the returned application token in the platform's secure storage.
- Admin API routes require an ADMIN bearer token; the separate admin web dashboard uses browser session authentication and CSRF protection.
