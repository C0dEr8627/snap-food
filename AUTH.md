# Snap Foodd — Authentication & Authorization

## Decision
**Google OAuth SSO.** OTP is deferred. Firebase/Supabase are not used.

## Flow
Flutter starts Google sign-in → sends Google credential to Laravel over HTTPS → Laravel verifies it → finds/creates user by stable provider subject → issues application session/token → Flutter stores it securely → Flutter calls `GET /api/v1/me`.

## Roles
`CUSTOMER`, `DELIVERY_PARTNER`, `ADMIN`. Restaurant is deferred. Delivery Partner/Admin access is provisioned server-side; clients cannot elevate roles.

## Authorization
Laravel enforces identity, role, resource ownership, assignment ownership, account status and valid workflow transitions. Flutter route guards are UX only.

## Security
Use the Laravel session/token mechanism selected during backend setup. Never commit OAuth secrets, DB credentials, access tokens or production env files. Never log credentials or sensitive customer data.

Admin web uses a separate protected Laravel web session.

## Tests
Invalid/expired Google credential, cancelled sign-in, inactive account, unapproved partner, expired session, logout and network failure.
