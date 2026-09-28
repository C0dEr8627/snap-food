# Snap Foodd — AI Development Rules

This repository is documented so AI agents do not invent a parallel architecture.

## Before coding
Read `README.md`, `PRODUCT.md`, `ARCHITECTURE.md` and relevant feature docs. For API work read `API_CONTRACT.md`; data `DATABASE.md`; auth `AUTH.md`; tracking `DELIVERY_TRACKING.md`.

## Approved stack
Flutter/Dart, Riverpod 3, go_router, Laravel/PHP, MySQL, Google OAuth, Google Maps and GoDaddy subject to verification. Do not introduce Firebase, Supabase or another backend/database without an explicit architecture decision.

## Rules
- Verify actual GoDaddy capabilities before relying on SSH, Composer, cron, queues, workers, WebSockets or PHP extensions.
- Never trust Flutter for role, price, availability, total, delivery fee, payment state, order status, assignment or delivery completion.
- Do not build deferred OTP, restaurant workflow, online payments, background GPS, geofencing, advanced notifications/recommendations or complex analytics unless explicitly requested.
- Preserve existing UI when integrating APIs; replace mocks behind existing abstractions rather than redesigning screens.
- Make the smallest correct change; reuse abstractions; add/update tests; update docs when contracts/architecture change; avoid unrelated rewrites.
- API changes document method/path, auth, authorization, request/response, errors, side effects and concurrency/idempotency.
- Database changes use Laravel migrations and document transitions, keys, indexes, transactions and historical snapshots.
- Never commit secrets, OAuth credentials, production env files or access tokens; never log tokens/sensitive customer data.
- Prioritize tests for authz, pricing, order transitions, assignment conflicts and tracking access.

## Git
Use focused commits such as `docs: update API contract`, `feat(auth): add Google sign-in`, `feat(orders): create COD order flow`, `feat(delivery): add active tracking`, `fix(profile): restore order navigation`, `test(orders): cover state transitions`.

## Uncertainty
Inspect existing evidence first. Take the smallest reversible change when safe; otherwise ask for the missing decision. Never silently guess a business rule or hosting capability.
