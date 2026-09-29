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


## Delivery assignment

### POST /api/v1/admin/orders/{order}/assignment

ADMIN only. Assigns a single approved, active, available delivery partner to an order that is `READY_FOR_PICKUP`. The operation is transactional and returns HTTP 409 with `code: CONFLICT` when the order is no longer eligible, the partner is not eligible, or the order is already assigned.

Request: `{ "delivery_partner_id": 123 }`

On success: HTTP 201 with `data` containing the assignment, delivery partner, assigning admin and order status. The server records the `READY_FOR_PICKUP` → `ASSIGNED` status history with the actor.
