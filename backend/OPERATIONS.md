# Backend Operations Checklist

This document is a pre-deployment checklist, not evidence that production hosting or backups have been configured. Confirm the exact GoDaddy plan and approved operational access before using any command below.

## Hosting readiness (must be verified)

- [ ] PHP 8.3 is selected for the application and required extensions are available: PDO MySQL, OpenSSL, Mbstring, Tokenizer, XML, Ctype, JSON, BCMath, Fileinfo, and cURL.
- [ ] Composer 2 can install the locked production dependencies, or a documented build artifact workflow is approved.
- [ ] MySQL version, database/user provisioning, TLS requirements, connection limits and backup options are confirmed.
- [ ] Web document root points to Laravel's public/ directory; .env, vendor/, source files and storage are not publicly served.
- [ ] storage/ and bootstrap/cache/ are writable by the runtime user, with least-privilege filesystem permissions.
- [ ] HTTPS, canonical application URL, Google OAuth client ID and OAuth redirect/origin configuration are confirmed.
- [ ] APP_DEBUG=false, APP_ENV=production, a unique APP_KEY, strong DB credentials and production-only OAuth configuration are set outside version control.
- [ ] Required cache/session drivers and rate-limit behavior are supported by the selected hosting plan.
- [ ] SSH, scheduled tasks, workers and cron are not assumed; verify each before depending on it.
- [ ] A deployment/rollback owner, maintenance window, monitoring and incident contact are documented.

## Database migration and seed policy

- CI verifies migrations against a newly provisioned MySQL test database. Before a release, repeat the migration check on a disposable staging database using the exact deployment artifact.
- Review every pending migration for lock duration, foreign keys, indexes, rollback behavior and backward compatibility.
- Demo seed data is for local/CI use only. Do not run development/demo seeders against production.
- Production schema migrations must be approved by the repository owner and run with a verified backup and rollback plan. Never run destructive migrations automatically as part of deployment.

## Backup procedure (when supported by the host)

1. Confirm the hosting plan's approved database export/backup mechanism and where backups may be stored.
2. Create a timestamped, encrypted MySQL logical backup using a dedicated least-privilege account. Prefer an interactive password prompt or a protected client option file rather than putting credentials in shell history.
3. Example for an authorized environment with MySQL client tools installed:

   ```bash
   mysqldump --single-transaction --routines --triggers --user=BACKUP_USER --host=DB_HOST --password DB_NAME > snap-foodd-YYYYMMDD-HHMMSS.sql
   ```

   The client prompts for the password. Treat the resulting SQL file as sensitive data; encrypt it, restrict access, and do not commit or attach it to issue/PR threads.
4. Record backup time, database/schema version, artifact checksum, storage location, retention expiry and responsible operator. Keep backup storage separate from the web document root.
5. Confirm backup completion through the host's actual logs or control panel. Do not claim success solely because a command was started.

## Restore drill

1. Select a disposable, isolated non-production MySQL database. Never test restore by overwriting production.
2. Restore an encrypted copy using the host-approved process. If command-line access is supported:

   ```bash
   mysql --user=RESTORE_USER --host=DB_HOST --password RESTORE_DATABASE < snap-foodd-YYYYMMDD-HHMMSS.sql
   ```

3. Run migration status, application health checks, and targeted integrity checks for users, categories, products, orders, assignments, status history and invoices.
4. Verify that immutable order/invoice snapshots and invoice numbers remain intact, then run the relevant automated tests against the restored copy where practical.
5. Document elapsed restore time, errors, data-loss window, corrective actions and the next drill date. Remove temporary copies securely after approval.

## Release verification

- [ ] Fresh dependency install from lock file succeeds on PHP 8.3.
- [ ] Migrations run from an empty staging MySQL database.
- [ ] Tests pass on the release candidate.
- [ ] Pint formatting check and any configured static/security checks have been run; record actual outcomes.
- [ ] No real .env, OAuth secret, DB password, application key, access token, production data dump or customer data is tracked.
- [ ] API contract, auth/authorization behavior, delivery state transitions, assignment conflicts and invoice snapshots have been reviewed.
- [ ] Backup exists and a restore drill has been completed for the target environment.
- [ ] GoDaddy-specific document-root, storage, HTTPS, database and runtime capabilities have been verified.
- [ ] Production deployment has explicit human approval and a rollback plan.

**Current limitation:** GoDaddy plan-specific capabilities are unverified. This document defines what to check; it does not authorize deployment or assert that backups, monitoring, or production infrastructure exist.
