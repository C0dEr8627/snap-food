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
- [~] M4 — Backend order/COD initial checkout/list/detail slice is now CI-green through workflow #186 after fixes for the status-history table/assertion, order-list `data` envelope, customer-only order route authorization, and cross-customer 403 error normalization. M4 remains in progress because server-owned status-transition/concurrency coverage and the complete Flutter-facing order/COD contract examples are still pending.
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

## Developer 2 checkpoint — 2026-09-29

- **Branch:** `developer-2-flutter`
- **Current Flutter PR:** #1 targeting `frontend`; latest implementation checkpoint is `c0fbe23643507eba58534a05d821eec89495d102`.
- **Flutter implementation completed:** API client/transport foundation, normalized API errors, environment API URL documentation, catalogue repository + fake/remote implementations, Riverpod catalogue controller/state, catalogue loading/empty/error/retry UI integration, secure application-session storage, `/me` restoration, logout/revocation handling, auth controller tests, auth-aware go_router redirects, and the local cart repository/controller boundary with explicit product IDs and quantity tests.
- **Backend checkpoint:** `developer-1-backend-admin` has documented fixes after workflow #179: `bf2febe67ee45507886be50aca809e7c0bca9f23` fixes the stale status-history table assertion, `a0f9b47f70df16871ea4da82a50ebf5640b1582b` restores the established `data` envelope for order lists, and `cf5236d87a7c2ad00be965a89ce94a5cd72a566b` restricts customer order routes with `role:CUSTOMER`. Backend documentation commit `a1fcc5c920db6e4de71a53e294f3d71df95ad9b0` records the earlier fixes; commit `032e4144e5fba9e0b24a16418b82a23b1dbc2d52` adds 403/FORBIDDEN exception normalization and workflow #186 verifies it.
- **Backend verification:** workflow #146 passed the corrected Phase 2/3 authentication/authorization + catalogue suite on PHP 8.3 with MySQL. The backend plan records workflow #204 as passing for server-owned admin order status transitions; workflow #205 failed on delivery-partner provisioning/approval conflict rendering; the backend fix is awaiting fresh CI verification.
- **M2:** `[~]` backend auth is verified, but Flutter SSO remains blocked by the undocumented exact Google credential request/response contract, public client configuration, and role response shape.
- **M3:** `[x]` backend catalogue milestone is verified; Flutter field-level DTO/UI mapping remains blocked because `API_CONTRACT.md` still does not document successful category/product response fields/envelope.
- **M4:** `[~]` backend initial order/COD checkout/list/detail slice is now green in workflow #186. Flutter still waits for documented checkout/list/detail request/response examples and the next server-owned status-transition/concurrency slice before marking the milestone complete.
- **Flutter runtime verification:** `dart format`, `flutter pub get`, `flutter analyze`, `flutter test`, `flutter build apk --debug`, and physical-device checks are **NOT RUN** because this GitHub-connected environment has no local Flutter/Dart runner.
- **Next owner/action:** Developer 1 should publish the exact Flutter-facing order/COD and address request/response examples and finish the pending delivery-partner provisioning/approval CI verification. Developer 2 has now completed the local cart boundary subtask and will not guess API payload fields. Google SSO and typed catalogue mapping remain blocked on their missing schemas. Once the order contract is frozen, continue cart → checkout → customer orders, then delivery → active-trip tracking → invoices → release hardening.


## Developer 2 checkpoint — 2026-09-29 (cart boundary implementation)

- Branch: developer-2-flutter
- Commit: c0fbe23643507eba58534a05d821eec89495d102
- Implemented: local cart repository + Riverpod controller, explicit product IDs, quantity mutation through the controller, and repository tests.
- Preserved: existing cart UI, route, and navigation.
- Not implemented: backend order submission, address API, server totals, order response DTOs; those remain contract-gated.
- Verification: Flutter/Dart commands remain NOT RUN because no local Flutter/Dart runner is available.
