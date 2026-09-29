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
- go_router redirects are wired to the Riverpod auth state.

## Current cross-branch checkpoint — 2026-09-29

Developer 1's branch has documented post-#179 fixes:
- `bf2febe67ee45507886be50aca809e7c0bca9f23` updates the stale order status-history table assertion.
- `a0f9b47f70df16871ea4da82a50ebf5640b1582b` wraps the customer order list in the established `data` response envelope.
- `cf5236d87a7c2ad00be965a89ce94a5cd72a566b` restricts customer order routes with `role:CUSTOMER`.
- `a1fcc5c920db6e4de71a53e294f3d71df95ad9b0` documents those Phase 4 corrections.

Workflow #146 passed the corrected Phase 2/3 authentication/authorization and catalogue slice on PHP 8.3 with MySQL. Workflow #179 failed the earlier Phase 4 state. No fresh green Phase 4 workflow has been verified from this Flutter checkpoint, so Flutter does not treat the order/COD slice as integration-ready yet.

The shared `API_CONTRACT.md` / `AUTH.md` still do not freeze the exact `/auth/google` credential field/type, successful application-token response shape, public Google client configuration, role response shape, or successful catalogue field schema.

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
- Do not mark the Google SSO integration complete until Flutter provider login, Laravel verification and Flutter session establishment are exercised end-to-end.
