# Snap Foodd — Shared AI Task Board

This board tracks **integration milestones**, not every code-level subtask. Detailed checklists belong to `DEVELOPER_1_PLAN.md` and `DEVELOPER_2_PLAN.md`.

## Status legend
- `[ ]` Not started
- `[~]` In progress
- `[x]` Verified complete (must have evidence/commit/test result)
- `[!]` Blocked

## Shared milestones

- [ ] M0 — GoDaddy plan/capabilities recorded; local development assumptions documented.
- [ ] M1 — Laravel boots and connects to non-production MySQL.
- [~] M2 — Backend Google SSO/authentication/authorization is CI-verified in workflow #146, but Flutter Google sign-in is not end-to-end because the shared contract still lacks the exact `/auth/google` credential field/type, success token response, public client configuration, and role response shape.
- [x] M3 — Admin product/category CRUD and customer catalogue API work end-to-end, including deterministic seed/demo data verified by backend workflow #146. Flutter repository/controller/state integration exists, but typed field-level UI mapping awaits the documented catalogue success schema.
- [~] M4 — Backend order/COD implementation is in progress on Developer 1's branch. The latest Phase 4 CI run (#179) still fails in `OrderApiTest`: the test environment is querying the singular `order_status_history` table while the intended model/migration contract expects `order_status_histories`. The migration fix is therefore not yet CI-verified, and the order/COD request/response contract is still not sufficiently documented for Flutter checkout integration.
- [ ] M5 — Admin provisions delivery partners and safely assigns orders.
- [ ] M6 — Partner accepts, confirms pickup, and completes delivery through valid state transitions.
- [ ] M7 — Active-trip GPS updates are authorized and customer map shows fresh/stale location states.
- [ ] M8 — Invoice generation and access rules are tested.
- [ ] M9 — Security, Android device, end-to-end and deployment-readiness checks pass.

## Handoff format

When a milestone changes, the responsible AI updates this board in its own branch/PR and reports:
- milestone and status;
- branch + commit SHA;
- evidence/commands/tests and actual outcomes;
- dependencies/blockers;
- next owner/action.

Do not mark a milestone complete based only on code existing. Require a verified integration result.

## Decision log

Record decisions here only after the owner approves or they are already established in the project docs:
- Backend: Laravel/PHP + MySQL.
- Mobile: Flutter, Riverpod 3, go_router.
- Identity: Google OAuth SSO; OTP deferred.
- Payment: COD.
- Admin: separate Laravel web dashboard.
- Maps: Google Maps Platform.
- Tracking: active-trip only using HTTP updates and polling for MVP.
- Hosting: GoDaddy; plan/capabilities unverified.
- Restaurant Partner workflow: deferred.

## Developer 2 checkpoint — 2026-09-29 (backend checkpoint refreshed)

- **Branch:** `developer-2-flutter`
- **Flutter implementation completed:** API client/transport foundation, normalized API errors, catalogue repository + fake/remote implementations, Riverpod catalogue controller/state, catalogue loading/empty/error/retry UI integration, secure application-session storage, `/me` restoration, logout/revocation handling, auth controller tests, and auth-aware go_router redirects.
- **Backend branch inspected:** `developer-1-backend-admin` at `083bab12b37a2a010b15b8c394561e9f627d65de`.
- **Backend verification:** workflow #146 passed the corrected Phase 2/3 authentication/authorization + catalogue suite on PHP 8.3 with MySQL. Deterministic catalogue seed/idempotence coverage is included.
- **Latest backend Phase 4 verification:** workflow #179 ran on the corrected backend branch state but **failed**: migrations completed, then `OrderApiTest` reported 3 failures, including a missing `order_status_history` table during order-history assertions and an admin-order-endpoint 500. The Phase 4 slice is not verified complete.
- **M2:** `[~]` backend auth is verified, Flutter SSO remains blocked by the undocumented exact Google credential request/response contract, public client configuration, and role response shape.
- **M3:** `[x]` backend catalogue milestone is verified; Flutter field-level DTO/UI mapping remains blocked because `API_CONTRACT.md` still does not document successful category/product response fields/envelope.
- **M4:** `[~]` order/COD backend implementation exists, but Flutter must wait for a green Phase 4 CI run plus documented checkout/order request/response fields before integrating.
- **Flutter runtime verification:** `dart format`, `flutter pub get`, `flutter analyze`, `flutter test`, `flutter build apk --debug`, and physical-device checks are **NOT RUN** because this GitHub-connected environment has no local Flutter/Dart runner.
- **Next owner/action:** Developer 1 fixes the remaining Phase 4 CI failures and publishes exact order/COD request/response examples plus the missing Google/catalogue response contracts. Developer 2 implements whichever documented contract becomes unblocked first, without guessing payload fields; then continues cart/COD → orders → delivery → active-trip tracking.
