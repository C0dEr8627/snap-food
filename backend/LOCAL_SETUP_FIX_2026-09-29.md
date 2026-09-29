# Local Laravel cache-table fix — 2026-09-29

## Issue
Local admin Google SSO completed successfully, but the Laravel request failed because the configured database cache store queried `snap_foodd_local.cache`, while the local database had no `cache` table.

`php artisan migrate` reported `Nothing to migrate`, confirming the repository was missing the cache/cache-lock migration.

## Fix
Added:

`backend/database/migrations/2026_09_29_000000_create_cache_table.php`

The migration creates the standard Laravel database cache tables:

- `cache`
- `cache_locks`

Both tables are reversible through the migration's `down()` method.

## Commit
`910919211f41b84028dc4ee6b263912e5d66beb0`

Message: `fix(backend): add database cache tables`

## Local verification
After pulling this commit:

```bash
git pull
php artisan migrate
php artisan optimize:clear
php artisan serve
```

Expected migration result: the new cache/cache-lock tables are created. `php artisan optimize:clear` should then be able to clear the database cache without the missing-table exception.

## Release safety
This is a schema migration for local/deployed application environments. No production migration was run by this task. Do not run migrations against production/GoDaddy until explicit release approval is given.
