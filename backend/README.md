# Snap Foodd Backend

Laravel API and admin application for Snap Foodd.

## Target runtime

The production server target is **PHP 8.3**.

The backend now targets **Laravel 13** because Laravel 11 reached the end of its security-fix window on March 12, 2026. Laravel 13 requires PHP 8.3, matching the production runtime target.

`backend/composer.json` also pins Composer dependency resolution to PHP `8.3.0` so development dependency resolution cannot select packages requiring a newer PHP runtime than the GoDaddy target.

## Current foundation status

- Laravel 13 application structure is established under `backend/`.
- API routes are versioned under `/api/v1`.
- `GET /api/v1/health` provides a non-sensitive health response.
- PHPUnit 12 configuration includes the health endpoint feature test.
- CI runs the backend with PHP 8.3 and required PDO/MySQL extensions.
- Sanctum 4.x is included for the planned application-token flow; authentication implementation is a later task.
- Environment-driven MySQL configuration is present at `backend/config/database.php`.
- MySQL remains the authoritative production database.
- No production credentials or `.env` files are committed.

## Progress tracking

The authoritative implementation checklist is `DEVELOPER_1_PLAN.md`. It contains:

- a phase-by-phase progress dashboard;
- completed and pending tasks;
- current CI/runtime blockers;
- the immediate next task;
- the required end-of-task reporting format.

Current phase: **Phase 2 — Identity & authorization (not started); Phase 1 foundation is complete.**

Latest foundation CI verification: workflow #30 successfully completed PHP 8.3 setup, dependency installation and `composer test`. The health test and PHPUnit suite now pass. The branch also contains the initial `users`, `addresses`, `categories` and `products` schema/models plus a MySQL-backed CI migration check; that new database slice is awaiting its first workflow run.

Immediate next task: verify the new MySQL-backed migration workflow, then add model relationship/validation coverage. Authentication remains the next major phase after the database foundation.

## Local setup

From `backend/`:

1. Ensure PHP 8.3 and Composer 2 are installed.
2. Copy `.env.example` to `.env`.
3. Run `composer install`.
4. Run `php artisan key:generate`.
5. Configure a non-production MySQL database in `.env`.
6. Run `php artisan migrate`.
7. Run `composer test`.
8. Run `composer format` before committing PHP changes.

## Environment verification

The isolated agent execution container currently has PHP 8.4.23, but it does not have Composer or the MySQL CLI. Those limitations mean Laravel dependency installation, migrations and PHPUnit cannot be claimed as locally executed here.

GitHub Actions has verified PHP 8.3.35, the requested PHP extensions and Composer 2.10.3, and the Laravel 13 dependency set now installs successfully. Workflow #26 verified dependency installation and reached PHPUnit, but failed because `backend/tests/Unit` was absent. That directory is now preserved in Git. The next CI run must verify the health test.

The target server information supplied by the project owner is PHP 8.3. Hosting capabilities beyond PHP version—Composer availability, required PHP extensions, database access, document root/public directory configuration, SSH/cron/queue support—still need verification on the actual GoDaddy plan before deployment.

## Hosting safety

Do not point development tests at production. Use a separate non-production MySQL database. Never commit OAuth credentials, database passwords, application keys, access tokens, or customer data.

## Next implementation slice

Verify the MySQL-backed migrations and `DatabaseSchemaTest` in CI. Then add relationship/validation coverage for users, addresses, categories and products. Authentication remains gated on verified Google credential handling and the selected Sanctum flow.
