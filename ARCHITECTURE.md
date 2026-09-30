# Snap Foodd — Technical Architecture

## System boundary

\`\`\`
Consumer + Delivery Partner Flutter (mobile) ──┐
                                               ├── HTTPS/JSON ── Laravel/PHP API ── MySQL
Admin Flutter Web (browser) ───────────────────┘                       │
                                                                       ├── Google OAuth verification
                                                                       └── Google Maps integrations
\`\`\`

There are two Flutter applications and one backend:
1. The existing root Flutter project is the consumer + delivery-partner mobile application.
2. \`admin_web/\` is a separate Flutter Web application for the admin GUI.
3. \`backend/\` is the shared Laravel/PHP API and the only application that accesses MySQL.

Existing Laravel Blade admin pages may remain during migration, but they are not the target admin client. Do not remove them until the Flutter Web replacement covers required operations and passes integration/security verification. The MVP does not require Firebase, Supabase or WebSockets.

## Core principles
1. Backend is authoritative for data, workflows and business rules.
2. Both Flutter applications are API clients, not sources of truth.
3. Feature-first organization and repository boundaries isolate UI from transport.
4. Thin controllers; business operations in Laravel services/use cases.
5. Server-side authorization is the security boundary; hiding UI is not authorization.
6. Transactions protect checkout and delivery assignment.
7. External integrations use adapters/services.
8. Prefer simple infrastructure until measured needs justify complexity.
9. Architecture, API, schema and workflow changes update docs and tests.

## Flutter mobile application
The root Flutter project owns the consumer and delivery-partner experience:
\`\`\`
Widget/Screen → Riverpod Controller/ViewModel → Repository → API Client → Laravel
\`\`\`
Recommended feature areas include auth, customer catalogue/cart/checkout/orders/tracking/profile, and delivery assignments/active delivery/navigation/tracking/history. Use Riverpod 3 and go_router. Keep secure storage, GPS and maps behind adapters.

## Flutter Web admin application
Project path: \`admin_web/\`. It is a separate Flutter application with its own \`pubspec.yaml\`, entrypoint, tests, build output and CI job. It must not import mobile platform-specific code.

Initial boundaries:
- \`lib/app/\`: app shell, route table and role-aware session guard.
- \`lib/core/api/\`: base URL configuration, HTTP client, auth headers and normalized errors.
- \`lib/features/auth/\`: admin sign-in/session lifecycle.
- \`lib/features/dashboard/\`: operational counts.
- \`lib/features/catalogue/\`: category/product management.
- \`lib/features/orders/\`: order search/detail/status and assignment.
- \`lib/features/delivery_partners/\`: partner directory, approval and availability.
- \`lib/features/invoices/\`: invoice access.

The initial scaffold is deliberately minimal. Build feature-by-feature against \`API_CONTRACT.md\` and existing backend authentication capabilities; do not invent endpoints or payloads.

## Laravel
Modules: Identity & access, Catalogue, Orders, Delivery, Tracking, Invoices and Admin.

Suggested boundaries:
\`\`\`
app/Http/Controllers/Api/V1/
app/Http/Requests/
app/Http/Resources/
app/Models/
app/Policies/
app/Services/{Auth,Catalogue,Orders,Delivery,Tracking,Invoices}/
app/Enums/
\`\`\`
Controllers validate/delegate/serialize. Services implement business operations. Policies enforce authorization.

## API and authentication
All API routes use \`/api/v1\`. Both Flutter apps use HTTPS/JSON and the same documented contract. Mobile users use Google OAuth → Laravel verification → application token → secure storage → \`/me\`. The admin web client must use the approved admin authentication flow; do not expose server secrets in browser code. Roles: CUSTOMER, DELIVERY_PARTNER, ADMIN. Clients cannot self-elevate roles.

## Business authority
Laravel owns product price, availability, delivery fee, order total, payment state, order status, delivery assignment and completion. Client totals are never authoritative. MySQL is accessed only by Laravel.

## Tracking and hosting
Only an authorized delivery partner on an active assignment may submit GPS. MVP uses HTTPS location updates and customer polling. Verify the exact GoDaddy plan before relying on SSH, cron, queues, workers, WebSockets or special PHP extensions. Confirm static Flutter Web hosting and API CORS/HTTPS configuration before deployment.

## Security baseline
HTTPS, server-side secrets, secure mobile session storage, safe browser session/token handling, validation, rate limiting, authorization tests, no credential logging and transactions for critical workflows.
