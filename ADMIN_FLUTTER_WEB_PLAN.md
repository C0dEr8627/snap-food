# Admin Flutter Web — Setup and Implementation Plan

## Decision
- `mobile_app/`: consumer + delivery partner mobile app.
- `admin_web/`: standalone Flutter Web admin GUI.
- `backend/`: Laravel/PHP API and sole database owner.

The admin GUI is a separate client. Current screens use clearly labelled preview/demo data until authentication and API integration are implemented.

## Phase 0 — Scaffold and independent verification
- [x] Create standalone Flutter project boundary at `admin_web/`.
- [x] Add entrypoint, dependency manifest and browser HTML shell.
- [x] Add independent GitHub Actions workflow for formatting, analysis, tests and Web build.
- [ ] Verify workflow against current branch head.

## Phase 1 — Design system and GUI foundation
- [x] Match the mobile app's warm cream canvas, golden-yellow primary accent, food-red secondary accent and rounded cards.
- [x] Add responsive admin shell with desktop sidebar, compact-screen drawer, top bar and preview/API configuration status.
- [x] Add dashboard metrics, weekly sales visualization, operational queue and recent orders.
- [x] Add orders, catalogue, delivery-partner and invoice layouts with illustrative data.
- [x] Add section navigation, order filter chips, catalogue category filter and placeholder action feedback.
- [x] Add widget tests for dashboard rendering, navigation and catalogue preview.
- [ ] Run formatting, analysis, widget tests and Web release build; record actual CI result.

## Phase 2 — Admin auth and API foundation
- [ ] Audit current Laravel admin web-session routes and `/api/v1` ADMIN bearer-token routes.
- [ ] Confirm browser authentication flow with the project owner based on existing backend capabilities; do not store privileged server secrets in browser code.
- [ ] Implement API transport, normalized errors, timeout handling and safe logging.
- [ ] Implement login/logout/session-expiry UX and route guards.
- [ ] Verify CORS, CSRF/session behavior or bearer-token behavior for the selected flow.

## Phase 3 — Operational API integration
- [ ] Replace preview dashboard metrics with live backend data.
- [ ] Connect catalogue categories/products CRUD and validation.
- [ ] Connect order search, filters, detail and valid status transitions.
- [ ] Connect delivery-partner directory, approval/activation and assignment.
- [ ] Connect invoice access for delivered orders.
- [ ] Implement loading, empty, error, retry and confirmation states.
- [ ] Add repository tests using fake transport and authorization/error cases.

## Phase 4 — Integration and migration
- [ ] Verify every action against the API contract and Laravel authorization.
- [ ] Test refresh/deep-link behavior, browser back navigation, responsive layouts and network failures.
- [ ] Run end-to-end admin operations against a non-production database.
- [ ] Confirm static web hosting, HTTPS, SPA fallback/deep links and API CORS with the selected GoDaddy plan.
- [ ] Keep Blade dashboard available until feature parity and release acceptance are documented.
- [ ] Plan Blade dashboard retirement separately after acceptance.

## Commands
```sh
cd admin_web
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter build web --release --dart-define=API_BASE_URL=https://YOUR_API_HOST/api/v1
```

Do not put private keys, OAuth client secrets, database credentials or server secrets in `--dart-define`; web build values are public to users.
