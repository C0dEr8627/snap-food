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
`POST /orders` · `GET /orders` · `GET /orders/{order}` · `GET /orders/{order}/tracking`.
Checkout sends product IDs, quantities and address data; Laravel resolves prices, availability, fees and totals.

## Delivery
`GET /delivery/requests` · `POST /delivery/assignments/{assignment}/accept` · `POST /delivery/assignments/{assignment}/pickup` · `POST /delivery/assignments/{assignment}/location` · `POST /delivery/assignments/{assignment}/complete`.
Admin uses `/admin/delivery-partners` and `POST /admin/orders/{order}/assign-delivery`.

Every endpoint must document auth, authorization, validation, response, errors, side effects and concurrency/idempotency behavior.

## Flutter-facing schema freeze — synchronized from backend implementation (2026-09-29)

The following concrete shapes are now synchronized for Flutter integration. Backend implementation remains authoritative for server behavior.

### Google auth
`POST /auth/google` accepts `{ "credential": "<Google ID token>" }`.
Success (200): `{ "data": { "token": "...", "user": { "id": 42, "name": "...", "email": "...", "role": "CUSTOMER|DELIVERY_PARTNER|ADMIN", "is_active": true } } }`.
`GET /me` returns `{ "data": { "user": { ... } } }`. Client never submits a role.

### Catalogue
Customer category/product reads are paginated under `data`, with paginator records at `data.data`. Product records include `id`, `category_id`, `name`, `price`, `is_active`, `is_available`, and optional nested `category { id, name }`. Product filtering supports `search`, `category_id`, and bounded `per_page` (1–100; default 20).

### Orders / COD
`POST /orders` accepts:
```json
{
  "items": [{ "product_id": 15, "quantity": 2 }],
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
Success (201) returns `data` containing at minimum `id`, `customer_id`, `status`, `payment_method`, `payment_status`, `subtotal`, `delivery_fee`, `total`, `items`, and `delivery_address_snapshot`. The server owns prices, availability, fees and totals; Flutter must not submit or trust client-calculated totals. Checkout accepts 1–50 distinct lines and quantity 1–99.
`GET /orders` returns the current customer's paginated orders (`data.data` records; `per_page` 1–100, default 20). `GET /orders/{order}` returns the owner order with items and status history. `GET /orders/{order}/tracking` returns active status, latest location and `is_stale`.
Known order statuses are `PLACED`, `ACCEPTED`, `PREPARING`, `READY_FOR_PICKUP`, `ASSIGNED`, `PICKED_UP`, `OUT_FOR_DELIVERY`, `DELIVERED`, and `CANCELLED`. The server is authoritative for lifecycle transitions.

### Address
Checkout currently accepts an inline `delivery_address` object with `label`, `recipient_name`, `address_line1`, optional `address_line2`, `city`, `state`, `postal_code`, `country`, `latitude`, and `longitude`. The created order exposes an immutable `delivery_address_snapshot`. A separate customer address CRUD contract is not currently frozen.

### Delivery / tracking
Canonical partner routes are:
- `GET /delivery/assignments`
- `PATCH /delivery/assignments/{assignment}/status` with `{ "status": "PICKED_UP|OUT_FOR_DELIVERY|DELIVERED" }`
- `POST /delivery/assignments/{assignment}/location` with `latitude`, `longitude`, `recorded_at`, optional `accuracy`
There are no separate accept/pickup/complete endpoints. Customer tracking is `GET /orders/{order}/tracking`; missing or older-than-120-second location is reported stale. Admin assignment is `POST /admin/orders/{order}/assignment` with `{ "delivery_partner_id": 123 }`.

### Invoice
`GET /orders/{order}/invoice` is customer-owner only and is available for delivered orders. It generates an immutable invoice on first read and returns the same invoice on repeated reads. Invoice numbering is deterministic as `INV-{YYYY}-{order_id padded to 8 digits}`. The invoice preserves immutable financial, address and item snapshots. Admin has the corresponding `/admin/orders/{order}/invoice` route.

### Error handling
Use the documented top-level `code` plus field-level `errors`. Important codes include `UNAUTHORIZED`, `FORBIDDEN`, `VALIDATION_FAILED`, `NOT_FOUND`, `CONFLICT`, `ORDER_STATE_CONFLICT`, `RATE_LIMITED`, `INVALID_GOOGLE_CREDENTIAL`, and `ACCOUNT_INACTIVE`. Treat HTTP 409 as a recoverable stale-state/business conflict rather than blindly replaying a mutation.

### Invoice Flutter-facing success schema

`GET /orders/{order}/invoice` returns `data` with these fields synchronized from the backend invoice controller: `id`, `order_id`, `invoice_number`, `customer_name`, `customer_email`, `delivery_address_snapshot`, `items`, `subtotal`, `delivery_fee`, `total`, `payment_method`, `payment_status`, `issued_at`, and `file_reference`.

Invoice items contain `product_id`, `product_name`, `unit_price`, `quantity`, and `line_total`. `customer_email`, `delivery_address_snapshot`, `issued_at`, and `file_reference` may be null. Financial values and item monetary values are serialized as strings. Flutter treats the invoice as server-authoritative read-only data and does not calculate invoice totals.

Example:
```json
{
  "data": {
    "id": 7,
    "order_id": 42,
    "invoice_number": "INV-2026-00000042",
    "customer_name": "Demo Customer",
    "customer_email": "demo@example.com",
    "delivery_address_snapshot": {"label":"Home","recipient_name":"Demo Customer","address_line1":"10 Example Road","address_line2":null,"city":"Mumbai","state":"Maharashtra","postal_code":"400001","country":"India","latitude":19.076,"longitude":72.8777},
    "items": [{"product_id":15,"product_name":"Biryani","unit_price":"240.00","quantity":2,"line_total":"480.00"}],
    "subtotal":"480.00","delivery_fee":"40.00","total":"520.00","payment_method":"COD","payment_status":"PENDING","issued_at":"2026-09-29T12:00:00+00:00","file_reference":null
  }
}
```
