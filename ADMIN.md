# Snap Foodd — Admin Flutter Web

The target admin GUI is a separate Flutter Web application in `admin_web/`. It calls the shared Laravel/PHP backend and has no independent backend or direct database connection.

## MVP
- **Dashboard:** new/active/preparing/awaiting-delivery/active-delivery counts.
- **Catalogue:** category/product CRUD, price and availability, supported images.
- **Orders:** search/filter, detail, status, COD state, delivery assignment and invoices.
- **Delivery partners:** directory, provision/approve, activate/deactivate, availability, active assignment and basic history.
- **Invoices:** view delivered-order invoice snapshots.

## Boundaries
- The root Flutter project remains the consumer + delivery-partner mobile app.
- Laravel/PHP remains the source of truth for authentication, authorization, validation, pricing, order processing, assignment, tracking and invoices.
- The browser app uses documented `/api/v1` endpoints and the approved authentication mechanism. It must never connect to MySQL or contain server secrets.
- Admin access must be checked by Laravel on every protected operation. Route guards and hidden controls are UX only, not security.
- Do not remove the existing Laravel Blade dashboard during initial setup. Retire it only after the Flutter Web replacement is feature-complete and verified.

## Initial setup status
- [x] Architecture decision recorded: two Flutter apps, one Laravel backend.
- [x] Separate `admin_web/` Flutter Web scaffold created.
- [ ] Configure and verify admin authentication against backend capabilities.
- [ ] Implement shared HTTP/API error handling and admin route protection.
- [ ] Implement dashboard, catalogue, orders, delivery partners and invoices incrementally.
- [ ] Add browser/widget tests and a separate Flutter Web CI/build gate.
- [ ] Verify CORS, HTTPS, hosting, refresh/deep-link behavior and end-to-end admin operations.

See `ADMIN_FLUTTER_WEB_PLAN.md` for the setup and implementation sequence.
