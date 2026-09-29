# Snap Foodd Backend

Laravel API and separate session-authenticated admin dashboard for Snap Foodd.

## Runtime and stack

- PHP target: **8.3**
- Laravel: **13**
- Database: **MySQL**
- API prefix: `/api/v1`
- API auth: Google credential verification + Sanctum tokens
- Admin web auth: Laravel web session; admin role is checked server-side
- Payment scope: COD only
- Tracking: active-trip HTTP location updates + polling; no WebSockets/background GPS requirement

## Current implementation status

The authoritative task checklist is `DEVELOPER_1_PLAN.md`. Client integration examples are in `API_CONTRACT.md` and `backend/API_INTEGRATION.md`; operational release, backup/restore and hosting checks are documented in `backend/OPERATIONS.md`.

- Phase 0: partially verified. GoDaddy plan-specific Composer, extensions, DB access, SSH and document-root capabilities still need confirmation.
- Phase 1: Laravel 13 foundation, MySQL migrations, health endpoint and PHP 8.3 CI are implemented.
- Phase 2: Google credential verification, token lifecycle, role middleware, policies and authorization tests are implemented.
- Phase 3: customer catalogue reads, admin API CRUD, validation and deterministic demo seeding are implemented.
- Phase 4: COD checkout, immutable order snapshots, customer order APIs, server-owned transitions and concurrency-safe assignment are implemented and CI-verified.
- Phase 5: protected admin web login/dashboard, order search/detail/status, catalogue management, customer/partner/assignment/invoice directories, partner approval/availability controls and web/API assignment are implemented and CI-verified.
- Phase 6: partner assignment listing/status progression, active-trip location updates and authorized tracking reads are implemented. The separate accept step is not implemented; pickup and delivery progression use the status endpoint.
- Phase 7: immutable invoice snapshots, deterministic numbering and customer/admin access are implemented.
- Phase 8: in progress. `API_CONTRACT.md` now includes representative request/response/error examples and `backend/API_INTEGRATION.md` describes client token handling, pagination, errors, safe retries and delivery tracking. Final formatter/static/security review, latest CI verification and hosting capability confirmation remain.

## Verification

GitHub Actions runs the backend against PHP 8.3 and MySQL, installs Composer dependencies, runs migrations, and executes PHPUnit.

Recent passing full-suite workflows:
- #349 — dashboard and customer/partner/assignment/invoice directory pages (358 assertions; 82 warnings).
- #363 — protected web catalogue management (375 assertions; 85 warnings).
- #371 — delivery-partner approval/activation/availability web controls (389 assertions; 87 warnings).
- #386 — web delivery assignment and assignment eligibility (402 assertions; 89 warnings).

Warnings are reported by PHPUnit; the workflows completed successfully. See the pull request and `DEVELOPER_1_PLAN.md` for the detailed history and next task.

## Local setup

From `backend/`:

1. Ensure PHP 8.3 and Composer 2 are installed.
2. Copy `.env.example` to `.env`.
3. Run `composer install`.
4. Run `php artisan key:generate`.
5. Configure a dedicated non-production MySQL database.
6. Run `php artisan migrate --seed`.
7. Run `composer test`.
8. Run `composer format` before committing PHP changes.

Do not run tests against production. Use only synthetic/demo data in local and CI environments.

## Environment and hosting verification

The isolated agent environment has PHP 8.4.23 but does not have Composer or the MySQL CLI, so local dependency installation, migrations and PHPUnit are not claimed as executed. GitHub Actions is the verified test environment.

The project owner has specified PHP 8.3 as the production target. Before deployment, verify the exact GoDaddy plan's PHP extensions, Composer availability, database access, public document-root configuration, storage permissions, SSH and cron/worker restrictions. Do not assume queues, background workers, WebSockets or shell access.

## Security and operational notes

- Never commit real OAuth credentials, database passwords, application keys, tokens, production `.env` files or customer data.
- `backend/.env.example` contains placeholders only.
- Keep admin web writes behind `EnsureAdminWebUser`, server-side validation and policies/services.
- Laravel remains authoritative for prices, totals, order status, partner eligibility, assignment, delivery completion and invoice snapshots.
- Assignment uses transactional row locks and marks a successfully assigned delivery partner unavailable.
- Catalogue deactivation is soft; product deactivation also marks the product unavailable.
- No production deployment or infrastructure changes are included in this branch.
