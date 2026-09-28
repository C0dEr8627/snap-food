# Snap Foodd — Technical Architecture

## System boundary
```
Customer Flutter ───────┐
Delivery Flutter ───────┼── HTTPS/JSON ── Laravel API ── MySQL
Admin Web ──────────────┘       │
                                ├── Google OAuth verification
                                └── Google Maps integrations
```
The MVP does not require Firebase, Supabase or WebSockets.

## Core principles
1. Backend is authoritative.
2. Flutter is a client, not a source of truth.
3. Feature-first organization.
4. Repository boundaries isolate UI/application code from transport.
5. Thin controllers; business operations in services/use cases.
6. Server-side authorization is the security boundary.
7. Transactions protect checkout and delivery assignment.
8. External integrations use adapters/services.
9. Prefer simple infrastructure until measured needs justify complexity.
10. Architecture, API, schema and workflow changes update docs and tests.

## Flutter
```
Widget/Screen → Riverpod Controller/ViewModel → Repository → API Client → Laravel
```
Recommended structure:
```
lib/
├── app/
├── core/
├── design_system/
└── features/
    ├── auth/
    ├── customer/{home,search,products,cart,checkout,orders,tracking,profile}/
    └── delivery/{requests,active_delivery,navigation,tracking,history}/
```
Use Riverpod 3 for state/DI and go_router for routing/auth redirects. Keep storage, GPS and maps behind adapters.

## Laravel
Modules:
- Identity & access
- Catalogue
- Orders
- Delivery
- Tracking
- Invoices
- Admin

Suggested boundaries:
```
app/Http/Controllers/Api/V1/
app/Http/Requests/
app/Http/Resources/
app/Models/
app/Policies/
app/Services/{Auth,Catalogue,Orders,Delivery,Tracking,Invoices}/
app/Enums/
```
Controllers validate/delegate/serialize. Services implement business operations. Policies enforce authorization.

## API
All mobile APIs use `/api/v1`. One configured Flutter API client owns base URL, auth, serialization, timeout/cancellation and normalized transport errors.

## Authentication
Flutter → Google OAuth → Laravel verifies credential → find/create user → issue application session/token → secure Flutter storage → `/me`.
Roles: CUSTOMER, DELIVERY_PARTNER, ADMIN. Restaurant is deferred. Clients cannot self-elevate roles.

## Business authority
Laravel owns product price, availability, delivery fee, order total, payment state, order status, delivery assignment and completion. Client totals are never authoritative.

## Tracking
Only an authorized delivery partner on an active assignment may submit GPS. Only authorized customers/operations may read tracking. MVP uses HTTPS location updates and customer polling because GoDaddy capabilities are unknown.

## Hosting constraint
Verify the exact GoDaddy plan before relying on SSH, cron, queues, workers, WebSockets or special PHP extensions.

## Security baseline
HTTPS, server-side secrets, secure client session storage, validation, rate limiting, authorization tests, no credential logging and transactions for critical workflows.
