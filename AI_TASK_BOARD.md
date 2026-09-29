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
- [!] M2 — Google SSO end-to-end is not yet verified. Flutter session restore/revoke foundation is implemented and the prior backend auth/authz CI checkpoint is green. The backend branch still does not freeze the exact `/auth/google` request credential field/type, successful application-token response shape, or public Google client configuration. No guessed payload/package/configuration has been added.
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


## Developer 2 checkpoint — 2026-09-29 (refreshed)

- **Branch:** `developer-2-flutter`
- **Current Flutter work:** API foundation, catalogue repository/controller/state integration, secure session/token persistence, `/me` restoration, logout/revocation handling, auth controller tests, and Riverpod-aware go_router redirects are implemented.
- **Latest Developer 2 documentation:** this checkpoint, `DEVELOPER_2_PLAN.md`, and `docs/AUTH_CONTRACT_HANDOFF.md` are synchronized with the latest inspected backend state.
- **Backend checkpoint:** Developer 1 latest inspected commit is `aaa75903c5b723aa4d307afa6691f6ab0c535ab7`. Workflow #142 exposed four stale assertions expecting `error.code`; fixes landed in `53cbf6e01ebed21cf295f3700809e2877aaccc26` and `28053a9ff26f854cc70301920b97844dad8c72c9`. Fresh CI after those fixes is still pending.
- **Shared contract status:** `API_CONTRACT.md` still documents only `POST /auth/google` at endpoint level; `AUTH.md` still does not define the exact Google credential field/type, successful application-token response shape, or public Google client configuration. Catalogue successful response fields are also not documented.
- **M2:** `[!]` Google SSO end-to-end remains blocked; secure session restoration/revocation foundation is complete.
- **M3:** `[ ]` Catalogue integration is implemented on Flutter behind repository/controller boundaries, but end-to-end admin-to-customer verification and deterministic backend seed/CI remain incomplete.
- **Flutter runtime verification:** formatter/analyzer/tests/build/device checks are **NOT RUN** because this GitHub-connected environment has no local Flutter/Dart runner.
- **Next owner/action:** Developer 1 verifies corrected backend CI and publishes the missing Google/catalogue response contract. Developer 2 then implements exact Google provider/exchange; if catalogue response fields are published first, typed catalogue DTO/UI mapping proceeds first. After those gates: cart/COD/orders, delivery, then active-trip tracking.
