# Snap Foodd

Snap Foodd is a food-delivery system for V1 with consumer, delivery-partner and admin Flutter clients backed by one Laravel/PHP API and MySQL database.

## V1 hosting and system plan

GoDaddy cPanel is the planned V1 hosting environment.

1. **Laravel/PHP APIs:** hosted on GoDaddy cPanel over HTTPS.
2. **Admin Flutter Web:** hosted on GoDaddy cPanel.
3. **Consumer + Delivery Partner:** the existing Flutter mobile application connects to the GoDaddy-hosted PHP APIs; after mobile/API integration, the consumer + delivery-partner Flutter Web application will also be hosted on GoDaddy cPanel.
4. **Database boundary:** MySQL is accessed **only by Laravel/PHP**. No Flutter application, browser client or other component connects directly to MySQL.

This is the complete V1 deployment direction. The current modularization is intended to preserve separation of concerns while reusing the implementation already completed.

## V1 target

**Delivery target: 3 October 2026.**

Prioritize integration, deployment readiness, security and end-to-end verification over unnecessary rewrites.

## Repository layout

- mobile_app/ — consumer + delivery-partner Flutter client for mobile and planned Web deployment.
- admin_web/ — separate Flutter Web admin GUI.
- backend/ — Laravel/PHP API and sole database access layer.

## Non-negotiable engineering rules

- Laravel is authoritative for business rules and data.
- Flutter clients are API clients, never database clients.
- Only the backend may contain database credentials.
- No Flutter/browser bundle may contain database credentials or server secrets.
- All clients communicate with the backend through documented HTTPS /api/v1 APIs.
- Server-side authorization is mandatory; client role/status/price/total values are never trusted.
- Keep Laravel Blade admin until Flutter Web admin reaches feature parity and acceptance.

## GoDaddy verification checklist

Before production deployment, verify the exact cPanel plan for PHP 8.3, required extensions, MySQL, Composer/deployment workflow, document roots, HTTPS, CORS, storage permissions and SSH/cron limitations.

## V1 implementation order

1. Verify GoDaddy cPanel capabilities.
2. Deploy and verify Laravel/PHP API and MySQL boundary.
3. Connect and verify the Flutter mobile application against the hosted API.
4. Complete and deploy the Flutter Web admin against the hosted API.
5. Complete and deploy the consumer + delivery-partner Flutter Web application.
6. Verify authentication, authorization, CORS, HTTPS, refresh/deep links and end-to-end workflows.
7. Perform final security, device/browser and release verification.
