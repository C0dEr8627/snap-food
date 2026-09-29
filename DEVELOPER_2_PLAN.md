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

> **Status as of 2026-09-29:** Developer 2 is working only on `developer-2-flutter`. PR #1 targets `frontend` and remains open. The latest documented Flutter head is `b32a6fb666f76ad2c09efc16c00ae90fcd1fec43`.
>
> **Verified complete in source control:** Phase 0 static Flutter audit, screen-to-contract mapping, platform/dependency inventory, API transport/client foundation, normalized API errors, environment API URL documentation, API-client fake-transport tests, the first catalogue repository boundary with a remote implementation plus deterministic fake repository, the catalogue Riverpod controller/state layer with retry/error handling and controller tests, configured repository wiring, catalogue loading/empty/error/retry UI integration across the existing customer catalogue screens with widget coverage, and the initial auth/session foundation with secure token storage, `/me` hydration, logout handling and auth-aware route redirects.
>
> **Backend checkpoint refreshed:** Developer 1's branch has documented fixes after workflow #179: `bf2febe...` corrected the status-history assertion, `a0f9b47...` restored the order-list `data` envelope, and `cf5236d...` added explicit customer-role middleware. Commit `a1fcc5c...` documents these Phase 4 corrections. These changes are not treated as verified integration until a fresh green Phase 4 workflow is observed.
>
> **Catalogue contract limitation:** `API_CONTRACT.md` still documents catalogue endpoints without defining successful category/product response fields or a common success envelope. The repository therefore preserves JSON payloads without inventing field names. Typed DTO/UI mapping must wait for documented response fields or an explicitly approved backend response shape.
>
> **Auth contract limitation:** `API_CONTRACT.md` / `AUTH.md` still do not define the exact Google credential request field/type, successful application-token response shape, public Google client configuration, or sufficiently explicit role response shape. The Flutter auth foundation is ready, but the real provider/exchange must wait for that contract.
>
> **Not verified because the GitHub-connected environment has no local Flutter/Dart runner:** `dart format`, `flutter pub get`, `flutter analyze`, `flutter test`, `flutter build apk --debug`, and physical-device checks. These remain **NOT RUN**, not passed.

## Phase 0 — Inspect current app

- [x] Inspect `pubspec.yaml`, routing, Riverpod providers, feature directories, existing mock repositories and all current screens (static source audit completed; runtime baseline remains separate).
- [ ] Run formatter/analyzer/tests available in the environment; record actual baseline results.
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

- [ ] Review current cart implementation and preserve usable UI.
- [ ] Ensure cart quantities reference product IDs; local subtotal is preview only.
- [ ] Implement address selection/entry based on agreed contract.
- [ ] Add COD checkout request and submit only product IDs, quantities and required address data. **Blocked until backend Phase 4 is green and request/response examples are frozen.**
- [ ] Display server-calculated totals and server validation errors.
- [ ] Prevent duplicate taps/submissions and show pending/success/failure states.
- [ ] Route successful order to order detail/status screen.
- [ ] Test empty cart, changed price, unavailable product, request timeout and duplicate submit.

**Milestone:** customer places a real COD order once backend is verified and documented.

## Phase 5 — Customer orders/profile

- [ ] Connect order history/detail/status to API.
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

## End-of-task report format

- Completed tasks:
- Screens/features connected:
- Files/dependencies changed:
- API contract assumptions/questions:
- Tests/build commands run and actual result:
- Platform/device checks:
- Remaining blockers:
- Next task:
