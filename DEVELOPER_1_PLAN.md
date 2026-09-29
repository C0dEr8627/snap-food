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

## Phase 0 — Inspect and establish the environment

- [x] Inspect repository and existing docs before creating files.
- [x] Record PHP, Composer, Laravel and MySQL requirements/status in `backend/README.md`. Exact versions remain unverified until local toolchain and hosting are known.
- [x] Document the GoDaddy hosting capability checklist in `backend/README.md`.
- [x] Hosting information is unavailable: local/staging setup remains portable and the blocker is recorded; no hosting capability is assumed.
- [x] Create a safe local environment example at `backend/.env.example` with placeholders only.
- [x] Document setup, migration, seed, test and deployment discovery/setup guidance in `backend/README.md`.

**Gate:** NOT YET PASSED. The repository has no Laravel application, Composer manifest or PHP test configuration, and the local PHP/Composer toolchain plus a non-production MySQL database have not been verified. Do not proceed to feature implementation until a Laravel environment can boot and connect to a non-production database.

## Phase 1 — Backend foundation

- [ ] Create Laravel app under `backend/`.
- [ ] Configure environment-based MySQL connection.
- [ ] Configure `/api/v1` routing, JSON error format and validation conventions.
- [ ] Establish migrations, factories/seeders and automated test setup.
- [ ] Add health/readiness endpoint without exposing configuration/secrets.
- [ ] Add request validation, rate limiting where appropriate, logging without credentials and consistent error responses.
- [ ] Document exact supported PHP/Laravel versions after verifying toolchain.

## Phase 2 — Identity and authorization

- [ ] Implement Google credential verification server-side using supported Google verification libraries/APIs.
- [ ] Find/create users using a stable Google subject identifier; do not rely only on mutable email.
- [ ] Choose and document the application-token/session approach compatible with the hosting and Flutter client (evaluate Laravel Sanctum if suitable).
- [ ] Implement login, `GET /api/v1/me`, logout/revocation and role middleware/policies.
- [ ] Roles: `CUSTOMER`, `DELIVERY_PARTNER`, `ADMIN`; no Restaurant Partner scope.
- [ ] Customer accounts may be created through Google sign-in; delivery partner accounts must be provisioned/approved; admin access must never be self-assigned.
- [ ] Enforce resource ownership for addresses, orders, invoices and tracking.
- [ ] Add tests for invalid credentials, inactive/unapproved accounts, token revocation, role escalation and cross-user data access.

**Milestone:** Google SSO → Laravel verification → MySQL user → application session/token → `/me`.

## Phase 3 — Catalogue

- [ ] Add categories and products migrations/models/validation/resources.
- [ ] Define product price, availability/stock and active state.
- [ ] Implement public/authenticated customer reads as agreed in `API_CONTRACT.md`.
- [ ] Implement admin category/product create, update, list, detail and deactivate/delete policy.
- [ ] Add pagination, search/filter and deterministic seed data.
- [ ] Add tests for validation, inactive products and admin-only writes.

**Milestone:** admin creates/updates a product; customer catalogue API returns it.

## Phase 4 — Orders and COD

- [ ] Define allowed order states and transitions from `PRODUCT.md` and `API_CONTRACT.md`.
- [ ] Implement address handling or validated delivery-address snapshots.
- [ ] Accept product IDs and quantities; recalculate price/availability/totals on server.
- [ ] Create order and item price/name snapshots in one database transaction.
- [ ] Persist payment method as COD and initial payment state as pending; do not invent collection reconciliation rules.
- [ ] Add order status history with actor/timestamp.
- [ ] Implement customer list/detail endpoints with ownership checks.
- [ ] Prevent invalid status jumps, duplicate creation where idempotency is needed and access to other customers' orders.
- [ ] Add tests for client price tampering, unavailable products, invalid quantities, rollback, state transitions and ownership.

**Milestone:** Flutter-compatible request creates a real MySQL COD order and customer can retrieve it.

## Phase 5 — Admin operations and delivery assignment

- [ ] Create protected Laravel web login/authorization for admins.
- [ ] Build functional dashboard for products/categories, orders, customers, delivery partners, assignments and invoice access.
- [ ] Implement order list/detail/filter and allowed status actions.
- [ ] Provision/approve/deactivate delivery partners.
- [ ] Implement assignment with transaction/locking or an equivalent concurrency-safe guard against double assignment.
- [ ] Record assignment/status history and actor.
- [ ] Add authorization and race/conflict tests.

## Phase 6 — Delivery APIs and active tracking

- [ ] Implement partner availability and eligible delivery request list.
- [ ] Accept/reject workflow only if approved in contract; enforce one valid assignment per order.
- [ ] Implement pickup confirmation and delivery completion with valid state checks.
- [ ] Implement location update endpoint for the partner's own active assignment only.
- [ ] Validate coordinate ranges, timestamps and payload size; persist latest location and required history.
- [ ] Implement tracking read endpoint with order/customer/assignment authorization.
- [ ] Do not require WebSockets or persistent workers; use HTTP updates + polling for MVP.
- [ ] Add stale-location handling and tracking authorization tests.

## Phase 7 — Invoices

- [ ] Agree invoice numbering and required fields before implementation.
- [ ] Generate invoice from immutable order snapshots.
- [ ] Protect customer invoice access by order ownership; protect admin access by role.
- [ ] Add tests for totals, numbering uniqueness and unauthorized access.

## Phase 8 — Integration and release readiness

- [ ] Provide safe seed/demo data.
- [ ] Maintain API contract examples and a concise integration guide.
- [ ] Run formatter, static analysis where configured, migrations from empty DB and automated tests.
- [ ] Document backup/restore and production environment checklist.
- [ ] Verify no secrets or sensitive data are committed.
- [ ] Produce a PR summary with changed files, commands/tests and known limitations.

## Developer 1 definition of done

A task is complete only when implementation, validation, authorization, automated tests, docs and error behavior agree. No claiming tests passed unless they were actually run. Report blockers explicitly.

## End-of-task report format

- Completed tasks:
- Files changed:
- Migrations:
- API changes:
- Tests run and actual result:
- Security/authorization considerations:
- Remaining blockers:
- Next task:
