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
- [!] M2 — Google SSO end-to-end is not yet verified. Flutter session restore/revoke foundation is implemented and backend auth/authz CI is green. The backend branch still does not freeze the exact `/auth/google` request credential field/type, successful application-token response shape, or public Google client configuration. No guessed payload/package/configuration has been added.
- [ ] M3 — Admin product/category CRUD and customer catalogue API work end-to-end.
- [ ] M4 — Customer creates a COD order with server-calculated totals; admin can inspect it.
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
- **Latest implementation/documentation commits:** `0ba538f4846db2459ce15e5233b45e289eda585e`, `c3623da7e745f23e783ccbbae7c05d9af50e6c7a`
- **Completed:** API foundation; catalogue repository/controller/state foundation and existing-screen integration; secure session/token persistence; /me restoration; logout/revocation handling; auth controller tests; Riverpod-aware go_router redirects; progress tracking documentation.
- **Verified backend dependency:** Developer 1 auth/authz workflow #109 passed on commit `b150b2cbb6874c00fda70197d0995057b19a0e6d`.
- **Blocked:** Google SSO exchange until backend freezes request/response fields and public client configuration.
- **Also blocked:** typed catalogue DTO/UI mapping until successful category/product response fields are documented.
- **Not run:** Flutter formatter/analyzer/tests/build/device checks because this environment has no local Flutter/Dart runner.
- **Next owner action:** backend/API owner freezes the Google auth contract; then Developer 2 implements provider adapter and exact exchange. Role-specific route separation follows the documented user-role shape. If catalogue response schema is published first, Developer 2 can proceed with typed catalogue mapping before auth integration.