# Snap Foodd — Shared AI Task Board

This board tracks **integration milestones**, not every code-level subtask. Detailed checklists belong to `DEVELOPER_1_PLAN.md` and `DEVELOPER_2_PLAN.md`.

## Status legend
- `[ ]` Not started
- `[~]` In progress
- `[x]` Verified complete (must have evidence/commit/test result)
- `[!]` Blocked

## Shared milestones

- [~] M0 — Local development assumptions are documented; GoDaddy plan/capabilities are still owner-verification pending.
- [x] M1 — Laravel boots and connects to non-production MySQL; clean MySQL migrations/tests are verified by the Backend CI workflow.
- [x] M2 — Google SSO backend authentication/authorization slice is implemented and verified through workflow #146; end-to-end Flutter session restoration/revocation remains a separate integration check.
- [x] M3 — Admin product/category CRUD and customer catalogue API work end-to-end, including deterministic seed/demo data verified by workflow #146.
- [x] M4 — Customer creates a COD order with server-calculated totals; customer order ownership/history, server-owned admin status transitions, and concurrency-safe delivery assignment are implemented and CI-verified through Workflows #189, #204 and #386.
- [x] M5 — Delivery-partner provisioning/approval, protected Laravel admin web operations, catalogue management, partner controls, directories, dashboard counts and web/API assignment are implemented and CI-verified through Workflows #209, #244, #324, #349, #363, #371 and #386.
- [x] M6 — Partner assignment listing and valid pickup → out-for-delivery → delivered transitions are implemented with ownership/conflict tests and verified by Workflow #259. No separate partner accept endpoint is part of the current product contract; assignment is server-created by ADMIN.
- [x] M7 — Active-trip GPS updates, latest-location reads, stale-state reporting and customer/admin authorization are implemented and verified by Workflow #266.
- [x] M8 — Invoice schema, deterministic numbering, immutable snapshots and customer/admin access are implemented and verified by Workflow #301.
- [~] M9 — Implementation and CI coverage are substantially complete. Backend workflow #423 passed the current branch head with PHP 8.3, Composer, Pint, MySQL migrations and PHPUnit. Remaining gates are external GoDaddy capability confirmation, broader end-to-end/device validation and explicit human release approval.

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

- Workflow #244 passed dependency installation, MySQL migrations and the PHPUnit test step after the admin web route/middleware restoration.
- Workflow #259 PASSED on commit 148e8ab54a617007c38d3ecb3498445d04d16968, verifying the corrected delivery-partner lifecycle authorization responses with PHP 8.3/MySQL.
- New Phase 6 increment: delivery partners can list their own active assignments and progress owned assignments through PICKED_UP → OUT_FOR_DELIVERY → DELIVERED. Cross-partner access, unapproved-partner access, and invalid state skips are covered by `DeliveryPartnerOrderTest`.


### Developer 1 status — delivery lifecycle and tracking — 2026-09-29

- M6 delivery-partner assignment listing and owned status progression are CI-verified complete by Workflow #259.
- Implemented M7 location slice: POST /api/v1/delivery/assignments/{assignment}/location for the owning approved/active partner, coordinate/accuracy/timestamp validation, active-trip enforcement, persistent location history, and GET /api/v1/orders/{order}/tracking plus admin tracking read with stale-state reporting.
- Location implementation commit: 8fce7c8374943d23e4e723f9df01776ac6d71b99; conflict response normalization follow-up: d2fbd64cbdc8086530eda80536ed09e33fd9ff16.
- M7 remains in progress pending CI verification; invoices remain next after the location/tracking gate passes.


- Workflow #266 **PASSED** on commit `f99dde6b52ff0450693fff8b63b90ce31bbe2722`, verifying M7 active-trip location/tracking with PHP 8.3/MySQL. M7 is now complete; Phase 7 invoices is the next implementation.


- Phase 7 invoice increment is implemented on `developer-1-backend-admin`: delivered-order invoice generation is idempotent, snapshots order/customer/item financial data, and customer/admin authorization is enforced.
- Workflow #284 failed because `InvoiceApiTest` used `User::factory()` while the minimal Laravel `User` model lacked `HasFactory`; User factory support was added.
- Workflow #288 then failed after dependency installation and MySQL migrations passed: 7 invoice tests called `Order::factory()` and the minimal `Order`/`OrderItem` models lacked factory support. Added `HasFactory`, `OrderFactory`, and `OrderItemFactory`.
- M8 remains in progress until a fresh CI run passes the full PHPUnit suite. Next action: rerun/verify invoice CI, then continue with the next incomplete plan item.


### Developer 1 status — invoice verification and admin dashboard — 2026-09-29

- Workflow #301 **PASSED** on the invoice authorization fix. PHP 8.3 setup, dependency installation, MySQL migrations and PHPUnit all completed successfully.
- M8 is now CI-verified complete.
- Started the next Phase 5 increment: protected admin dashboard order-operation counts for PLACED (new), ACCEPTED (active), PREPARING, READY_FOR_PICKUP/ASSIGNED (awaiting delivery), and PICKED_UP/OUT_FOR_DELIVERY (active delivery).
- Added `AdminDashboardTest` coverage for the counts and admin-only access. CI verification for this dashboard increment is pending.
- Next implementation: admin order search/filter/detail/status workflow, followed by broader admin dashboard operations.


### Developer 1 release-readiness status — 2026-09-29

- Current branch: `developer-1-backend-admin`
- CI verification head: `941e9f2ee2916499fec4d60e4df1a6d37fb789b9` (documentation-only tracking commits followed)
- PR: #2 → `frontend`
- Workflow #406: **PASSED**. The configured Backend workflow ran PHP 8.3, Composer install, MySQL 8.4 migrations and `composer test`.
- Phase 8 documentation/contract integration work is complete: route audit, representative request/response examples, stable error mapping and `backend/API_INTEGRATION.md`.
- No formatter/static-analysis/security command is configured in the current Backend workflow. Those checks remain unexecuted rather than being inferred from the passing PHPUnit workflow.
- GoDaddy plan-specific capability verification remains pending with the owner.
- No deployment or production migration was performed.

### Developer 1 task-tracking update — 2026-09-29

- Workflow #413 **FAILED** at the new Pint check: dependency installation passed, Pint found 29 style issues across 101 files, and migrations/tests were skipped.
- Commit `d7042331b8da04a0ca8b8960761b30aa9c5f03a7` adds a push-only `Backend Format` workflow to apply Pint and commit generated formatting changes directly to `developer-1-backend-admin`; fresh PR verification is still pending.
 (quality gate)

- Added a PHP 8.3 CI Pint formatting check to `.github/workflows/backend.yml` in commit `781364ba1c0d69340b488e71ac1eb9e74dbe0ff0`.
- The PR head is now `781364ba1c0d69340b488e71ac1eb9e74dbe0ff0`; the connector has not yet returned a PR-triggered workflow run for this commit, so the formatting gate is **pending verification** and is not marked complete.
- Static-analysis/security tooling is still not configured in CI; local PHP/Composer execution remains unavailable in the connector environment.
- **Next owner/action:** verify the new CI formatting gate, then complete available static/security review; project owner confirms GoDaddy capabilities and gives explicit release approval. Developer 2/frontend integration remains a separate validation track.

### Developer 1 task-tracking update — 2026-09-29

- Phase 4 documentation is now aligned with the verified implementation: server-owned order transitions and concurrency-safe delivery assignment are complete and CI-verified.
- Phase 6 documentation is now aligned with the current contract: partner approval/activation/availability and eligible-partner selection are implemented through admin assignment; partner-owned delivery progression is `PICKED_UP → OUT_FOR_DELIVERY → DELIVERED`. No separate partner-accept endpoint is being introduced without a product-contract change.
- Phase 8 remains **IN PROGRESS**. Workflow #406 passed on CI verification head `941e9f2ee2916499fec4d60e4df1a6d37fb789b9`; subsequent tracking commit `1184d969d5a32267019e23b39f3e7f595879a81b` updates the plan only.
- Remaining release gates: PHP 8.3/Composer formatter/static-analysis/security checks where available, final manual security/content review, GoDaddy capability confirmation, broader Flutter/device/end-to-end validation, and explicit human release approval.
- No deployment or production migration was performed.


### Developer 1 task-tracking update — 2026-09-29 (formatter remediation)

- M9 remains **IN PROGRESS**; formatting is not yet verified complete.
- Workflow #416 confirmed Pint still fails with 29 style issues across 101 PHP files; migrations/tests were skipped.
- Commit `b39ed4c1935a99e8b4ca043686d135a2a50682ee` updates the backend formatter workflow to cover same-repository PR synchronization as well as branch pushes, so formatting remediation has an explicit CI path.
- Backend workflow #418 is currently queued/running against the new head. Do not mark M9 complete until a fresh formatter-clean Backend workflow verifies migrations and PHPUnit.
- Next owner/action: verify #418; then resolve any remaining formatter/static-analysis/security findings, complete manual security/content review, confirm GoDaddy capabilities, and obtain explicit human release approval.


### Developer 1 task-tracking update — 2026-09-29 (Pint applied)

- The formatter remediation workflow successfully created generated formatting commit `fe67a57f07500f06443b8978d8ad42906132edd7` with message `style(backend): apply Laravel Pint formatting`.
- This confirms the previously identified Pint changes were applied to the backend branch. The formatter gate is therefore **remediated at the source level**, but the required fresh Backend verification is still pending.
- Backend workflow #419 for the formatting commit is `action_required`, so it is not being counted as a passing verification.
- Backend workflow #420 is currently `in_progress` on the subsequent documentation head `fd34ef249e14961700e506cda563ded7c404aaa5`; its final result is required before marking the CI gate complete.
- No Flutter-owned files, deployment, or production migration were changed.

**Next task:** verify workflow #420. If it passes formatting, migrations and PHPUnit, mark the formatting/CI gate verified; then proceed to final manual security/content review, GoDaddy capability confirmation and broader integration/release validation.


### Release-readiness update — 2026-09-29

- **Backend workflow #421 PASSED** on branch head `e7f9b346c8d9f0bf32f684d087a14e8d900ff3ec`.
- The complete CI gate passed: PHP 8.3 setup, Composer dependency installation, **Laravel Pint formatting check**, MySQL database migrations, and the PHPUnit test suite.
- This closes the previously blocked formatter/CI verification gate. The earlier 29 Pint issues are now resolved by generated formatting commit `fe67a57f07500f06443b8978d8ad42906132edd7`.
- Release-readiness is **not yet complete**: remaining work is final manual security/diff review, confirmation of GoDaddy production capabilities, broader Flutter/device/end-to-end integration validation, and explicit human release approval.
- No deployment or production migration has been performed.

**Next implementation task:** perform the final backend security/content/diff review and document any findings before release approval.


### Developer 1 status — final security/content review — 2026-09-29

- Backend workflow **#423 PASSED** on the code head immediately before the final documentation-only tracking commits. Backend workflow **#425 is currently in progress** on the current branch head.
- The current CI gate is verified end-to-end: PHP 8.3, Composer dependencies, Laravel Pint formatting, clean MySQL migrations and PHPUnit all completed successfully.
- Final manual backend review covered route/middleware authorization, Google credential verification and token handling, admin web session protection, order/checkout invariants, delivery assignment/status/location ownership, invoice/tracking access, request validation, environment/secret handling, and the PR changed-file scope.
- **Review result:** no blocking security/content/diff finding was identified in the reviewed backend paths. This is a repository review result, not a claim of absolute security.
- No Flutter-owned files were changed. No deployment or production migration was performed.
- Remaining release gates are now external/integration gates: GoDaddy capability confirmation, broader Flutter/device/E2E validation, and explicit human release approval.
- **Next owner/action:** owner confirms hosting capabilities and release readiness; Developer 2 completes frontend/device/E2E validation. Developer 1 should only make further backend changes if those validations uncover a concrete backend issue.


### Developer 1 task-tracking update — 2026-09-29 (CI #425/#427 completed)

- Backend workflow **#425 PASSED** on tracking head `09ce904325128c4363f79087c3cff05b5d9a88c0`.
- Backend workflow **#427 PASSED** on the latest branch head `f76db385f21448198e8181fa142c1c7f62267dc6`.
- Latest CI verification covers PHP 8.3, Composer, Laravel Pint, clean MySQL migrations and PHPUnit on the current branch head.
- Final manual backend security/content/diff review is complete; no blocking finding was identified in the reviewed backend paths.
- M9 remains **IN PROGRESS** only for external release gates: GoDaddy capability confirmation, broader Flutter/device/E2E validation, and explicit human release approval.
- No planned backend feature task remains before those gates. Developer 1 should only make further backend changes if external validation exposes a concrete defect.
- No Flutter-owned files were changed. No deployment or production migration was performed.


## Developer 1 status — 2026-09-29 (latest CI verification)

- Backend workflow **#428 PASSED** on branch head `0e0344d8fbe66ddc3a5036a4642c66ec3f19d1b7`.
- #428 verified PHP 8.3, Composer dependency installation, Laravel Pint formatting, clean MySQL migrations and PHPUnit.
- This closes the current branch-head CI verification gate after the documentation-only tracking updates. #427 on `f76db385f21448198e8181fa142c1c7f62267dc6` is now historical.
- Final manual backend security/content/diff review is complete; no blocking finding was identified in the reviewed backend paths.
- **Completed:** all planned backend feature implementation, API/admin/delivery/invoice work, integration documentation, formatting remediation, CI verification, and final manual backend review.
- **Remaining:** GoDaddy capability confirmation, broader Flutter/device/E2E validation, and explicit human release approval.
- **No new backend feature should be invented at this stage.** Developer 1 only continues if external validation exposes a concrete backend defect or the product/API contract changes.
- No Flutter-owned files were changed; no deployment or production migration was performed.

**Next owner/action:** owner validates hosting/release prerequisites; Developer 2 completes frontend/device/E2E validation; then the owner gives explicit release approval. Any backend defect found during those checks becomes the next implementation task and must be CI-verified before release.


### Developer 1 task-tracking update — 2026-09-29 (local Laravel serving fix)

- Local backend testing exposed a concrete missing Laravel runtime directory: backend/public/ was absent from the tracked backend tree.
- Added the standard Laravel backend/public/index.php front controller and backend/public/.htaccess rewrite configuration.
- This restores the expected Laravel HTTP document root needed by php artisan serve and Apache-style hosting.
- Commits: 81d0753ca65ee7de00d743ec8d09153da6b9ec00, 2d25a91eb7d24194fc4fc74f5d9895d4fcf3f923.
- CI verification for the new runtime fix is pending; local validation should rerun php artisan serve after pulling the latest branch.
- No Flutter-owned files, deployment, or production migration were changed.


### Developer 1 status — 2026-09-29 (local Laravel front-controller import fix)

- Local validation exposed a second concrete runtime defect after restoring `backend/public/`: `public/index.php` called `Request::capture()` without importing `Illuminate\\Http\\Request`, producing `Class "Request" not found` under `php artisan serve`.
- Fixed `backend/public/index.php` by adding the standard `use Illuminate\\Http\\Request;` import.
- Fix commit: `2376e97cd3d3fab6465ddf6ff6ebb021c9628a22`.
- Backend workflow #435 **PASSED** on the preceding public-directory fix commit `d1431914bfa2dd13c319c6508318ae566fdaab6d`; this new import fix requires a fresh CI verification.
- Next local validation: pull the latest branch, restart `php artisan serve`, then proceed to local `.env`/MySQL configuration and migrations once the server responds successfully.
- No Flutter-owned files, deployment, or production migration were changed.
