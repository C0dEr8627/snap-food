# Snap Foodd — Architecture

## 1. Purpose

This document defines the production architecture for Snap Foodd, a food-delivery platform targeting **iOS, Android, Windows, macOS, and Web** and designed to scale toward approximately **500,000 simultaneous users**.

The 500,000 figure is a capacity target, not a claim that the first release already sustains that load. Production readiness requires load, soak, failure, and realtime-connection testing against realistic Snap Foodd traffic.

The architecture is specific to three product surfaces:

- Customer ordering
- Restaurant Partner operations
- Delivery Partner fulfilment

## 2. Architectural principles

### One product, three operational surfaces

Customer, Restaurant, and Delivery are separate feature domains inside one Flutter application. They share design-system primitives, identity, networking abstractions, and selected domain models, but their workflows remain isolated.

### Feature-first architecture

Organize by business capability rather than global `screens/`, `widgets/`, or `services/` folders.

A non-trivial feature follows:

```
Presentation
    ↓
Application / ViewModel
    ↓
Domain logic (when workflow complexity justifies it)
    ↓
Repository interface
    ↓
Data sources
```

Simple visual features may omit a domain layer. Checkout, orders, dispatch, delivery verification, and authentication should have explicit application/domain logic.

### UI is a projection of state

Widgets render state and emit intents. They do not perform API requests, persistence, authorization, pricing, assignment, or order-state decisions.

### Repository boundary

Repositories are the stable boundary between feature/application code and data sources. Phase 1 uses fake repositories; production repositories later satisfy the same interfaces.

### Stateless production application tier

The future backend application tier is horizontally scalable and stateless. Long-running or retryable work leaves the synchronous request path through queues/events.

### Modular monolith first

The initial backend should be a **modular monolith**, not premature microservices. Modules have explicit boundaries so services can be extracted later when measured load, team ownership, or failure isolation justifies it.

## 3. Flutter decisions

### Flutter + Dart

Dart and Flutter are the cross-platform foundation. The app shares business logic and UI across mobile, desktop, and web. Platform-specific integrations are isolated behind adapters.

### State management + dependency injection — Riverpod 3

Riverpod is the application state and dependency-injection mechanism.

Rules:

- No scattered mutable singleton state.
- Providers expose application dependencies/state, not raw HTTP clients.
- Keep ephemeral widget state local when it does not need sharing.
- Keep server state separate from transient UI state.
- Test overrides must be possible for every external dependency.

### Navigation — go_router

go_router is used for declarative routing, deep links, browser URLs, authentication redirects, nested role flows, and navigation restoration.

Representative routes:

```
/customer/home
/customer/restaurants/:restaurantId
/customer/restaurants/:restaurantId/items/:itemId
/customer/cart
/customer/checkout
/customer/orders/:orderId
/customer/profile

/restaurant/dashboard
/restaurant/orders
/restaurant/orders/:orderId
/restaurant/menu

/delivery/home
/delivery/requests
/delivery/trips/:tripId/pickup
/delivery/trips/:tripId/delivery
/delivery/earnings
```

### Models — Freezed + json_serializable

Use immutable models. Separate transport/API models from domain models when their lifecycles differ, especially for Order, DeliveryTrip, and payment data.

### Networking — Dio behind an API abstraction

Feature code never configures Dio directly.

```
ViewModel
   ↓
Repository
   ↓
SnapFoodApiClient
   ↓
Dio
```

The API client owns base URL selection, headers, serialization, timeouts, cancellation, auth integration, and normalized transport errors.

### Local persistence

Use interfaces for storage.

- Sensitive native/desktop session material: platform-secure storage.
- Web session: prefer secure server-managed cookies rather than long-lived credentials in browser local storage.
- Preferences: lightweight preferences storage.
- Larger offline/cache data: add a local database only for a demonstrated Snap Foodd requirement.

## 4. Target Flutter structure

```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── bootstrap.dart
│   ├── router/
│   └── environment/
├── core/
│   ├── errors/
│   ├── logging/
│   ├── networking/
│   ├── platform/
│   ├── storage/
│   └── utilities/
├── design_system/
│   ├── tokens/
│   ├── theme/
│   ├── components/
│   ├── layouts/
│   ├── responsive/
│   └── icons/
└── features/
    ├── auth/
    ├── customer/
    │   ├── home/
    │   ├── restaurants/
    │   ├── cart/
    │   ├── checkout/
    │   ├── orders/
    │   └── profile/
    ├── restaurant/
    │   ├── dashboard/
    │   ├── orders/
    │   └── menu/
    ├── delivery/
    │   ├── onboarding/
    │   ├── requests/
    │   ├── trips/
    │   └── earnings/
    └── orders/
```

Feature folders own their screens, state controllers, feature components, repositories, domain logic, and tests. A component belongs in `design_system/` only when it is genuinely reusable.

## 5. Responsive architecture

Snap Foodd is mobile-first but not mobile-only.

Use centralized semantic layout classes:

- **Compact** — phone/narrow browser
- **Medium** — tablet/small desktop
- **Expanded** — desktop/wide web

Do not scatter raw breakpoint numbers through widgets.

Compact layouts prioritize one-thumb interaction, bottom navigation, sheets, horizontal food rows, and sticky cart actions.

Medium layouts can introduce increased gutters, multi-column content, and dual-pane operational views.

Expanded layouts use the Stitch 12-column desktop language, centered customer content up to 1200px, and denser multi-column restaurant/KDS/delivery operations.

Responsive behavior may change arrangement, never product meaning.

## 6. Shared vs platform-specific

Shared by default:

- Domain models
- Repositories
- Controllers/ViewModels
- Validation
- Design tokens
- Feature widgets
- API contracts
- Navigation model

Platform-specific behind adapters:

- Push notifications
- Secure storage
- Background location
- Maps SDK details
- Payment SDKs
- Camera/file access
- Deep OS integrations
- Desktop window/system behavior
- Browser-specific APIs

## 7. Frontend data flow

```
User interaction
      ↓
Screen / Widget
      ↓
ViewModel / Controller
      ↓
Repository interface
      ↓
Mock repository (Phase 1)
      ↓
Production repository (later)
      ↓
API / local data / realtime
```

Example checkout flow:

```
Checkout button
   ↓
CheckoutViewModel.submit()
   ↓
OrderRepository.placeOrder()
   ↓
Backend validates cart, price, availability, payment state
   ↓
Order created
   ↓
Realtime/order events
   ↓
Tracking state updates
```

The client never treats displayed price, availability, delivery fee, or order status as authoritative.

## 8. Realtime architecture

Snap Foodd has two distinct realtime workloads:

1. Order/operational events — KDS changes, order status, assignment, customer tracking status.
2. Delivery location telemetry — active delivery-partner positions.

Expose a transport-neutral realtime interface. The production backend may use a managed WebSocket/realtime gateway without changing feature code.

Location telemetry must be throttled, coalesced, permission-aware, battery-aware, and never broadcast raw GPS samples indiscriminately.

## 9. Production backend boundary

Planned Snap Foodd capabilities:

```
Identity & Access
Restaurant / Catalog
Cart / Pricing
Orders
Payments
Dispatch
Delivery Trips
Realtime Tracking
Notifications
Reviews
Partner Operations
```

The initial backend is a modular monolith with independently testable modules.

### Infrastructure direction

AWS is the preferred deployment direction, subject to capacity, cost, limits, and failure-mode validation.

```
Users / Apps
     │
     ├── Web → CDN / edge
     └── Mobile/Desktop
              │
              ▼
        API / Realtime Edge
              │
       ┌──────┴───────┐
       ▼              ▼
 Stateless App     Realtime
   Containers       Gateway
       │              │
       ├──────┬───────┤
       ▼      ▼       ▼
 Relational  Redis  Queue/Event Bus
  Database
       │
       ├── Object/media storage
       └── External providers
```

### Transactional database

A PostgreSQL-compatible relational database is the planned system of record for users, restaurants, menus, orders, payment records, delivery trips, and transactional relationships.

Orders and payments require transactional integrity and explicit state transitions.

### Cache

Redis is planned for cacheable reads, rate limiting, short-lived coordination, and selected dispatch/realtime state. It is never authoritative for orders or payments.

### Async processing

Use durable queues/events for notifications, media processing, analytics, retryable integrations, and post-order side effects.

### Media

Use object storage + CDN for food/restaurant images and other media. APIs return media references rather than proxying large files through application servers.

## 10. Order lifecycle

Order status is a state machine, not an arbitrary string.

Representative flow:

```
CREATED
  ↓
PAYMENT_CONFIRMED
  ↓
RESTAURANT_ACCEPTED
  ↓
PREPARING
  ↓
READY_FOR_PICKUP
  ↓
PICKED_UP
  ↓
OUT_FOR_DELIVERY
  ↓
DELIVERED
```

Exceptional paths such as payment failure, rejection, cancellation, delivery failure, and refund are explicit states/transitions and are server-authoritative.

## 11. Delivery lifecycle

```
REQUESTED
  ↓
OFFERED
  ↓
ACCEPTED
  ↓
NAVIGATING_TO_RESTAURANT
  ↓
PICKUP_VERIFIED
  ↓
NAVIGATING_TO_CUSTOMER
  ↓
HANDOVER_PIN_VERIFIED
  ↓
COMPLETED
```

Assignment, pickup verification, handover verification, and location telemetry are server-authoritative.

## 12. Authentication and authorization

Expected roles:

- Customer
- Restaurant Partner / staff
- Delivery Partner
- Future administrative/operator roles

Client route guards are for UX. Backend authorization is the security boundary.

## 13. Error model

Normalize transport/domain errors before they reach widgets:

```
NetworkUnavailable
Unauthorized
Forbidden
ValidationFailed
ResourceNotFound
Conflict
RateLimited
ServerFailure
PaymentFailure
OrderStateConflict
Unknown
```

Repositories do not display snackbars/dialogs.

## 14. Testing

### Unit
Domain rules, pricing, state transitions, validators, repositories, ViewModels.

### Widget
Design-system components, critical states, forms, responsive branches.

### Integration
- Customer: browse → restaurant → cart → checkout → tracking
- Restaurant: receive → accept → prepare → ready
- Delivery: request → accept → pickup verification → customer PIN → complete

### Visual regression
Compare critical Stitch screens at reference, compact, medium, and expanded viewports.

## 15. Performance

- Lazy/virtualized long lists.
- Correctly sized/cached images.
- No expensive work in `build()`.
- Cancel obsolete requests.
- Debounce search.
- Keep delivery location updates separate from normal UI refresh.
- Measure with DevTools and production telemetry.

## 16. Security

- No secrets in the client.
- Never trust client price, role, availability, delivery state, or payment state.
- Secure transport only.
- Secure authentication storage.
- Never log tokens, payment data, OTPs, PINs, or sensitive customer data.
- Rate limiting and abuse controls are server-side.

## 17. Observability

Production must expose:

- Structured logs
- Crash/error reporting
- API latency/error metrics
- Realtime connection metrics
- Order lifecycle metrics
- Dispatch/acceptance metrics
- Queue/retry metrics
- Database health/latency
- Client performance

Operational questions should be answerable, for example: why an order remained preparing, why a delivery was not assigned, or where tracking became stale.

## 18. Capacity policy

The 500,000-user target requires realistic load modeling:

- Browsing bursts
- Restaurant/menu reads
- Cart updates
- Checkout spikes
- Restaurant KDS concurrency
- Delivery request bursts
- Active location streams
- Realtime fan-out
- Notification/queue backlog

Scale from measured bottlenecks and SLOs, not from a theoretical concurrency number.

## 19. Change policy

Changes affecting feature boundaries, API contracts, authentication, order transitions, or design-system contracts must update documentation and tests in the same change. Significant architectural choices should be recorded as ADRs.
