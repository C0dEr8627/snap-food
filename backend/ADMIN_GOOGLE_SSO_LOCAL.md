# Admin Google SSO — Local Verification

## Purpose

The Laravel admin login now uses Google Identity Services (GIS) in the browser. The existing server-side Google credential verifier remains the authority: the browser receives a Google ID-token credential and submits it to the existing `POST /admin/login` endpoint.

## Local setup

1. Configure the local backend `.env`:

```env
GOOGLE_CLIENT_ID=<Google Web OAuth client ID>
```

2. Clear/rebuild Laravel configuration:

```bash
php artisan config:clear
php artisan config:cache
```

3. In Google Cloud, configure the Web OAuth client with these authorized JavaScript origins:

- `http://127.0.0.1:8000`
- `http://localhost:8000`

4. Ensure the Google account used for testing is allowed by the OAuth consent configuration and already exists in the local database as an active ADMIN user with a matching `google_subject`.

5. Start Laravel:

```bash
php artisan serve
```

6. Open:

```text
http://127.0.0.1:8000/admin/login
```

7. Click the Google sign-in button. GIS returns the ID token to the page, and the page submits that token to the existing admin login endpoint.

## Security notes

- The Google Client ID is configuration, not a client secret.
- Do not commit `.env` or any Google client secret.
- Do not bypass server-side token verification.
- Do not add a development-only authentication backdoor.
- The admin controller still checks the Google subject against an active ADMIN user before creating the Laravel web session.
- No Google access token is required for this admin login flow.

## Current implementation

Commit: `75f967dc82d773b5394192703dfc978f6ed26eab`

Changed file:

- `backend/resources/views/admin/auth/login.blade.php`

The page loads Google's official GIS browser library, renders the sign-in button using `config('services.google.client_id')`, stores the returned credential in the existing form field, and submits to the existing `admin.login.store` route.

## Next verification

- Pull the latest `developer-1-backend-admin` branch.
- Restart `php artisan serve`.
- Open the admin login page.
- Complete Google sign-in.
- If the server rejects the credential, capture the Laravel validation/error message without sharing the token itself.
- After successful login, continue local admin dashboard/order/catalogue/delivery testing.

No Flutter-owned files were changed. No deployment or production migration was performed.
