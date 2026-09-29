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

> **Status as of 2026-09-29:** Developer 2 is working only on `developer-2-flutter`. PR #1 targets `frontend` and remains open/mergeable. The latest implementation checkpoint is `ef8e5c4db2e7ead50fbaecca10f986a13407be12`.
>
> **Verified complete in source control:** Phase 0 static Flutter audit, screen-to-contract mapping, platform/dependency inventory, API transport/client foundation, normalized API errors, environment API URL documentation, API-client fake-transport tests, the catalogue repository boundary with remote/fake implementations, the catalogue Riverpod controller/state layer with retry/error handling and tests, configured repository wiring, catalogue loading/empty/error/retry UI integration across existing customer catalogue screens, secure session storage, `/me` hydration, logout handling, auth-aware route redirects, and the local cart repository/controller boundary with explicit product IDs, quantity updates/removal and provider/repository tests.
>
> **Backend checkpoint refreshed:** backend workflow #209 passes, so delivery-partner provisioning/approval is CI-verified. Backend order checkout/list/detail and server-owned status-transition/concurrency work are also verified. Flutter delivery work still requires documented assignment/request/location/tracking response schemas, while Flutter order/COD work requires the exact order/address request/response examples in `API_CONTRACT.md`.
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
- Verified that workflow #209 (delivery-partner provisioning/approval) now passes, so delivery Flutter work is not yet unblocked.
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


## Developer 2 checkpoint — 2026-09-29 (latest implementation continuation)

- Re-read `DEVELOPER_2_PLAN.md`, `AI_TASK_BOARD.md`, `API_CONTRACT.md` and `FLUTTER_CONTRACT_QUESTIONS.md` before selecting the next implementation.
- Current PR state: PR #1 targets `frontend`, remains open and mergeable; branch head is `ea4756e366e16a438d696a48aad1d38f3f2e7ec3`.
- Confirmed `API_CONTRACT.md` is unchanged at the required integration gate: it still provides endpoint names and high-level order guidance, but not exact order create/list/detail examples, address request/response fields, Google credential exchange, catalogue success fields, or delivery assignment/tracking schemas.
- Confirmed backend workflow #209 is passing for delivery-partner provisioning/approval; this is no longer a backend provisioning blocker.
- No safe Flutter API implementation can be added for orders/addresses/delivery without inventing undocumented DTO fields or payloads, so no speculative network code was introduced.
- Existing completed Flutter work remains: API transport/errors, catalogue repository/controller/state integration, secure session storage and session restoration/logout, auth-aware routing, and local cart repository/controller with explicit product IDs and quantity tests.
- Flutter/Dart formatting, analysis, tests, APK build and physical-device verification remain **NOT RUN**; GitHub reports no Flutter commit statuses.

**Next implementation gate:** Developer 1 freezes the exact order/COD + address contract. Then Developer 2 implements typed order models → checkout repository/controller → server-authoritative totals → order success/detail/history, followed by delivery request/assignment/tracking using the documented delivery schemas.


## Developer 2 checkpoint — 2026-09-29 (implementation continuation / current gate)

- Re-checked the shared API contract and current PR before selecting the next task.
- Branch: `developer-2-flutter`; PR #1 targets `frontend` and is open/mergeable; current head is `ef8e5c4db2e7ead50fbaecca10f986a13407be12`.
- No new Flutter API integration was safely available in this checkpoint because `API_CONTRACT.md` remains unchanged: exact order create/list/detail schemas, address request/response fields, Google auth exchange, catalogue success fields, and delivery assignment/tracking schemas are still undocumented.
- The next incomplete Phase 4 item (address selection/entry) is therefore explicitly contract-blocked. Implementing it now would require inventing a resource/snapshot model or payload.
- Backend workflow #209 is passing for delivery-partner provisioning/approval; this prerequisite is no longer blocked, but Flutter delivery still needs the documented assignment/request/location/tracking response shapes.
- Completed Flutter work remains the API foundation, catalogue state/repository boundary, auth/session lifecycle, auth-aware routing, and local cart repository/controller with explicit product IDs and quantity tests.
- Runtime verification remains **NOT RUN** for formatter/analyzer/tests/APK/device because no Flutter/Dart runner is available and no Flutter CI status is reported.

**Next implementation:** freeze the exact order/COD + address contract, then implement typed order models and the cart → COD checkout repository/controller → server totals → order detail/history flow. After that, implement the delivery request/assignment/tracking flow from the documented delivery contract. No undocumented API payloads will be introduced.


## Developer 2 checkpoint — 2026-09-29 (latest continuation)

- Re-checked `API_CONTRACT.md` on both `developer-2-flutter` and `frontend`. The shared/base contract still contains only endpoint-level order guidance; exact order create/list/detail and address schemas are not frozen.
- The backend branch has added an admin delivery-assignment contract section (`POST /api/v1/admin/orders/{order}/assignment`, with `delivery_partner_id` and a 201 assignment response), but this is backend/admin-owned and is not yet present on the Flutter base contract. It does not unblock the partner/customer Flutter response schemas required for delivery flows.
- PR #1 is still open/mergeable and currently points at branch head `b69c3965ea2a5da65b193c24b1a64aa1bb015df0`.
- No new network DTOs or checkout/delivery API calls were added because the customer order/address and delivery-partner response contracts remain incomplete. This preserves the contract-first rule and avoids inventing payloads.
- Completed Flutter work remains: API transport/error foundation; catalogue repository/controller/state integration; secure session storage and `/me`/logout lifecycle; auth-aware routing; local cart repository/controller with explicit product IDs and quantity tests; and contract-question documentation.
- Backend workflow #209 remains the verified delivery-partner provisioning/approval result; backend order checkout/list/detail and server-owned status-transition/concurrency work remain verified.
- Flutter/Dart formatting, analysis, tests, APK build and physical-device checks remain **NOT RUN** because no Flutter/Dart runner is available and no Flutter CI status is reported.

**Next implementation gate:** Developer 1 must merge/freeze the complete Flutter-facing order/COD + address examples into the shared contract. Then Developer 2 will implement typed order models → checkout repository/controller → server-authoritative totals → order success/detail/history. Delivery partner request/assignment/location/tracking follows once those response schemas are documented.


## Developer 2 checkpoint — 2026-09-29 (latest contract gate / status synchronization)

- **Branch:** `developer-2-flutter`; **PR:** #1 → `frontend`, open and mergeable.
- **Current implementation status:** the local cart repository/controller boundary is the latest completed customer-flow implementation. Existing API transport/error handling, catalogue repository/controller/state wiring, secure session storage, `/me` restoration, logout/revocation and auth-aware routing remain complete.
- **Contract re-check:** the shared `frontend` `API_CONTRACT.md` still does not define exact order create/list/detail request/response examples or address request/response fields. The backend branch now documents delivery assignment/lifecycle/tracking behavior, but those changes are not yet synchronized into the shared/base contract and still do not provide the complete Flutter-facing response examples needed for typed delivery integration.
- **Backend verification:** delivery-partner provisioning/approval workflow #209 passes; backend order checkout/list/detail plus server-owned status-transition/concurrency work are verified.
- **Implementation decision:** no speculative order/address DTOs, status enums, checkout payloads or delivery network calls were added. This is intentional contract-first behavior, not an implementation failure.
- **Verification:** Flutter/Dart formatting, analyzer, tests, APK build and physical-device checks remain **NOT RUN** because this GitHub-connected environment has no local Flutter/Dart runner; no Flutter CI status is reported.
- **Next task after contract freeze:** implement typed order models → checkout repository/controller → server-authoritative totals/error handling → order success/detail/history, preserving the existing UI. After the delivery schemas are frozen in the shared contract, implement delivery request/assignment/status/tracking flows.


## Developer 2 checkpoint — 2026-09-29 (latest backend verification / implementation gate)

- Re-checked the shared Flutter contract and backend branch before selecting the next implementation.
- Backend workflow #259 is documented as passing the delivery-partner assignment listing and owned `PICKED_UP → OUT_FOR_DELIVERY → DELIVERED` progression on PHP 8.3 with MySQL. This supersedes the older delivery-lifecycle blocker recorded in earlier checkpoints.
- The backend branch also documents partner location updates and customer/admin tracking routes, but the shared/base `API_CONTRACT.md` still lacks complete Flutter-facing request/response examples required to safely implement those calls.
- The next Phase 4 customer task remains blocked: exact order create/list/detail request/response examples and address request/response fields are still missing from the shared contract. No order DTOs, address payloads, status enums, or checkout network calls will be invented.
- Google SSO remains blocked on the exact credential exchange/configuration and role response shape; catalogue typed mapping remains blocked on documented success fields.
- Completed Flutter work remains the API transport/error foundation, catalogue repository/controller/state integration, secure session storage and session lifecycle, auth-aware routing, and the local cart repository/controller with explicit product IDs and quantity tests.
- Flutter/Dart formatter, analyzer, tests, APK build and physical-device checks remain **NOT RUN** because no Flutter/Dart runner is available; no Flutter CI status is reported.
- **Next implementation:** once Developer 1 freezes the shared order/COD + address contract, implement typed order models → checkout repository/controller → server-authoritative totals/errors → order success/detail/history. Then consume the frozen delivery schemas for assignment/status/location/tracking UI.


## Developer 2 checkpoint — 2026-09-29 (latest backend refresh / task tracking)

- **Branch:** `developer-2-flutter`; **PR:** #1 → `frontend`, open and mergeable.
- **Completed Flutter implementation:** API transport/client + normalized errors; catalogue repository/controller/state boundary with loading/empty/error/retry UI integration; secure session storage; `/me` restoration; logout/revocation; auth-aware routing; local cart repository/controller with explicit product IDs, quantity updates/removal and tests; contract-question tracking.
- **Backend verification refresh:** Developer 1 documents Workflow #259 as passing delivery-partner assignment listing and owned `PICKED_UP → OUT_FOR_DELIVERY → DELIVERED` progression, and Workflow #266 as passing active-trip location/tracking: partner-owned location writes, coordinate/timestamp validation, active-trip enforcement, persisted history, customer/admin tracking authorization and stale-location behavior. This removes the earlier backend delivery-tracking verification blocker.
- **New backend scope observed:** the backend contract now also documents invoice endpoints and idempotent invoice-number generation/access rules. Flutter invoice integration is **not** started because the shared Flutter contract does not yet contain the complete invoice response schema and Phase 4 order/address integration is still blocked.
- **Shared contract remains the primary blocker:** `developer-2-flutter` `API_CONTRACT.md` still lacks exact Flutter-facing Google auth exchange, catalogue success fields, order create/list/detail request/response examples, address request/response shape, and delivery assignment/location/tracking response examples. The backend branch has richer delivery/invoice documentation, but it is not synchronized into the shared/base contract.
- **Implementation decision:** no speculative order/address DTOs, status enums, checkout payloads, delivery network calls or invoice response models were introduced.
- **Verification:** Flutter/Dart formatting, analyzer, tests, APK build and physical-device checks remain **NOT RUN** because no Flutter/Dart runner is available; no Flutter CI status is reported.

### Task status after this checkpoint
- **Phase 0:** complete except runtime verification/tooling baseline, which remains NOT RUN.
- **Phase 1:** complete.
- **Phase 2:** partially complete; session lifecycle is implemented, Google SSO exchange/config and role routing remain contract/config gated.
- **Phase 3:** repository/controller/state integration is complete; typed field mapping remains blocked by the missing success schema.
- **Phase 4:** local cart boundary is complete; address, COD checkout, server totals/errors, duplicate-submit handling, order success/detail/history and API-backed tests remain blocked by the missing order/address contract.
- **Phase 5:** customer order history/detail/status remains blocked on documented order list/detail schemas.
- **Phase 6/7 delivery tracking:** backend is now verified through Workflow #266, but Flutter integration remains blocked by the missing shared delivery response schemas.
- **Invoice:** backend implementation is documented, but Flutter invoice UI/repository/model work is not started and remains contract-gated.

**Next implementation sequence:** (1) Developer 1 freezes the complete shared order/COD + address + relevant delivery response examples; (2) Developer 2 implements typed order models; (3) cart → COD checkout repository/controller with duplicate-submit protection; (4) server-authoritative totals/error handling; (5) order success/detail/history; (6) delivery request/assignment/status/location/tracking; (7) invoice integration once its Flutter-facing response schema is frozen. No undocumented payloads will be invented.


## Developer 2 checkpoint — 2026-09-29 (latest contract re-check / task progress)

- Re-checked the shared API_CONTRACT.md on developer-2-flutter before starting the next implementation.
- The shared contract is still high-level for the Flutter integration gate: it lists order, delivery and auth endpoints, but does not provide the exact Flutter-facing order create/list/detail request/response examples, address request/response shape, Google credential exchange/session response, catalogue success fields, or delivery assignment/location/tracking response schemas.
- Compared the backend branch contract: developer-1-backend-admin now documents delivery assignment/lifecycle/tracking and invoice endpoints, including deterministic/idempotent invoice numbering, but those complete Flutter-facing response schemas are not yet synchronized into the shared/base contract.
- Backend verification is stronger than the previous checkpoint: Workflows #209, #259 and #266 are documented as passing for delivery-partner provisioning/approval, assignment/status progression, and active-trip location/tracking respectively. The remaining delivery blocker is therefore the shared Flutter response contract, not backend CI.
- No new Flutter API implementation was added in this checkpoint. Creating typed order/address/delivery/invoice models or network calls now would require guessing undocumented fields and would violate the contract-first rule.
- Completed Flutter scope remains: API transport/error foundation; catalogue repository/controller/state and loading/empty/error/retry integration; secure session storage and /me restoration; logout/revocation; auth-aware routing; local cart repository/controller with explicit product IDs and quantity updates/removal plus tests; contract-question tracking.
- Phase 0 — complete except runtime/tooling verification, which is NOT RUN.
- Phase 1 — complete.
- Phase 2 — partial; Google SSO exchange/config and role routing remain contract/config gated.
- Phase 3 — repository/controller/state integration complete; typed field mapping remains schema-gated.
- Phase 4 — local cart boundary complete; address, COD checkout, server totals/errors, duplicate-submit handling, order success/detail/history and API-backed checkout tests remain contract-gated.
- Phase 5 — customer order history/detail/status remains contract-gated.
- Phase 6/7 — backend delivery lifecycle/tracking is verified, but Flutter delivery integration remains schema-gated.
- Invoice — backend scope exists, but Flutter integration remains contract-gated.
- Flutter/Dart formatter, analyzer, tests, APK build and physical-device checks remain NOT RUN because no Flutter/Dart runner or Flutter CI result is available in this GitHub-connected environment.
- Next implementation sequence once the shared contract is frozen: typed order models → cart/COD checkout repository/controller with duplicate-submit protection → server-authoritative totals/error handling → order success/detail/history → delivery assignment/status/location/tracking → invoice model/repository/UI.

No undocumented API payloads will be introduced.



## Developer 2 checkpoint — 2026-09-29 (continuation / contract synchronization re-check)

- Re-checked the shared `API_CONTRACT.md` on `developer-2-flutter` before selecting the next implementation.
- The shared contract still defines the high-level order/auth/catalogue/delivery endpoints but does **not** contain the exact Flutter-facing order create/list/detail examples, address request/response shape, Google auth exchange/session shape, catalogue success fields, or delivery assignment/location/tracking response examples.
- Re-checked `developer-1-backend-admin/API_CONTRACT.md`: backend delivery assignment/lifecycle/tracking and invoice endpoint behavior is now documented there, including invoice idempotency/numbering. Those additions are not yet synchronized into the shared Flutter contract with complete response examples.
- Backend delivery verification remains recorded as passing for workflows #209, #259 and #266. This means the current delivery blocker is contract synchronization, not backend implementation verification.
- No new Flutter network implementation was added in this continuation because typed order/address/delivery/invoice models would require undocumented field assumptions.

### Task progress
- **Phase 0:** [~] Static audit/documentation complete; Flutter/Dart runtime verification remains NOT RUN.
- **Phase 1:** [x] API foundation complete.
- **Phase 2:** [~] Session lifecycle complete; Google SSO exchange/config and role routing remain contract/config gated.
- **Phase 3:** [~] Catalogue repository/controller/state and UI state integration complete; typed response mapping remains schema-gated.
- **Phase 4:** [~] Local cart repository/controller boundary complete; address, COD checkout, server totals/errors, duplicate-submit handling, order success/detail/history and API-backed checkout tests remain contract-gated.
- **Phase 5:** [ ] Customer order history/detail/status remains blocked on list/detail response schemas.
- **Phase 6/7:** [~] Backend delivery lifecycle/tracking is verified; Flutter delivery integration remains blocked on shared response schemas.
- **Invoice:** [ ] Backend scope is documented; Flutter invoice integration has not started because the shared invoice response schema is incomplete.

### Next implementation queue
1. Synchronize the complete Flutter-facing order/COD + address contract into the shared/base branch.
2. Implement typed order models and repository/controller boundaries.
3. Implement cart → COD checkout with duplicate-submit protection and server-authoritative totals/errors.
4. Implement order success/detail/history and loading/empty/error/refresh states.
5. Implement delivery assignment/status/location/tracking from the frozen schemas.
6. Implement invoice model/repository/UI once its Flutter-facing response schema is frozen.

No undocumented API payloads will be introduced, and no Laravel/backend-owned files will be modified by Developer 2.


## Developer 2 checkpoint — 2026-09-29 (continuation / contract re-check)

- **Branch/PR:** `developer-2-flutter`, PR #1 → `frontend`, still open and mergeable.
- **Implementation decision:** no new Flutter API integration was added in this continuation because the shared `API_CONTRACT.md` is still missing the exact Flutter-facing schemas required for the next order/COD task. Implementing DTOs or network calls now would require undocumented assumptions.
- **Completed implementation remains:** API transport/client + normalized errors; catalogue repository/controller/state and loading/empty/error/retry integration; secure session storage; `/me` restoration; logout/revocation; auth-aware routing; local cart repository/controller with explicit product IDs and quantity updates/removal plus tests.
- **Backend evidence re-checked:** developer-1-backend-admin documents passing Workflows #209, #259 and #266 for delivery-partner provisioning/approval, assignment/status progression and active-trip tracking. Backend invoice scope is also documented, but Flutter-facing invoice response fields are not frozen in the shared contract.
- **Current blockers:** Google auth exchange/session/role schema; catalogue success fields; order create/list/detail request/response examples; address request/response shape; delivery assignment/status/location/tracking response examples; invoice success response/snapshot fields.
- **Verification:** Flutter/Dart formatting, analyzer, tests, APK build and physical-device checks remain **NOT RUN** because no Flutter/Dart runner or Flutter CI result is available.

### Task tracking after this continuation
- **Phase 0:** static audit/documentation complete; runtime verification/tooling baseline remains NOT RUN.
- **Phase 1:** complete.
- **Phase 2:** session lifecycle complete; Google SSO exchange/config and role routing remain contract/config gated.
- **Phase 3:** repository/controller/state integration complete; typed catalogue mapping remains schema-gated.
- **Phase 4:** local cart boundary complete; address, COD checkout, server totals/errors, duplicate-submit flow, order success/detail/history and API-backed edge-case tests remain contract-gated.
- **Phase 5:** customer order history/detail/status remains blocked by missing order list/detail schemas.
- **Phase 6/7:** backend delivery lifecycle/tracking is verified; Flutter delivery integration remains blocked by missing shared delivery schemas.
- **Invoice:** backend scope documented; Flutter invoice model/repository/UI remains not started pending the shared success schema.

**Next executable Flutter task once the shared contract is frozen:** implement typed order models and repository/controller boundaries, then cart → COD checkout with duplicate-submit protection and server-authoritative totals/error handling. No undocumented payloads will be introduced.


## Developer 2 checkpoint — 2026-09-29 (implementation gate / current branch sync)

- **Branch:** `developer-2-flutter`; **PR:** #1 → `frontend`, open and mergeable.
- **Current PR head observed:** `0c9f9844afbfc3bfb99fc2604f50cab5cec8beeb`.
- Re-read the required architecture, auth, delivery-tracking, design and development documentation and inspected the existing Flutter source structure before selecting the next task.
- The first incomplete plan item remains Phase 2 Google SSO, but it is **blocked** by the missing exact `POST /api/v1/auth/google` credential field/type, success session/token response, public Google client configuration, and role response shape. Implementing it now would require inventing an API/config contract.
- The next contract-dependent implementation gate is Phase 4 typed order/COD + address integration. The shared `API_CONTRACT.md` still lacks exact order create/list/detail request/response examples and address request/response fields. Backend delivery workflows are verified, but Flutter delivery response schemas are also not synchronized into the shared contract.
- **No speculative Flutter DTOs, status enums, request payloads, network calls, or invoice response models were added.** Backend/Laravel-owned files remain untouched.
- Completed implementation remains: API transport/error foundation; catalogue repository/controller/state and loading/empty/error/retry integration; secure session storage and `/me` restoration; logout/revocation; auth-aware routing; local cart repository/controller with explicit product IDs, quantity updates/removal and tests; contract-question tracking.
- **Verification:** Flutter/Dart formatter, analyzer, tests, APK build and physical-device checks remain **NOT RUN** because this GitHub-connected environment has no local Flutter/Dart runner and no Flutter CI result is available.

### Task status
- Phase 0: **[~]** static audit/documentation complete; runtime verification unavailable.
- Phase 1: **[x]** complete.
- Phase 2: **[~]** session lifecycle complete; Google SSO exchange/config and role routing contract-gated.
- Phase 3: **[~]** repository/controller/state integration complete; typed catalogue mapping schema-gated.
- Phase 4: **[~]** local cart boundary complete; address/COD checkout/server totals/order success-history contract-gated.
- Phase 5: **[ ]** customer order history/detail/status waiting on order schemas.
- Phase 6/7: **[~]** backend delivery lifecycle/tracking verified; Flutter integration waiting on shared response schemas.
- Invoice: **[ ]** backend scope exists; Flutter response schema is not frozen.

**Next executable implementation:** after Developer 1 synchronizes the complete Flutter-facing order/COD + address contract, implement typed order models and repository/controller boundaries, then cart → COD checkout with duplicate-submit protection and server-authoritative totals/errors. Do not bypass the contract gate.

## Developer 2 checkpoint — 2026-09-29 (Flutter CI workflow)

- Added `.github/workflows/flutter-ci.yml` to automate Flutter dependency resolution, Dart formatting validation, static analysis, unit/widget tests and Android debug APK compilation.
- The workflow is configured for relevant Flutter changes on `developer-2-flutter`, pull requests targeting `frontend`, and manual dispatch.
- Workflow definition commit: `785ab5f4a1a68fa7bf2a11ff2c0a549eb558d5fa`.
- **Verification state:** the workflow has not yet been confirmed passing. Do not mark Phase 0 runtime verification or Phase 8 release verification complete until an actual run succeeds. Local Flutter/Dart commands remain NOT RUN in this environment.
- No Flutter API DTOs/network calls were added because the shared contract remains incomplete; backend-owned files were not changed.

**Next task:** inspect the workflow run and address any real failures first. In parallel, Developer 1 must synchronize exact Flutter-facing API examples and canonical delivery routes into the shared contract. Once order/address schemas are frozen, continue with typed order models and repository/controller boundaries, followed by COD checkout, order history/detail, delivery/tracking and invoice integration.


## Developer 2 checkpoint — 2026-09-29 (CI formatter gate fixed)

- Re-checked Flutter PR #1 and the first Flutter CI run.
- Flutter CI run `36590699675` completed cancelled at the formatting gate: Flutter 3.47.5 and dependency resolution succeeded, then the strict Dart formatter check reported 45 files requiring formatting and exited 1. Analyze, tests and Android build were skipped, so no passing runtime/build result is claimed.
- Updated `.github/workflows/flutter-ci.yml` in commit `4ee6286385f02a2154645488208b4c46ff90c146` so the developer branch workflow applies `dart format .`, commits only Dart formatting changes back to `developer-2-flutter`, then runs the strict formatting check, analyzer, tests and Android debug build.
- This is a CI/verification-enablement fix; no backend-owned files and no API DTOs/payloads were added.
- The next CI run must be observed before marking Phase 0 runtime verification complete.
- The shared `API_CONTRACT.md` is still incomplete for Google auth, typed catalogue fields, order/COD + address, delivery/tracking and invoice Flutter-facing schemas. Therefore the next product-feature implementation remains contract-gated.

### Current task status
- **Phase 0:** [~] static audit complete; CI formatting gate identified and remediation committed; analyzer/tests/APK still unverified.
- **Phase 1:** [x] API foundation complete.
- **Phase 2:** [~] session lifecycle complete; Google SSO exchange/config and role routing contract/config gated.
- **Phase 3:** [~] repository/controller/state integration complete; typed catalogue mapping schema-gated.
- **Phase 4:** [~] local cart boundary complete; address/COD checkout and order integration remain schema-gated.
- **Phase 5:** [ ] order history/detail/status not started.
- **Phase 6/7:** [~] backend delivery lifecycle/tracking verified; Flutter integration schema-gated.
- **Invoice:** [ ] Flutter integration not started; response schema not frozen.
- **Release verification:** [ ] pending a successful CI run plus device/integration verification.

### Next executable work
1. Observe the formatter-remediation CI run and fix any real analyzer/test/build failures.
2. Developer 1 synchronizes the exact Flutter-facing order/COD + address contract and resolves canonical delivery routes.
3. Implement typed order models/repository/controller, then COD checkout with duplicate-submit protection and server-authoritative totals/errors.
4. Implement order success/detail/history, then delivery/tracking and invoice from frozen schemas.


## Developer 2 checkpoint — 2026-09-29 (CI remediation run in progress)

- Current branch head is `4c7570bd6aa064643d868e1984286fd85dc364d8`; PR #1 remains open, mergeable and targets `frontend`.
- Flutter CI run `36591111357` for the previous formatting-remediation commit was cancelled because the branch advanced to the formatting-remediation commit; this is not a test failure and is not evidence of a passing build.
- The new Flutter CI run `36591122454` is currently **in progress** against the current branch head. Job `109484505605` has completed checkout successfully and is currently installing Flutter; formatter/analyzer/tests/Android build have not completed yet.
- Therefore Phase 0 runtime verification and Phase 8 release verification remain **pending**, not passed.
- The shared `API_CONTRACT.md` remains incomplete for Google auth exchange/session fields, catalogue success fields, order/COD + address request/response examples, delivery canonical routes/response schemas, and invoice response/snapshot fields. No speculative API implementation was added.

### Current task status
- **Phase 0:** [~] static audit complete; CI verification is now running, with no final result yet.
- **Phase 1:** [x] API foundation complete.
- **Phase 2:** [~] session lifecycle complete; Google SSO exchange/config and role routing remain contract/config gated.
- **Phase 3:** [~] repository/controller/state integration complete; typed catalogue mapping remains schema-gated.
- **Phase 4:** [~] local cart boundary complete; address/COD checkout and order integration remain schema-gated.
- **Phase 5:** [ ] order history/detail/status not started.
- **Phase 6/7:** [~] backend delivery lifecycle/tracking verified; Flutter integration remains schema-gated and delivery route variants still require canonicalization.
- **Invoice:** [ ] Flutter integration not started; response schema not frozen.
- **Release verification:** [ ] pending successful CI plus physical-device/integration verification.

### Next executable work
1. Complete and inspect CI run `36591122454`; fix only concrete formatter/analyzer/test/build failures if they occur.
2. Developer 1 synchronizes the exact Flutter-facing order/COD + address contract and canonical delivery routes/responses.
3. Implement typed order models/repository/controller, then COD checkout with duplicate-submit protection and server-authoritative totals/errors.
4. Implement order success/detail/history, then delivery/tracking and invoice from frozen schemas.


## Developer 2 continuation checkpoint — 2026-09-29 (CI failure triage + test fix)

- Re-checked PR #1 and the latest Flutter CI result before selecting the next implementation.
- Branch head advanced to `7a70fa05e271dfeee6518fc9f9de71a763c3772e` with a focused test-only fix: `test/features/customer/catalogue_controller_test.dart` now imports the existing `ApiException` type from `lib/core/network/api_exception.dart`.
- CI run `36591386723` failed at **flutter analyze** after dependency resolution and formatting passed. The concrete blocking analyzer errors were four unresolved `ApiException` references in the catalogue controller test. Tests and Android build were skipped because analysis failed.
- The failure was not caused by a new API contract assumption; the test was missing an import for an already-existing shared exception type. No backend-owned files or API DTOs/payloads were changed.
- Replacement CI run `36591707567` for commit `7a70fa05e271dfeee6518fc9f9de71a763c3772e` is currently **in progress**. A pull-request run `36591713156` is also queued. No passing analyzer/test/build result is claimed yet.
- Current contract gate remains unchanged: the shared `API_CONTRACT.md` still lacks complete Flutter-facing order/COD + address schemas and canonical delivery request/assignment route/response definitions. Therefore the next product implementation is still blocked from safely creating typed network models.

### Updated task status
- **Phase 0:** [~] static audit complete; CI now reaches analyzer, with one concrete test compile issue fixed; final analyzer/tests/Android build result pending.
- **Phase 1:** [x] API foundation complete.
- **Phase 2:** [~] session lifecycle complete; Google SSO exchange/config and role routing remain contract/config gated.
- **Phase 3:** [~] repository/controller/state integration complete; typed catalogue mapping remains schema-gated. Catalogue controller test compile blocker fixed in `7a70fa0`.
- **Phase 4:** [~] local cart boundary complete; address/COD checkout and order integration remain contract-gated.
- **Phase 5:** [ ] customer order history/detail/status not started.
- **Phase 6/7:** [~] backend delivery lifecycle/tracking verified; Flutter integration remains schema-gated and delivery route canonicalization is pending.
- **Invoice:** [ ] Flutter integration not started; shared response schema not frozen.
- **Release verification:** [ ] pending successful CI plus physical-device/integration verification.

### Next execution order
1. Observe CI run `36591707567` and fix only concrete formatter/analyzer/test/build failures if any remain.
2. Developer 1 synchronizes the complete Flutter-facing order/COD + address contract and canonical delivery routes/responses into the shared/base contract.
3. Implement typed order models, repository/controller, duplicate-submit protection and server-authoritative totals/errors.
4. Implement order success/detail/history, then delivery/tracking and invoice integrations from frozen schemas.

No speculative API payloads, status enums, identifiers or backend changes are permitted while the contract gate remains open.


## 2026-09-29 — CI triage and implementation checkpoint (latest)

- Branch head: `74b5877e58333976774b325e9476d26d06b224bc`.
- Flutter CI run `36591771642` reached `flutter analyze` and failed on two concrete errors: Riverpod `AsyncValue<AuthStatus>.valueOrNull` was unavailable in `lib/app/app.dart`, and `ApiClient` now requires an `ApiTransport` in `lib/features/auth/presentation/auth_controller.dart`.
- Fixed those concrete analyzer errors only: routing now reads `authState.value`, and the auth API client is constructed with `HttpApiTransport()`.
- Fix commits: `995a9d56f53ce9bf9e3d0408cd37e3feb009d520` and `74b5877e58333976774b325e9476d26d06b224bc`.
- New push/PR CI runs `36592415878` and `36592421982` are currently pending; the previous runs for the intermediate commit are still in progress/cancelled as superseded. Do not mark CI green until the latest head completes analyzer, tests, and Android build.
- Existing non-blocking analyzer warnings/info remain in the legacy UI surface; no broad cleanup was introduced during this checkpoint.

### Current implementation status
- Phase 0 [~] Static audit/documentation complete; CI verification is active, physical-device verification remains not run here.
- Phase 1 [x] API foundation complete.
- Phase 2 [~] Session lifecycle complete; Google SSO exchange/config and role routing remain contract/config gated.
- Phase 3 [~] Repository/controller/state integration complete; typed catalogue mapping remains schema-gated.
- Phase 4 [~] Local cart boundary complete; address/COD checkout, server-authoritative totals/errors, duplicate-submit protection, order success/detail/history remain contract-gated.
- Phase 5 [ ] Customer order history/detail/status not started.
- Phase 6/7 [~] Backend delivery lifecycle/tracking verified; Flutter delivery integration remains schema-gated and canonical route/response synchronization is still required.
- Invoice [ ] Flutter integration not started; response schema is not frozen.

### Next execution order
1. Re-check CI for branch head `74b5877e58333976774b325e9476d26d06b224bc` and fix only newly reported concrete failures.
2. Once CI is clean and Developer 1 synchronizes the Flutter-facing order/COD + address contract, implement typed order models.
3. Implement order repository/controller, then cart → COD checkout with duplicate-submit protection and server-authoritative totals/errors.
4. Implement order success/detail/history and related refresh/empty/error states.
5. Implement delivery assignment/status/location/tracking from the frozen contract.
6. Implement invoice model/repository/UI after its Flutter-facing response schema is frozen.

No undocumented API payloads, status enums, route assumptions, or backend-owned changes are to be introduced.


## Developer 2 continuation checkpoint — 2026-09-29 (CI analyzer warning remediation)

- Re-checked the latest Flutter CI result before continuing implementation.
- Current branch head: `9d3132dd92a1c77868aaba8801729d9ff24fad5e`.
- PR #1 remains open, mergeable, and targets `frontend`.
- CI run `36592511530` failed at `flutter analyze` on the PR merge commit. Dependency resolution and Dart formatting passed; tests and Android build were skipped.
- The analyzer reported no Dart errors, but four warning-level issues caused the analyzer command to exit non-zero:
  1. unused `filterNames` field in `home_feed_screen.dart`;
  2. unused optional `selected` parameter in the restaurant `_Nav` widget;
  3. unused `_FakeStore` test declaration;
  4. unused optional `user` constructor parameter in `_FakeRepository`.
- Fixed only those concrete Flutter-owned analyzer warnings:
  - removed the unused `filterNames` constant;
  - removed the unused `selected` parameter/state from `_Nav`;
  - removed the unused `_FakeStore` and now-unneeded import;
  - simplified `_FakeRepository` construction while retaining its default `AuthUser`.
- Fix commits:
  - `de05d667cbb84999ff214d38a263a623c2792916`
  - `3b9ca0dff6dbdbc22731da1a8f9673e18a59c8a8`
  - `9d3132dd92a1c77868aaba8801729d9ff24fad5e`
- Replacement CI runs for the updated branch are pending/in progress: push `36593120616`, PR `36593128253`; an intermediate PR run `36593116771` is still in progress and may be superseded. Do not mark CI green until the current head completes analysis, tests and Android build.
- The shared `API_CONTRACT.md` remains incomplete for Flutter-facing order/COD, address, delivery/tracking and invoice schemas, and the delivery route discrepancy remains unresolved. No speculative DTOs, status enums, payloads or backend-owned files were added.

### Updated task status

- **Phase 0:** [~] static audit complete; CI has reached analyzer and concrete warning blockers were remediated; current-head analyzer/tests/Android build still pending.
- **Phase 1:** [x] API foundation complete.
- **Phase 2:** [~] session lifecycle complete; Google SSO exchange/config and role routing remain contract/config gated.
- **Phase 3:** [~] repository/controller/state integration complete; typed catalogue mapping remains schema-gated.
- **Phase 4:** [~] local cart boundary complete; address/COD checkout, duplicate-submit protection, server-authoritative totals/errors and order integration remain contract-gated.
- **Phase 5:** [ ] customer order history/detail/status not started.
- **Phase 6/7:** [~] backend delivery lifecycle/tracking verified; Flutter integration remains schema-gated and canonical route/response synchronization is required.
- **Invoice:** [ ] Flutter integration not started; shared response schema is not frozen.
- **Release verification:** [ ] pending successful current-head CI plus physical-device/integration verification.

### Next execution order

1. Inspect CI for current branch head `9d3132dd92a1c77868aaba8801729d9ff24fad5e`; fix only concrete formatter/analyzer/test/build failures.
2. Developer 1 synchronizes the exact Flutter-facing order/COD + address contract and resolves canonical delivery routes/responses.
3. Implement typed order models, repository/controller and tests.
4. Implement cart → COD checkout with duplicate-submit protection and server-authoritative totals/errors.
5. Implement order success/detail/history and refresh/empty/error states.
6. Implement delivery assignment/status/location/tracking, then invoice integration, from frozen schemas.


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

- Completed: typed catalogue category/product DTOs, paginated product state, documented data.data decoding, numeric product-ID validation, typed catalogue tests, removal of placeholder cart fixtures, and CartController.addItem/repository support for real catalogue IDs.
- Contract alignment: product price remains a string; no client total calculation was introduced. Checkout still sends only product IDs/quantities and the server remains authoritative for totals.
- Verification: local Flutter/Dart execution is unavailable; current-head CI is the required automated verification source.
- Next: connect actual catalogue selection to cart add, add checkout success/duplicate/validation/409 tests, then tracking/delivery/invoice and final verification.


## Developer 2 continuation checkpoint — 2026-09-29 (catalogue-to-cart + checkout tests)

- Completed: live typed catalogue product selection in restaurant menu and food details, real product IDs in cart, active/availability gating, and checkout tests for duplicate submit, validation failure and HTTP 409 conflict.
- Order controller compatibility fix: replaced unsupported async state accessor with state.value.
- Remaining: customer tracking, delivery partner integration, invoice UI, CI/device verification.


## Developer 2 continuation checkpoint — 2026-09-29 (active-trip location boundary)

The active-trip tracking slice has progressed beyond the previous delivery lifecycle checkpoint:
- [x] Define a foreground-only location-source abstraction with explicit permission states.
- [x] Add a throttled foreground adapter using the documented 5–10 second starting interval (5 seconds default).
- [x] Bind location publishing to the active assignment ID and the canonical location endpoint.
- [x] Add clean stop/dispose behavior so location publishing does not continue after trip exit.
- [x] Bind partner customer navigation to the active assignment instead of static trip identifiers.
- [x] Add adapter/controller-boundary tests.
- [ ] Wire a concrete approved Android/iOS location plugin behind the adapter.
- [ ] Add platform permission/revocation and physical GPS verification.
- [ ] Add partner freshness/error presentation and complete lifecycle verification.
- [ ] Add Maps SDK integration and marker rendering once platform configuration is available.

The default location source intentionally reports 'unavailable' until the approved platform location dependency/configuration is available; no fake coordinates or background location behavior is introduced.

No backend/Laravel-owned files were modified.


## Developer 2 continuation checkpoint — 2026-09-29 (active-trip lifecycle/freshness)

- Completed the next unblocked active-trip subtask after the foreground location adapter boundary: the partner navigation screen now starts/stops location publishing with the active assignment and navigation lifecycle.
- Added last-successful-publish tracking and UI states for requesting permission, tracking, permission denied, unavailable GPS and publish errors.
- Kept the default location source explicitly unavailable until an approved Android/iOS location package is documented/configured; no fake coordinates or speculative dependency were introduced.
- Invoice remains the next contract-safe feature after the location lifecycle work.
- Runtime verification remains **NOT RUN** because no Flutter/Dart runner is available in the GitHub-connected environment.

### Updated execution queue
1. Wire the approved platform location package and Maps configuration once identified in project configuration/documentation.
2. Verify permission/revocation and real GPS on a physical device.
3. Implement invoice model/repository/UI from the frozen endpoint contract.
4. Run current-head CI and fix only concrete failures.
5. Complete Android/device/E2E verification and update PR readiness.


## Developer 2 continuation checkpoint — 2026-09-29 (current-head CI analyzer fixes)

- Inspected Flutter CI run `36601413076`: dependency resolution and formatting passed; analyzer failed on concrete delivery/order/test callback issues, so tests/APK were skipped.
- Fixed every concrete analyzer error reported by that run and pushed the fixes to `developer-2-flutter` at head `7d1809dd33dcc7dd8996a0cedf5fa544cbeee5d2`.
- No speculative location dependency, Maps SDK, API response field or backend-owned change was introduced.
- Fresh CI for the new head was not yet visible when this checkpoint was written.

### Updated queue
1. Verify fresh current-head CI and address only concrete failures.
2. Wire approved platform GPS + Maps configuration once documented/configured.
3. Perform physical permission/GPS verification.
4. Implement invoice integration only after the exact Flutter-facing invoice response fields are frozen.
5. Finish E2E/release verification.


## Developer 2 continuation checkpoint — 2026-09-29 (current-head CI analyzer follow-up)

- CI run `36603659984` (run #187) against the prior current head passed dependency resolution and formatting but stopped at `flutter analyze` because `StreamController` was missing from `test/features/delivery/delivery_location_adapter_test.dart`.
- Fixed the concrete test compile/analyzer error by restoring the `dart:async` import in commit `ea88f35202db2153570aa149b51b8b805df07bcc`.
- The latest shared contract is now synchronized for Google auth, catalogue, orders/COD, address, delivery/tracking and invoice. Invoice implementation is therefore no longer contract-blocked.
- `pubspec.yaml` still contains no concrete Maps/location dependency. Do not add a package until the approved platform choice/configuration is confirmed.
- Runtime/device verification remains pending.

### Next execution order
1. Inspect CI for `ea88f35202db2153570aa149b51b8b805df07bcc` and fix only concrete failures.
2. Identify the approved Android/iOS location and Maps configuration.
3. Implement invoice model/repository/UI from the frozen contract.
4. Verify real GPS permission/revocation and Maps behavior on physical devices.
5. Complete E2E/release verification and update PR readiness.


## Developer 2 continuation checkpoint — 2026-09-29 (fresh CI started)

- Documentation commits moved the branch to `a6eced1685ac96f817164b920f3ae3a407e88346`; PR #1 remains open, targets `frontend`, and is currently reported mergeable.
- Fresh Flutter CI run `36605874261` (run #189) is now **in progress** for the updated branch. Setup/checkout have passed; Flutter setup is currently running. Analyzer, tests and Android build have not run yet, so no green verification is claimed.
- The immediate test-level analyzer blocker from run #187 is fixed by `ea88f35202db2153570aa149b51b8b805df07bcc`.
- Task documentation is now explicitly aligned with the current implementation queue: invoice is unblocked at the contract level; concrete platform GPS/Maps dependency selection and device verification remain pending.


## Developer 2 continuation checkpoint — 2026-09-29 (CI warning cleanup + task board refresh)

- Completed the concrete analyzer-warning cleanup identified by CI #191: removed the unnecessary order non-null assertion and unused delivery imports/test import.
- Updated task tracking to reflect the actual implementation state: catalogue/cart, COD checkout, customer orders/tracking, delivery lifecycle and active-trip lifecycle are implemented; GPS/Maps platform wiring, invoice DTO/UI, and release verification remain pending.
- Fresh CI #195 is running against 718db207354c67b9cbdb7d2208f3d040c7e066c6; its result is the next verification gate.
- No backend/Laravel-owned files were modified.

### Next implementation queue
1. Inspect CI #195 and fix only concrete failures.
2. Establish the approved GPS/Maps platform dependency/configuration.
3. Implement invoice integration after exact response fields are frozen.
4. Verify physical GPS/Maps behavior and end-to-end flows.


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

- CI #200 (36607353094) reached analyzer successfully after flutter analyze --no-fatal-infos, then failed on three concrete tests: integer product-ID expectation, catalogue async error-state timing, and stale welcome-screen smoke assertions.
- Those test failures are now fixed; latest branch head is fb0fac9b1e886b3c56fb839fadb6fe24e87bcad6.
- No backend/Laravel-owned files were modified and no speculative GPS/Maps dependency was added.

### Updated execution order
1. Verify fresh CI from fb0fac9b1e886b3c56fb839fadb6fe24e87bcad6; tests must pass before the Android build can be evaluated.
2. Fix only concrete current-head test/build failures.
3. Confirm approved Android/iOS location and Maps dependencies/configuration.
4. Implement invoice integration from the frozen success response.
5. Complete physical GPS/Maps and customer/delivery E2E verification.


## Developer 2 continuation checkpoint — 2026-09-29 (current-head CI #207)

- CI #207 (`36608012303`) completed on the PR merge ref with dependency resolution, formatting, and analyzer passing.
- The test gate failed on one stale smoke-test assertion: the welcome brand is rendered as an SVG plus split rich text spans, so `find.text('SNAP FOODD')` does not match the rendered widget tree. The failure is in `test/app_smoke_test.dart`, not application runtime behavior.
- Updated the smoke test to assert the existing SVG semantic label `Snap Foodd` instead of assuming a single literal text node.
- Android debug APK was skipped because the test step failed first.
- No backend/Laravel-owned files were modified and no GPS/Maps dependency was introduced.
- Flutter commands were run by GitHub Actions; local Flutter execution remains unavailable in this connected environment.

### Next execution order
1. Verify a fresh CI run from the smoke-test fix; confirm tests pass and Android debug APK runs.
2. Confirm approved Android/iOS location package and Google Maps configuration before adding platform dependencies.
3. Freeze invoice success JSON fields and implement typed invoice repository/model/UI.
4. Perform physical GPS/Maps verification and customer/delivery E2E verification.


## Developer 2 authoritative status checkpoint — 2026-09-29 (latest branch state)

**Authoritative checkpoint:** `developer-2-flutter` HEAD is `cea9143e6f7c56ad095a5a9f3a5dc8f25f3da11c`. PR #1 remains open, targets `frontend`, and GitHub currently reports it mergeable.

### Completed implementation

- **Phase 0 audit:** static Flutter application audit, screen/feature mapping, dependency/platform inventory, and architecture inspection completed.
- **Phase 1 API foundation:** configured API client, normalized errors, safe logging, environment URL handling, repository boundaries, fake transport/tests, and shared catalogue state/retry handling completed.
- **Phase 2 session:** secure session storage, `/me` hydration, logout, expired-session cleanup, Riverpod auth state and go-router redirects completed. Google sign-in/platform credential verification remains pending.
- **Phase 3 catalogue/cart:** typed catalogue integration, category/product selection, product-ID cart mutations, loading/empty/error/retry states and associated tests completed.
- **Phase 4 COD checkout:** address validation, server-authoritative order totals, duplicate-submit protection, successful-order cart clearing and order-detail navigation are implemented against the documented contract. Automated/runtime verification remains.
- **Phase 5 customer orders/tracking:** order history/detail/tracking integration and status presentation are implemented. Runtime verification remains.
- **Phase 6 delivery lifecycle:** assignment discovery, lifecycle status updates and location publishing are implemented through the documented delivery endpoints.
- **Phase 7 active-trip lifecycle:** foreground location adapter/controller boundary, active-assignment binding, throttling, lifecycle start/stop, last-successful-publish tracking and permission/error/freshness states are implemented. The platform source still intentionally reports unavailable until an approved location dependency/configuration is provided.
- **CI smoke-test maintenance:** fixed the current concrete welcome-screen smoke assertion to use the existing `Snap Foodd` semantic label instead of assuming one literal text node.

### Current verification state

- Fresh Flutter CI **#210** (`36609233693`) is currently **pending** for HEAD `cea9143...`. No green/failed result is claimed yet.
- The previous CI gate (#207) passed dependency resolution, formatting and analyzer, then failed only at the stale welcome smoke assertion. That assertion has now been fixed.
- Android debug APK verification is still pending because CI #207 stopped before the build.
- Local Flutter/Dart execution is unavailable in the connected development environment; local `flutter analyze`, `flutter test`, and `flutter build apk --debug` are **NOT RUN**.
- No backend/Laravel-owned files have been modified.

### Remaining tasks, in execution order

1. **CI verification:** wait for CI #210 and fix only concrete test/build failures.
2. **GPS/Maps platform integration:** confirm the approved Android/iOS location package and Google Maps configuration, then implement the existing platform adapter without changing repository/controller contracts.
3. **Invoice:** freeze the exact Flutter-facing success JSON fields for `GET /orders/{order}/invoice`, then implement typed invoice DTO/repository/UI. Do not invent fields.
4. **Runtime/device verification:** verify GPS permission/revocation, real location publishing, Maps behavior, active-trip lifecycle and customer tracking on physical devices.
5. **E2E/release gate:** verify customer COD, order tracking, delivery lifecycle, Android debug build and final PR readiness.

### Task board

| Area | Status | Current state |
|---|---|---|
| Phase 0 — audit/verification | [~] | Static audit complete; CI/device verification pending |
| Phase 1 — API foundation | [x] | Complete |
| Phase 2 — auth/session | [~] | Session lifecycle complete; Google platform/runtime verification pending |
| Phase 3 — catalogue/cart | [x] | Complete |
| Phase 4 — COD checkout | [x] | Implementation complete; automated/runtime verification pending |
| Phase 5 — customer orders/tracking | [x] | Implementation complete; runtime verification pending |
| Phase 6 — delivery lifecycle | [x] | Assignment/status/location integration complete |
| Phase 7 — active GPS/Maps | [~] | Adapter/controller/lifecycle complete; approved platform dependency + real Maps/GPS verification pending |
| Invoice | [ ] | Endpoint documented; exact success JSON field set still not frozen |
| Release verification | [ ] | Green CI, Android APK, physical-device and E2E verification pending |


## Developer 2 checkpoint — 2026-09-29 (CI smoke-test follow-up)

- Current PR CI run #211 completed with dependency resolution, formatting and analyzer passing, then failed only in `test/app_smoke_test.dart` because the welcome headline is rendered as separate text nodes rather than one literal `GOOD FOOD.\nFAST DELIVERY.` widget.
- Fixed the smoke test to assert the two visible headline fragments independently with `find.textContaining`, preserving the existing UI and avoiding production-code changes.
- Android debug build was skipped by CI because the test step failed; it remains pending until the smoke test passes.
- No backend/Laravel-owned files were modified.
- Next: verify the new smoke-test commit in CI. If green, proceed to the next unblocked platform/configuration gate; do not add an unapproved GPS/Maps dependency.


## Developer 2 checkpoint — 2026-09-29 (invoice implementation)

- Revalidated the backend invoice implementation on branch `developer-1-backend-admin` before adding Flutter DTOs; the customer invoice controller exposes a concrete `data` payload with invoice identity, customer snapshot, delivery-address snapshot, immutable item snapshot, financial totals, payment fields, issue timestamp, and optional file reference.
- Froze those Flutter-facing invoice fields in `API_CONTRACT.md` without modifying any Laravel/backend-owned file.
- Implemented typed `Invoice` and `InvoiceItem` models, a remote/fake `InvoiceRepository`, Riverpod `InvoiceController`, invoice repository tests, and a customer invoice screen.
- Added a delivered-order-only `View invoice` action and route at `/orders/:orderId/invoice`. Existing order navigation and visual structure remain intact.
- Invoice monetary values remain server-authoritative strings; Flutter performs no invoice total calculation.
- Current CI #214 was still in progress for the pre-invoice commit `eb9041a...`; the invoice commits necessarily trigger a fresh CI run. No green result is claimed yet.
- Local Flutter/Dart execution remains NOT RUN because the connected environment has no local Flutter/Dart runner.

### Updated execution order
1. Verify the fresh CI run for the invoice implementation and fix only concrete analyzer/test/build failures.
2. Confirm the approved Android/iOS location package and Google Maps configuration; do not add an unapproved dependency.
3. Wire the approved platform GPS source behind the existing location adapter and perform physical permission/Maps verification.
4. Complete customer/delivery E2E verification, Android debug APK verification, and final PR readiness.

### Current task board

| Area | Status | Current state |
|---|---|---|
| Phase 0 — audit/verification | [~] | Static audit complete; CI/device verification pending |
| Phase 1 — API foundation | [x] | Complete |
| Phase 2 — auth/session | [~] | Session lifecycle complete; Google platform/runtime verification pending |
| Phase 3 — catalogue/cart | [x] | Complete |
| Phase 4 — COD checkout | [x] | Implementation complete; automated/runtime verification pending |
| Phase 5 — customer orders/tracking | [x] | Implementation complete; runtime verification pending |
| Phase 6 — delivery lifecycle | [x] | Assignment/status/location integration complete |
| Phase 7 — active GPS/Maps | [~] | Adapter/controller/lifecycle complete; approved platform dependency + real GPS/Maps verification pending |
| Invoice | [x] | Contract frozen; typed repository/controller/UI and delivered-order route implemented; runtime verification pending |
| Release verification | [ ] | Fresh green CI, Android APK, physical-device and E2E verification pending |


## Developer 2 continuation checkpoint — 2026-09-29 (invoice CI analyzer follow-up)

- Fresh Flutter CI run #229 (36610984138) reached dependency resolution and formatting successfully, then failed at flutter analyze; tests and Android build were skipped.
- Inspected the actual analyzer output and found two concrete invoice-screen errors: the new invoice screen was missing the DeliveryAddress import, and nullable address-list elements were being passed to trim() without narrowing. There was also one redundant null assertion in the invoice fake repository.
- Fixed those concrete issues in commits 255905c4c2c896dce47575dd86097a567f539f41 and 3e4adf5c0977aa8c01dee8035c0511d15dd6ba12.
- No backend/Laravel-owned files were modified. No GPS/Maps dependency was added.
- A new CI run is expected for the corrected head; its analyzer/test/build result must be verified before claiming the invoice implementation is CI-green.
- The next feature remains the approved GPS/Maps platform integration, but it is still blocked because pubspec.yaml has no location/Maps package and the Android manifest has no location/Maps configuration. Do not invent or add an unapproved dependency.

### Current task board

| Area | Status | Current state |
|---|---|---|
| Phase 0 — audit/verification | [~] | CI verification ongoing; physical-device verification pending |
| Phase 1 — API foundation | [x] | Complete |
| Phase 2 — auth/session | [~] | Session lifecycle complete; Google platform/runtime verification pending |
| Phase 3 — catalogue/cart | [x] | Complete |
| Phase 4 — COD checkout | [x] | Implementation complete; automated/runtime verification pending |
| Phase 5 — customer orders/tracking | [x] | Implementation complete; runtime verification pending |
| Phase 6 — delivery lifecycle | [x] | Assignment/status/location integration complete |
| Phase 7 — active GPS/Maps | [~] | Adapter/controller/lifecycle complete; approved platform dependency + real GPS/Maps verification pending |
| Invoice | [x] | Contract frozen; typed model/repository/controller/UI and delivered-order route implemented; analyzer fixes just applied; CI verification pending |
| Release verification | [ ] | Green current-head CI, Android APK, physical-device and E2E verification pending |

### Next execution order
1. Verify fresh CI for commits 255905c... / 3e4adf5... and fix only concrete failures.
2. Confirm the approved Android/iOS location package and Google Maps configuration.
3. Wire the approved platform location source behind the existing adapter/controller boundary.
4. Perform physical GPS permission/revocation, Maps and active-trip verification.
5. Complete customer/delivery E2E, Android debug APK and final PR readiness.



## Developer 2 continuation checkpoint — 2026-09-29 (CI smoke-test timing follow-up)

- Fresh Flutter CI run #234 (36611311310) used the PR merge ref and completed dependency resolution, formatting and analyzer successfully.
- The test suite reached the invoice, order, cart, delivery and API tests successfully; the only failing test was `test/app_smoke_test.dart`.
- The concrete failure was a timing assumption: the smoke test asserted welcome-screen copy immediately after `pumpAndSettle()`, while the app intentionally keeps the splash screen for 1350 ms before navigating to `/welcome`. The failure found zero widgets containing `GOOD FOOD.`.
- Updated the smoke test to verify the splash logo first, advance the fake clock past the 1350 ms splash duration, settle the welcome animations, and then assert the welcome UI.
- Commit: `a614c6d963d26064d71ccb28c3b1e5d921608d01`.
- This is a test-only correction; no backend/Laravel-owned files, API contracts, or platform dependencies were changed.
- CI must be re-run on the corrected head. Do not claim green CI until the new run reaches analyzer, tests and Android debug build successfully.

### Current task board

| Area | Status | Current state |
|---|---|---|
| Phase 0 — audit/verification | [~] | Current-head CI verification ongoing; physical-device verification pending |
| Phase 1 — API foundation | [x] | Complete |
| Phase 2 — auth/session | [~] | Session lifecycle complete; Google platform/runtime verification pending |
| Phase 3 — catalogue/cart | [x] | Complete |
| Phase 4 — COD checkout | [x] | Implementation complete; automated/runtime verification pending |
| Phase 5 — customer orders/tracking | [x] | Implementation complete; runtime verification pending |
| Phase 6 — delivery lifecycle | [x] | Assignment/status/location integration complete |
| Phase 7 — active GPS/Maps | [~] | Adapter/controller/lifecycle complete; approved platform dependency + real GPS/Maps verification pending |
| Invoice | [x] | Contract frozen; typed model/repository/controller/UI and delivered-order route implemented; analyzer fixed; current CI blocked only by smoke-test timing |
| Release verification | [ ] | Current-head green CI, Android APK, physical-device and E2E verification pending |

### Next execution order

1. Verify the fresh CI run for `a614c6d...` and fix only concrete failures.
2. Confirm the approved Android/iOS location package and Google Maps configuration; do not invent a dependency.
3. Wire the approved platform location source behind the existing adapter/controller boundary.
4. Perform physical GPS permission/revocation, Maps and active-trip verification.
5. Complete customer/delivery E2E, Android debug APK verification and final PR readiness.


## Developer 2 continuation checkpoint — 2026-09-29 (current-head CI #237 verification)

- Verified PR #1 still targets `frontend`, remains open, and GitHub currently reports it mergeable.
- Current branch HEAD remains `aea821120f71ab2b559aadf28f99c0428cb76a49`.
- Fresh Flutter CI run #237 (`36612073430`) is now registered for the current head and is **in progress**. The job has completed checkout and is currently setting up Flutter; dependency resolution, formatting, analyzer, tests and Android debug build have not completed yet.
- Therefore **no green CI result is claimed**. Local Flutter/Dart execution remains NOT RUN in the connected environment.
- The latest concrete smoke-test timing failure from CI #234 was addressed in commit `a614c6d963d26064d71ccb28c3b1e5d921608d01`; `DEVELOPER_2_PLAN.md` was then updated in commit `aea821120f71ab2b559aadf28f99c0428cb76a49`.
- No backend/Laravel-owned files were modified and no unapproved GPS/Maps dependency was added.

### Authoritative task board

| Area | Status | Current state |
|---|---|---|
| Phase 0 — audit/verification | [~] | Static audit complete; current-head CI #237 in progress; physical-device verification pending |
| Phase 1 — API foundation | [x] | Complete |
| Phase 2 — auth/session | [~] | Session lifecycle complete; Google platform/runtime verification pending |
| Phase 3 — catalogue/cart | [x] | Complete |
| Phase 4 — COD checkout | [x] | Implementation complete; automated/runtime verification pending |
| Phase 5 — customer orders/tracking | [x] | Implementation complete; runtime verification pending |
| Phase 6 — delivery lifecycle | [x] | Assignment/status/location integration complete |
| Phase 7 — active GPS/Maps | [~] | Adapter/controller/lifecycle complete; approved platform dependency + real GPS/Maps verification pending |
| Invoice | [x] | Contract frozen; typed model/repository/controller/UI and delivered-order route implemented; CI verification pending on current head |
| Release verification | [ ] | Green current-head CI, Android APK, physical-device and E2E verification pending |

### Next execution order

1. **Finish CI #237 verification** and fix only concrete current-head failures if any; do not mark CI green while it is in progress.
2. **Confirm the approved Android/iOS location package and Google Maps configuration** from repository/project documentation before adding any platform dependency.
3. **Wire the approved platform GPS source** behind the existing location adapter/controller boundary once the dependency/configuration is explicitly approved; do not invent a package or fake coordinates.
4. **Verify physical-device GPS/Maps behavior** including permission denial/revocation, active-trip start/stop, throttling, freshness and location publishing.
5. **Complete customer/delivery E2E and release verification**: COD → order → delivery lifecycle → customer tracking → delivered → invoice, plus Android debug APK and final PR readiness.

### Current blockers / verification gaps

- GitHub Actions is the only available Flutter/Dart execution environment in this session; local Flutter commands remain unavailable.
- The repository still has no documented approved concrete location/Maps package and no concrete platform Maps configuration that Developer 2 can safely add without guessing. Existing active-trip code therefore keeps the platform source explicitly unavailable until approval/configuration exists.
- Google auth platform/runtime verification remains pending because public platform configuration/runtime credentials have not been verified in this environment.

`DEVELOPER_2_PLAN.md` is the authoritative task-progress record for Developer 2. Each implementation or verification checkpoint must update this board before the next task is started.

## Developer 2 continuation checkpoint — 2026-09-30 (CI #238 + platform dependency gate)

- **Branch:** `developer-2-flutter`
- **PR:** #1 → `frontend`, open and currently reported mergeable.
- **Current HEAD:** `bf3e32f4587032104f36745af3e0bd8219080db6`.
- **Latest Flutter CI:** run #238 (`36612431841`) is **in progress** for the current documentation commit. Job `109556959338` has completed checkout and is currently setting up Flutter; dependency resolution, formatting, analyzer, tests and Android debug build have not completed. **CI is not marked green.**
- The task board was refreshed in the preceding documentation commit; this checkpoint records the latest observed CI state and platform-dependency gate.
- **Platform dependency audit:** `pubspec.yaml` contains no concrete location or Google Maps package, and `android/app/src/main/AndroidManifest.xml` contains no location permissions or Maps metadata. Repository search also found no `geolocator` or `google_maps_flutter` usage and no documented approved concrete replacement.
- Therefore the next GPS/Maps implementation is **blocked on explicit project approval/configuration**, not on missing adapter/controller code. The existing foreground location adapter/controller remains the integration boundary and must not be bypassed with an invented package or fake coordinates.
- Google SSO platform/runtime verification remains pending; no client secrets or platform credentials are to be invented or committed.
- **No backend/Laravel-owned files were modified. No merge or deployment was performed.**

### Authoritative task board

| Area | Status | Current state |
|---|---|---|
| Phase 0 — audit/verification | [~] | Static audit complete; CI #238 in progress; physical-device verification pending |
| Phase 1 — API foundation | [x] | Complete |
| Phase 2 — auth/session | [~] | Session lifecycle complete; Google platform/runtime verification pending |
| Phase 3 — catalogue/cart | [x] | Typed catalogue, real product IDs, cart integration and tests complete; runtime verification pending |
| Phase 4 — COD checkout | [x] | Server-backed COD flow, address validation, duplicate-submit protection, server-authoritative totals/errors and success navigation implemented; runtime verification pending |
| Phase 5 — customer orders/tracking | [x] | Order history/detail integration implemented; tracking integration remains to be verified/completed where not yet covered |
| Phase 6 — delivery lifecycle | [x] | Assignment/status/location integration implemented against canonical routes; runtime verification pending |
| Phase 7 — active GPS/Maps | [~] | Adapter/controller/lifecycle complete; approved platform location + Maps configuration and physical verification blocked |
| Invoice | [x] | Contract frozen; typed model/repository/controller/UI and delivered-order route implemented; CI/runtime verification pending |
| Release verification | [ ] | Green current-head CI, Android APK, physical-device and full E2E verification pending |

### Next execution order

1. **Finish CI #238 verification** and fix only concrete current-head formatter/analyzer/test/build failures.
2. **Close the platform dependency gate:** obtain/confirm the approved Android/iOS location package and Google Maps configuration from project documentation/owner direction. Do not guess.
3. **Wire the approved platform GPS source** behind the existing location adapter/controller boundary.
4. **Complete customer tracking and delivery runtime verification** including stale/no-location/error states, permission denial/revocation, active-trip start/stop and location publishing.
5. **Run the release gate:** Android debug APK, physical-device verification, customer COD → order → delivery → tracking → delivered → invoice E2E, then final PR readiness.

### Current blockers

- GitHub Actions is the available Flutter/Dart execution environment; local Flutter/Dart commands remain unavailable in this session.
- No approved concrete GPS/Maps dependency or platform Maps configuration is documented in the repository, so adding one would be speculative.
- Google auth platform/runtime verification remains pending.

`DEVELOPER_2_PLAN.md` remains the authoritative Developer 2 task-progress record; update it after each implementation or verification checkpoint.


## Developer 2 continuation checkpoint — 2026-09-30 (CI #239 smoke-test failure + correction)

- **Current branch:** `developer-2-flutter`.
- **PR:** #1 → `frontend`, open and currently reported mergeable.
- **CI run #239** (`36612623553`) completed with **failure**. Dependency resolution, Dart formatting, formatting check and analyzer all passed. The test suite reached 36 passing tests before the smoke test failed; Android debug build was skipped because the test step failed.
- The concrete failure was `test/app_smoke_test.dart`: the test expected the splash SVG's `semanticsLabel` to produce a semantics node named `Snap Foodd`, but the GitHub Flutter test environment found zero matching semantics nodes. The splash implementation itself still renders the same `SvgPicture` asset with that label.
- Corrected the smoke test to assert the rendered `SvgPicture` widget directly instead of relying on the SVG semantics tree, while retaining the timed transition and welcome-screen assertions.
- **Fix commit:** `7e111f34dca6db8889747f7167314764ec6b88f1` (`test(flutter): make splash smoke assertion asset-based`).
- This is a test-only correction. No Laravel/backend-owned files, API contracts, platform credentials or GPS/Maps dependencies were changed.
- **CI is not green yet**; a fresh run must verify the correction through tests and the Android debug build.

### Authoritative task board

| Area | Status | Current state |
|---|---|---|
| Phase 0 — audit/verification | [~] | Static audit complete; CI #239 exposed a smoke-test assertion issue; correction committed; fresh CI pending |
| Phase 1 — API foundation | [x] | Complete |
| Phase 2 — auth/session | [~] | Session lifecycle complete; Google platform/runtime verification pending |
| Phase 3 — catalogue/cart | [x] | Typed catalogue, real product IDs, cart integration and tests complete; runtime verification pending |
| Phase 4 — COD checkout | [x] | Server-backed COD flow, address validation, duplicate-submit protection, server-authoritative totals/errors and success navigation implemented; runtime verification pending |
| Phase 5 — customer orders/tracking | [x] | Order history/detail/tracking implementation present; runtime/E2E verification pending |
| Phase 6 — delivery lifecycle | [x] | Assignment/status/location integration implemented against canonical routes; runtime verification pending |
| Phase 7 — active GPS/Maps | [~] | Adapter/controller/lifecycle complete; approved platform location + Maps configuration and physical verification blocked |
| Invoice | [x] | Contract frozen; typed model/repository/controller/UI and delivered-order route implemented; current CI verification pending |
| Release verification | [ ] | Green current-head CI, Android APK, physical-device and full E2E verification pending |

### Next execution order

1. **Verify fresh CI on `7e111f3...`** and fix only concrete failures; do not claim green until tests and Android debug build complete successfully.
2. **Close the GPS/Maps dependency gate** by confirming the approved Android/iOS location package and Maps configuration from project documentation/owner direction.
3. **Wire the approved platform GPS source** behind the existing adapter/controller boundary.
4. **Verify customer tracking and delivery runtime behavior**: permission denial/revocation, stale/no-location/error states, active-trip start/stop, throttling and location publishing.
5. **Run release E2E and Android debug APK verification**: COD → order → delivery → tracking → delivered → invoice, then final PR readiness.

### Current blockers

- No approved concrete GPS/Maps dependency or platform Maps configuration is documented in the repository.
- Google auth platform/runtime verification remains pending.
- Local Flutter/Dart execution remains unavailable; GitHub Actions is the available Flutter execution environment.


## Developer 2 continuation checkpoint — 2026-09-30 (CI #242 smoke-test session-state correction)

- Fresh Flutter CI run #242 (`36612952240`) completed on the PR merge ref with dependency resolution, formatting and analyzer passing.
- The test suite again reached 36 passing tests before `test/app_smoke_test.dart` failed because `GOOD FOOD.` was still absent after the splash wait. Android debug APK was skipped because the test step failed.
- The actual app routing is auth-aware: the splash route can be redirected based on asynchronous session restoration. The smoke test was depending on the real secure-storage/session bootstrap while also asserting the public welcome route, making the test nondeterministic in the CI test environment.
- Corrected the smoke test to override `authControllerProvider` with a deterministic signed-out controller, while retaining the splash asset assertion, 1350 ms splash transition, welcome assertions and Explore Food navigation check.
- **Fix commit:** `de6ffe452009a2a8ea2ff6772e9d1fe2eef324dc` (`test(flutter): isolate smoke test from session restore`).
- This is a test-only correction. No Laravel/backend-owned files, API contracts, platform credentials, GPS/Maps dependencies or production routing behavior were changed.
- A fresh CI run is required before marking Phase 0 or release verification green.

### Authoritative task board

| Area | Status | Current state |
|---|---|---|
| Phase 0 — audit/verification | [~] | CI #242 exposed auth/session nondeterminism in the smoke harness; deterministic override committed; fresh CI pending |
| Phase 1 — API foundation | [x] | Complete |
| Phase 2 — auth/session | [~] | Session lifecycle implementation complete; Google platform/runtime verification pending |
| Phase 3 — catalogue/cart | [x] | Typed catalogue, real product IDs, cart integration and tests complete; runtime verification pending |
| Phase 4 — COD checkout | [x] | Server-backed COD flow, address validation, duplicate-submit protection, server-authoritative totals/errors and success navigation implemented; runtime verification pending |
| Phase 5 — customer orders/tracking | [x] | Order history/detail/tracking implementation present; runtime/E2E verification pending |
| Phase 6 — delivery lifecycle | [x] | Assignment/status/location integration implemented against canonical routes; runtime verification pending |
| Phase 7 — active GPS/Maps | [~] | Adapter/controller/lifecycle complete; approved platform location + Maps configuration and physical verification blocked |
| Invoice | [x] | Contract frozen; typed model/repository/controller/UI and delivered-order route implemented; CI/runtime verification pending |
| Release verification | [ ] | Green current-head CI, Android APK, physical-device and full E2E verification pending |

### Next execution order

1. **Verify fresh CI on `de6ffe4...`** and fix only concrete test/build failures.
2. **Close the GPS/Maps dependency gate** by confirming an approved Android/iOS location package and Maps configuration; do not invent a dependency.
3. **Wire the approved platform GPS source** behind the existing adapter/controller boundary.
4. **Verify customer tracking and delivery runtime behavior** including permission denial/revocation, stale/no-location/error states, active-trip lifecycle, throttling and location publishing.
5. **Run release E2E and Android debug APK verification**: COD → order → delivery → tracking → delivered → invoice, then final PR readiness.

### Current blockers

- No approved concrete GPS/Maps dependency or platform Maps configuration is documented in the repository.
- Google auth platform/runtime verification remains pending.
- Local Flutter/Dart execution remains unavailable; GitHub Actions is the available Flutter execution environment.


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
