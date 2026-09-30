# Snap Foodd

Snap Foodd is a food-delivery system with two Flutter clients backed by one Laravel/PHP API and MySQL database.

## Repository layout

```
.
├── mobile_app/       # Consumer + Delivery Partner Flutter mobile application
├── admin_web/        # Separate Flutter Web admin GUI
├── backend/          # Laravel/PHP API and database access layer
├── docs/             # Supporting project documentation
├── design-images/    # Design references
└── *.md              # Product, architecture, API and development documentation
```

## Applications
- **Consumer + Delivery Partner mobile:** `mobile_app/`; Google SSO, catalogue/search, cart, COD checkout, orders, delivery workflow and active tracking.
- **Admin Web:** `admin_web/`; operational GUI for dashboard, catalogue, orders, delivery partners, assignments and invoices.
- **Backend:** `backend/`; Laravel API, authentication, authorization, business rules, database access and invoice generation.
- **Restaurant Partner:** deferred for this release.

## Local development

Mobile:
```sh
cd mobile_app
flutter pub get
flutter analyze
flutter test
flutter run
```

Admin Web:
```sh
cd admin_web
flutter pub get
flutter analyze
flutter test
flutter run -d chrome --dart-define=API_BASE_URL=https://YOUR_API_HOST/api/v1
```

Backend:
```sh
cd backend
composer install
php artisan migrate
php artisan test
```

## Approved technical decisions

| Area | Decision |
|---|---|
| Mobile | Flutter / Dart |
| Admin client | Separate Flutter Web application (`admin_web/`) |
| State + DI | Riverpod 3 for mobile; keep admin dependencies minimal until features are implemented |
| Navigation | go_router where applicable |
| Backend | Laravel / PHP |
| API | REST under `/api/v1` |
| Database | MySQL, accessed only by Laravel |
| Auth | Google OAuth SSO for mobile; admin flow follows documented backend capabilities |
| OTP | Deferred |
| Payments | COD |
| Maps | Google Maps Platform |
| Tracking | Active-trip HTTP updates + polling |
| Hosting | GoDaddy; exact plan must be verified |
| Backend style | Laravel modular monolith |
| WebSockets | Not required for MVP |

## Documentation source of truth
Read before coding:
1. [PRODUCT.md](PRODUCT.md)
2. [ARCHITECTURE.md](ARCHITECTURE.md)
3. [API_CONTRACT.md](API_CONTRACT.md)
4. [DATABASE.md](DATABASE.md)
5. [AUTH.md](AUTH.md)
6. [DELIVERY_TRACKING.md](DELIVERY_TRACKING.md)
7. [ADMIN.md](ADMIN.md)
8. [ADMIN_FLUTTER_WEB_PLAN.md](ADMIN_FLUTTER_WEB_PLAN.md)
9. [DEVELOPMENT.md](DEVELOPMENT.md)
10. [AI_RULES.md](AI_RULES.md)
11. [DESIGN.md](DESIGN.md)
12. [DEVELOPER_1_PLAN.md](DEVELOPER_1_PLAN.md)
13. [DEVELOPER_2_PLAN.md](DEVELOPER_2_PLAN.md)
14. [AIDLC_WORKFLOW.md](AIDLC_WORKFLOW.md)
15. [AI_TASK_BOARD.md](AI_TASK_BOARD.md)
16. [AI_TASK_TEMPLATE.md](AI_TASK_TEMPLATE.md)

## Engineering rules
- Backend is authoritative for business rules and data.
- Flutter widgets do not own API calls, pricing or workflow decisions.
- Never trust client role, price, availability, total, payment state or order status.
- Both clients use documented Laravel APIs; no client directly accesses MySQL.
- Keep secrets out of Flutter/browser bundles and Git.
- Preserve existing mobile UI unless a design change is explicitly requested.
- Loading, empty, error and degraded-network states are part of completion.
- Update docs/tests when architecture, API, schema or workflow changes.

## Implementation order
1. Verify GoDaddy/static web hosting, HTTPS, domain and CORS capabilities.
2. Keep the existing Laravel API and mobile client stable; verify current integration.
3. Set up the separate `admin_web/` Flutter Web project and CI.
4. Implement admin auth/session and API client against existing backend capabilities.
5. Implement dashboard, catalogue, order operations, delivery partner operations and invoices.
6. Verify role enforcement, CORS, browser refresh/deep links and end-to-end workflows.
7. Retire Laravel Blade admin only after the Flutter Web replacement is accepted.
8. Complete security/integration/device and release testing.
