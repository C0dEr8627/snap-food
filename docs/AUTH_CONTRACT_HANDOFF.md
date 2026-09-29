# Auth Contract Handoff — Flutter

## Purpose

This document records the exact information Flutter needs before Google SSO can be implemented against Laravel. It intentionally does not invent field names or response envelopes.

## Backend contract to confirm

`POST /api/v1/auth/google` must document:

1. Authentication/transport requirements.
2. The request JSON shape and the exact field containing the Google credential.
3. Whether the credential is an ID token, authorization code, access token, or another provider artifact.
4. The successful HTTP status.
5. The successful JSON response shape.
6. The exact application session/token field name and token type.
7. Whether the response includes the authenticated user and its shape.
8. Validation/error status codes and JSON error shape.
9. Behavior for cancelled/invalid Google credentials and inactive/unapproved accounts.
10. Logout semantics for `POST /api/v1/auth/logout` and whether the client must send/revoke anything beyond the application session token.

## Flutter implementation already ready

- `SessionStore` securely persists the application token.
- `ApiClient` can attach the stored token as a bearer credential.
- `AuthRepository` can hydrate `/me` and clear the session on logout.
- `AuthController` can transition between signed-out, authenticated, loading and failure states.
- Controller tests cover restoration, expired session cleanup and logout.

## Remaining implementation after contract freeze

- Add the approved public Google sign-in package/configuration.
- Obtain the provider credential through a platform adapter.
- Send exactly the documented request to `/auth/google`.
- Parse exactly the documented successful response.
- Store the returned application token through `SessionStore`.
- Hydrate the user through `/me`.
- Connect auth state to go_router redirects while keeping route guards UX-only.
- Add tests for cancellation, invalid credentials, network failure and successful login.

## Do not do

- Do not guess the request field name.
- Do not guess the token field or response envelope.
- Do not store Google credentials as the application's long-lived session.
- Do not embed Google OAuth secrets.
- Do not mark the Google SSO milestone complete until Laravel verification and Flutter session establishment are exercised end-to-end.