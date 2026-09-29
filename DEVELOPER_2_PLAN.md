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

> **Status as of 2026-09-29:** Developer 2 is working only on `developer-2-flutter`. PR #1 targets `frontend` and remains open/mergeable. The latest implementation checkpoint is `7854e5a3ef6131e8bbb3f252d579ef21c7589b94`.
>
> **Verified complete in source control:** Phase 0 static Flutter audit, screen-to-contract mapping, platform/dependency inventory, API transport/client foundation, normalized API errors, environment API URL documentation, API-client fake-transport tests, the catalogue repository boundary with remote/fake implementations, the catalogue Riverpod controller/state layer with retry/error handling and tests, configured repository wiring, catalogue loading/empty/error/retry UI integration across existing customer catalogue screens, secure session storage, `/me` hydration, logout handling, auth-aware route redirects, and the local cart repository/controller boundary with explicit product IDs, quantity updates/removal and provider/repository tests.
>
> **Backend checkpoint refreshed:** backend workflow #209 passes, so delivery-partner provisioning/approval is CI-verified. This removes the earlier provisioning blocker, but Flutter delivery work still requires documented assignment/request/location/tracking response schemas. Backend order checkout/list/detail and server-owned status-transition work are verified on the backend, but the shared Flutter-facing order/COD/address examples are still absent from `API_CONTRACT.md`.
>
> **Remaining contract limitations:** Google auth exchange details, catalogue successful response fields, order create/list/detail response/request examples, and address request/response shape are not frozen. Developer 2 will not invent DTO fields, identifiers, statuses or payloads.
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
- [x] Ensure cart quantities reference product IDs; local subtotal is preview only. Cart lines now carry explicit productId values and controller mutations resolve quantities by that ID. Exact backend product-ID schema remains contract-gated.
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


## Developer 2 checkpoint — 2026-09-29 (cart boundary hardening)

- Fixed a source-level cart UI binding typo introduced during the cart-controller migration (vegetarian field).
- Strengthened cart provider test coverage using a managed Riverpod ProviderContainer; the test verifies the initial item count and preview subtotal exposed by the cart controller.
- Confirmed the cart quantity task is complete at the local repository/controller boundary: quantity mutations resolve by explicit product ID.
- No backend order/address payloads were added or inferred.
- Flutter/Dart formatting, analysis and test execution remain NOT RUN because no Flutter/Dart runner is available in the GitHub-connected environment.
- Next implementation remains contract-gated: typed order request/response models and COD submission after Developer 1 documents exact order/address schemas.


## Developer 2 checkpoint — 2026-09-29 (contract integration gate documented)

## Developer 2 checkpoint — 2026-09-29 (backend delivery gate refresh)

- Re-checked the backend execution plan after the latest Developer 1 update.
- Workflow #209 now passes, so delivery-partner provisioning/approval is CI-verified on the backend. This removes the previously recorded provisioning blocker, but it does not yet provide the Flutter delivery request/assignment/tracking response schemas required by the contract-first gate.
- The Flutter order/COD implementation remains blocked because `API_CONTRACT.md` still does not contain exact request/response examples for order creation, order list/detail, or address handling.
- Google SSO remains blocked on the exact `/auth/google` credential request/response and public client configuration. Catalogue typed mapping remains blocked on successful response field definitions.
- No backend-owned files were modified by Developer 2, and no undocumented API payloads were introduced.
- Flutter runtime verification remains **NOT RUN** because the GitHub-connected environment has no Dart/Flutter runner.

**Next implementation gate:** consume the frozen order/address contract as soon as Developer 1 publishes it, then implement typed order models and the cart → COD checkout → server totals → order detail/history flow. Delivery Flutter can follow the documented assignment/tracking contract now that backend provisioning is verified.

- Added `FLUTTER_CONTRACT_QUESTIONS.md` to make the remaining backend-to-Flutter integration requirements explicit without inventing API fields.
- The document covers order create/list/detail, address handling, Google auth exchange, catalogue success schemas, and delivery response/verification requirements.
- No API DTOs or network calls were added because `API_CONTRACT.md` still lacks the exact response/request examples needed for safe implementation.
- The local cart repository/controller boundary remains the latest completed customer-flow implementation.
- Flutter runtime verification remains NOT RUN because no Dart/Flutter runner is available in this environment.
- Next implementation gate: consume the frozen order/address contract and implement typed order models plus cart → COD checkout → server totals → order detail/history.


## Developer 2 checkpoint — 2026-09-29 (implementation continuation / status synchronization)

- Re-read the current Flutter plan, shared task board, API contract and Flutter contract questions before selecting the next code task.
- Verified current PR state: PR #1 remains open and mergeable, targeting `frontend`; branch head is `7854e5a3ef6131e8bbb3f252d579ef21c7589b94`.
- Verified backend delivery workflow #209 is now passing. Delivery-partner provisioning/approval is therefore no longer a backend CI blocker for this project.
- The next Flutter implementation is still contract-gated rather than code-gated: `API_CONTRACT.md` does not yet define the exact order create/list/detail request/response examples or address request/response shape required to safely build typed order DTOs and a real COD checkout repository/controller.
- Therefore no speculative order DTOs, status enums, address payloads, or checkout network calls were added in this continuation. The existing cart boundary remains the latest completed customer-flow implementation.
- Google SSO, typed catalogue mapping and delivery assignment/tracking integration remain blocked on their documented schemas/configuration.
- Flutter runtime verification remains **NOT RUN** because no Dart/Flutter runner is available; the current GitHub commit status also exposes no Flutter check results.
- **Next implementation gate:** once Developer 1 freezes order/COD + address examples, implement typed order models → checkout repository/controller → server-authoritative totals → order success/detail/history, preserving the existing UI and navigation. Then implement delivery request/assignment/tracking flows from the documented delivery contract.
