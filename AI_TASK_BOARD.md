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
- [~] M4 — Customer creates a COD order with server-calculated totals; customer order ownership/history, server-owned admin status transitions, and delivery assignment are implemented. Workflow #204 verified status transitions; assignment verification is pending.
- [~] M5 — Delivery-partner provisioning/approval is CI-verified by Workflow #209 behind ADMIN API authorization. Protected Laravel web authentication and concurrency-safe order assignment are implemented and Workflow #244 has passed the PHPUnit suite; broader dashboard operations remain.
- [~] M6 — Partner assignment listing and valid pickup → out-for-delivery → delivered transitions are implemented with ownership/conflict tests; explicit partner accept step remains to be finalized against the product contract; CI exposed two 403 cases being normalized as 500, and the response handling has been corrected pending fresh verification.
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

- Phase 4 initial order/COD slice is implemented: orders/order-items/status-history schema, transactional checkout, server-side totals, immutable snapshots, COD pending state, customer list/detail endpoints, and regression tests.
- Workflow #175 failed with 4 order-related test failures because the migration created `order_status_history` while the `OrderStatusHistory` model queried `order_status_histories`.
- Fix commit: `112a2ffe1df0bcd07bbf54f43748798809c144b8` aligns the migration and rollback table name with the model convention.
- Workflow #179 failed with 3 order-related tests: singular status-history assertion, missing `data` envelope on order list, and admin order-route authorization returning 500 instead of 403.
- Fixes: `bf2febe67ee45507886be50aca809e7c0bca9f23`, `a0f9b47f70df16871ea4da82a50ebf5640b1582b`, `cf5236d87a7c2ad00be965a89ce94a5cd72a566b`.
- Current gate: corrected CI verification pending; after green, continue with server-owned status transition operations and concurrency/conflict coverage.

- Workflow #184 ran the corrected order branch: MySQL migrations and the suite booted successfully, but the cross-customer order-detail test received HTTP 500 instead of 403.
- Fix commit `032e4144e5fba9e0b24a16418b82a23b1dbc2d52` adds explicit `AccessDeniedHttpException` mapping to the standard 403/FORBIDDEN API response.
- Documentation commits: `f11a9526f8177c10d1a7bb114044ffa033f56e7f` and typo correction `858e3b7dd887a57f3d3e135ed5ebe838aae59990`.
- Current gate: fresh CI verification of the exception fix is required before M4 advances; next implementation remains server-owned order status transitions and concurrency/conflict coverage.

- Workflow #189 **PASSED**: PHP 8.3, MySQL migrations and PHPUnit suite verified the Phase 4 authorization correction; the initial checkout/list/detail slice is now CI-verified.
- New Phase 4 increment: `PATCH /api/v1/admin/orders/{order}/status` is implemented for ADMIN users only. It validates target states, locks the order row with `lockForUpdate()`, enforces the server transition matrix, records actor history, and returns `ORDER_STATE_CONFLICT`/409 for invalid or repeated transitions.
- Regression tests cover valid admin transition, invalid jump, repeated transition conflict, and customer denial.
- Workflow #204 **PASSED**: PHP 8.3, MySQL migrations and PHPUnit suite verified the server-owned admin status-transition increment.
- Delivery-partner provisioning/approval is implemented with admin-only authorization, transactional user-role provisioning, approval/revocation state, and regression tests. Workflow #205 **FAILED** because duplicate/admin conflicts returned 500 instead of 409; generic conflict handling was corrected and Workflow #209 **PASSED** on PHP 8.3/MySQL with the full PHPUnit suite.
- Protected Laravel admin web authentication/dashboard foundation is now implemented on `developer-1-backend-admin` with Google credential verification, web-session login, ADMIN-only access, logout/session invalidation, and rate limiting; Workflow #221 is the current verification gate.
- Admin role bootstrap remains operator-controlled; web login only permits already-provisioned active ADMIN users.

- New implementation: `POST /api/v1/admin/orders/{order}/assignment` uses a transaction with `lockForUpdate()` on both the order and delivery partner, requires `READY_FOR_PICKUP` and approved/active/available partner state, prevents duplicate assignment, and records `ASSIGNED` status history with the admin actor. Fresh CI verification is pending.

- Backend Workflow #234 failed on the admin-web test slice because the minimal Laravel skeleton lacked Blade compiled-view/session runtime configuration; the failure was concrete (`Please provide a valid cache path`). Runtime configuration and required framework directories were added.
- Workflow #240 then failed because the branch's `backend/routes/web.php` had reverted to the default welcome route and `bootstrap/app.php` lacked the admin web middleware alias, causing 404s/session assertions in all 7 admin-web tests. Those files were restored in commits `fe7f3cabb1e38782971c53062d50af8b1ff83ce3` and `cc08d4ff61540fdd4e5786d82821e43dc53b1377`.
- Workflow #243 is running on `cc08d4ff61540fdd4e5786d82821e43dc53b1377`; admin web authentication and delivery assignment are not marked verified until it passes.

- Workflow #244 passed dependency installation, MySQL migrations and the PHPUnit test step after the admin web route/middleware restoration; final workflow cleanup was still in progress when checked.
- New Phase 6 increment: delivery partners can list their own active assignments and progress owned assignments through PICKED_UP → OUT_FOR_DELIVERY → DELIVERED. Cross-partner access, unapproved-partner access, and invalid state skips are covered by `DeliveryPartnerOrderTest`.
