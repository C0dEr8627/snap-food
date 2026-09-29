# Developer 2 — Flutter, Customer/Delivery UX & Maps Execution Plan

> **Branch:** `developer-2-flutter`  
> **Base:** `frontend`  
> **Primary ownership:** existing Flutter app, API client, auth/session UX, customer workflows, delivery partner workflows, Maps and active-trip tracking UI.  
> **Read first:** `README.md`, `AI_RULES.md`, `PRODUCT.md`, `ARCHITECTURE.md`, `API_CONTRACT.md`, `AUTH.md`, `DELIVERY_TRACKING.md`, `DESIGN.md`, `DEVELOPMENT.md`, `AIDLC_WORKFLOW.md`.

## Mission

Evolve the existing Flutter application to consume the documented Laravel API while preserving the current visual design and navigation. Replace mock data behind repository boundaries instead of rewriting screens.

## Non-negotiable boundaries

- Flutter/Dart, Riverpod 3 and go_router as currently approved.
- Keep current feature-first structure and design unless a change is explicitly requested.
- Do not create a second backend, Firebase, Supabase, local server, or client-authoritative data store.
- No OTP, online payments, restaurant partner role, background GPS, geofencing or WebSocket dependency.
- Never embed Google OAuth client secrets, backend credentials or server-side Maps keys in the app.
- Never trust client-calculated totals or client-supplied roles/status.
- Use API contracts from `API_CONTRACT.md`. If something is unclear, document a question/assumption rather than silently inventing an incompatible payload.
- Keep all platform-specific code behind small adapters where practical.

## Current execution status

> **Status as of 2026-09-29:** Developer 2 is working only on `developer-2-flutter`. PR #1 targets `frontend` and remains open. The latest implementation checkpoint is `c0fbe23643507eba58534a05d821eec89495d102`.
>
> **Verified complete in source control:** Phase 0 static Flutter audit, screen-to-contract mapping, platform/dependency inventory, API transport/client foundation, normalized API errors, environment API URL documentation, API-client fake-transport tests, the first catalogue repository boundary with a remote implementation plus deterministic fake repository, the catalogue Riverpod controller/state layer with retry/error handling and controller tests, configured repository wiring, catalogue loading/empty/error/retry UI integration across the existing customer catalogue screens with widget coverage, and the initial auth/session foundation with secure token storage, `/me` hydration, logout handling and auth-aware route redirects.
>
> **Backend checkpoint refreshed:** the backend plan now records workflow #204 as passing for server-owned admin order status transitions and workflow #205 as failed for delivery-partner provisioning/approval; the backend plan records a conflict-rendering fix awaiting fresh CI verification. The initial checkout/list/detail slice is CI-green, but the Flutter-facing order/COD request/response examples are still not documented in `API_CONTRACT.md`. The shared board therefore still blocks Flutter from inventing payloads.
>
> **Catalogue contract limitation:** `API_CONTRACT.md` still documents catalogue endpoints without defining successful category/product response fields or a common success envelope. The repository therefore preserves JSON payloads without inventing field names. Typed DTO/UI mapping must wait for documented response fields or an explicitly approved backend response shape.
>
> **Auth contract limitation:** `API_CONTRACT.md` / `AUTH.md` still do not define the exact Google credential request field/type, successful application-token response shape, public Google client configuration, or sufficiently explicit role response shape. The Flutter auth foundation is ready, but the real provider/exchange must wait for that contract.
>
> **Flutter runtime verification remains unavailable because the GitHub-connected environment has no local Flutter/Dart runner:** `dart format`, `flutter pub get`, `flutter analyze`, `flutter test`, `flutter build apk --debug`, and physical-device checks. These remain **NOT RUN**, not passed.

## Phase 0 — Inspect current app

- [x] Inspect `pubspec.yaml`, routing, Riverpod providers, feature directories, existing mock repositories and all current screens (static source audit completed; runtime baseline remains separate).
- [!] Run formatter/analyzer/tests available in the environment; **NOT RUN** because the GitHub-connected development environment has no local Flutter/Dart runner and the branch currently has no Flutter CI workflow. This is a tooling blocker, not a passing baseline.
- [x] Map each current screen to its feature and intended API endpoint.
- [x] Identify existing navigation/design regressions from static inspection; do not expand scope into unrelated redesigns.
- [x] Record dependencies/platform configuration required for Google sign-in, secure storage, Maps and location.

## Phase 1 — API foundation

- [x] Add a single configured API client with environment-specific base URL.
- [x] Centralize JSON serialization, timeouts, auth headers, normalized API errors and safe logging (sensitive payloads are not logged).
- [x] Add repository interfaces/implementations using the current architecture. Catalogue repository boundary implemented.
- [x] Add loading, empty, error and retry states through the shared catalogue state widget.
- [x] Keep secrets out of source; document API URL and public-key configuration approach.
- [x] Use a fake transport for API client unit tests; feature repository fakes are present for catalogue.

## Phase 2 — Google SSO and session state

- [ ] Implement Google sign-in using platform-appropriate public client configuration. **Blocked on the missing public configuration and exact backend exchange contract.**
- [ ] Send credential to Laravel `POST /api/v1/auth/google` according to the contract. **Blocked; do not guess the field or credential type.**
- [x] Securely persist the application session/token using `flutter_secure_storage` behind `SessionStore`.
- [x] Hydrate current user through `GET /api/v1/me`; unauthorized restoration clears the stored token.
- [x] Implement logout/revocation via `POST /api/v1/auth/logout` and clear local session state.
- [x] Integrate Riverpod auth state with go_router redirects.
- [ ] Keep customer and approved delivery partner navigation separated; role-specific routing remains pending the documented user-role response shape and real SSO integration.
- [x] Add controller tests for startup restoration, expired session cleanup and logout.

**Milestone:** Google sign-in → Laravel auth → authenticated Flutter session.

## Phase 3 — Customer catalogue

- [ ] Define typed models for categories/products and API response/error envelopes. **Blocked on missing successful response schema in `API_CONTRACT.md`.**
- [ ] Replace hard-coded catalogue presentation behind existing UI. **Repository/controller/state integration is complete; field-level replacement is blocked on undocumented response fields.**
- [x] Connect home, search/filter, restaurant menu and product details to the catalogue controller state boundary.
- [x] Handle empty catalogue plus loading/error/retry states.
- [ ] Keep displayed price informational; checkout total comes from backend response.
- [x] Add repository fake coverage for catalogue fixtures.
- [x] Add catalogue controller and widget coverage for success/loading/empty/error/retry states.

**Milestone:** admin-created products appear in customer app when backend is integrated.

## Phase 4 — Cart, addresses and COD checkout

- [x] Review current cart implementation and preserve usable UI. The existing Stitch-aligned UI/navigation is preserved.
- [x] Introduce a local cart repository/controller boundary using explicit productId values and quantity updates. Cart prices/subtotals remain preview-only; no checkout payload is inferred.
- [ ] Ensure cart quantities reference product IDs; local subtotal is preview only. The current cart item identifier is the existing local product key; exact backend product-ID shape remains pending the shared order/catalogue contract.
- [ ] Implement address selection/entry based on agreed contract. **Blocked; no finalized address request/response shape is documented for Flutter.**
- [ ] Add COD checkout request and submit only product IDs, quantities and required address data. **Backend checkout/list/detail is now CI-green in workflow #186; Flutter implementation remains blocked until exact request/response examples are documented in the shared contract.**
- [ ] Display server-calculated totals and server validation errors. **Blocked until the order success/error envelope is documented for Flutter.**
- [ ] Prevent duplicate taps/submissions and show pending/success/failure states. **Can be implemented with the order controller once the request/response contract is frozen.**
- [ ] Route successful order to order detail/status screen. **Blocked until order response fields/identifier are documented.**
- [ ] Test empty cart, changed price, unavailable product, request timeout and duplicate submit. **Blocked for API-backed cases until typed order repository/controller exists.**

**Milestone:** customer places a real COD order once the verified backend contract examples are documented and Flutter integration is tested.

## Phase 5 — Customer orders/profile

- [ ] Connect order history/detail/status to API. **Blocked until documented list/detail response examples are added to `API_CONTRACT.md`.**
- [ ] Render backend status values through a centralized status-to-label/presentation mapping.
- [ ] Ensure users only see their own orders through backend authorization.
- [ ] Keep existing favorites/profile/settings navigation working; isolate any temporary local/mock behavior and document it.
- [ ] Add loading, empty, error and refresh states.

## Phase 6 — Delivery Partner app flows

- [ ] Build approved-partner entry/session state using the same backend identity contract.
- [ ] Connect availability, delivery request list, accept, pickup and completion.
- [ ] Display current assignment and prevent duplicate actions while requests are in flight.
- [ ] Implement pickup/customer navigation using Google Maps SDK or approved external navigation approach.
- [ ] Handle denied permissions, unavailable GPS, stale locations, no network and completed trips.
- [ ] Do not expose admin or customer-only screens through delivery navigation.

## Phase 7 — Maps and active-trip tracking

- [ ] Configure Google Maps per platform with restricted client keys.
- [ ] Request location permission only when needed and explain why it is required.
- [ ] Create a location adapter that emits current position during an active trip only.
- [ ] Throttle updates; start near the documented 5–10 second interval and tune on physical devices.
- [ ] Send updates to the documented location endpoint only for the active assignment.
- [ ] Poll customer tracking endpoint only while tracking screen is active; cancel polling on exit/completion.
- [ ] Render partner marker, destination, status and freshness indicator.
- [ ] Distinguish fresh/stale/no-location/loading/error states.
- [ ] Test denied/revoked permission, app screen exit, network loss, stale GPS and completed delivery.
- [ ] No continuous background location, geofencing or WebSockets.

## Phase 8 — Quality and release

- [ ] Run formatter, analyzer, unit/widget tests and Android build when tooling is available.
- [ ] Test on a physical Android device; record device/OS and actual outcomes.
- [ ] Check navigation/back behavior, session expiry, accessibility basics and small-screen layout.
- [ ] Verify no secrets are committed and platform permissions match actual use.
- [ ] Provide backend integration steps and list endpoints that still need backend completion.
- [ ] Produce a PR summary with changed files, commands/tests and known limitations.

## Developer 2 definition of done

A task is complete only when it has predictable loading/error/empty behavior, no unauthorized assumptions, tests where practical, docs for configuration and no unrelated visual changes. Never claim an unrun build/test passed.

## Developer 2 checkpoint — 2026-09-29 (contract gate review)

- Re-read the current shared API contract and backend execution plan before selecting the next implementation.
- Verified that backend order checkout/list/detail is CI-green and that server-owned admin status transitions are CI-verified by workflow #204.
- Verified that workflow #205 (delivery-partner provisioning/approval) is still pending, so delivery Flutter work is not yet unblocked.
- Confirmed that `API_CONTRACT.md` still contains endpoint names and high-level checkout guidance, but not the exact Google auth payload, catalogue success fields, order create/list/detail response examples, address payload, or order identifier/status representation needed for safe typed Flutter integration.
- No new API implementation was added in this checkpoint because doing so would require inventing undocumented payload fields, violating the project contract-first rule.
- Existing cart/checkout/order-tracking screens remain UI prototypes; they are not being falsely marked as API-integrated.
- Runtime verification remains **NOT RUN** because no Flutter/Dart toolchain is available in the GitHub-connected environment.

**Current next implementation gate:** Developer 1 must publish the exact Flutter-facing order/COD and address examples (and finish the pending delivery-partner provisioning CI verification). Once the order contract is frozen, Developer 2 will implement the cart repository/controller → COD checkout request → server-calculated response → order detail/history flow without changing the existing UI.

## End-of-task report format

- Completed tasks:
- Screens/features connected:
- Files/dependencies changed:
- API contract assumptions/questions:
- Tests/build commands run and actual result:
- Platform/device checks:
- Remaining blockers:
- Next task:


## Developer 2 checkpoint — 2026-09-29 (cart boundary implementation)

- Implemented the next unblocked Phase 4 subtask without touching the backend contract: the existing cart is now backed by a CartRepository/CartController boundary.
- Cart lines now carry an explicit productId; quantity changes are performed through the controller instead of widget-local mutable item state.
- The current preview subtotal/delivery/tax display remains clearly client-side and non-authoritative. No COD request or server total was invented.
- Existing cart visual layout, route and navigation were preserved.
- Added repository tests for product IDs, quantity updates and removal at zero quantity.
- Flutter runtime verification is still NOT RUN: no local Dart/Flutter runner is available in this GitHub-connected environment.
- API integration remains blocked on the exact order/address request/response examples in API_CONTRACT.md.
- Delivery Flutter remains blocked on the pending backend delivery-partner provisioning/approval CI verification.

Next implementation gate: freeze the documented order/COD + address contract, then add typed order request/response models and repository/controller submission flow. Do not change the existing checkout UI until the server response shape is explicit.
