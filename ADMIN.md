# Snap Foodd — Admin Flutter Web

The target admin GUI is a separate Flutter Web application in admin_web/. It calls the shared Laravel/PHP backend and has no independent backend or direct database connection.

## V1 deployment

The admin Flutter Web build will be hosted on GoDaddy cPanel. The browser communicates only with the Laravel/PHP API over HTTPS.

## Boundaries

- Laravel/PHP is the source of truth for authentication, authorization, validation, pricing, orders, assignment, tracking and invoices.
- The browser uses documented /api/v1 endpoints and the approved authentication mechanism.
- The browser must never connect to MySQL or contain server secrets.
- Admin authorization is enforced by Laravel on every protected operation.
- Keep the existing Laravel Blade dashboard until Flutter Web feature parity and release acceptance are documented.

## V1 acceptance

Verify API connectivity, authentication/session behavior, CORS, HTTPS, browser refresh/deep links, responsive behavior and all protected admin operations before production release.
