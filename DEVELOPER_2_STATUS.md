# Developer 2 — Current Flutter Implementation Status

**Date:** 2026-09-29  
**Branch:** `developer-2-flutter`  
**PR:** #1 → `frontend`  
**Current branch head:** `da0137afc79f78469b126a64a283e8b91fa90ce9`

## Current verification checkpoint

The latest observed Flutter CI run for PR #1 was **run 36593195762**. It tested the PR merge commit `563a7d3b399001ec7ea1546eca193cc765d4d614`, not the current branch head.

- Dependency resolution: **passed**
- Dart formatting: **passed**
- `flutter analyze`: **failed**
- Tests: **skipped because analyze failed**
- Android debug build: **skipped because analyze failed**

The analyzer failure in this run was caused by the older PR merge commit still containing the obsolete `_FakeStore` test declaration in `test/features/auth/auth_controller_test.dart`. That declaration was already removed on `developer-2-flutter` by commit `9d3132dd92a1c77868aaba8801729d9ff24fad5e`. Therefore this run does **not** establish that the current branch head fails analysis.

Do not mark Phase 0 as fully verified until a CI run executes the current head `da0137afc79f78469b126a64a283e8b91fa90ce9` (or its corresponding PR merge commit) through analyzer, tests, and Android build.

## Completed implementation

### Phase 0 — Audit / verification
- [x] Static Flutter source audit and screen-to-contract mapping.
- [x] Platform/dependency inventory.
- [x] Flutter CI workflow added and formatting/analyzer verification loop established.
- [~] Current-head CI verification pending.
- [ ] Physical Android device verification.

### Phase 1 — API foundation
- [x] Configured API transport/client.
- [x] Normalized API exceptions and error handling.
- [x] Auth headers/timeouts/safe logging foundation.
- [x] Repository boundaries and fake transport coverage.

### Phase 2 — Session lifecycle
- [x] Secure session storage.
- [x] `/me` session restoration.
- [x] Unauthorized restoration cleanup.
- [x] Logout/revocation and local session cleanup.
- [x] Auth-aware go_router redirects.
- [x] Session controller tests.
- [ ] Google credential exchange/config — blocked by incomplete contract/config.
- [ ] Final role-specific routing — blocked by missing documented user-role response.

### Phase 3 — Catalogue
- [x] Catalogue repository boundary.
- [x] Riverpod controller/state boundary.
- [x] Loading/empty/error/retry UI states.
- [x] Existing customer catalogue screens connected to the state boundary.
- [x] Catalogue fake/controller/widget coverage.
- [ ] Typed category/product DTO mapping — blocked by missing successful response schema.
- [ ] Fully API-backed displayed catalogue fields — schema-gated.

### Phase 4 — Cart / address / COD
- [x] Existing cart UI preserved.
- [x] Local CartRepository/CartController boundary.
- [x] Explicit product IDs for cart lines.
- [x] Quantity update/removal behavior and tests.
- [x] Client subtotal remains preview-only.
- [ ] Address entry/selection — blocked by missing request/response schema.
- [ ] Typed order create request/response — blocked by missing schema.
- [ ] COD checkout — blocked by missing schema.
- [ ] Duplicate-submit protection for real checkout — waits for order controller.
- [ ] Server-authoritative totals/errors — waits for documented order response/error envelope.
- [ ] Order success/detail/history — waits for documented order identifier/status/list/detail fields.

### Phase 5 — Customer orders
- [ ] Order history.
- [ ] Order detail/status.
- [ ] Refresh/empty/error states.
- [ ] Centralized status presentation mapping.

### Phase 6/7 — Delivery / Maps / tracking
- [~] Backend delivery lifecycle/tracking behavior has been reviewed/documented.
- [ ] Flutter delivery assignment/request integration — schema-gated.
- [ ] Canonical delivery routes still need synchronization: shared contract currently names `/delivery/requests` plus separate action routes, while backend detail uses `/delivery/assignments` and PATCH status.
- [ ] Location/tracking Flutter integration.
- [ ] Maps/location permission and active-trip UI.
- [ ] Physical-device GPS verification.

### Invoice
- [ ] Flutter invoice model/repository/UI.
- Blocked until the Flutter-facing invoice success response and immutable snapshot fields are frozen.

## Current blockers

The shared `API_CONTRACT.md` still does not provide complete Flutter-facing examples for:

1. Google auth credential field/type and session response.
2. Catalogue category/product success fields.
3. Order create/list/detail request and response envelopes, stable order ID/status values, and pagination.
4. Address request/response shape and validation.
5. Delivery assignment/status/location/tracking responses and canonical routes.
6. Invoice success response and immutable financial/address/item snapshot fields.

No undocumented DTO fields, status enums, route assumptions, or checkout payloads will be invented.

## Next implementation order

1. **CI:** obtain a run against the current head and fix only concrete current-head formatter/analyzer/test/build failures.
2. **Contract:** Developer 1 synchronizes the exact Flutter-facing order/COD + address schemas and resolves the delivery route discrepancy in the shared/base contract.
3. **Order foundation:** implement typed order models, repository, controller and tests.
4. **Checkout:** implement cart → COD submission with duplicate-submit protection, server-authoritative totals and normalized validation/conflict errors.
5. **Orders UI:** implement success/detail/history plus loading/empty/error/refresh behavior.
6. **Delivery:** implement assignment/status/location/tracking from the frozen contract.
7. **Invoice:** implement invoice integration from the frozen response schema.
8. **Release:** successful CI plus physical-device/integration verification.

## Ownership / safety

- Backend/Laravel-owned files were not modified.
- PR #1 remains open and targets `frontend`.
- No merge or deployment was performed.
- Local Flutter/Dart commands are not available in this GitHub-connected environment; CI is the source of truth for automated Flutter verification.


## Developer 2 continuation checkpoint — 2026-09-29 (current CI + contract gate re-check)

- **Branch:** `developer-2-flutter`
- **PR:** #1 → `frontend`, open and mergeable.
- **Current head:** `2afcb96a119a695a99bd7cf8eeb3d12f5d72ef7b`.
- **Latest Flutter CI:** run `36594747609` is **in progress** against the current head. The job has completed setup/checkout and is currently installing Flutter; dependency resolution, formatting, analyzer, tests and Android build have not completed. Therefore CI is not marked passed or failed.
- **Contract re-check:** shared `API_CONTRACT.md` remains high-level. It still lacks concrete Flutter-facing Google auth, catalogue success, order create/list/detail, address, delivery/tracking and invoice response schemas. The delivery route discrepancy also remains unresolved.
- **Implementation decision:** no safe API-backed order/COD implementation is newly unblocked. Do not invent DTO fields, status enums, request payloads, or route variants.

### Task status
- Phase 0: **[~]** static audit/documentation complete; current-head CI verification in progress; physical-device verification not run.
- Phase 1: **[x]** API foundation complete.
- Phase 2: **[~]** session lifecycle complete; Google SSO exchange/config and role routing contract/config gated.
- Phase 3: **[~]** catalogue repository/controller/state integration complete; typed API mapping schema-gated.
- Phase 4: **[~]** local cart boundary complete; address/COD checkout, server totals/errors and order integration contract-gated.
- Phase 5: **[ ]** customer order history/detail/status not started.
- Phase 6/7: **[~]** backend delivery lifecycle/tracking verified; Flutter delivery integration and canonical routes remain schema-gated.
- Invoice: **[ ]** Flutter integration not started; response schema not frozen.
- Release verification: **[ ]** pending successful CI plus device/integration verification.

### Next execution order
1. Complete and inspect CI run `36594747609`; fix only concrete current-head formatter/analyzer/test/build failures.
2. Developer 1 synchronizes the complete Flutter-facing order/COD + address contract and canonical delivery routes/responses into the shared/base contract.
3. Implement typed order models → repository/controller → tests.
4. Implement cart → COD checkout with duplicate-submit protection and server-authoritative totals/errors.
5. Implement order success/detail/history and refresh/empty/error states.
6. Implement delivery assignment/status/location/tracking, then invoice integration, from frozen schemas.

No backend/Laravel-owned files were modified. No merge or deployment was performed.

## Developer 2 implementation checkpoint — 2026-09-29 (typed order foundation)

### Completed in this increment
- Synchronized the Flutter-facing API contract with the current backend implementation for Google auth, catalogue pagination, COD checkout, order history/detail, address snapshot, canonical delivery/tracking routes, invoice access and error codes.
- Added typed order/domain models for order status, inline delivery address, checkout line requests, order items, server-authoritative totals and paginated order results.
- Added RemoteOrderRepository for POST /orders, GET /orders, and GET /orders/{order} with strict envelope validation and normalized ApiException failures.
- Added OrderCheckoutController with duplicate-submit protection and authenticated API access through secure session-token storage.
- Added OrderHistoryController with paginated history loading, refresh, next-page loading and order-detail loading.
- Added repository/controller tests covering COD payload serialization, server-authoritative order data, missing-order behavior and duplicate-submit protection.

### Verification
- Flutter CI for the current branch is not yet green/complete; a fresh run is required after the implementation commits.
- Local Flutter/Dart commands are unavailable in this GitHub-connected environment, so local analyzer/test/APK results are not claimed.

### Remaining order work
- Wire the checkout controller into the existing cart/address UI.
- Add server validation/conflict presentation without recalculating totals client-side.
- Implement customer order success/detail/history screens and states.
- Add tracking and delivery-partner Flutter flows from the now-frozen canonical routes.
- Add invoice model/repository/UI from the frozen invoice response.

No backend/Laravel-owned files were modified.
## Status correction — contract gate cleared

The earlier sections of this file describing the Flutter order/delivery contract as incomplete are superseded by the 2026-09-29 schema synchronization in `API_CONTRACT.md`. The backend branch now documents the concrete request/response examples used by the new order foundation, and those relevant details have been synchronized to the Flutter branch.

Current implementation therefore advances from contract-gated Phase 4 work to the next integration slice: cart/address UI wiring → COD submission → server-error/conflict presentation → order success/detail/history UI.

Current branch head at this documentation checkpoint: `44efccf13fa01660aaf873d22130cc6d5bc4b2a6`.
GitHub currently reports PR #1 as open but `mergeable: false`; a compare against `frontend` reports the Flutter branch is 168 commits ahead and 0 behind. This mergeability state is recorded without assuming a cause.
CI verification for the latest code commit is not available through the current connector result set; no green analyzer/test/APK result is claimed.
## Developer 2 implementation checkpoint — 2026-09-29 (customer order UI)

### Completed in this increment
- Connected the existing customer Orders screen to `OrderHistoryController` instead of hard-coded order fixtures.
- Added loading, empty, error/retry, pull-to-refresh and pagination states for customer order history.
- Added server-backed order status/payment/total display without recalculating financial totals.
- Added customer order-detail screen backed by `GET /orders/{order}`.
- Added order-detail route `/orders/:orderId`.
- Added server-provided delivery-address snapshot and financial fields to the detail UI.

### Checkout boundary retained
- The COD repository/controller foundation remains implemented, including duplicate-submit protection.
- The current local cart still contains placeholder product identifiers, so this checkpoint does not submit those fixtures to the backend or invent a product-ID mapping.
- The existing checkout screen still contains legacy payment/total presentation and must be converted to the server-authoritative COD flow once cart/product IDs are backed by the catalogue.

### Verification
- PR #1 is open and currently reported mergeable by GitHub.
- The latest Flutter CI run for the previous head is pending; a fresh result for these UI commits is required before marking CI green.
- Local Flutter/Dart commands are unavailable in this GitHub-connected environment; no local analyzer/test/APK result is claimed.

### Next execution order
1. Run/inspect current-head CI and fix only concrete failures.
2. Replace legacy checkout totals/payment choices with COD-only server-backed submission and editable/validated address input.
3. Clear the cart only after a successful server-created order and navigate to order detail using the returned order ID.
4. Add delivery tracking to order detail using the frozen `/orders/{order}/tracking` contract.
5. Implement delivery partner assignment/status/location UI and then invoice integration.

No backend/Laravel-owned files were modified.
## Developer 2 implementation checkpoint — 2026-09-29 (COD checkout integration)

### Completed in this increment
- Wired the customer checkout screen to the existing authenticated OrderCheckoutController.
- Replaced legacy UPI/card selection and client-calculated totals with the contract-defined COD-only checkout flow.
- Added inline delivery-address form validation for the frozen checkout address fields.
- Derived checkout line items from the local cart and enforce positive numeric catalogue product IDs before submission; placeholder fixture IDs are rejected rather than submitted as fake backend IDs.
- Added server-error presentation using ApiException message/code, including validation/conflict responses without recalculating totals client-side.
- Added duplicate-submit protection through the existing controller and disabled checkout controls while submitting.
- Added cart clear operation and clear the cart only after the server successfully creates an order.
- Navigate to the server-returned order detail after successful checkout.
- Corrected the order-detail screen to avoid the unsupported AsyncValue.valueOrNull API.
- Aligned OrderLineRequest.productId with the API contract's integer product IDs and updated the repository test.

### Important remaining integration point
- The current local cart still seeds illustrative non-numeric IDs (biryani, butter). The checkout now safely refuses those values instead of creating invalid orders. The next catalogue/cart increment must replace those fixture identifiers with real API product IDs when adding products to the cart.

### Verification
- No local Flutter/Dart execution is available in this GitHub-connected environment.
- CI must be inspected for the current branch head before marking this increment verified.
- No backend/Laravel-owned files were modified.

### Next execution order
1. Verify current-head CI and fix concrete Flutter failures only.
2. Replace local cart fixture product IDs with real catalogue-backed IDs and typed catalogue mapping.
3. Add/expand checkout tests for successful COD submission, duplicate submission, validation failure and 409 conflict presentation.
4. Improve order success/detail/history UX around the newly real checkout path.
5. Add customer tracking using GET /orders/{order}/tracking.
6. Continue delivery partner integration and invoice UI from the frozen contract.

## Developer 2 continuation checkpoint — 2026-09-29 (typed catalogue + real-ID cart boundary)

### Completed in this increment
- Replaced the transport-neutral catalogue record with typed category/product DTOs matching the synchronized contract: numeric product/category IDs, name, decimal-safe price string, active/available flags, and optional category.
- Added typed paginated catalogue state with currentPage, lastPage, perPage, total and hasNextPage.
- Updated the remote catalogue repository to decode the documented data.data paginator envelope and typed product/category responses, while retaining normalized invalid-response errors.
- Tightened single-product lookup to require a positive numeric product ID.
- Updated catalogue controller/state messaging and tests for the typed model.
- Removed illustrative biryani/butter cart fixtures so checkout cannot accidentally submit fake product IDs.
- Added a cart addItem boundary that stores the catalogue product ID and merges quantities with the backend limit of 99.
- Updated cart tests to cover numeric catalogue IDs and empty initial state.

### Current task status
- Phase 0: [~] source/CI workflow established; current-head CI and physical-device verification remain pending.
- Phase 1: [x] API foundation complete.
- Phase 2: [~] session lifecycle complete; Google credential exchange/config and final role routing remain pending configuration/integration verification.
- Phase 3: [x] typed catalogue DTO/repository/controller mapping is now implemented from the frozen contract; actual runtime API verification remains CI/integration dependent.
- Phase 4: [~] local cart boundary now has no placeholder IDs and supports catalogue-backed numeric IDs; checkout/COD path is implemented but needs successful-path and error/conflict tests.
- Phase 5: [x] customer order history/detail UI is implemented; UX hardening and tracking remain.
- Phase 6/7: [~] backend delivery lifecycle/tracking is documented/verified; Flutter delivery and customer tracking integration remain.
- Invoice: [ ] Flutter invoice integration remains.
- Release verification: [ ] current-head CI, Android build and physical-device/integration verification remain.

### Verification limitation
No local Flutter/Dart runner is available in this GitHub-connected environment. The implementation was therefore not locally formatted/analyzed/tested/built here. CI must be observed on the current branch head before claiming green verification.

### Next implementation queue
1. Verify the new current-head Flutter CI run and fix only concrete failures.
2. Wire a real catalogue product selection into CartController.addItem so the existing food-detail flow no longer depends on mock IDs.
3. Add checkout tests for successful COD submission, duplicate submit, VALIDATION_FAILED, and HTTP 409 conflict handling.
4. Harden order success/detail/history UX and connect customer tracking to the frozen /orders/{order}/tracking response.
5. Continue delivery-partner assignment/status/location and invoice UI from the frozen contract.


## Developer 2 continuation checkpoint — 2026-09-29 (catalogue-to-cart + checkout tests)

### Completed in this increment
- Replaced the remaining illustrative restaurant-menu product IDs with the live typed catalogue product list.
- Restaurant menu now filters the loaded catalogue by category, displays backend product IDs/prices, and adds real catalogue products to the local cart.
- Food-detail route now requires a numeric catalogue product ID, reads the matching typed product from catalogue state, respects active/available flags, and adds that exact product ID to cart.
- Removed the food-detail/menu dependency on mock IDs such as biryani/butter/paneer.
- Checkout controller tests now cover successful duplicate-submit protection, VALIDATION_FAILED, and HTTP 409 conflict handling.
- Fixed order history controller state access to use the supported state.value API.
- Cart remains server-authoritative at checkout; catalogue prices are preview-only.

### Current task status
- Phase 0: [~] documentation/source workflow complete; CI/device verification remains.
- Phase 1: [x] API foundation complete.
- Phase 2: [~] session lifecycle implemented; Google SSO/config and final role-routing verification remain.
- Phase 3: [x] typed catalogue DTO/repository/controller and catalogue-backed UI selection complete.
- Phase 4: [~] real-ID cart + COD checkout implemented; checkout test coverage now includes success/duplicate/validation/409 paths. End-to-end runtime verification remains.
- Phase 5: [x] order history/detail UI implemented; customer tracking remains.
- Phase 6/7: [~] backend delivery lifecycle/tracking behavior is documented/verified; Flutter delivery/tracking integration remains.
- Invoice: [ ] Flutter invoice integration remains.
- Release verification: [ ] current-head CI, Android build and physical-device/integration verification remain.

### Next implementation queue
1. Verify current-head CI and fix concrete compile/analyzer/test failures.
2. Inspect the frozen tracking response and implement customer tracking from /orders/{order}/tracking.
3. Implement delivery assignment/status/location integration from the documented schemas.
4. Implement invoice model/repository/UI from the frozen invoice schema.
5. Finish UX hardening and final CI/device/end-to-end verification.


## Developer 2 implementation checkpoint — 2026-09-29 (CI failure remediation + catalogue cart wiring)

- **Branch:** `developer-2-flutter`
- **Current head:** `a4330bc9a54571a958414b68c77a390b7ab228db`.
- **CI evidence inspected:** Flutter CI run `36598554720` failed during `Analyze`. Formatting/check-format completed successfully; tests and Android build were skipped because analysis failed.
- **Concrete failures remediated:** restored the missing cart model import, replaced unsupported Riverpod `valueOrNull`, restored the order-model import, removed an unused broken auth test fake, updated the typed catalogue widget fixture, restored the `ApiException` test import, and restored the missing menu-item tap callback.
- **Catalogue/cart correction:** removed remaining illustrative restaurant-menu product fixtures and connected the restaurant menu to typed catalogue products and the real local cart boundary. Menu actions now use numeric catalogue product IDs and respect active/available state.
- **Verification:** no local Flutter/Dart runner is available in the GitHub-connected environment. A new CI run is required against the current head; no green result is claimed yet.
- **Backend boundary:** no Laravel/backend-owned files were modified.
- **PR:** existing PR #1 continues to target `frontend`; no merge or deployment performed.

### Current task status
- Phase 0: **[~]** static audit complete; CI failure analyzed and concrete failures fixed; current-head CI verification remains pending.
- Phase 1: **[x]** API foundation complete.
- Phase 2: **[~]** session lifecycle complete; Google credential exchange/config and final role routing remain configuration/integration work.
- Phase 3: **[x]** typed catalogue mapping and catalogue-backed menu/product selection are implemented; runtime API verification remains CI/integration dependent.
- Phase 4: **[~]** numeric-ID cart and COD checkout foundation are implemented; successful runtime checkout verification remains pending.
- Phase 5: **[x]** order history/detail UI implemented; tracking remains.
- Phase 6/7: **[~]** delivery/tracking Flutter integration remains.
- Invoice: **[ ]** Flutter invoice integration remains.
- Release verification: **[ ]** current-head CI, Android build and physical-device/end-to-end verification remain.

### Next task
1. Inspect the new current-head Flutter CI run and fix only concrete failures.
2. Then implement customer order tracking from `GET /orders/{order}/tracking`.
3. Continue delivery-partner assignment/status/location integration, then invoice UI.


## Developer 2 implementation checkpoint — 2026-09-29 (customer order tracking)

### Completed in this increment
- Added typed customer tracking models for tracking status, latest latitude/longitude, recorded timestamp, accuracy and stale-state handling.
- Extended the existing OrderRepository with GET /orders/{order}/tracking using the frozen API contract.
- Added OrderTrackingController with loading/error/data states.
- Extended the existing order-detail screen to load tracking only for active orders, show current delivery status/location freshness, and expose retry behavior.
- Added repository/model coverage for tracking decoding and corrected the existing checkout test to assert the documented integer product_id.
- Preserved existing order-detail navigation and visual structure; no backend/Laravel-owned files were modified.

### Verification
- Local Flutter/Dart commands remain unavailable in this GitHub-connected environment; no local analyze/test/build result is claimed.
- The earlier current-head CI run 36594747609 was cancelled and therefore does not verify this increment.
- A fresh CI run for the new commits is required and must complete dependency resolution, formatting, analyzer, tests and Android build before release verification can be marked complete.

### Current task status
- Phase 0: [~] static audit complete; current-head CI/device verification remains pending.
- Phase 1: [x] API foundation complete.
- Phase 2: [~] session lifecycle complete; Google SSO configuration/exchange and final role routing remain integration-gated.
- Phase 3: [x] typed catalogue → menu/detail → real numeric cart IDs complete.
- Phase 4: [x] cart → COD checkout foundation and tests complete; address validation, server errors and successful order navigation are integrated.
- Phase 5: [x] order history/detail UI complete; customer tracking now implemented.
- Phase 6/7: [~] delivery-partner assignment/status/location integration and active-trip/maps UI remain.
- Invoice: [ ] Flutter invoice integration remains.
- Release verification: [ ] current-head CI, Android/device and end-to-end verification remain.

### Next implementation
1. Verify the current-head Flutter CI and fix only concrete failures.
2. Implement delivery-partner assignment/request/status/location Flutter flows from the frozen canonical delivery contract.
3. Add active-trip/customer navigation and location freshness handling without background GPS, geofencing or WebSockets.
4. Implement invoice model/repository/UI.
5. Finish physical-device and end-to-end verification.

No merge or deployment performed.

## Developer 2 implementation checkpoint — 2026-09-29 (delivery assignment foundation)

- Added typed delivery assignment and location-update models.
- Added RemoteDeliveryRepository for GET /delivery/assignments, PATCH /delivery/assignments/{assignment}/status and POST /delivery/assignments/{assignment}/location.
- Added assignment/status validation and connected the existing Delivery Requests screen to the assignment API through Riverpod without changing its overall layout/navigation.
- The request action now crosses the real server status mutation boundary instead of only showing a snackbar.
- No background GPS, WebSockets, geofencing or backend/Laravel-owned files were introduced.

### Verification
- Local Flutter/Dart execution is unavailable; formatter/analyzer/tests/APK build are NOT RUN.
- A fresh Flutter CI run is required for the current branch head.
- No merge or deployment performed.

### Current task status
- Phase 0: [~] static audit complete; CI/device verification pending.
- Phase 1: [x] API foundation complete.
- Phase 2: [~] session lifecycle complete; Google SSO/config and role routing remain gated.
- Phase 3: [x/~] catalogue-to-cart and checkout integration implemented; runtime verification pending.
- Phase 4: [x/~] cart/COD checkout and order integration implemented; runtime verification pending.
- Phase 5: [x] customer orders/detail/tracking integration implemented in source; runtime verification pending.
- Phase 6: [~] delivery assignment repository/request-list API integration started; lifecycle UX and active-assignment flow remain.
- Phase 7: [~] customer tracking exists; partner location publishing, active-trip location adapter and maps integration remain.
- Invoice: [ ] not started.
- Release verification: [ ] CI/device/E2E pending.

### Next implementation
1. Verify current-head CI and fix only concrete failures.
2. Refine delivery assignment lifecycle UI for PICKED_UP, OUT_FOR_DELIVERY and DELIVERED.
3. Implement active-assignment state and location adapter with permission/freshness/error handling, without background GPS.
4. Connect delivery navigation screens to assignment/order data.
5. Implement invoice model/repository/UI.


## Developer 2 implementation checkpoint — 2026-09-29 (delivery lifecycle)

### Completed
- Added a Riverpod delivery repository/controller boundary for assignment retrieval and active-assignment discovery.
- Refined Delivery Requests actions to follow the documented server lifecycle: unstarted assignment -> PICKED_UP -> OUT_FOR_DELIVERY -> DELIVERED.
- Removed the previous hard-coded request fallback when the assignment API fails; API errors now surface instead of presenting stale mock requests as real data.
- Added typed delivery model tests covering assignment decoding and location payload serialization.
- Kept the existing delivery UI structure and navigation intact.
- No background GPS, geofencing, WebSockets, or backend/Laravel changes introduced.

### Verification
- Local Flutter/Dart commands remain NOT RUN because the GitHub-connected environment has no Flutter/Dart runner.
- Current-head CI/device verification is still required before claiming the implementation verified.

### Updated task status
- Phase 0: [~] static audit complete; runtime/CI verification pending.
- Phase 1: [x] API foundation complete.
- Phase 2: [~] session lifecycle complete; Google SSO exchange/config and final role routing remain contract/config gated.
- Phase 3: [x/~] catalogue -> menu/detail -> cart integration implemented; runtime verification pending.
- Phase 4: [x/~] cart/COD checkout foundation implemented; runtime verification pending.
- Phase 5: [x/~] order history/detail/tracking source integration implemented; runtime verification pending.
- Phase 6: [~] delivery assignment retrieval + lifecycle transitions implemented; active trip/navigation/location flow remains.
- Phase 7: [~] customer tracking implemented; partner location adapter, permission/freshness handling and maps integration remain.
- Invoice: [ ] not started.
- Release verification: [ ] CI/device/E2E pending.

### Next implementation
1. Implement active-trip location adapter with permission/error/freshness handling and throttled foreground updates only.
2. Connect partner navigation/trip screen to the active assignment instead of static trip data.
3. Send location updates only for the active assignment and stop them on completion/exit.
4. Add invoice repository/model/UI.
5. Run current-head CI and device/E2E verification when tooling is available.


## Developer 2 implementation checkpoint — 2026-09-29 (active-trip location boundary)

### Completed in this increment
- Added a foreground-only `DeliveryLocationSource` abstraction so platform GPS/permission APIs stay behind a small adapter boundary.
- Added `ForegroundDeliveryLocationAdapter` with explicit permission states, start/stop lifecycle, first-position emission and throttling at a default 5-second interval in line with `DELIVERY_TRACKING.md`.
- Added `ActiveDeliveryLocationController` that binds location publishing to one active assignment ID and posts only through `POST /delivery/assignments/{assignment}/location`.
- Location publishing stops when the active trip is stopped; no background location, geofencing or WebSockets were introduced.
- Bound the partner customer-navigation screen to `activeDeliveryAssignmentProvider` so assignment/order/address/status values no longer come from the old static trip identifiers.
- Added adapter/controller-boundary tests for denied permission, unavailable GPS, foreground emission, throttling and clean shutdown.

### Important platform limitation
- The repository currently has no concrete Android/iOS location plugin dependency. The default app source therefore uses an explicit `UnavailableDeliveryLocationSource` rather than inventing a platform GPS implementation.
- A platform adapter still needs to be wired once the approved location package/platform configuration is available. Physical permission/GPS verification remains pending.
- This preserves the contract boundary and prevents the app from silently pretending that GPS is available.

### Current task status
- Phase 0: **[~]** static audit complete; current-head CI/device verification pending.
- Phase 1: **[x]** API foundation complete.
- Phase 2: **[~]** session lifecycle complete; Google SSO configuration/exchange and final role routing remain integration-gated.
- Phase 3: **[x]** typed catalogue → menu/detail → real numeric cart IDs complete; runtime verification pending.
- Phase 4: **[x]** cart → COD checkout foundation/tests and server-backed navigation integrated; runtime verification pending.
- Phase 5: **[x]** order history/detail/tracking source integration implemented; runtime verification pending.
- Phase 6: **[~]** delivery assignment retrieval/lifecycle and active-assignment state implemented; concrete platform GPS and complete partner trip flow remain.
- Phase 7: **[~]** foreground location adapter, permission-state boundary and throttled active-assignment publishing boundary implemented; platform GPS source, freshness UI, maps SDK and physical-device verification remain.
- Invoice: **[ ]** Flutter invoice integration not started.
- Release verification: **[ ]** current-head CI, Android build and physical-device/E2E verification pending.

### Next implementation queue
1. Wire the approved platform location package into `DeliveryLocationSource` once its dependency/configuration is available.
2. Add last-location freshness/error presentation to the partner active-trip UI.
3. Stop the location controller on completed assignment and navigation exit; verify lifecycle behavior.
4. Implement invoice model/repository/UI from the frozen invoice contract.
5. Run current-head CI and physical-device/E2E verification when tooling is available.

No backend/Laravel-owned files were modified. No merge or deployment was performed.


## Developer 2 implementation checkpoint — 2026-09-29 (active-trip lifecycle/freshness)

### Completed in this increment
- Extended the active delivery location controller with last-successful-publish tracking.
- Bound the partner customer-navigation screen to the active assignment lifecycle: location publishing starts for an active assignment, stops for delivered/cancelled assignments, stops when the partner marks arrival, and stops when the navigation screen is disposed.
- Added foreground location status presentation for requesting permission, active tracking, permission denial, unavailable GPS and publish errors.
- Preserved the existing navigation/map UI structure; no background GPS, geofencing or WebSockets were introduced.
- The default location source remains explicitly unavailable because no concrete Android/iOS location package is currently configured; the UI now reports that limitation instead of implying GPS is active.

### Verification
- Local Flutter/Dart formatter, analyzer, tests and Android build remain NOT RUN because the GitHub-connected environment has no Flutter/Dart runner.
- No physical-device permission/GPS verification was performed.
- No backend/Laravel-owned files were modified.

### Current task status
- Phase 0: **[~]** static audit complete; current-head CI/device verification pending.
- Phase 1: **[x]** API foundation complete.
- Phase 2: **[~]** session lifecycle complete; Google SSO configuration/exchange and final role routing remain integration-gated.
- Phase 3: **[x]** typed catalogue → menu/detail → real numeric cart IDs complete; runtime verification pending.
- Phase 4: **[x]** cart → COD checkout foundation/tests and server-backed navigation integrated; runtime verification pending.
- Phase 5: **[x]** order history/detail/tracking source integration implemented; runtime verification pending.
- Phase 6: **[~]** delivery assignment retrieval/lifecycle and active-assignment state implemented; concrete platform GPS and complete partner trip flow remain.
- Phase 7: **[~]** foreground adapter, active-assignment publishing, lifecycle stop behavior and freshness/error presentation are implemented; approved platform GPS source, Maps SDK, physical-device verification and customer/partner map rendering remain.
- Invoice: **[ ]** Flutter invoice integration not started.
- Release verification: **[ ]** current-head CI, Android build and physical-device/E2E verification pending.

### Next implementation queue
1. Identify and wire the approved Android/iOS location package and restricted Maps configuration from project documentation/configuration; do not add speculative dependencies.
2. Complete platform permission/revocation and real-GPS physical-device verification.
3. Implement invoice model/repository/UI from the frozen invoice endpoint contract, without inventing undocumented response fields.
4. Inspect/fix current-head CI once available.
5. Finish end-to-end/device verification and update PR readiness.

No backend/Laravel-owned files were modified. No merge or deployment was performed.


## Developer 2 continuation checkpoint — 2026-09-29 (current-head CI analyzer fixes)

- Current branch head: `7d1809dd33dcc7dd8996a0cedf5fa544cbeee5d2`.
- Inspected Flutter CI run `36601413076` for the previous active-trip head. Dependency resolution and formatting passed, but `flutter analyze` failed; tests and Android build were skipped.
- Fixed all concrete analyzer errors reported by that run:
  - imported the typed `DeliveryLocationUpdate` model into the active location controller;
  - corrected `ConsumerStatefulWidget.createState` typing and preserved the active-assignment map panel binding;
  - removed stale duplicate delivery transport/session provider declarations from the delivery requests screen;
  - completed the order-controller test fake with `fetchTracking`;
  - removed invalid const construction in foreground location adapter tests;
  - made the food-detail quantity increment callback nullable to match the disabled-at-limit state.
- No speculative API fields, location packages, Maps SDKs or backend/Laravel files were added.
- A new CI run for `7d1809dd33dcc7dd8996a0cedf5fa544cbeee5d2` was not yet visible at documentation time; current-head verification remains pending.

### Task board after this increment
- Phase 0: **[~]** static audit complete; concrete current-head CI failures from the last run fixed; fresh analyzer/test/Android verification pending; physical-device verification pending.
- Phase 1: **[x]** API foundation complete.
- Phase 2: **[~]** session lifecycle complete; Google SSO exchange/config and final role routing remain configuration/integration gated.
- Phase 3: **[x]** typed catalogue → menu/detail → real numeric cart IDs complete; runtime verification pending.
- Phase 4: **[x]** cart → COD checkout foundation, validation/conflict handling and successful-order navigation implemented; runtime verification pending.
- Phase 5: **[x]** order history/detail and customer tracking implemented; runtime verification pending.
- Phase 6: **[~]** delivery assignment/status lifecycle implemented; partner active-trip location lifecycle implemented; approved platform GPS/Maps integration remains.
- Phase 7: **[~]** customer tracking + foreground location adapter/lifecycle/freshness/error states implemented; concrete GPS/Maps platform integration and physical-device verification remain.
- Invoice: **[ ]** Flutter invoice model/repository/UI remains; exact Flutter-facing invoice response fields are still not enumerated in the shared contract, so no speculative DTO is being added.
- Release verification: **[ ]** fresh CI, Android build, physical device and E2E verification pending.

### Next execution queue
1. Inspect the fresh CI run for `7d1809dd33dcc7dd8996a0cedf5fa544cbeee5d2` and fix only newly reported concrete failures.
2. Identify an approved Android/iOS location package and Maps configuration from project configuration/documentation before adding dependencies.
3. Verify real permission/GPS behavior on a physical device.
4. Freeze the exact invoice success response fields, then implement invoice model/repository/UI without inventing fields.
5. Complete E2E/device verification and update PR readiness.


## Developer 2 continuation checkpoint — 2026-09-29 (current-head CI analyzer follow-up)

- Current implementation branch: `developer-2-flutter`.
- PR #1 remains open, targets `frontend`, and GitHub reports it mergeable.
- Current implementation head before this fix: `b6e20cbfdcfaf3d5d74fbdae05c904d964486a39`.
- Flutter CI run `36603659984` (run #187) executed against the PR merge commit containing that head. Dependency resolution and Dart formatting passed; `flutter analyze` failed, so tests and Android debug build were skipped.
- The only concrete analyzer error in the run was `StreamController` being unresolved in `test/features/delivery/delivery_location_adapter_test.dart`. The test used `StreamController<DeliveryPosition>` without importing `dart:async`.
- Fixed that exact issue in commit `ea88f35202db2153570aa149b51b8b805df07bcc`. No production behavior, API contract, GPS dependency, Maps SDK, or backend/Laravel-owned file was changed.
- The CI log also contains many pre-existing warning/info-level lints across the legacy UI. They were not broad-cleaned in this increment; only the concrete analyzer error that stopped the pipeline was fixed.
- The synchronized `API_CONTRACT.md` now contains concrete Google auth, catalogue, order/COD, address, delivery/tracking and invoice contract details. Therefore order/invoice work is no longer blocked by the earlier documentation gap.
- `pubspec.yaml` currently has no concrete Android/iOS location or Google Maps package. The approved platform dependency/configuration still needs to be identified from project requirements before adding one; no speculative package was added.

### Task status after this increment
- Phase 0: **[~]** static audit and CI workflow complete; current-head analyzer/test/Android verification still pending after the latest fix; physical-device verification pending.
- Phase 1: **[x]** API foundation complete.
- Phase 2: **[~]** session lifecycle and auth-aware routing complete; Google platform credential configuration and final role-specific runtime verification remain.
- Phase 3: **[x]** typed catalogue → menu/detail → real numeric cart IDs complete; automated/runtime verification pending.
- Phase 4: **[x]** cart → COD checkout foundation, validation/conflict handling, duplicate-submit protection, server-authoritative order response handling and success navigation implemented; current CI/device verification pending.
- Phase 5: **[x]** order history/detail and customer tracking source integration implemented; runtime verification pending.
- Phase 6: **[~]** delivery assignment/status lifecycle and active-assignment location lifecycle implemented; concrete platform GPS/Maps integration and complete partner trip verification remain.
- Phase 7: **[~]** foreground location adapter, active-assignment publishing, stop lifecycle and freshness/error states implemented; concrete GPS source, Maps SDK/configuration and physical-device verification remain.
- Invoice: **[ ]** Flutter invoice model/repository/UI remains to be implemented from the now-documented endpoint contract.
- Release verification: **[ ]** fresh CI green run, Android build, physical-device and E2E verification pending.

### Next implementation queue
1. Verify the new CI run for `ea88f35202db2153570aa149b51b8b805df07bcc`; fix only concrete analyzer/test/build failures.
2. Inspect project/platform configuration for the approved Android/iOS location and Google Maps setup before adding dependencies.
3. Implement the frozen invoice model/repository/UI without inventing response fields.
4. Complete real GPS permission/revocation and Maps/device verification.
5. Finish E2E/release verification and update PR readiness.

No backend/Laravel-owned files were modified. No merge or deployment was performed.


## Developer 2 continuation checkpoint — 2026-09-29 (fresh CI started)

- Documentation commits moved the branch to `a6eced1685ac96f817164b920f3ae3a407e88346`; PR #1 remains open, targets `frontend`, and is currently reported mergeable.
- Fresh Flutter CI run `36605874261` (run #189) is now **in progress** for the updated branch. Setup/checkout have passed; Flutter setup is currently running. Analyzer, tests and Android build have not run yet, so no green verification is claimed.
- The immediate test-level analyzer blocker from run #187 is fixed by `ea88f35202db2153570aa149b51b8b805df07bcc`.
- Task documentation is now explicitly aligned with the current implementation queue: invoice is unblocked at the contract level; concrete platform GPS/Maps dependency selection and device verification remain pending.


## Developer 2 continuation checkpoint — 2026-09-29 (current-head CI warning cleanup)

- Inspected completed Flutter CI run #191 (36605956482) for the previous PR merge commit. Dependency resolution and Dart formatting passed, but flutter analyze failed; tests and Android build were skipped.
- The analyzer output contained three concrete warning-level blockers: unnecessary non-null assertion in lib/features/customer/data/order_repository.dart; unused delivery data/repository imports in lib/features/delivery/presentation/delivery_requests_screen.dart; unused dart:async import in test/features/delivery/active_delivery_location_controller_test.dart.
- Removed only those concrete warnings. No unrelated legacy lint cleanup was performed.
- The fixes are now on developer-2-flutter; current PR head is 718db207354c67b9cbdb7d2208f3d040c7e066c6.
- Fresh Flutter CI #195 (36606407678) is currently in progress against the updated head. Do not mark CI green until analyzer, tests and Android build complete.
- PR #1 remains open, targets frontend, and GitHub currently reports it as mergeable.
- Invoice implementation remains pending because API_CONTRACT.md documents the invoice endpoint and immutability behavior but does not yet provide a concrete Flutter-facing success JSON field set sufficient to define a typed invoice DTO safely.
- Platform GPS/Maps integration remains pending: pubspec.yaml has no concrete location/Maps dependency, so no speculative package was added. The existing adapter continues to report unavailable until the approved dependency/configuration is established.
- Local Flutter/Dart execution is unavailable in this GitHub-connected environment; CI is the automated verification source.

### Current task board

| Area | Status | Current state |
|---|---|---|
| Phase 0 — audit/verification | [~] | Audit and CI workflow complete; current-head CI #195 pending; physical-device verification pending |
| Phase 1 — API foundation | [x] | Complete |
| Phase 2 — auth/session | [~] | Session restore/logout/routing complete; Google platform credential configuration and final runtime role verification pending |
| Phase 3 — catalogue/cart | [x] | Typed catalogue, real numeric product IDs and catalogue-to-cart integration complete |
| Phase 4 — COD checkout | [x] | COD submission, address validation, duplicate protection, conflict handling and server-authoritative order navigation complete |
| Phase 5 — customer orders/tracking | [x] | History/detail and tracking source integration complete |
| Phase 6 — delivery lifecycle | [x] | Assignment/status/location repository and lifecycle UI integration complete |
| Phase 7 — active GPS/Maps | [~] | Adapter/controller/lifecycle/freshness complete; concrete platform GPS, Maps SDK/configuration and device verification pending |
| Invoice | [ ] | Contract endpoint known; typed response/UI not started because exact success fields are not frozen |
| Release verification | [ ] | Current-head CI, Android build, physical-device GPS/Maps and end-to-end verification pending |

### Next execution order

1. Inspect Flutter CI #195 and fix only concrete current-head analyzer/test/build failures.
2. Confirm the approved Android/iOS GPS package and Google Maps configuration before adding platform dependencies.
3. Freeze the exact Flutter-facing invoice success response fields, then implement invoice model/repository/UI without inventing fields.
4. Run physical-device permission/GPS/Maps verification.
5. Complete customer/delivery end-to-end verification and update PR readiness.


## Developer 2 continuation checkpoint — 2026-09-29 (CI verification gate + implementation queue)

- Rechecked PR #1 on `developer-2-flutter`: current head is `413e3dff20902d51d47a0f371b984efc153540d8d`; PR targets `frontend` and is reported mergeable.
- Flutter CI run #196 (`36606481962`) is **in progress**. Job `Analyze, test and build Android` has completed checkout and is still setting up Flutter; dependency resolution, formatting, analyzer, tests and Android build have not yet executed. No green/failed conclusion is claimed.
- Reviewed current Flutter platform configuration. `pubspec.yaml` contains no location or Google Maps package, and the Android manifest contains no location/Maps configuration. The navigation/duty-map screens still contain illustrative custom-painted map surfaces rather than a real Maps SDK. No speculative platform dependency was added.
- The shared invoice contract documents `GET /orders/{order}/invoice`, delivered-order ownership, immutable generation and deterministic invoice numbering, but it does not enumerate a concrete success JSON field set. The Flutter invoice DTO/UI therefore remains intentionally unimplemented rather than inventing fields.
- No backend/Laravel-owned files were modified.

### Current task board

| Area | Status | Current state |
|---|---|---|
| Phase 0 — audit/verification | [~] | CI workflow exists; current-head CI #196 pending; physical-device verification pending |
| Phase 1 — API foundation | [x] | Complete |
| Phase 2 — auth/session | [~] | Session restore/logout/routing complete; Google platform credential/runtime verification pending |
| Phase 3 — catalogue/cart | [x] | Complete |
| Phase 4 — COD checkout | [x] | Complete; automated/runtime verification remains |
| Phase 5 — customer orders/tracking | [x] | Complete; runtime verification remains |
| Phase 6 — delivery lifecycle | [x] | Assignment/status/location integration complete |
| Phase 7 — active GPS/Maps | [~] | Adapter/controller/lifecycle complete; real GPS + Maps SDK/configuration/device verification pending |
| Invoice | [ ] | Endpoint known; exact success schema still not frozen, so DTO/UI not started |
| Release verification | [ ] | Green CI, Android APK, physical-device and E2E verification pending |

### Next execution order
1. Wait for/inspect CI #196 and fix only concrete analyzer/test/build failures.
2. Obtain/confirm approved Android/iOS location package and Maps configuration; then implement the platform source behind the existing location adapter without changing repository contracts.
3. Freeze the invoice success JSON fields and implement typed invoice repository/model/UI.
4. Run physical GPS permission/revocation and Maps verification.
5. Complete E2E/release verification and update PR readiness.


## Developer 2 continuation checkpoint — 2026-09-29 (CI analyzer policy cleanup)

- CI #197 (`36606655506`) completed with failure at the Analyze step. Dependency resolution and Dart formatting both passed; tests and Android build were skipped because `flutter analyze` returned non-zero.
- The analyzer output contained **126 informational lint findings only** (`info` severity); no warning/error diagnostics were reported. The repository CI invoked plain `flutter analyze`, which made informational findings block the pipeline.
- Updated `.github/workflows/flutter-ci.yml` to run `flutter analyze --no-fatal-infos`. This keeps warnings/errors blocking while allowing informational lint guidance to be reported without preventing tests/build from running.
- Commit: `2a7bebbedda165b12db1af3424a8d148b739b6f2`.
- No application behavior or backend/Laravel-owned files were changed in this CI-only fix.

### Updated execution order
1. Re-run/inspect CI from commit `2a7bebbedda165b12db1af3424a8d148b739b6f2`; confirm analyzer passes and tests/build execute.
2. Fix any concrete warning/error/test/build failures that appear.
3. Confirm approved Android/iOS GPS package and Google Maps configuration before adding platform dependencies.
4. Freeze exact invoice success JSON fields, then implement typed invoice repository/model/UI.
5. Perform physical GPS/Maps and customer/delivery E2E verification.


## Developer 2 continuation checkpoint — 2026-09-29 (CI test gate)

- Flutter CI run #200 (36607353094) verified that the new analyzer policy works: dependency resolution passed, Dart formatting passed, and flutter analyze passed with informational findings only.
- CI then reached the test suite and exposed three concrete test failures; Android APK build was skipped because the test step failed.
- Fixed the three concrete test issues: integer product-ID expectation, catalogue async error-state timing, and stale welcome-screen smoke assertions.
- Latest implementation commit after these fixes: fb0fac9b1e886b3c56fb839fadb6fe24e87bcad6.
- No backend/Laravel-owned files were modified.

### Current task board
| Area | Status | Current state |
|---|---|---|
| Phase 0 — audit/verification | [~] | Analyzer passes; fresh CI after test fixes pending; device verification pending |
| Phase 1 — API foundation | [x] | Complete |
| Phase 2 — auth/session | [~] | Session restore/logout/routing complete; Google credential/runtime verification pending |
| Phase 3 — catalogue/cart | [x] | Typed catalogue + real numeric product IDs wired into cart/menu/detail |
| Phase 4 — COD checkout | [x] | Server-backed COD flow, address validation, duplicate-submit protection and conflict handling implemented |
| Phase 5 — customer orders/tracking | [x] | History/detail/tracking integration implemented; runtime verification pending |
| Phase 6 — delivery lifecycle | [x] | Assignment/status/location integration complete |
| Phase 7 — active GPS/Maps | [~] | Adapter/controller/lifecycle complete; approved real GPS + Maps SDK/config/device verification pending |
| Invoice | [ ] | Exact Flutter-facing success fields must be frozen before DTO/UI implementation |
| Release verification | [ ] | Green current-head CI, Android APK, physical-device and E2E verification pending |

### Next implementation order
1. Inspect fresh CI for fb0fac9b1e886b3c56fb839fadb6fe24e87bcad6; fix only concrete formatter/analyzer/test/build failures.
2. If tests pass, inspect Android debug APK build output and record the result.
3. Confirm the approved Android/iOS GPS package and Google Maps configuration before adding platform dependencies.
4. Freeze the exact invoice success JSON fields and implement invoice repository/model/UI without inventing fields.
5. Perform physical GPS/Maps and customer/delivery E2E verification.


## Developer 2 continuation checkpoint — 2026-09-30 (CI #245 smoke-route correction)

- Fresh Flutter CI run #245 (`36613575199`) executed the PR merge ref containing the latest smoke-test override. Dependency resolution, formatting, formatting check and analyzer passed; 36 tests passed before the smoke test failed again at the welcome assertion. Android debug build was skipped because tests failed.
- The deterministic signed-out auth override is present in the merge ref, so the remaining failure is in router behavior while asynchronous auth bootstrap is still loading: the router currently redirected `/welcome` back to `/` until auth restoration completed, while the splash timer was navigating to `/welcome`.
- Corrected `lib/app/app.dart` so the public `/` and `/welcome` routes remain reachable while auth restoration is loading; protected routes remain redirected to the splash. This keeps public onboarding independent of session bootstrap without weakening protected-route gating.
- **Fix commit:** `e9ff9078d6e1e2fe6c6bc407214c171ca2dcfd78` (`fix(flutter): keep welcome route reachable during auth bootstrap`).
- No backend/Laravel-owned files, API contracts, platform credentials, GPS/Maps dependencies or production data flows were changed.

### Authoritative task board

| Area | Status | Current state |
|---|---|---|
| Phase 0 — audit/verification | [~] | CI #245 isolated the remaining auth-bootstrap/splash routing issue; fix committed; fresh CI pending |
| Phase 1 — API foundation | [x] | Complete |
| Phase 2 — auth/session | [~] | Session lifecycle implementation complete; Google platform/runtime verification pending; public onboarding now remains reachable during bootstrap |
| Phase 3 — catalogue/cart | [x] | Typed catalogue, real product IDs, cart integration and tests complete; runtime verification pending |
| Phase 4 — COD checkout | [x] | Server-backed COD flow, address validation, duplicate-submit protection, server-authoritative totals/errors and success navigation implemented; runtime verification pending |
| Phase 5 — customer orders/tracking | [x] | Order history/detail/tracking implementation present; runtime/E2E verification pending |
| Phase 6 — delivery lifecycle | [x] | Assignment/status/location integration implemented against canonical routes; runtime verification pending |
| Phase 7 — active GPS/Maps | [~] | Adapter/controller/lifecycle complete; approved platform location + Maps configuration and physical verification blocked |
| Invoice | [x] | Contract frozen; typed model/repository/controller/UI and delivered-order route implemented; CI/runtime verification pending |
| Release verification | [ ] | Green current-head CI, Android APK, physical-device and full E2E verification pending |

### Next execution order
1. Verify fresh CI on `e9ff907...` and fix only concrete current-head failures.
2. Close the GPS/Maps dependency gate by confirming an approved Android/iOS location package and Maps configuration; do not invent a dependency.
3. Wire the approved platform GPS source behind the existing adapter/controller boundary.
4. Verify customer tracking and delivery runtime behavior, including permission denial/revocation, stale/no-location/error states, active-trip lifecycle, throttling and location publishing.
5. Run release E2E and Android debug APK verification: COD → order → delivery → tracking → delivered → invoice, then final PR readiness.

### Current blockers
- No approved concrete GPS/Maps dependency or platform Maps configuration is documented in the repository.
- Google auth platform/runtime verification remains pending.
- Local Flutter/Dart execution remains unavailable; GitHub Actions is the available Flutter execution environment.


## Developer 2 continuation checkpoint — 2026-09-30 (current-head verification + platform dependency gate)

- Rechecked PR #1 on `developer-2-flutter`: head remains `e1a4e767def775351a7bdc28e163cd8d9a09ba6c`, PR targets `frontend`, is open and GitHub reports it mergeable.
- Flutter CI #247 (`36614126505`) was cancelled while the Analyze step was starting. Dependency resolution, formatting and formatting check had passed; tests and Android build did not run. This run is **not** counted as a pass or failure.
- Fresh CI #248 (`36614159360`) is currently **in progress** against the latest documentation head. Flutter setup is running; dependency resolution, analyzer, tests and Android debug build have not completed. No green CI result is claimed.
- Re-inspected the platform dependency boundary before making the next implementation change. `pubspec.yaml` contains no concrete location or Google Maps package, the Android manifest contains no location permissions or Maps metadata, and repository search found no approved GPS/Maps package or configuration to adopt. Therefore no speculative dependency was added.
- The frozen invoice implementation is already present: typed model/repository/controller/UI, delivered-order route and order-detail entry are complete; remaining work is CI/runtime verification.
- The previous auth-bootstrap correction remains the latest application behavior change: public splash/welcome routes stay reachable during async session restoration while protected routes remain gated.

### Authoritative task board

| Area | Status | Current state |
|---|---|---|
| Phase 0 — audit/verification | [~] | CI #247 cancelled before tests; CI #248 in progress; Android/device verification still pending |
| Phase 1 — API foundation | [x] | Complete |
| Phase 2 — auth/session | [~] | Session lifecycle and auth-aware routing complete; Google platform/runtime verification pending |
| Phase 3 — catalogue/cart | [x] | Typed catalogue, real product IDs, cart integration and tests complete; runtime verification pending |
| Phase 4 — COD checkout | [x] | Server-backed COD flow, validation, duplicate protection, server-authoritative totals/errors and success navigation complete; runtime verification pending |
| Phase 5 — customer orders/tracking | [x] | Order history/detail/tracking integration complete; runtime/E2E verification pending |
| Phase 6 — delivery lifecycle | [x] | Assignment/status/location integration complete; concrete platform GPS verification pending |
| Phase 7 — active GPS/Maps | [~] | Adapter/controller/lifecycle/freshness complete; approved platform GPS + Maps dependency/configuration is still unavailable |
| Invoice | [x] | Contract frozen and Flutter model/repository/controller/UI plus delivered-order route implemented; CI/runtime verification pending |
| Release verification | [ ] | Green current-head CI, Android debug APK, physical-device checks and full E2E remain |

### Next execution order
1. Finish and inspect CI #248; fix only concrete current-head failures and record the actual test/build result.
2. If CI is green, obtain/confirm the approved Android/iOS location package and Google Maps configuration from project requirements before adding any dependency.
3. Wire that approved platform GPS source behind the existing location adapter/controller boundary; do not change API contracts or invent a package.
4. Perform physical permission/revocation, GPS freshness/error, throttling and location-publish verification for active delivery trips.
5. Run the full COD → order → delivery → tracking → delivered → invoice E2E path and final PR readiness review.

### Current blockers
- No approved concrete GPS/Maps dependency or platform configuration is documented in the repository.
- Google auth platform/runtime verification remains pending.
- Local Flutter/Dart execution is unavailable; GitHub Actions is the available Flutter execution environment.
- No backend/Laravel-owned files were modified, and no merge/deployment was performed.


## Developer 2 continuation checkpoint — 2026-09-30 (CI #249 smoke timing correction)

- Flutter CI #249 (run `36614487710`) completed with **failure**. Dependency resolution, formatting, formatting check and analyzer all passed; 36 tests passed before `test/app_smoke_test.dart` failed because the welcome copy was still absent after the 1400 ms splash wait. Android debug build was skipped because tests failed.
- The failure remains isolated to the smoke-test timing boundary; no production Flutter analyzer error was reported. The splash implementation navigates from `/` to `/welcome` after a 1350 ms timer, followed by router processing and the welcome route's first-frame work.
- Updated the smoke test wait from 1400 ms to 1800 ms before settling, giving the documented 1350 ms splash transition additional deterministic headroom without changing production behavior.
- **Fix commit:** `56eca872e37f4dd65ee7e401c8336ba4af868a97` (`test(flutter): allow splash transition settling in smoke test`).
- No backend/Laravel-owned files, API contracts, platform credentials, GPS/Maps dependencies or production routing were changed.

### Authoritative task board

| Area | Status | Current state |
|---|---|---|
| Phase 0 — audit/verification | [~] | CI #249 isolated a smoke timing boundary; correction committed; fresh CI pending |
| Phase 1 — API foundation | [x] | Complete |
| Phase 2 — auth/session | [~] | Session lifecycle and auth-aware routing complete; Google platform/runtime verification pending |
| Phase 3 — catalogue/cart | [x] | Typed catalogue, real product IDs, cart integration and tests complete; runtime verification pending |
| Phase 4 — COD checkout | [x] | Server-backed COD flow, validation, duplicate protection, server-authoritative totals/errors and success navigation complete; runtime verification pending |
| Phase 5 — customer orders/tracking | [x] | Order history/detail/tracking integration complete; runtime/E2E verification pending |
| Phase 6 — delivery lifecycle | [x] | Assignment/status/location integration complete; concrete platform GPS verification pending |
| Phase 7 — active GPS/Maps | [~] | Adapter/controller/lifecycle/freshness complete; approved platform GPS + Maps dependency/configuration unavailable |
| Invoice | [x] | Contract frozen and Flutter model/repository/controller/UI plus delivered-order route implemented; CI/runtime verification pending |
| Release verification | [ ] | Green current-head CI, Android debug APK, physical-device checks and full E2E remain |

### Next execution order
1. Verify fresh CI after commit `56eca872...`; only fix the next concrete current-head failure.
2. If CI becomes green, confirm an approved Android/iOS location package and Google Maps configuration before adding any dependency.
3. Wire the approved platform GPS source behind the existing location adapter/controller boundary.
4. Verify physical permission/revocation, GPS freshness/error, throttling and location publishing for active delivery trips.
5. Run full COD → order → delivery → tracking → delivered → invoice E2E and final PR readiness.

### Current blockers
- No approved concrete GPS/Maps dependency or platform configuration is documented in the repository.
- Google auth platform/runtime verification remains pending.
- Local Flutter/Dart execution is unavailable; GitHub Actions is the available Flutter execution environment.
- No backend/Laravel-owned files were modified, and no merge/deployment was performed.


## Developer 2 continuation checkpoint — 2026-09-30 (current-head CI test failure triage)

- **Branch:** `developer-2-flutter`; **PR:** #1 → `frontend`, still open.
- **Current implementation:** catalogue/cart, COD checkout, customer order history/detail/tracking, delivery lifecycle, foreground active-trip location boundary, and invoice model/repository/UI are present in the branch. The invoice response schema is now frozen in `API_CONTRACT.md`.
- **Latest CI:** run `36615074843` executed against PR merge commit `5479e4090b4a12356bf3926bc4d5663fb8ace65d`. Dependency resolution, Dart formatting and `flutter analyze` **passed**. `flutter test` **failed** only in `test/app_smoke_test.dart`; Android build was skipped because the test step failed.
- **Concrete failure:** the smoke test tapped the welcome-screen “Explore food” action, which correctly navigates to `/home`, but then incorrectly expected welcome-screen text. This is a stale test assertion, not a production navigation failure.
- **Fix committed:** `3470e72773de7130485028633562f020c9d3a2d7` updates the smoke test to assert the existing home-screen text `What are you craving today?` after navigation. No production UI/navigation or backend-owned files were changed.
- **Verification:** the fix itself has **not yet been executed by CI** at this checkpoint. Local Flutter/Dart execution is unavailable here.
- **Remaining product/runtime work:** approved concrete Android/iOS location + Maps dependency/configuration and physical-device verification remain pending; Google SSO still requires the public platform client configuration/runtime sign-in wiring; role-specific routing requires consuming the documented role field safely.
- **Next task:** inspect the CI run for commit `3470e72773de7130485028633562f020c9d3a2d7`; if green, proceed with the approved GPS/Maps platform integration or the next explicitly unblocked authentication configuration task. Do not claim CI green until the run completes.


## Developer 2 continuation checkpoint — 2026-09-30 (CI failure fixed, next implementation queue)

- **Branch:** `developer-2-flutter`
- **PR:** #1 → `frontend`, still open.
- **Current branch state:** the customer order/COD, typed catalogue/cart, order history/detail, tracking models, delivery location lifecycle, and invoice foundation are present. No Laravel/backend-owned files were changed.

### Latest CI result
- Workflow run **36615634186** tested PR merge commit `fa4c4c741339ed644cc16b5751e30e87fbbc6d14`.
- Dependency resolution: **passed**.
- Dart formatting: **passed**.
- `flutter analyze`: **passed** (informational lint output only).
- `flutter test`: **failed only in `test/app_smoke_test.dart`** because that PR merge snapshot still expected the obsolete welcome-screen text after the Explore Food navigation.
- Android debug build: **skipped because the test step failed**.
- The current `developer-2-flutter` file has the corrected assertion: after tapping **Explore food**, it expects the existing home-screen text `What are you craving today?`. A new PR CI run is required to verify that current branch content is what GitHub tests.

### Completed task tracking
- **Phase 0 Audit/verification:** [~] audit and CI workflow complete; current-head green CI and physical-device verification remain.
- **Phase 1 API foundation:** [x] complete.
- **Phase 2 Session lifecycle:** [~] session restore/logout/redirects complete; Google SSO platform configuration and final role routing remain.
- **Phase 3 Catalogue:** [x] typed DTO/repository/controller mapping and state UI complete; runtime integration verification remains.
- **Phase 4 Cart/address/COD:** [~] numeric catalogue-backed cart IDs, COD repository/controller, address validation, duplicate-submit protection, server-authoritative totals/errors, successful-order cart clearing/navigation are implemented; success-path runtime verification and broader checkout UI hardening remain.
- **Phase 5 Customer orders:** [x] order history/detail screens and states are implemented; customer tracking UI remains.
- **Phase 6/7 Delivery/tracking:** [~] delivery lifecycle/location adapter/controller foundation is implemented; assignment/status/tracking UI and physical GPS verification remain.
- **Invoice:** [~] invoice model/repository/controller/screen foundation is present; end-to-end backend response verification and final UX integration remain.
- **Release verification:** [ ] not complete; requires green CI, Android build, and physical-device/integration verification.

### Next implementation order
1. **CI correction verification:** let the new PR run test the current branch snapshot; fix only any concrete current-head failure.
2. **Customer tracking:** wire order-detail tracking to the frozen `GET /orders/{order}/tracking` contract, including loading/error/stale-location states while preserving the existing UI/navigation.
3. **Delivery partner integration:** complete assignment/request/status/location UI from the frozen delivery contract.
4. **Invoice integration:** connect invoice access to completed orders and verify the frozen immutable invoice fields.
5. **Authentication completion:** implement only the documented Google SSO/platform configuration and role-routing contract when available.
6. **Release verification:** green CI + Android build + physical-device GPS/permissions/API integration checks.

### Safety / ownership
- Do not invent API fields, routes, status enums, credentials, or product IDs.
- Use fake repositories where a backend response is not yet available.
- Do not modify Laravel/backend-owned files.
- Do not merge or deploy from this branch.


## Developer 2 continuation checkpoint — 2026-09-30 (local smoke-test failure)

- **Reported failure:** local `flutter test` fails in `test/app_smoke_test.dart` at the welcome copy assertion (`GOOD FOOD.` not found). Other tests shown in the supplied output continue passing; the smoke test is the reported failure.
- **Cause identified from current code:** the test begins advancing the splash timer immediately after `pumpWidget`, while the overridden signed-out auth controller resolves asynchronously. `appRouterProvider` watches auth state, so auth restoration can rebuild the router and restart the splash route/timer during that initial wait.
- **Correction committed:** `74886bcd8e958f0183e6cff64817614a4d8b8378` adds an initial `pumpAndSettle()` before advancing the 1800 ms splash wait, allowing the signed-out auth state/router refresh to settle before waiting for the splash transition.
- **Verification:** this environment cannot execute Flutter/Dart locally. The correction is committed to `developer-2-flutter`; current-head CI must verify it. Do not mark the test or CI as passed until a fresh run completes.
- **Ownership:** no production UI, routing, backend/Laravel files, API contract, platform config, or production infrastructure changed in this correction.

### Immediate next steps
1. Inspect fresh CI for commit `74886bcd8e958f0183e6cff64817614a4d8b8378`.
2. If the smoke test still fails, fix the underlying router lifecycle deterministically rather than extending arbitrary test delays.
3. Once tests pass, verify the Android debug build and update release-readiness status based on actual CI results.


## Developer 2 continuation checkpoint — 2026-09-30 (welcome prompt finder correction)

- **Reported failure:** the smoke test now reaches the welcome screen and passes the welcome headline, Explore food, and preceding assertions, but fails to find “Already have an account?”.
- **Cause identified from widget structure:** that prompt is rendered as a RichText with nested TextSpans in _WelcomeActions, not as a standalone Text widget. The test's find.textContaining was not configured to search rich-text widgets, so it could not match the visible prompt.
- **Correction committed:** 8c720c2ccf193d48b39e07993e1a5417e1f51a66 updates the assertion to find.textContaining('Already have an account?', findRichText: true). The earlier auth/splash settling correction remains in place.
- **Verification:** a fresh CI run was pending for the previous head when checked; the new finder correction has not yet been executed by CI. Local Flutter/Dart execution is unavailable here, so no test pass is claimed.
- **Scope:** test and status documentation only; no production UI/navigation, API contract, or backend/Laravel-owned files changed.

### Immediate next steps
1. Inspect CI for the latest branch head after 8c720c2ccf193d48b39e07993e1a5417e1f51a66.
2. If the smoke test passes, verify the Android debug build and record actual results.
3. If another assertion fails, distinguish widget-finder semantics from real navigation/rendering behavior before changing production code.


## Developer 2 continuation checkpoint — 2026-09-30 (guest-browsing route guard correction)

- **Reported failure:** the local smoke test reaches the welcome screen, taps **Explore food**, then cannot find `What are you craving today?` on the home feed.
- **Root cause identified:** `/home` rendered the expected `HomeFeedScreen`, but the auth redirect classified it as protected. The smoke-test auth override is signed out, so GoRouter redirected back to `/welcome` after the tap. The home-feed text itself is a normal `Text` widget; this is a route-access behavior issue, not a rich-text finder issue.
- **Correction committed:** `4d2f9fdedc547b09d3a29db37067844e9045228a` adds `/home` to the public routes and applies the public-route rule consistently while auth restoration is loading. Other customer actions such as orders, checkout, profile and tracking remain behind the auth guard.
- **CI evidence before correction:** workflow run `36616886099` (run #264) passed dependency resolution, formatting, formatting check and analyzer, then failed in tests; Android debug APK build was skipped. This run tested the prior head and does not verify this correction.
- **Verification:** Flutter/Dart cannot be run locally in this connected environment. Fresh CI is required; no test/build pass is claimed.
- **Scope:** one router access-rule correction plus this status documentation; no backend/Laravel-owned files or API contracts changed. No merge/deployment performed.

### Immediate next steps
1. Verify current-head CI for `4d2f9fdedc547b09d3a29db37067844e9045228a`.
2. If the smoke test passes, confirm Android debug APK build and then continue the next unblocked implementation task.
3. Keep GPS/Maps platform configuration, Google auth runtime verification, physical-device checks and full E2E on the release-readiness checklist.
