# Snap Foodd Backend

Laravel API and protected admin dashboard for Snap Foodd. This directory is the backend boundary; Flutter-owned files remain at the repository root and under `lib/`.

## Toolchain status

The repository currently has no Laravel application, `composer.json`, PHP test configuration, or backend source. A check of the isolated execution container on 2026-09-29 found PHP CLI 8.4.23, but Composer and the MySQL CLI are not installed. This is only the agent's execution environment; it does not verify the developer's machine or the GoDaddy hosting plan. No database server or non-production connection has been verified.

| Component | Current requirement/status |
|---|---|
| PHP | Agent container: 8.4.23 CLI; developer machine and hosting version not verified. Choose a Laravel-supported version after checking both. |
| Composer | Not installed in agent container; developer machine/hosting availability not verified. |
| Laravel | Not installed; choose a version compatible with verified PHP and hosting. |
| MySQL | MySQL-compatible database required; no MySQL CLI/server connection verified. |
| HTTPS/domain | Hosting details not yet supplied. |
| Extensions | Verify Laravel-required PHP extensions against the chosen Laravel version and hosting plan. |

Do not treat unknown capabilities as available. In particular, SSH, Composer on-host, cron, queue workers, WebSockets, writable storage, and document-root control are unverified.

## GoDaddy hosting discovery checklist

Complete this checklist against the exact hosting plan and account before choosing a deployment procedure. Do not put credentials or account identifiers in this file.

- [ ] Hosting product/plan and limits identified
- [ ] Supported PHP version and selectable PHP configuration verified
- [ ] Required PHP extensions verified
- [ ] MySQL version, database creation and remote/local connection constraints verified
- [ ] HTTPS and intended API/admin domain or subdomain verified
- [ ] SSH access verified
- [ ] Composer availability (or safe build-artifact deployment path) verified
- [ ] Document-root/public-directory control verified
- [ ] Laravel storage/cache write permissions verified
- [ ] Cron availability and minimum interval verified
- [ ] Queue/background worker/process limits verified
- [ ] Deployment, rollback and backup/restore method documented

**Current blocker:** the exact developer toolchain, a non-production MySQL database and hosting account/plan details have not been provided or verified. Keep development portable and do not deploy. The current execution container is insufficient to install dependencies or validate a Laravel/MySQL boot sequence as-is.

## Local setup (after Laravel scaffold is added)

1. Install a PHP version supported by the selected Laravel release and the required extensions.
2. Install Composer.
3. Copy `.env.example` to `.env` and set local-only values.
4. Create a dedicated, non-production MySQL database and user.
5. From this directory, run `composer install`, `php artisan key:generate`, `php artisan migrate`, and `php artisan test` when the corresponding Laravel files exist.
6. Never point local tests or migrations at production.

Commands above are setup guidance, not commands executed as part of this repository inspection. Update this document with exact version requirements and verified command results once the toolchain and database are available.
