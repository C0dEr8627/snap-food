# Flutter Application Audit — Developer 2

**Branch:** `developer-2-flutter`  
**Audit type:** Static repository inspection through the GitHub source tree  
**Execution note:** No local checkout or Flutter/Dart command runner was available during this audit. Test, analyzer, formatter, and build results are therefore **NOT RUN** and are not inferred from source inspection.

## Current application structure

- Entry point: `lib/main.dart` initializes Flutter, applies path URL strategy on web, and starts `SnapFoodApp` in a Riverpod `ProviderScope`.
- App shell/routing: `lib/app/app.dart` defines a Riverpod-provided `GoRouter` and a `MaterialApp.router`.
- Design system: `lib/design_system/theme/app_theme.dart`, with separate components, layout, and token directories.
- Feature screens currently live primarily in presentation-only folders:
  - Customer: splash/welcome, home, search, restaurant menu, food details, cart review, checkout, orders, live order tracking, favorites, profile, settings.
  - Delivery: login/onboarding, requests, duty map, restaurant/customer navigation, pickup verification, delivery verification, earnings history.
  - Restaurant: dashboard, KDS, order detail, menu/stock screens (restaurant partner is deferred in the current release docs).
  - Foundation: preview screen.
- Existing widget coverage: `test/app_smoke_test.dart` exercises the splash/welcome-to-home flow and verifies key text.

## Dependencies and platform configuration

`pubspec.yaml` currently declares Flutter, `flutter_riverpod ^3.0.0`, `go_router ^16.2.0`, and `flutter_svg ^2.2.0`. Flutter test and Flutter lints are configured as dev dependencies.

No declared dependencies were found for HTTP transport, Google sign-in, secure token storage, Google Maps, or device location. No iOS directory was present in the inspected branch. Android uses the standard Flutter launcher icon resource reference and has no location permission declared in the inspected manifest. Add integrations only in the phase that needs them and after confirming the API/session contract and platform requirements.

## Initial screen-to-contract map

| Existing screen/flow | Intended API integration |
|---|---|
| Splash, welcome, customer profile/settings | Auth session restoration, `GET /api/v1/me`, `POST /api/v1/auth/google`, `POST /api/v1/auth/logout` when auth UX is implemented |
| Home, search, restaurant menu, food details | `GET /api/v1/categories`, `GET /api/v1/products`, `GET /api/v1/products/{product}` |
| Cart review, checkout | `POST /api/v1/orders`; server owns prices, fees, availability, and totals |
| Orders, live order tracking | `GET /api/v1/orders`, `GET /api/v1/orders/{order}`, `GET /api/v1/orders/{order}/tracking` |
| Favorites | No favorites endpoint is documented yet; retain isolated temporary behavior until contract is agreed |
| Delivery login/onboarding | Same identity/session flow as `/auth/google` and `/me`; server provisions partner role |
| Delivery requests | `GET /api/v1/delivery/requests` |
| Delivery pickup/completion actions | `POST /api/v1/delivery/assignments/{assignment}/accept`, `/pickup`, and `/complete` |
| Delivery duty map/navigation | Active assignment state plus approved external navigation or a future map adapter; do not imply background GPS |
| Delivery active location | `POST /api/v1/delivery/assignments/{assignment}/location` only during an active trip |
| Delivery earnings/history | No endpoint is documented in the current API contract; isolate mock data until a contract is agreed |
| Restaurant screens | Restaurant Partner is deferred; do not connect these screens to an invented mobile API |

## Architecture observations

- Routing is centralized and currently has no auth/session redirect logic.
- The app uses Riverpod for router dependency injection, but inspected screen organization does not yet show a shared API client or repository/data layer.
- The smoke test is the only test file found in the inspected `test/` directory.
- Preserve the current screen implementation and add the API client/repository layer behind existing UI rather than replacing screens wholesale.
- API contract detail is currently high-level for most endpoints; before end-to-end auth, the backend team needs to settle token/session response shape and Google credential field. Use documented contracts and fakes; do not invent a conflicting payload.

## Baseline verification

| Command | Result |
|---|---|
| `dart format` | **NOT RUN** — no local Dart command runner available |
| `flutter analyze` | **NOT RUN** — no local Flutter command runner available |
| `flutter test` | **NOT RUN** — no local Flutter command runner available |
| `flutter build apk --debug` | **NOT RUN** — no local Flutter/Android build environment available |
| Physical Android device checks | **NOT RUN** — no device connected to this environment |

## Next step

Complete Phase 0 runtime baseline from a local checkout, then start Phase 1 with one configured API client and normalized transport errors. Before auth implementation, coordinate the application token/session response and Google credential field with Developer 1.
