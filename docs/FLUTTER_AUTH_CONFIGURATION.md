# Flutter Authentication Configuration

## Implemented

- Application session tokens are isolated behind `SessionStore`.
- `SecureSessionStore` uses `flutter_secure_storage`.
- `AuthController` restores a stored token by calling `GET /api/v1/me`.
- HTTP authentication headers are supplied centrally by `ApiClient`.
- A `401` during startup session restoration clears the stored token and returns the app to signed-out state.
- Logout calls `POST /api/v1/auth/logout` and clears local session state in a `finally` block.

## Contract boundary

`AUTH.md` defines Google OAuth SSO but does not define the exact successful `/auth/google` request payload, successful response envelope, token field name, token type, or Google credential field expected by Laravel.

The Flutter implementation therefore does **not** invent those fields. Google sign-in credential exchange remains the next integration step after the backend contract is made explicit.

## Security

- Never commit OAuth client secrets, application tokens, production environment files or database credentials.
- Session tokens are not stored in ordinary preferences.
- Do not log credentials or authenticated response payloads.
- Route guards must remain UX only; Laravel remains authoritative for identity and role authorization.