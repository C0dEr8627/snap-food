# Snap Foodd Backend

Laravel API and protected admin dashboard for Snap Foodd. This directory is the backend boundary; Flutter-owned files remain at the repository root and under `lib/`.

## Toolchain status

No Laravel application, `composer.json`, PHP test configuration, or backend source existed in the repository when this baseline was inspected. Exact supported versions must be selected only after checking the available local toolchain and the target GoDaddy plan.

| Component | Current requirement/status |
|---|---|
| PHP | Version not yet verified; select a Laravel-supported version after toolchain/hosting discovery |
| Composer | Availability/version not yet verified |
| Laravel | Not installed; choose a version compatible with verified PHP and hosting |
| MySQL | MySQL-compatible database required; server version not yet verified |
| HTTPS/domain | Hosting details not yet supplied |
| Extensions | Verify Laravel-required PHP extensions against the chosen Laravel version and hosting plan |

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

**Current blocker:** hosting account/plan details and a local PHP/Composer toolchain have not been provided, so capabilities and supported versions cannot yet be confirmed. Keep development portable and do not deploy.

## Local setup (after Laravel scaffold is added)

1. Install a PHP version supported by the selected Laravel release and the required extensions.
2. Install Composer.
3. Copy `.env.example` to `.env` and set local-only values.
4. Create a dedicated, non-production MySQL database and user.
5. From this directory, run `composer install`, `php artisan key:generate`, `php artisan migrate`, and `php artisan test` when the corresponding Laravel files exist.
6. Never point local tests or migrations at production.

Commands above are setup guidance, not commands executed as part of this repository inspection. Update this document with exact version requirements and verified command results once the toolchain and Laravel scaffold are available.
