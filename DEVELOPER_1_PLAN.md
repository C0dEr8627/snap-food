# Developer 1 — Backend, Database & Admin Execution Plan

> **Branch:** `developer-1-backend-admin`  
> **Base:** `frontend`  
> **Primary ownership:** Laravel API, MySQL, authentication verification, business rules, delivery operations, invoices and separate Laravel admin web.  
> **Read first:** `README.md`, `AI_RULES.md`, `PRODUCT.md`, `ARCHITECTURE.md`, `API_CONTRACT.md`, `DATABASE.md`, `AUTH.md`, `ADMIN.md`, `DEVELOPMENT.md`, `AIDLC_WORKFLOW.md`.

## Mission

Build the trusted backend and admin operations that the existing Flutter app can consume. Work in small, tested vertical slices. Do not assume GoDaddy features that have not been verified.

## Non-negotiable boundaries

- Keep backend code in `backend/` unless repository evidence or the owner approves another location.
- Laravel + PHP + MySQL. REST APIs are versioned under `/api/v1`.
- Google OAuth credentials are verified server-side. Never trust a role sent by Flutter.
- Backend owns product prices, availability, totals, payment state, order transitions, delivery assignment and completion.
- COD only. No online gateway.
- Restaurant Partner workflow, OTP, Firebase, Supabase, WebSockets and background GPS are out of scope.
- Admin is a protected Laravel web dashboard, separate from Flutter.
- Never commit `.env`, secrets, real credentials, database dumps with personal data or tokens.
- Do not change Flutter screens or dependencies except when a documented contract change requires coordination.

## Progress dashboard

| Phase | Status | Completed / remaining |
|---|---|---|
| Phase 0 — Environment & repository baseline | **PARTIAL** | Repository/docs inspected; PHP 8.3 target recorded; hosting checklist and safe env example documented. Actual GoDaddy Composer/MySQL capability remains unverified. |
| Phase 1 — Backend foundation | **COMPLETED** | Laravel API skeleton, routing, health endpoint, PHPUnit config/test, PHP 8.3 CI, Sanctum, MySQL config, Laravel 13 baseline and required Git-preserved directories are complete. Workflow #30 passed the foundation suite. Initial MySQL schema/models and CI migration verification also passed in workflow #48. |
| Phase 2 — Identity & authorization | **PARTIAL** | Google verification service, login, Sanctum token storage, `/me`, logout, role middleware, resource policies and negative/cross-user authorization tests are implemented. Rate limiting and credential-safe logging are also implemented. Latest combined authorization/API-hardening CI verification remains pending. |
| Phase 3 — Catalogue | **PARTIAL** | Customer category/product read APIs, search/pagination, admin create/update/deactivate APIs, update validation and endpoint regression tests are now implemented. Deterministic seed data and final CI verification remain. |
| Phase 4 — Orders & COD | **NOT STARTED** | Order snapshots, totals, COD state, transitions, history and tests remain. |
| Phase 5 — Admin & assignment | **NOT STARTED** | Protected admin web dashboard and delivery assignment operations remain. |
| Phase 6 — Delivery tracking | **NOT STARTED** | Partner workflow, pickup/completion, location updates and tracking authorization remain. |
| Phase 7 — Invoices | **NOT STARTED** | Numbering decision, invoice generation and access control remain. |
| Phase 8 — Release readiness | **NOT STARTED** | Seeds, contract examples, clean-DB migration run, automated tests, security review and deployment checklist remain. |

## Phase 0 — Inspect and establish the environment

- [x] Inspect repository and existing docs before creating files.
- [x] Record PHP, Composer, Laravel and MySQL requirements/status in `backend/README.md`.
- [x] Document the GoDaddy hosting capability checklist.
- [x] Record that unverified hosting capabilities must not be assumed.
- [x] Create safe `backend/.env.example` placeholders.
- [x] Check agent environment: PHP 8.4.23 exists; Composer and MySQL CLI are absent.
- [x] Record production PHP target as PHP 8.3.
- [x] Add PHP 8.3 Composer platform constraint.

**Gate:** PARTIALLY PASSED. The target runtime is known, but local dependency/database execution and actual GoDaddy capabilities remain unverified.

## Phase 1 — Backend foundation

- [x] Create Laravel application foundation under `backend/`.
- [x] Configure `/api/v1` routing baseline and health endpoint.
- [x] Establish PHPUnit feature-test configuration and health test.
- [x] Add non-sensitive health/readiness endpoint.
- [x] Add PHP 8.3 GitHub Actions workflow with PDO/MySQL extensions.
- [x] Add Sanctum dependency for the planned application-token flow.
- [x] Add environment-driven MySQL configuration at `backend/config/database.php`.
- [x] Align application configuration with the current Laravel skeleton structure.
- [x] Align PHPUnit configuration with the Laravel 13/PHPUnit 12 baseline.
- [x] Update framework baseline from Laravel 11 to Laravel 13 because Laravel 11 security support ended March 12, 2026; Laravel 13 requires PHP 8.3.
- [x] Verify CI can resolve and install the Laravel 13 dependency set on PHP 8.3.
- [x] Confirm the health PHPUnit test and foundation suite pass after preserving required Laravel test directories.
- [x] Add MySQL-backed CI service, run migrations and verify the initial database schema.
- [x] Add model relationship coverage and request validation groundwork for the initial database slice.
- [x] Add rate limiting where appropriate, credential-safe logging and consistent API error responses.

**Foundation/database CI verification:** workflow #30 passed PHP 8.3 setup, dependency installation and the foundation `composer test` suite. Workflow #48 also passed the MySQL-backed migration and current test suite for the initial database slice.

## Phase 2 — Identity and authorization

- [x] Implement Google credential verification server-side through the Google API client, validating the configured OAuth client ID.
- [x] Find/create users by stable Google subject identifier.
- [x] Implement Sanctum application tokens/session flow and token storage migration.
- [x] Implement login, `GET /api/v1/me`, logout/revocation; role middleware/policies remain.
- [x] Define role constants for `CUSTOMER`, `DELIVERY_PARTNER`, `ADMIN`; no Restaurant Partner scope.
- [ ] Provision/approve delivery partners and admins server-side only.
- [x] Enforce address resource ownership through a Laravel policy; admin access is explicit through policy `before` handling.
- [x] Add invalid credential, inactive account, token revocation and role-escalation regression tests.
- [x] Add explicit role middleware, register the `role` middleware alias, register resource policies and add cross-user authorization tests.

**Milestone:** Google SSO → Laravel verification → MySQL user → application token/session → `/me`.

## Phase 3 — Catalogue

- [x] Add initial categories and products migrations/models/casts.
- [x] Add initial category/product request validation and admin authorization checks.
- [x] Define and enforce final catalogue write policy at endpoint level; admin writes are protected by role middleware and model policies.
- [x] Implement customer catalogue reads for active categories/products.
- [x] Implement admin category/product create/update/deactivate endpoints.
- [x] Add pagination and search/filter query handling.
- [x] Add inactive-product visibility and admin-only endpoint tests.
- [ ] Add deterministic seed data and final CI verification for the catalogue slice.

**Milestone:** admin creates/updates a product; customer catalogue API returns it.

## Phase 4 — Orders and COD

- [ ] Define allowed order states and transitions from `PRODUCT.md` and `API_CONTRACT.md`.
- [ ] Implement validated delivery-address snapshots.
- [ ] Recalculate price/availability/fees/totals server-side.
- [ ] Create order/item immutable snapshots in one transaction.
- [ ] Persist COD payment method and initial pending payment state.
- [ ] Add order status history.
- [ ] Implement customer list/detail endpoints with ownership checks.
- [ ] Prevent invalid state jumps, price tampering and unauthorized access.
- [ ] Add transaction, state-transition and ownership tests.

**Milestone:** Flutter-compatible request creates a real MySQL COD order and customer can retrieve it.

## Phase 5 — Admin operations and delivery assignment

- [ ] Create protected Laravel web login/authorization for admins.
- [ ] Build dashboard for catalogue, orders, customers, partners, assignments and invoices.
- [ ] Implement order search/filter/detail/status actions.
- [ ] Provision/approve/deactivate delivery partners.
- [ ] Implement concurrency-safe delivery assignment.
- [ ] Record assignment/status history and actor.
- [ ] Add authorization and race/conflict tests.

## Phase 6 — Delivery APIs and active tracking

- [ ] Implement partner availability and eligible request list.
- [ ] Implement approved accept/pickup/completion workflow.
- [ ] Implement partner-owned active-assignment location updates.
- [ ] Validate coordinates, timestamps and payload size.
- [ ] Persist latest location and required history.
- [ ] Implement authorized tracking reads.
- [ ] Use HTTP updates + polling for MVP; no WebSockets/background GPS dependency.
- [ ] Add stale-location and authorization tests.

## Phase 7 — Invoices

- [ ] Agree invoice numbering and required fields before implementation.
- [ ] Generate invoices from immutable order snapshots.
- [ ] Protect customer/admin invoice access.
- [ ] Add totals, numbering uniqueness and unauthorized-access tests.

## Phase 8 — Integration and release readiness

- [ ] Provide safe seed/demo data.
- [ ] Maintain API contract examples and integration guide.
- [ ] Run formatter/static analysis where configured.
- [ ] Run migrations from an empty MySQL database.
- [ ] Run the automated test suite.
- [ ] Document backup/restore and production environment checklist.
- [ ] Verify no secrets or sensitive data are committed.
- [ ] Produce final PR summary with changed files, tests and limitations.

## Current execution status

### Completed in this branch

1. Repository and backend documentation baseline established.
2. PHP 8.3 production target recorded.
3. Laravel API foundation created under `backend/`.
4. `/api/v1/health` endpoint and feature test created.
5. PHP 8.3 CI workflow created.
6. Sanctum dependency added for planned authentication.
7. Invalid Composer JSON identified by CI and corrected.
8. Laravel baseline upgraded to `^13.17`, with PHP `^8.3`, current Sanctum compatibility, PHPUnit 12, Pint 1.27 and Collision 8.9.
9. Laravel-style application config and environment-driven MySQL config added.
10. CI verified dependency resolution and installation successfully on PHP 8.3.
11. CI bootstrap/test-directory failures diagnosed and fixed.
12. Workflow #30 passed the foundation PHPUnit suite.
13. Initial `users`, `addresses`, `categories` and `products` migrations/models added.
14. Workflow #48 passed MySQL startup, migrations, schema assertions and the current PHPUnit suite.
15. Bidirectional Eloquent relationship tests added for users/addresses and categories/products.
16. Foreign-key behavior tests added for address cascade and product/category restrict-on-delete.
17. Initial address/category/product FormRequest validation added, including coordinate ranges, slug/price/stock validation and admin-only authorization checks.
18. Workflow #58 passed the relationship/request-validation slice.
19. Google credential verification service, auth controller, Sanctum token storage, `/me`, logout and authentication regression tests implemented.
20. Workflow #79 exposed that the authentication routes had not been persisted into `routes/api.php`; the missing route registration was corrected in commit `8df16414dd31f5eb0901d09dd94b43fca1707d72`.
21. Workflow #81 ran against the corrected routes but failed because `App\Http\Controllers\Controller` was missing from the Laravel 13 application skeleton.
22. Added the application controller base class in commit `d01b6de139d819b4b0e2572f0e8dc22b6a6d5c12`.
23. Workflow #85 reached the authentication suite successfully; one logout regression failed because the Laravel test container retained the authenticated guard instance after token deletion, so the subsequent request received HTTP 200 despite the database token being deleted.
24. Fixed the logout regression test by clearing cached guards after revocation in commit `9bdef081822ae75d5628b62d3df400ef5b7d7f5b`.
25. Added role constants/helpers, `EnsureUserHasRole`, the `role` middleware alias, explicit Address/Category/Product policies and Gate registration.
26. Added middleware and cross-user/role policy coverage in `AuthorizationPolicyTest.php`; final CI verification is pending for this combined authz slice.
27. Added Google sign-in rate limiting, credential-safe failure logging, and consistent `/api/v1` exception/error responses with regression tests.
28. Implemented customer catalogue category/product reads with active-item filtering, search, pagination and authenticated access.
29. Implemented admin category/product create/update/deactivate endpoints, update validation and endpoint regression tests; inactive products are hidden from customer reads.
30. Corrected catalogue policies so active customers can read categories/products while admin-only write operations remain protected.
31. Workflow #134 failed on the latest combined API-hardening + catalogue state because Laravel 13's base controller does not provide the `authorize` helper; catalogue controllers were corrected to use `Gate::authorize`.
32. The correction is committed on `developer-1-backend-admin`; CI verification of those commits is pending.
33. Progress documentation is maintained against actual CI results rather than assuming implementation is verified.

### Latest verification result

- Workflow #109 passed the prior authentication + authorization implementation.
- Workflow #134 ran the combined latest branch state and **failed in the catalogue test suite**: 7 tests failed after the application boot, dependency installation and MySQL migrations all succeeded.
- The concrete failure was `Method App\\Http\\Controllers\\Api\\V1\\Catalogue\\ProductController::authorize does not exist.` The same controller-level authorization helper was also used by `CategoryController`.
- Fixed the Laravel 13 controller authorization calls by switching catalogue controllers to `Gate::authorize(...)` in commits `26f6217e7a89362550f8f68cfa8027027030645a` and `64aaefff30c5a02bbc0cdf2b367e11166d2403d6`.
- A new CI result for the fix commits is pending; Phase 2/3 must remain unverified until it passes.
- A real production Google credential has not been used; tests mock the verifier to avoid external identity-provider calls.
- GoDaddy Composer/extensions/database/document-root/SSH capabilities remain unverified.

## Immediate next task

**Verify CI after the catalogue authorization fix.** If green, update the verified Phase 2/3 status, add deterministic catalogue seed/demo data, and then begin Phase 4 order/COD workflow. If CI exposes another defect, fix the concrete failure before advancing.

## Developer 1 definition of done

A task is complete only when implementation, validation, authorization, automated tests, docs and error behavior agree. Never claim tests passed unless they actually ran. Report blockers explicitly.

## End-of-task report format

- Completed tasks:
- Files changed:
- Migrations:
- API changes:
- Tests run and actual result:
- Security/authorization considerations:
- Remaining blockers:
- Next task:
