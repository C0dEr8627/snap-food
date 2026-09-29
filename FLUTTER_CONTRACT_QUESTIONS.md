# Flutter Contract Questions / Integration Gate

This document records the exact API details Developer 2 needs before replacing current local/prototype customer flows with real API calls. It intentionally does not invent payloads.

## Order creation — POST /api/v1/orders
- Exact request JSON field names and types.
- Product-line field names for product ID and quantity.
- Exact address fields; whether the API accepts a saved address ID, inline address, or both.
- COD/payment-method field and allowed value.
- Whether an idempotency key/header is required.
- Success status code and complete response example, including order ID and status.
- Authoritative totals fields and money representation.
- Validation/error examples for unavailable products, invalid quantities, changed prices, empty cart and invalid address.

## Order list — GET /api/v1/orders
- Pagination envelope and field names.
- Order summary fields, order ID/type, status values, timestamps, totals/payment summary.
- Empty collection response.

## Order detail — GET /api/v1/orders/{order}
- Complete success response.
- Order ID/status fields.
- Item/product snapshot fields, quantity and server-calculated prices/totals.
- Delivery-address snapshot fields.
- Payment method/state.
- Status history if exposed.
- Not-found/forbidden examples.

## Address handling
- Whether addresses are persisted customer resources or submitted as delivery snapshots.
- Create/list/update/delete endpoints, if applicable.
- Request/response examples, validation and address identifier type.
- Ownership/error behavior.

## Authentication — POST /api/v1/auth/google
- Exact credential field/type.
- Whether Flutter sends an ID token, authorization code, access token, or another credential.
- Success application-token/session shape.
- User/role response fields.
- Public platform client configuration required by Flutter.

## Catalogue
For GET /categories, GET /products and GET /products/{product}, document the success envelope and exact category/product field names/types, product ID type, price representation, availability/active fields, and pagination/search fields.

## Delivery gate
Before Flutter delivery implementation:
- Delivery-partner provisioning/approval CI is green.
- Delivery request/assignment response examples are documented.
- Assignment ID/status fields and transitions are documented.
- Location update and tracking request/response examples are documented.

## Developer 2 rule
Until these examples are frozen in the shared contract, Flutter will not guess field names, status values, identifiers or payload shapes. Local repositories/fakes may keep UI development moving, but must not be presented as API integration.


## Invoice integration gate
The backend branch now documents `GET /api/v1/orders/{order}/invoice` for customer-owned delivered orders and the corresponding admin route, including deterministic/idempotent invoice numbering. Before Flutter invoice work begins, the shared contract must document the complete Flutter-facing invoice success response, financial/address/item snapshot fields, invoice identifier/number fields, authorization errors and generation/error behavior. Developer 2 will not infer these response fields from the backend implementation.


## 2026-09-29 contract re-check

The backend branch now documents delivery assignment/lifecycle/tracking and invoice endpoints, and backend workflows #209/#259/#266 are recorded as passing. These backend facts do not yet unblock Flutter because the shared contract still lacks the complete Flutter-facing success response schemas.

Still required in the shared/base contract before implementation:
- Order create/list/detail request and response examples, including stable order ID/status and authoritative totals.
- Address resource or inline-snapshot request/response shape and validation behavior.
- Google auth credential exchange and application-session/user-role response.
- Catalogue category/product success fields and pagination/search representation.
- Delivery assignment/list/status/location/tracking request and response examples, including location freshness fields.
- Invoice success response with invoice identifier/number and immutable financial/address/item snapshot fields.

Developer 2 will continue to use local repositories/fakes only where the API contract is incomplete and will not infer missing fields from backend implementation details.



## 2026-09-29 continuation re-check

- Shared `developer-2-flutter/API_CONTRACT.md` remains insufficient for typed Flutter order/address/delivery/invoice integration.
- Backend `developer-1-backend-admin/API_CONTRACT.md` now includes delivery assignment/lifecycle/tracking and invoice endpoint behavior, but does not provide the complete Flutter-facing order/address/catalogue/auth success schemas needed by Developer 2.
- Workflows #209/#259/#266 are recorded as passing, so backend delivery verification is no longer the blocker.

### Still required in the shared/base contract
1. Order create/list/detail request and response examples, including stable ID/status and authoritative totals.
2. Address request/response shape and validation/ownership behavior.
3. Google auth credential exchange and application-session/user-role response.
4. Catalogue category/product success fields and pagination/search representation.
5. Delivery assignment/list/status/location/tracking request and response examples, including freshness fields.
6. Invoice success response with invoice identifier/number and immutable financial/address/item snapshot fields.

Until these are synchronized, Developer 2 will not infer field names, status values, identifiers or payload shapes.


## 2026-09-29 continuation re-check

- Re-read the shared contract on `developer-2-flutter`: it still contains only high-level endpoint declarations for auth, catalogue, orders and delivery, without the complete Flutter-facing success schemas needed for typed integration.
- Re-read `developer-1-backend-admin/API_CONTRACT.md`: delivery assignment/lifecycle/tracking and invoice behavior are documented there, but the richer backend documentation is not synchronized into the shared/base contract with complete Flutter response examples.
- Backend verification #209/#259/#266 is therefore useful evidence for readiness, but it does not remove the shared-schema gate.
- Developer 2 will keep the next order/COD implementation contract-first and will not infer identifiers, status values, DTO fields, payloads or invoice snapshot shapes from backend implementation details.

### Required before the next implementation slice
1. Order create/list/detail request and response examples, stable IDs/status values and authoritative totals.
2. Address request/response shape plus validation and ownership behavior.
3. Google auth credential exchange, application session/token and user-role response.
4. Catalogue success fields, IDs, money/availability representation and pagination/search.
5. Delivery assignment/list/status/location/tracking request and response examples, including freshness fields.
6. Invoice success response, identifier/number fields and immutable snapshot fields.


## 2026-09-29 implementation-gate re-check

The first incomplete Flutter implementation task remains Google SSO, but it cannot be safely implemented until the shared contract defines the exact credential exchange, application session/token response, public client configuration and role fields. The next customer code slice (typed orders/COD/address) is likewise blocked until the shared contract contains exact request/response examples. Developer 2 will not infer these fields from backend implementation details.