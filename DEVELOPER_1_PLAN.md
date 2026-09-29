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
| Phase 2 — Identity & authorization | **PARTIAL** | Google verification service, login, Sanctum token storage, `/me`, logout and negative auth tests are implemented; final CI verification and role middleware/policies remain. |
| Phase 3 — Catalogue | **PARTIAL** | Categories/products schema, models, casts and initial request validation are implemented. Catalogue APIs, resources, pagination/search, deterministic seeds, admin CRUD and endpoint tests remain. |
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
- [ ] Add rate limiting where appropriate, credential-safe logging and consistent API error responses.

**Foundation/database CI verification:** workflow #30 passed PHP 8.3 setup, dependency installation and the foundation `composer test` suite. Workflow #48 also passed the MySQL-backed migration and current test suite for the initial database slice.

## Phase 2 — Identity and authorization

- [x] Implement Google credential verification server-side through the Google API client, validating the configured OAuth client ID.
- [x] Find/create users by stable Google subject identifier.
- [x] Implement Sanctum application tokens/session flow and token storage migration.
- [x] Implement login, `GET /api/v1/me`, logout/revocation; role middleware/policies remain.
- [ ] Roles: `CUSTOMER`, `DELIVERY_PARTNER`, `ADMIN`; no Restaurant Partner scope.
- [ ] Provision/approve delivery partners and admins server-side only.
- [ ] Enforce resource ownership.
- [x] Add invalid credential, inactive account, token revocation and role-escalation regression tests.
- [ ] Add explicit role middleware/policy and cross-user resource authorization tests.

**Milestone:** Google SSO → Laravel verification → MySQL user → application token/session → `/me`.

## Phase 3 — Catalogue

- [x] Add initial categories and products migrations/models/casts.
- [x] Add initial category/product request validation and admin authorization checks.
- [ ] Define and enforce final catalogue write policy/resources at endpoint level.
- [ ] Implement customer catalogue reads.
- [ ] Implement admin category/product CRUD and deactivate/delete policy.
- [ ] Add pagination, search/filter and deterministic seed data.
- [ ] Add inactive-product and admin-only endpoint tests.

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
19. Google credential verification service, auth routes, Sanctum token storage, `/me`, logout and authentication regression tests implemented.
20. `DEVELOPER_1_PLAN.md` and `backend/README.md` updated to reflect the verified database foundation and current authentication implementation status.

### Not yet verified

- The latest Google SSO/Sanctum implementation is awaiting workflow #73.
- A real production Google credential has not been used; tests mock the verifier to avoid external identity-provider calls.
- GoDaddy Composer/extensions/database/document-root/SSH capabilities.

## Immediate next task

**Verify workflow #73 for the Google SSO/Sanctum slice.** If green, complete the remaining Phase 2 authorization work (role middleware/policies and cross-user authorization tests), then proceed to catalogue read/admin CRUD endpoints.

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
