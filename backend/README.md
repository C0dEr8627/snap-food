# Snap Foodd Backend

Laravel API and admin application for Snap Foodd.

## Target runtime

The production server target is **PHP 8.3**. The backend dependency baseline therefore uses Laravel 11, which supports PHP 8.2+ and is compatible with PHP 8.3.

`backend/composer.json` also pins Composer dependency resolution to PHP `8.3.0` through Composer's platform configuration. This prevents development dependency resolution from selecting packages that require a newer PHP runtime than the GoDaddy target.

## Current foundation

- Laravel 11 application structure is established under `backend/`.
- API routes are versioned under `/api/v1`.
- `GET /api/v1/health` provides a non-sensitive health response.
- PHPUnit 11 feature-test configuration includes the health endpoint test.
- CI runs the backend with PHP 8.3 and required PDO/MySQL extensions.
- Sanctum is included as the planned application-token mechanism; authentication implementation is a later task.
- MySQL remains the authoritative production database.
- No production credentials or `.env` files are committed.

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

The isolated agent execution container currently has PHP 8.4.23, but it does not have Composer or the MySQL CLI. Those limitations mean the Laravel dependency install, migrations, and PHPUnit suite cannot be claimed as locally executed here.

The target server information supplied by the project owner is PHP 8.3. Hosting capabilities beyond PHP version—Composer availability, required PHP extensions, database access, document root/public directory configuration, SSH/cron/queue support—still need verification on the actual GoDaddy plan before deployment.

## Hosting safety

Do not point development tests at production. Use a separate non-production MySQL database. Never commit OAuth credentials, database passwords, application keys, access tokens, or customer data.

## Next implementation slice

After the foundation is installed in an environment with Composer, implement the MySQL migrations/models for users, addresses, categories and products, then add the corresponding validation and tests. Authentication remains gated on verified Google credential handling and the selected Sanctum flow.
