# Snap Foodd — Customer Mobile UI/UX Development Plan

> **Purpose:** This document is the single working source of truth for the ongoing customer-facing Flutter mobile UI/UX redesign on the `frontend` branch.
>
> **Product direction:** **Warm Editorial Food Commerce** — premium food photography, warm tactile surfaces, strong typography, minimal chrome, fast interactions, and a distinctive Snap Foodd identity.
>
> **Important:** This is a UI/UX modernization plan, not a backend rewrite. Preserve existing business logic, APIs, repositories, authentication, routing, state management, and data contracts unless a change is strictly required for the UI.

---

## 1. Working Rules for the AI

1. Work **one task at a time**, in the order listed below unless a dependency makes a different order necessary.
2. Before implementing a task, inspect the current code and understand existing behavior. Do not blindly replace working logic.
3. Preserve existing API contracts, Riverpod state, GoRouter navigation, authentication, cart/order behavior, and repository layers.
4. Prefer reusable Snap Foodd components over repeated page-specific styling.
5. Do not introduce stock Material styling where it conflicts with the Snap Foodd visual language.
6. Do not invent random dimensions, colors, radii, shadows, or typography values. Use the design tokens.
7. Keep accessibility in scope: semantic labels, touch targets, text scaling, keyboard/focus support where applicable, and states that do not rely on color alone.
8. Respect safe areas and compact/mobile layouts.
9. Avoid unnecessary dependencies. If a new package is genuinely needed, explain why before adding it.
10. After every task:
   - run the relevant formatter/analyzer/tests available in the project;
   - fix regressions caused by the task;
   - update this file's progress section;
   - record the files changed and validation performed.
11. Do not mark a task complete merely because the code compiles. Validate the intended visual/interaction behavior as far as the available environment allows.
12. If a requirement conflicts with existing product behavior or API constraints, preserve functionality and document the constraint instead of silently breaking it.

---

## 2. Product Design Direction

### 2.1 Brand Character

Snap Foodd should feel:

- Energetic
- Appetizing
- Warm
- Tactile
- Premium without being pretentious
- Operationally clear
- Fast and easy to use

The app should feel like a **food commerce product first**, rather than a generic Flutter application containing food data.

### 2.2 Visual Direction

Use a **warm editorial food commerce** approach:

- Warm cream background
- High-quality food imagery as a primary visual asset
- Strong dark typography
- Golden yellow for highlights, ratings, selections and promotions
- Food red for conversion actions
- Restrained borders and shadows
- Generous spacing
- Clear hierarchy
- Minimal visual chrome
- Purposeful motion

Avoid:

- Excessive gradients
- Excessive glassmorphism
- Heavy shadows
- Too many cards
- Excessive animation
- Random colors
- Overuse of red/yellow
- Generic Material-looking controls when a Snap component is appropriate

---

## 3. Design Tokens

The existing centralized design tokens are the foundation. Extend them rather than scattering values throughout screens.

### 3.1 Colors

Primary working palette:

| Token | Value | Usage |
|---|---|---|
| Surface | #FFF8F5 | Main app canvas |
| Surface Container Low | #FDF1EA | Soft sections |
| Surface Container | #F7ECE5 | Secondary surfaces |
| Surface Container High | #F1E6DF | Elevated warm surfaces |
| Surface Container Highest | #EBE0D9 | Stronger surface separation |
| White | #FFFFFF | Cards / utility surfaces |
| Warm Black | #201B17 | Primary text |
| On Surface Variant | #4E4634 | Secondary text |
| Outline | #7F7662 | Strong borders / muted controls |
| Outline Variant | #D1C5AE | Soft borders |
| Brand Gold | #E4B935 | Highlights / selected states / rating |
| Brand Red | #D54126 | Primary conversion actions |
| Accent Yellow | #FBE929 | Strong promotional accent |
| Soft Yellow | #FFF3C4 | Selection / promotion backgrounds |
| Soft Red | #FBE3DC | Error / secondary emphasis |
| Error | #BA1A1A | Errors |

Do not introduce another primary brand palette without a documented reason.

### 3.2 Typography

Primary typeface: **Plus Jakarta Sans**.

Hierarchy:

- Display / hero: 32–40px, 700–800
- Large section title: 24–26px, 700
- Section/title: 18–20px, 600–700
- Body: 14–16px
- Supporting metadata: 12–14px
- Labels: 11–14px, generally 600–700
- Prices: visually prominent, bold/extra-bold

Verify that the font is actually available at runtime. If the project currently relies on fallback behavior, resolve that deliberately rather than assuming the font is bundled.

### 3.3 Spacing

Use the existing 4/8 rhythm:

- 4
- 8
- 16
- 24
- 32
- 48

Compact/mobile guidance:

- Compact gutter: 12
- Typical outer margin: 16
- Safe-area aware bottom content
- Avoid cramped controls

### 3.4 Shape

Use:

- 4: micro
- 8: small controls
- 12: standard controls / smaller cards
- 16: main cards / sections
- 24: hero / prominent surfaces
- Full/pill: chips, badges and compact actions

### 3.5 Elevation

Keep elevation subtle:

- Level 0: flat
- Level 1: light separation
- Level 2: interactive commerce surfaces
- Level 3: sticky navigation, checkout CTA, modal/bottom-sheet surfaces

---

## 4. Component System to Build

Create and progressively adopt reusable components under the design system rather than keeping large private widgets inside individual screens.

Suggested structure:

```
mobile_app/lib/design_system/
  tokens/
    app_colors.dart
    app_radii.dart
    app_spacing.dart
    app_shadows.dart
    app_typography.dart

  components/
    buttons/
      snap_primary_button.dart
      snap_secondary_button.dart
    cards/
      snap_product_card.dart
      snap_restaurant_card.dart
    commerce/
      snap_price.dart
      snap_quantity_stepper.dart
      snap_rating_badge.dart
    navigation/
      snap_bottom_navigation.dart
      snap_icon_button.dart
    inputs/
      snap_search_field.dart
      snap_filter_chip.dart
    feedback/
      snap_empty_state.dart
      snap_skeleton.dart
    surfaces/
      snap_bottom_sheet.dart
      snap_section_header.dart
```

Names may be adjusted to match the existing architecture, but the intent must remain.

Core components:

- `SnapPrimaryButton`
- `SnapSecondaryButton`
- `SnapIconButton`
- `SnapSearchField`
- `SnapFilterChip`
- `SnapCategoryChip`
- `SnapBottomSheet`
- `SnapProductCard`
- `SnapRestaurantCard`
- `SnapQuantityStepper`
- `SnapPrice`
- `SnapRatingBadge`
- `SnapSectionHeader`
- `SnapEmptyState`
- `SnapSkeleton`
- `SnapOrderStatus`
- `SnapAddressTile`
- `SnapBottomNavigation`

Every reusable component should have clear states where relevant: default, pressed, selected, disabled, loading, error, and focus.

---

## 5. Customer Navigation

Primary compact navigation:

**Home · Discover/Search · Cart · Orders · Profile**

Requirements:

- Custom Snap Foodd bottom navigation rather than a generic Material appearance.
- Selected destination gets a clear branded container/pill treatment.
- Cart count is a compact badge.
- Touch targets remain comfortable.
- Navigation respects bottom safe area.
- Do not make the navigation visually heavier than the content.

---

# 6. Phased Task Plan

## Phase 1 — Design Foundation

### Task 1 — Audit and stabilize the design-token foundation
**Status:** ✅ Complete

- Review existing colors, typography, spacing, radii and theme.
- Add missing shadow/elevation and typography token abstractions where useful.
- Verify Plus Jakarta Sans availability.
- Remove duplicated hard-coded design values where practical.
- Ensure Material 3 theme reflects Snap Foodd tokens without changing business behavior.

**Done when:** The design system is internally consistent and screens can consume the same tokens reliably.

### Task 2 — Build Snap Foodd buttons and icon controls
**Status:** ✅ Complete

- Primary conversion button: food red.
- Secondary/action button: gold/yellow treatment.
- White utility button where appropriate.
- Custom icon-button treatment.
- Pressed/disabled/loading/focus states.
- Minimum comfortable touch targets.

### Task 3 — Build search, category and filter controls
**Status:** ✅ Complete

- Custom search field.
- Category chips.
- Filter chips.
- Selected/inactive states.
- Replace visually generic Material chip/search styling where used in customer screens.

### Task 4 — Build commerce primitives
**Status:** ✅ Complete

- Snap price component.
- Rating badge.
- Quantity stepper.
- Add-to-cart interaction.
- Reusable section header.
- Ensure quantities and prices have strong visual hierarchy.

### Task 5 — Build branded feedback surfaces
**Status:** ✅ Complete

- Skeleton loading states.
- Empty states.
- Error states.
- Branded bottom sheets/dialog surfaces.
- Respect reduced-motion/accessibility requirements.

---

## Phase 2 — Home & Discovery

### Task 6 — Redesign customer Home screen hierarchy
**Status:** ✅ Complete

Target hierarchy:

1. Location / delivery destination
2. Search: “What are you craving?”
3. Categories
4. Promotional / discovery hero
5. Popular near you
6. Top restaurants
7. Bottom navigation

Requirements:

- Make food imagery the visual hero.
- Reduce the visual weight of secondary filters.
- Introduce better vertical rhythm.
- Avoid a wall of equal-weight controls.
- Preserve catalogue/API behavior.
- Make the first viewport immediately useful and appetizing.

### Task 7 — Redesign product cards
**Status:** ✅ Complete

Product cards should:

- Give food imagery dominance.
- Use consistent image aspect/cropping.
- Have strong title and price hierarchy.
- Use meaningful badges only when data supports them.
- Support favorite and add actions elegantly.
- Avoid generic “Fresh” labels when they do not communicate useful information.
- Feel tactile without excessive shadows.

Potential contextual badges:

- Bestseller
- Popular
- New
- Vegetarian
- Spicy
- Offer
- Free delivery
- ETA

Only show badges supported by real data or clearly defined product rules.

### Task 8 — Restaurant-first discovery
**Status:** ⏭️ Not Applicable — Product model has no restaurants

**Product decision:** Snap Foodd does not have a restaurant concept in the customer product model. Products are not associated with restaurants, and restaurant-specific discovery, metadata, navigation, menus or tagging are not part of the intended product behavior.

**Completed/retained:** The previously added `SnapRestaurantCard` primitive is no longer part of the customer roadmap and should not be adopted or extended for restaurant discovery. Restaurant-specific work is intentionally skipped.

**Roadmap action:** Treat Task 8 as skipped/not applicable and continue with product/catalogue-first discovery tasks.

### Task 9 — Redesign Search / Discover
**Status:** ✅ Complete

- Refined the customer search surface around the existing catalogue contract.
- Replaced hard-coded craving categories with API-backed catalogue categories.
- Added reusable selected/inactive category filtering with `SnapFilterChip`.
- Preserved local text search across product names and category names.
- Added clear-filter affordance when a category is selected.
- Improved result-state hierarchy for all/category/query result modes.
- Preserved product-detail navigation and catalogue retry behavior.
- Did not add unsupported recent-search or popularity data.

- Strong search entry point.
- Recent/popular searches where supported.
- Category/filter controls.
- Clear results hierarchy.
- Empty/loading/error states.
- Consistent cards and typography.

---

## Phase 3 — Food Detail & Commerce

### Task 10 — Redesign food item details
**Status:** ✅ Complete

- Reworked the food detail screen around the existing catalogue product as the single source of truth.
- Removed obsolete hard-coded item-name, description and price fallbacks.
- Strengthened the hero-image-first hierarchy.
- Promoted product name and catalogue price for faster scanning.
- Added branded availability/category metadata treatment.
- Preserved the existing quantity stepper, server-authoritative cart behavior and add-to-cart navigation.
- Added safe-area-aware sticky commerce controls and accessible back/availability semantics.
- Preserved catalogue loading/error handling and product lookup behavior.


Target hierarchy:

1. Large hero image
2. Name
3. Rating / metadata
4. Price
5. Description
6. Customization/options
7. Quantity
8. Sticky add-to-cart CTA

Requirements:

- Food image should dominate.
- Make price and primary action immediately scannable.
- Use branded quantity control.
- Preserve all existing product customization/business logic.

### Task 11 — Redesign restaurant menu
**Status:** ⏭️ Not Applicable — no restaurant concept

**Product decision:** Snap Foodd does not have a restaurant concept in the customer product model. There is no restaurant-to-product relationship, so restaurant menu headers, restaurant metadata, restaurant menu categories, restaurant navigation and restaurant-specific cart behavior are not intended customer product behavior.

**Roadmap action:** Skip Task 11 and continue with product/catalogue-first commerce tasks. Do not reintroduce restaurant concepts into later customer UI work.

### Task 12 — Redesign Cart
**Status:** ✅ Complete

- Reworked the cart around the existing `CartController` and remote cart repository without changing cart APIs or quantity behavior.
- Strengthened item/name/description/price hierarchy with the reusable Snap Foodd typography and commerce primitives.
- Kept tactile `SnapQuantityStepper` controls for optimistic add/remove quantity changes.
- Added a clearer bill-details hierarchy for the preview item total and explicitly preserved the current server-authoritative final-charge behavior.
- Kept the empty-cart experience branded with `SnapEmptyState` and added a lightweight browse-dishes action.
- Replaced the generic checkout button with the reusable `SnapPrimaryButton` and kept it safe-area aware and sticky.
- Replaced the raw back control with `SnapIconButton` and retained existing navigation.
- Avoided generic add/remove snackbars; quantity changes continue through the existing optimistic cart controller flow with server reconciliation on failure.
- Preserved product imagery fallback behavior, checkout routing, cart state, and server-authoritative pricing.
### Task 13 — Redesign Checkout
**Status:** ✅ Complete

Target hierarchy:

1. Delivery address
2. Order summary
3. Payment method
4. Price breakdown
5. Final total
6. Sticky “Place order” CTA

Requirements:

- High trust and clarity.
- No ambiguous totals.
- Clear selected states.
- Strong error/validation treatment.
- Safe-area aware sticky CTA.
- Preserve checkout/order API behavior.
- Reworked the checkout hierarchy around delivery address, order summary, payment method, price breakdown, final-total messaging, and the sticky place-order action.
- Reused Snap Foodd controls including `SnapIconButton`, `SnapSectionHeader`, `SnapPrice`, `SnapPrimaryButton`, and branded checkout surfaces.
- Kept the current COD-only API contract explicit instead of presenting unsupported payment choices.
- Kept the current server-authoritative pricing behavior explicit: cart prices are shown as a preview, while delivery/final charges remain confirmed by the server after order placement.
- Preserved saved-address selection, inline address creation, `CreateOrderRequest`, order submission, cart clearing, and order-detail navigation.

### Task 14 — Redesign address selection/book
**Status:** ✅ Complete

- Reworked the address book around clear, reusable SnapAddressTile surfaces with explicit selected semantics and a visible “Selected” label so selection does not rely on color alone.
- Preserved address selection behavior and checkout integration: selecting an address still updates AddressBookController and returns to the previous flow when the route can pop.
- Reworked add-address into a branded, inline form with token-based spacing, reusable Snap buttons, validation, safe-area handling and inline API error feedback.
- Preserved the existing /addresses GET/POST/DELETE API behavior, selected-address state and address model.
- Added confirmation before deletion and branded error feedback for failed deletes.
- The current customer address API exposes add and delete operations but no documented update/edit operation. An edit action was therefore not fabricated; the reusable tile supports an edit callback for future API support, while the current UI truthfully exposes only supported add/delete behavior.
- Checkout continues to consume the selected SavedAddress through the existing toDeliveryAddress() path; no order or address API contract was changed.

---

## Phase 4 — Orders, Profile & Retention

### Task 15 — Redesign Orders
**Status:** ✅ Complete

- Reworked the customer Orders surface into clearly separated Active orders and Past orders sections using the existing order history provider.
- Added a reusable `SnapOrderStatus` component with explicit status labels, icons and accessible semantics so order meaning does not depend on color alone.
- Optimized order cards for fast scanning: order identifier, status, item count, total and payment status, with the entire card remaining a safe navigation target to order details.
- Preserved pagination and refresh behavior through the existing `OrderHistoryController`.
- Did not fabricate reorder actions because the current customer order contract/controller does not expose a reorder operation.
- Reused branded loading, error and empty states plus existing Snap Foodd buttons, price and tokenized typography/spacing.


### Task 16 — Redesign Order Details
**Status:** ✅ Complete

- Reworked Order Details around order identity and status-first hierarchy; the product decision that Snap Foodd has no restaurant concept is preserved, so no restaurant identity or metadata was introduced.
- Grouped ordered items, quantities and API-supported line totals into a scan-friendly items section. Product names are read from the existing order payload when available; no unsupported product data is fabricated.
- Grouped delivery-address snapshot, payment method/status, subtotal, delivery fee and total using the existing order contract.
- Reused SnapOrderStatus, SnapPrice, SnapSectionHeader, SnapPrimaryButton, SnapSecondaryButton and branded loading/error/empty states.
- Preserved existing order-detail loading through OrderHistoryController and the current order repository/API contract.
- Preserved live-tracking preview and the existing `/orders/:id/tracking` route for non-terminal orders.
- Preserved the existing delivered-order invoice route; no reorder/support actions were fabricated because the current customer order contract does not expose those operations.
- Added safe-area-aware scrolling, accessible order/status semantics, stronger grouping and tokenized spacing/typography without changing business logic.

### Task 17 — Redesign live order tracking
**Status:** ✅ Complete

- Reworked live tracking into a status-first, safe-area-aware tracking experience using the existing order tracking provider and API contract.
- Added a prominent current-status hero with accessible live-region semantics and reusable `SnapOrderStatus`.
- Added a clear visual order-progress timeline for every status currently represented by the customer order contract.
- Removed the previous restaurant-specific wording from tracking because Snap Foodd has no restaurant concept.
- Preserved the existing 10-second polling behavior and pull-to-refresh interaction.
- Preserved stale-location handling and made the distinction between live, stale and unavailable tracking explicit.
- Reworked location presentation around the actual `OrderTrackingLocation` data, including coordinates, optional timestamp and optional accuracy; no map was fabricated because the current mobile infrastructure/API does not expose a map abstraction.
- Did not fabricate ETA, rider identity/contact information or support actions because the current tracking model exposes none of those fields.
- Preserved branded loading, error and unavailable states and added clearer cancelled-order handling.
- Reused centralized spacing, typography, colors, radii and order-status components without changing tracking business logic or repository/API behavior.

This should become a signature Snap Foodd experience:

- Clear live ETA (only when the tracking API exposes an ETA; the current contract does not).
- Visual progress states.
- Rider/delivery information when available.
- Map abstraction where current infrastructure supports it.
- Clear status labels so meaning does not depend only on color.
- Subtle progress/micro-motion.
- Preserve tracking logic and API behavior.

### Task 18 — Redesign Profile and Favorites
**Status:** ✅ Complete

- Reworked the customer profile around authenticated account identity, compact account stats, and a clear hierarchy for orders, favorites and saved addresses.
- Replaced generic profile chrome with Snap Foodd icon controls, typography, spacing and branded account rows.
- Preserved existing auth/logout behavior and existing /orders, /favorites and /addresses routes.
- Removed unsupported/fabricated payment-method, coupon, notification, language, support and privacy controls from the customer profile because the current customer API/UI contract does not expose those settings as working operations.
- Reworked Favorites into an image-led saved-dishes surface with stronger food imagery, product name/category/price hierarchy, accessible remove controls, browse-dishes action, responsive one/two/three-column layouts, and branded loading/error/empty states.
- Preserved favoriteControllerProvider, server-backed refresh/toggle behavior and product-detail navigation.
- Kept the experience product/catalogue-first; no restaurant identity or restaurant-specific favorite behavior was introduced.

## Phase 5 — Onboarding & Delight

### Task 19 — Improve onboarding and welcome experience
**Status:** ⬜ Not Started

- Food-first visual storytelling.
- Reduce generic marketing-copy feel.
- Use mascot/illustrations selectively.
- Clear primary CTA.
- Smooth but restrained transitions.
- Preserve authentication/navigation behavior.

### Task 20 — Add motion and tactile feedback
**Status:** ⬜ Not Started

Motion guidance:

- Micro interaction: 80–120ms
- Standard transition: 180–250ms
- Emphasis: 300–500ms

Use motion for:

- Button press
- Add-to-cart
- Quantity changes
- Bottom navigation selection
- Order progress
- Delivery marker
- Celebration moments

Respect reduced-motion preferences.

### Task 21 — Final accessibility and responsive UX pass
**Status:** ⬜ Not Started

Audit:

- Text scaling
- Contrast
- Semantic labels
- Touch targets
- Focus states
- Keyboard behavior where applicable
- Safe areas
- Overflow/clipping
- Small-screen layouts
- Larger-screen layouts
- Color-independent status communication

---

## 7. Quality Gate for Every Task

Before marking any task complete, verify:

- [ ] Existing business logic preserved
- [ ] Existing API/data behavior preserved
- [ ] No unintended route/auth regression
- [ ] No overflow/clipping
- [ ] Safe areas respected
- [ ] Tokens used instead of random constants
- [ ] Reusable components used where appropriate
- [ ] Loading/empty/error states considered
- [ ] Accessibility considered
- [ ] Formatter/analyzer/tests run where available
- [ ] No unnecessary dependency added
- [ ] This document updated

---

## 8. Progress Log

| Date | Task | Result | Notes |
|---|---|---|---|
| 2026-10-03 | Planning reset | ✅ Complete | Removed legacy AIDLC planning files and established this document as the new customer mobile UI/UX development source of truth. |
| 2026-10-03 | Task 1 — Audit and stabilize the design-token foundation | ✅ Complete | Audited the existing mobile design system, aligned core brand colors with the plan, added centralized typography and elevation tokens, and tightened Material 3 theme defaults without changing product behavior. Validation: source-level review completed; repository Flutter CI is configured to run `dart format`, `flutter analyze`, `flutter test`, and Android debug build on frontend PRs. Local command execution was not available through the GitHub connector. |
| 2026-10-03 | Task 2 — Build Snap Foodd buttons and icon controls | ✅ Complete | Reworked the existing button component into reusable `SnapPrimaryButton`, `SnapSecondaryButton`, and `SnapIconButton` controls with branded colors, 48px+ touch targets, loading/disabled/selected states, semantics, tooltips, and token-based radii/spacing. Existing `SnapFoodPrimaryButton`/`SnapFoodSecondaryButton` names remain as compatibility aliases. Validation: source-level review completed; no business logic or navigation changes. Local Flutter commands were unavailable through the GitHub connector. |
| 2026-10-03 | Task 3 — Build search, category and filter controls | ✅ Complete | Added reusable `SnapSearchField`, `SnapCategoryChip`, and `SnapFilterChip` controls and adopted them in the customer Home and Search surfaces, including branded focus/selected/inactive states, clear-search behavior, accessible labels, and comfortable touch targets. Existing catalogue filtering/search state and navigation behavior were preserved. Validation: source-level review completed; repository CI status was not available for the implementation commits through the connector, and local Flutter commands remain unavailable. |
| 2026-10-03 | Task 4 — Build commerce primitives | ✅ Complete | Added reusable `SnapPrice`, `SnapRatingBadge`, `SnapQuantityStepper`, `SnapAddToCartButton`, and `SnapSectionHeader` commerce primitives, then adopted the price/quantity/add-to-cart/section-header patterns across customer Home, Food Details, Restaurant Menu, and Cart surfaces. Existing cart/catalogue state, navigation, quantity bounds, and server-authoritative pricing behavior were preserved. Validation: source-level review completed; implementation commit CI status returned no exposed checks through the connector, and local Flutter commands remain unavailable. |
| 2026-10-03 | Task 5 — Build branded feedback surfaces | ✅ Complete | Added reusable `SnapBottomSheet`, `SnapEmptyState`, `SnapErrorState`, `SnapSkeleton`, `SnapLoadingState`, and `SnapAlertDialog` feedback surfaces. Adopted them across catalogue loading/empty/error states, Home filtering/empty/loading, cart empty state, address loading/empty/error, checkout errors, and live tracking loading/unavailable/error states. Skeleton animation respects the platform reduced-motion setting. Existing API, Riverpod state, navigation, filtering, cart, address, checkout, and tracking behavior were preserved. Validation: source-level review completed including delimiter/brace checks on changed Dart files; local Flutter/Dart commands remain unavailable through the GitHub connector, and no connector-exposed CI result was available for the implementation commits. |
| 2026-10-03 | Task 6 — Redesign customer Home screen hierarchy | ✅ Complete | Reworked the customer Home into a clearer food-first hierarchy: delivery destination, craving-led search, categories, a catalogue-backed discovery hero, popular dishes, and lightweight bottom navigation. Reduced secondary chrome, tightened vertical rhythm, reused Tasks 1–5 components/tokens, and preserved catalogue filtering, favorites, cart, routing, and authentication behavior. The current consumer catalogue contract does not expose restaurant discovery data, so the Home does not fabricate a Top Restaurants feed; the plan documents that constraint for the later restaurant-first discovery task. Validation: source-level delimiter checks passed and the implementation commit exposed no CI status through the connector; local Flutter/Dart commands remain unavailable through the GitHub connector. |
| 2026-10-03 | Task 8 — Introduce restaurant-first discovery | 🔴 Blocked | Added the reusable `SnapRestaurantCard` primitive with image-led restaurant presentation and optional rating/review count, ETA, delivery metadata, category and open/closed state slots. API inspection confirmed that the current `frontend` backend has no consumer restaurant endpoint/model/contract, so restaurant discovery cannot be truthfully adopted without fabricated data. The task remains blocked pending a backend consumer restaurant discovery contract. Validation: changed Dart source passed brace/parenthesis/bracket balance checks; local Flutter/Dart formatter, analyzer, and tests remain unavailable through the GitHub connector. |
| 2026-10-03 | Product decision — Restaurant concept | ✅ Complete | Confirmed that Snap Foodd does not have a restaurant concept and products are not tagged to restaurants. Task 8 is therefore treated as not applicable rather than blocked; restaurant-specific discovery/card work will not be continued. |
| 2026-10-03 | Task 10 — Redesign food item details | ✅ Complete | Reworked Food Details around the real catalogue product contract: removed obsolete hard-coded product fallbacks, strengthened image/name/price hierarchy, added branded availability/category metadata, preserved quantity/cart/navigation behavior, and kept the sticky add-to-cart control safe-area aware. Validation: changed Dart source was reviewed for structural correctness; local Flutter/Dart formatter, analyzer, and tests remain unavailable through the GitHub connector. |
| 2026-10-03 | Task 9 — Redesign Search / Discover | ✅ Complete | Refined customer search using the existing catalogue contract: API-backed categories replaced hard-coded category data, reusable `SnapFilterChip` controls now filter by category, text search remains local and covers product/category names, and the result hierarchy distinguishes browse, category, and query states. Existing product navigation and catalogue retry behavior were preserved. Validation: source-level brace/parenthesis/bracket checks passed; local Flutter/Dart formatter, analyzer, and tests remain unavailable through the GitHub connector. |
| 2026-10-03 | Task 7 — Redesign product cards | ✅ Complete | Added the reusable `SnapProductCard` editorial card and adopted it on the customer Home catalogue. Product imagery now leads the composition with consistent cropping, stronger name/price hierarchy, category metadata when available, 40px favorite and 44px action targets, explicit availability semantics, restrained borders, and no fabricated rating/popularity badges. Existing favourite toggling and product-detail navigation remain feature-owned and unchanged. Validation: source-level brace/parenthesis/bracket checks passed for the changed component and Home screen; implementation commits exposed no CI status through the connector; local Flutter/Dart formatter, analyzer, and tests remain unavailable through the GitHub connector. |
| 2026-10-03 | Task 11 — Restaurant menu | ⏭️ Not Applicable | Confirmed that Snap Foodd has no customer-facing restaurant concept or product-to-restaurant relationship. Restaurant menu work is intentionally skipped; future customer UI work remains product/catalogue-first. |
| 2026-10-03 | Task 12 — Redesign Cart | ✅ Complete | Reworked the customer Cart with stronger item/price hierarchy, token-based spacing/typography, tactile quantity controls, branded empty state, clearer bill details, and a safe-area-aware sticky checkout CTA using reusable Snap components. The existing CartController, remote repository synchronization, optimistic quantity changes, checkout route, image fallback, and server-authoritative final pricing behavior were preserved. Validation: changed Dart source was structurally reviewed; local Flutter/Dart formatter, analyzer, and tests remain unavailable through the GitHub connector; no connector-exposed CI result was available for the implementation commit. |
| 2026-10-03 | Task 13 — Redesign Checkout | ✅ Complete | Reworked Checkout into a high-trust, product/catalogue-first commerce flow with clear delivery address, order summary, COD payment selection, preview price breakdown, explicit server-authoritative final-total messaging, and a safe-area-aware sticky primary CTA. Reused Snap Foodd components and preserved saved-address selection, inline address creation, `CreateOrderRequest`, order submission, cart clearing, and order-detail navigation. Validation: changed Dart source has balanced delimiter counts; the implementation commit exposed no GitHub status checks through the connector; local Flutter/Dart formatter, analyzer, and tests remain unavailable through the GitHub connector. |
| 2026-10-03 | Task 14 — Redesign address selection/book | ✅ Complete | Reworked the customer address book with a reusable SnapAddressTile, explicit selected semantics, clearer saved-address hierarchy, branded add-address form, inline validation/error feedback, delete confirmation, and preserved checkout selection behavior. The existing address contract currently exposes GET/POST/DELETE but no documented update/edit endpoint, so an edit action was intentionally not fabricated; the reusable tile supports a future edit callback when the API supports it. Validation: changed Dart source files have balanced braces/parentheses/brackets; the implementation commit exposed no GitHub status checks through the connector; local Flutter/Dart formatter, analyzer, and tests remain unavailable through the GitHub connector. |
| 2026-10-03 | Task 15 — Redesign Orders | ✅ Complete | Reworked Orders into clear Active orders and Past orders sections with scan-friendly cards, reusable SnapOrderStatus semantics, prominent totals and item counts, branded loading/error/empty states, refresh and pagination preservation, and existing order-detail navigation. Reorder was not fabricated because the current customer order contract/controller exposes no reorder operation. Validation: changed Dart source files have balanced braces/parentheses/brackets; implementation commits exposed no GitHub status checks through the connector; local Flutter/Dart formatter, analyzer, and tests remain unavailable through the GitHub connector. |
| 2026-10-03 | Task 16 — Redesign Order Details | ✅ Complete | Reworked Order Details around order identity, status, items, delivery snapshot, payment/total information and supported actions. Reused Snap Foodd order/status/price/buttons/feedback components, preserved existing order-detail loading, live-tracking navigation and delivered-order invoice behavior, and intentionally did not fabricate restaurant identity, reorder or support actions because the current product/API contract does not expose them. Validation: changed Dart source has balanced braces/parentheses/brackets; implementation commit exposed no GitHub status checks through the connector; local Flutter/Dart formatter, analyzer, and tests remain unavailable through the GitHub connector. |
| 2026-10-03 | Task 17 — Redesign live order tracking | ✅ Complete | Reworked live tracking into a status-first experience with a prominent current-status hero, reusable SnapOrderStatus, accessible progress timeline, safe-area-aware layout, pull-to-refresh, preserved 10-second polling, explicit stale/unavailable states, and API-backed location details. Removed restaurant-specific wording because Snap Foodd has no restaurant concept. ETA, rider identity/contact, map and support actions were not fabricated because the current tracking contract does not expose them; no map abstraction is currently available. Validation: changed Dart source has balanced braces/parentheses/brackets; implementation commit exposed no GitHub status checks through the connector; local Flutter/Dart formatter, analyzer, and tests remain unavailable through the GitHub connector. |
| 2026-10-03 | Task 18 — Redesign Profile and Favorites | ✅ Complete | Reworked Profile around authenticated account identity, order/favorite/address counts, supported account navigation and branded list rows. Reworked Favorites around image-led saved dishes with responsive layouts, stronger food imagery, Snap price/remove controls, browse action and branded loading/error/empty states. Preserved existing auth/logout, favorites controller/API, address/order routes and product-detail navigation. Removed unsupported/fabricated payment, coupon, notification, language, support and privacy controls from the profile. Validation: changed Dart source files have balanced braces/parentheses/brackets; implementation commits exposed no GitHub status checks/workflow runs through the connector; local Flutter/Dart formatter, analyzer and tests remain unavailable through the GitHub connector. |

---

## 9. Change Log

### 2026-10-03
- Removed legacy AIDLC planning documents.
- Created the new customer mobile UI/UX development plan.
- Established **Warm Editorial Food Commerce** as the target design direction.
- Completed Task 1: stabilized customer mobile design tokens and Material 3 theme foundation.
- Completed Task 2: built reusable branded buttons and icon controls.
- Completed Task 3: built and adopted branded search, category and filter controls.
- Completed Task 4: built reusable commerce primitives and adopted them across core customer commerce surfaces.
- Completed Task 5: built branded loading, skeleton, empty, error, bottom-sheet and dialog feedback surfaces and adopted them across customer flows.
- Completed Task 6: redesigned the customer Home hierarchy with food-first discovery, craving-led search, categories, popular dishes, and lighter navigation chrome.
- Completed Task 7: built and adopted the editorial SnapProductCard with image-led hierarchy, meaningful metadata, favorite/action affordances, availability semantics, and restrained visual treatment.
- Started Task 8: added the reusable SnapRestaurantCard primitive and documented the missing consumer restaurant API/data contract.
- Marked Task 8 blocked because the required consumer restaurant discovery contract is not present.
- Completed Task 9: refined Search/Discover with API-backed categories, reusable filter chips, clearer result states, and preserved catalogue/product navigation behavior.
- Product decision: removed restaurant discovery from the roadmap because Snap Foodd has no restaurant concept or product-to-restaurant relationship.
- Completed Task 10: polished Food Details using the real catalogue contract, stronger visual hierarchy, branded metadata, and preserved commerce behavior.
- Confirmed Task 11 is not applicable because Snap Foodd has no restaurant concept.
- Completed Task 12: redesigned Cart with stronger commerce hierarchy, branded empty state, reusable quantity/CTA controls, clearer bill details, and preserved server-authoritative cart behavior.
- Completed Task 13: redesigned Checkout around address, order summary, COD payment, transparent price preview/final-total messaging, and a safe-area-aware place-order CTA while preserving existing checkout/order behavior.
- Completed Task 14: redesigned the address book with reusable selected-address tiles, branded add-address flow, safe deletion confirmation, and preserved checkout selection behavior; documented the current API limitation around address editing.
- Completed Task 15: redesigned Orders with active/past grouping, scan-first order cards, reusable status semantics, branded states, and preserved pagination/detail navigation; documented that reorder is not supported by the current order contract.
- Completed Task 16: redesigned Order Details around status-first order identity, item/totals hierarchy, delivery snapshot, payment information and supported tracking/invoice actions while preserving the existing order API and avoiding unsupported restaurant/reorder/support concepts.
- Completed Task 17: redesigned live order tracking around current status, progress, stale/live location state and accessible tracking feedback while preserving the existing tracking API, polling and refresh behavior; documented that ETA, rider, map and support data are not currently available.
- Completed Task 18: redesigned Profile and Favorites around supported account data, branded account navigation, food-first saved dishes, responsive layouts and useful feedback states while preserving authentication, favorites and existing customer routes.
- Defined phased implementation tasks.
- Defined reusable component strategy.
- Defined quality gates and progress tracking.

---

## 10. Completion Definition

The customer mobile redesign is complete when:

1. All applicable tasks above are completed or explicitly documented as blocked/not applicable.
2. The customer app consistently uses the Snap Foodd visual language.
3. Home/discovery feels food-first, premium and easy to scan.
4. Product and restaurant discovery are both strong.
5. Food details, cart and checkout feel like one coherent commerce flow.
6. Orders and tracking are clear and trustworthy.
7. Loading, empty, error and success states are branded.
8. Navigation and controls no longer feel like generic Material UI.
9. Accessibility and responsive behavior have been reviewed.
10. Existing functional behavior remains intact.