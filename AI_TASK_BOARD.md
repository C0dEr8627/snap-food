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
- [x] M2 — Google SSO backend authentication/authorization slice is implemented and verified through workflow #146; end-to-end Flutter session restoration/revocation remains a separate integration check.
- [x] M3 — Admin product/category CRUD and customer catalogue API work end-to-end, including deterministic seed/demo data verified by workflow #146.
- [~] M4 — Customer creates a COD order with server-calculated totals; customer order ownership/history are implemented, while CI verification and admin inspection/status operations remain.
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


## Developer 1 status — 2026-09-29

- Workflow #146 completed successfully on the corrected branch state. MySQL migrations and the PHPUnit suite passed on PHP 8.3.
- Phase 2 identity/authorization is now CI-verified complete for the backend slice.
- Phase 3 catalogue is now CI-verified complete, including deterministic seed/demo data and idempotence coverage.

- Phase 2 authentication/authorization implementation: **implemented and CI-verified complete**.
- Phase 3 catalogue implementation: **implemented and CI-verified complete**, including deterministic seed/demo data.
- Catalogue APIs now support authenticated category/product reads, active-item filtering for customers, search and bounded pagination.
- Admin category/product create/update/deactivate operations are protected by role middleware and policies.
- Update request validation and catalogue endpoint regression tests are present.
- Deterministic seed data is implemented in `DatabaseSeeder` and covered by `DatabaseSeederTest`.
- Workflow #134 failed during catalogue tests because the Laravel 13 base controller does not expose `$this->authorize`.
- Workflow #138 confirmed remaining `$this->authorize` calls in catalogue `show`/`destroy` paths; these have now been replaced with `Gate::authorize`.
- Fix commits: `26f6217e7a89362550f8f68cfa8027027030645a`, `64aaefff30c5a02bbc0cdf2b367e11166d2403d6`, `7d7fa3fc02456c4f724fbbcc345717c35ac42b78`, `735853594f3c7b82b0e8c19db92483f9cf7a9324`.
- Workflow #138 failed with the remaining controller authorization calls; the latest two commits fixed those paths. Workflow #142 then failed on four stale test assertions expecting `error.code`; the API contract uses top-level `code`. Test assertions were corrected in commits `53cbf6e01ebed21cf295f3700809e2877aaccc26` and `28053a9ff26f854cc70301920b97844dad8c72c9`. Fresh CI verification is pending.
- Verification gate: GitHub Actions workflow #146 passed.
- Next implementation: Phase 4 order/COD workflow, starting with state definitions and transition rules.

- Phase 4 initial order/COD slice is now implemented on the branch: orders/order-items/status-history schema, transactional checkout, server-side totals, immutable snapshots, COD pending state, customer list/detail endpoints, and regression tests. CI verification is pending.
