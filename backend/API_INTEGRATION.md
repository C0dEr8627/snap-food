# Backend API Integration Guide

This guide is for the Flutter client and any trusted internal API consumer. The canonical endpoint and payload contract is `../API_CONTRACT.md`; this guide focuses on client behavior and integration sequencing.

## Environment

- API base URL: `https://<host>/api/v1` in deployed environments.
- Local development: use the backend's configured local host and port; do not hardcode a production hostname in source.
- Send `Accept: application/json` on every API request.
- Send `Content-Type: application/json` for JSON request bodies.
- Protected API requests use `Authorization: Bearer <application-token>`.
- Never commit environment-specific endpoints, Google credentials, or user tokens.

## Authentication lifecycle

1. Use Google Sign-In in the client and obtain the Google ID credential.
2. Send it to `POST /auth/google` as `{ "credential": "<ID token>" }`.
3. Store the returned `data.token` in platform secure storage; it is a Laravel Sanctum application token, not the Google ID token.
4. Load the user from `data.user` or refresh through `GET /me`.
5. Attach the application token to protected requests.
6. On sign-out, call `POST /auth/logout` and clear the locally stored token regardless of the network result.
7. If a protected call returns 401, clear the session and require authentication again. A 403 means the caller is authenticated but lacks permission or the account/partner is inactive; do not automatically retry it.

Roles are server-owned: `CUSTOMER`, `DELIVERY_PARTNER`, and `ADMIN`. A client must never send a role to elevate access. Delivery-partner access also depends on server-side approval and activation.

## Response handling

Success responses normally use `{ "data": ... }`. For paginated endpoints, the response is `{ "data": { "current_page": 1, "data": [...], "per_page": 20, "total": 123, ... } }`; the list is nested under `data.data`.

API errors use this shape:

```json
{
  "message": "Validation failed.",
  "errors": {
    "items.0.quantity": ["The items.0.quantity field must be at least 1."]
  },
  "code": "VALIDATION_FAILED"
}
```

Recommended client behavior:

| HTTP status | Client behavior |
|---|---|
| 401 | Clear invalid session and navigate to sign-in. |
| 403 | Show permission/account state; do not loop retries. |
| 404 | Treat the requested resource as unavailable; refresh lists where useful. |
| 409 | Refresh current order/assignment/partner state and explain that it changed. |
| 422 | Show field validation errors using `errors`. |
| 429 | Respect retry-after information if provided; avoid rapid retries. |
| 5xx/network failure | Show a recoverable error; retry only safe reads unless current state has been refreshed. |

Use `code` for stable behavior and field-keyed `errors` for forms. Do not branch on English `message` strings.

## Catalogue

- Customer catalogue reads require authentication.
- Use `GET /categories?search=...` and `GET /products?search=...&category_id=...&per_page=...`.
- Customer responses exclude inactive categories and inactive/unavailable products.
- Treat returned price as authoritative display data, not as a checkout quote.
- Admin writes are separate protected endpoints documented in the API contract; soft-deactivation does not physically delete historical data.

## Checkout and order state

- Submit product IDs, quantities, delivery address fields and `payment_method: "COD"` to `POST /orders`.
- Do not submit or trust client prices, subtotal, delivery fee, total, payment state, or order status.
- Use the server-returned order and item snapshots for confirmation screens.
- Refresh order state after a conflict or uncertain checkout/assignment result. The current checkout contract does not expose a client idempotency key; avoid automatic POST retries after timeouts.
- Use `GET /orders` and `GET /orders/{order}` for server-owned status and history.
- Invoice reads are available only after the order is delivered. Invoice number and snapshots are immutable after issuance.

## Delivery partner and tracking

- The assigned partner uses `GET /delivery/assignments`; the current contract has no separate accept endpoint.
- Advance delivery status through `PATCH /delivery/assignments/{assignment}/status` using only `PICKED_UP`, `OUT_FOR_DELIVERY`, and `DELIVERED`.
- Post location only for an active trip and only for the partner's own assignment. Coordinates must be valid; recorded timestamps materially in the future are rejected.
- Customer tracking is owner-only and available for an active assigned trip. Missing or older-than-120-second locations are stale; clients should not represent stale points as live.
- Location polling frequency should be conservative and coordinated with product requirements and hosting limits; no WebSocket or background-GPS service is part of this API.

## Admin access

The API admin endpoints require an ADMIN bearer token. The Laravel web admin dashboard is a separate session-authenticated browser flow with CSRF protection; do not call web form routes as if they were JSON API endpoints.

## Before end-to-end release

- [ ] Confirm Flutter repositories parse the response envelopes and paginator nesting described here.
- [ ] Confirm secure token storage and 401 logout behavior on target platforms.
- [ ] Confirm the configured Google OAuth client ID and allowed origins with the owner.
- [ ] Run integration tests against a disposable MySQL database and a non-production OAuth setup.
- [ ] Verify the actual hosting plan supports the chosen PHP extensions, document root, HTTPS and database connectivity.
- [ ] Do not deploy or run migrations against production without explicit owner approval.
