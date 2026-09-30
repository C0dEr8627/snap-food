# Admin Flutter Web — Setup and Implementation Plan

## Decision
- Root Flutter project: consumer + delivery partner mobile app.
- \`admin_web/\`: standalone Flutter Web admin GUI.
- \`backend/\`: Laravel/PHP API and sole database owner.

This plan tracks the new admin-web client only. The scaffold does not mean admin features are complete.

## Phase 0 — Scaffold and independent verification
- [x] Create standalone Flutter project boundary at \`admin_web/\`.
- [x] Add entrypoint, browser HTML shell, dependency manifest and starter widget test.
- [x] Add independent GitHub Actions workflow for formatting, analysis, tests and Web build.
- [x] Document architecture and preserve current Blade dashboard during migration.
- [ ] Verify workflow against current branch head.

## Phase 1 — Admin auth and API foundation
- [ ] Audit current Laravel admin web-session routes and \`/api/v1\` ADMIN bearer-token routes.
- [ ] Confirm browser authentication flow with the project owner based on existing backend capabilities; do not store privileged server secrets in browser code.
- [ ] Implement API transport, normalized errors, timeout handling and safe logging.
- [ ] Implement login/logout/session-expiry UX and route guards.
- [ ] Verify CORS, CSRF/session behavior or bearer-token behavior for the selected flow.

## Phase 2 — Admin operational GUI
- [ ] Dashboard counts.
- [ ] Catalogue categories/products CRUD and validation.
- [ ] Order search, filters, detail and valid status transitions.
- [ ] Delivery-partner directory, approval/activation and assignment.
- [ ] Invoice access for delivered orders.
- [ ] Loading, empty, error, retry and confirmation states.
- [ ] Widget/repository tests using fake transport.

## Phase 3 — Integration and migration
- [ ] Verify every action against the API contract and Laravel authorization.
- [ ] Test refresh/deep-link behavior, browser back navigation, responsive layouts and network failures.
- [ ] Run end-to-end admin operations against a non-production database.
- [ ] Confirm static web hosting, HTTPS, SPA fallback/deep links and API CORS with the selected GoDaddy plan.
- [ ] Keep Blade dashboard available until feature parity and release acceptance are documented.
- [ ] Plan Blade dashboard retirement separately after acceptance.

## Commands
From repository root, once Flutter SDK is installed:
\`\`\`sh
cd admin_web
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter build web --release --dart-define=API_BASE_URL=https://YOUR_API_HOST/api/v1
\`\`\`

Do not put private keys, OAuth client secrets, database credentials or server secrets in \`--dart-define\`; web build values are public to users.
