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
| Phase 1 — Backend foundation | **IN PROGRESS** | Laravel API skeleton, `/api/v1` routing, health endpoint, PHPUnit config/test, PHP 8.3 CI and Sanctum dependency are present. MySQL config is now added. CI still needs a successful dependency install/test run. |
| Phase 2 — Identity & authorization | **NOT STARTED** | Google verification, users, Sanctum tokens, roles, ownership and auth tests remain. |
| Phase 3 — Catalogue | **NOT STARTED** | Categories/products schema, models, validation, catalogue APIs, admin CRUD and tests remain. |
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
- [ ] Obtain a successful `composer install` in CI.
- [ ] Run the PHPUnit health test successfully in CI.
- [ ] Add request validation, rate limiting where appropriate, logging without credentials and consistent error responses.

**Current CI blocker:** workflow run #13 reached PHP 8.3.35 and installed the required extensions and Composer 2.10.3, but dependency resolution stopped because the Laravel 11 constraint selected versions blocked by current security advisories. The dependency baseline has now been moved to Laravel 13/PHP 8.3. A new CI run must verify the corrected manifest.

## Phase 2 — Identity and authorization

- [ ] Implement Google credential verification server-side.
- [ ] Find/create users by stable Google subject identifier.
- [ ] Implement Sanctum application tokens/session flow.
- [ ] Implement login, `GET /api/v1/me`, logout/revocation and role middleware/policies.
- [ ] Roles: `CUSTOMER`, `DELIVERY_PARTNER`, `ADMIN`; no Restaurant Partner scope.
- [ ] Provision/approve delivery partners and admins server-side only.
- [ ] Enforce resource ownership.
- [ ] Add invalid credential, inactive account, token revocation, role escalation and cross-user access tests.

**Milestone:** Google SSO → Laravel verification → MySQL user → application token/session → `/me`.

## Phase 3 — Catalogue

- [ ] Add categories and products migrations/models/validation/resources.
- [ ] Define price, availability/stock and active state.
- [ ] Implement customer catalogue reads.
- [ ] Implement admin category/product CRUD and deactivate/delete policy.
- [ ] Add pagination, search/filter and deterministic seed data.
- [ ] Add validation, inactive-product and admin-only write tests.

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
8. CI dependency blocker identified: Laravel 11 is now outside its security-support window and Composer blocks the affected framework versions.
9. Laravel baseline upgraded to `^13.17`, with PHP `^8.3`, current Sanctum compatibility, PHPUnit 12, Pint 1.27 and Collision 8.9.
10. Laravel-style application config and environment-driven MySQL config added.

### Not yet verified

- Composer dependency installation after the Laravel 13 change.
- PHPUnit execution.
- MySQL migration execution.
- Any real Google credential verification.
- GoDaddy Composer/extensions/database/document-root/SSH capabilities.

## Immediate next task

**Foundation verification:** run the GitHub Actions workflow against the corrected Laravel 13/PHP 8.3 dependency manifest. If dependency installation and the health test pass, proceed immediately to the database foundation for `users`, `addresses`, `categories` and `products`, using `DATABASE.md` as the schema contract.

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
