# Snap Food

Snap Food is a production food-delivery platform for **Customers**, **Restaurant Partners**, and **Delivery Partners**. It targets **iOS, Android, Windows, macOS, and Web** from one Flutter/Dart codebase.

The current repository is design-first. The Google Stitch export in \`stitch_snap_food_design_system.zip\` and the images in \`design-images/\` are the authoritative visual references for the initial UI.

## Product surfaces

### Customer
1. Splash & Welcome
2. Home Feed
3. Restaurant & Menu
4. Food Item Details
5. Checkout
6. Live Order Tracking
7. Cart & Review
8. Customer Profile

### Restaurant Partner
1. Dashboard
2. Live Orders / KDS
3. Order Detail Ticket
4. Partner Menu / Stock

### Delivery Partner
1. Login / Onboarding
2. Delivery Requests
3. Partner Home / Duty Map
4. Navigate to Restaurant
5. Pickup Confirmation / Verification
6. Navigate to Customer
7. Delivery Verification / PIN Verification
8. Earnings / Trip History

## Engineering standard

Snap Food is a real client product. We do not optimize for “make the screen work”; we optimize for **modularity, changeability, testability, responsive behavior, security, performance, and production operation**.

Core rules:

- Feature-first architecture with explicit boundaries.
- UI never owns API, persistence, authentication, or business rules.
- Immutable models/state where practical.
- Repository interfaces isolate features from data sources.
- Dependency injection; no scattered global mutable services.
- Shared design-system components instead of screen-specific duplicates.
- Platform-specific behavior behind adapters.
- Mock repositories first; production repositories later.
- No secrets or privileged credentials in the client.
- Loading, empty, error, offline/degraded, and accessibility states are part of feature completion.
- Third-party packages require a Snap Food use case and maintenance/license review.
- Architectural changes must be documented.

## Technology decisions

| Concern | Decision |
|---|---|
| Language | Dart |
| Cross-platform UI | Flutter |
| State + DI | Riverpod 3 |
| Navigation | go_router |
| Immutable models | Freezed |
| JSON | json_serializable |
| HTTP | Dio behind Snap Food API abstractions |
| Secure session storage | Platform-secure implementation behind an interface |
| Preferences | Lightweight preferences behind an interface |
| Testing | unit + widget + integration + visual regression |
| Initial data | deterministic mock repositories |

The Stitch HTML is **not** production source code. It is the design specification. Production UI is native Flutter.

## Architecture

The target frontend flow is:

\`\`\`
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
\`\`\`

The detailed architecture is in [ARCHITECTURE.md](ARCHITECTURE.md).

The visual contract is in [DESIGN.md](DESIGN.md).

## Development order

### Phase 0 — Foundation
Flutter workspace, CI, linting, architecture, design tokens, routing shell, environment configuration, and tests.

### Phase 1 — Frontend
Implement the Stitch screens with deterministic mock data. Build the design system before duplicating screen-specific UI.

### Phase 2 — Frontend hardening
Responsive QA across phone/tablet/desktop/web, accessibility, widget tests, visual regression, loading/error/empty states, and performance checks.

### Phase 3 — Backend contracts
Freeze API/realtime contracts from validated frontend workflows.

### Phase 4 — Backend + database
Implement identity, catalog, cart, orders, payments, restaurant operations, dispatch, delivery tracking, notifications, and reviews.

### Phase 5 — Production
Load/soak/failure testing, observability, security, disaster recovery, cost validation, and deployment gates.

## Definition of done

A screen is complete only when it:

- Matches its Stitch reference at the intended viewport.
- Adapts correctly at compact/medium/expanded sizes.
- Uses centralized Snap Food tokens/components.
- Keeps logic outside widgets.
- Has deterministic tests where behavior matters.
- Handles loading/error/empty states where applicable.
- Avoids unnecessary rebuilds and expensive work in \`build()\`.
- Supports relevant touch, mouse, keyboard, and platform navigation.
- Passes formatting, analysis, and tests.

## Target repository structure

\`\`\`
lib/
├── app/
├── core/
├── design_system/
├── features/
│   ├── auth/
│   ├── customer/
│   ├── restaurant/
│   ├── delivery/
│   └── orders/
├── main.dart
test/
integration_test/
assets/
ARCHITECTURE.md
DESIGN.md
README.md
\`\`\`

The exact tree may evolve when real boundaries are discovered. New architectural patterns should not be introduced casually.
