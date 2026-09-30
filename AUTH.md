# Snap Foodd — Authentication & Authorization

## Decision
**Admin authentication: Email/Password + Google OAuth SSO.** OTP is deferred. Firebase/Supabase are not used.

## Flow
Flutter admin starts either Email/Password or Google sign-in → sends credentials to Laravel over HTTPS → Laravel verifies them and enforces `ADMIN` role + active account → issues a Sanctum application token → Flutter stores the token in browser storage → Flutter calls `GET /api/v1/me` before showing the dashboard. Google admin SSO never creates an account; the Google subject must already belong to an authorized admin (with the local-only bootstrap binding documented in the backend).

## Roles
`CUSTOMER`, `DELIVERY_PARTNER`, `ADMIN`. Restaurant is deferred. Delivery Partner/Admin access is provisioned server-side; clients cannot elevate roles.

## Authorization
Laravel enforces identity, role, resource ownership, assignment ownership, account status and valid workflow transitions. Flutter route guards are UX only.

## Security
Use the Laravel session/token mechanism selected during backend setup. Never commit OAuth secrets, DB credentials, access tokens or production env files. Never log credentials or sensitive customer data.

Admin Flutter web uses the protected `/api/v1/auth/admin/*` bearer-token flow. The existing Laravel Blade admin routes continue to use the separate protected `web` session.

## Tests
Invalid/expired Google credential, cancelled sign-in, invalid email/password, unauthorized Google admin, inactive account, expired session, logout and network failure.
