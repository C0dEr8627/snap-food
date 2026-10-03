# Snap Foodd — Admin Web UI/UX Development Plan

> **Purpose:** This is the single working source of truth for the ongoing UI/UX modernization of the Flutter Web admin application in `admin_web/` on the `frontend` branch.
>
> **Working model:** The AI must implement this plan one task at a time, update the progress in this same file after every task, and never create another competing UI/UX task-board Markdown file.
>
> **Product direction:** **Modern Food-Commerce Operations Platform** — warm, precise, premium, operational, data-dense without feeling cramped.
>
> **Critical domain rule:** Snap Foodd has **no restaurant concept**. Do not introduce restaurants, restaurant cards, restaurant menus, restaurant filters, restaurant metadata, or restaurant-specific admin workflows unless the backend/product contract is explicitly changed later.

---

## 1. How the AI Must Work

1. Work on **one task at a time**, in the order listed below unless a dependency requires a different order.
2. Before changing code, inspect the current `admin_web/` implementation and relevant backend/API contracts.
3. Preserve existing business logic, API contracts, authentication, authorization, state management and navigation unless a change is strictly required for the UI/UX task.
4. Use `shadcn_flutter` as the foundation where it fits, but do not accept a stock-looking result. Wrap/adapt primitives into Snap Foodd-specific components.
5. Prefer reusable design-system components over page-specific styling.
6. Centralize colors, typography, spacing, radii, shadows and motion. Do not scatter arbitrary design values.
7. Use the existing HugeIcons-based icon direction consistently. Do not randomly mix Material/HugeIcons/other icon systems.
8. Keep the UI responsive across desktop, tablet and narrower browser widths.
9. Accessibility is part of the implementation: keyboard/focus states, semantic labels, comfortable targets, readable contrast and non-color-only status communication.
10. Do not fabricate product data, backend capabilities, metrics, workflows or domain concepts.
11. Do not introduce a restaurant concept.
12. Avoid unnecessary dependencies. If a new dependency is genuinely needed, document why.
13. After every task:
    - run the relevant formatter/analyzer/tests/build commands that are actually available;
    - fix regressions caused by the task;
    - inspect the changed files for syntax, overflow and unrelated edits;
    - update this file's task status and change log;
    - record validation performed and any limitations honestly.
14. A task is not complete merely because the code compiles. Review the intended hierarchy, spacing, interaction states and responsive behavior.
15. If a requirement conflicts with an existing API/product constraint, preserve functionality and document the constraint rather than inventing behavior.
16. Do not redesign unrelated mobile/customer screens as part of this admin-web plan.
17. Do not create another Markdown plan/tracker for this work. Update this file.

---

## 2. Current Admin Product Scope

The current admin web application contains these major areas:

- Overview / Dashboard
- Orders
- Catalogue
- Users
- Delivery Partners
- Invoices

The backend remains authoritative for:

- authentication and authorization;
- users/customers;
- products/categories;
- orders and order state;
- delivery partners and assignment;
- invoices/tax/billing data.

The browser is an API client only. It must never connect directly to MySQL or contain server secrets.

---

## 3. Honest Starting Assessment

The current application is a functional foundation, but its visual language currently feels closer to a conventional internal CRUD/admin panel than a premium operations product.

### Strengths

- Clear high-level information architecture.
- Existing central admin shell/sidebar/header.
- Existing shared admin widgets and color definitions.
- `shadcn_flutter` is already available and can provide a strong primitive layer.
- HugeIcons is already used.
- Backend/API boundaries are established.
- Core operational areas are present.
- Previous table overflow work gives a useful base for further refinement.

### Main problems to solve

- Pages feel like separate screens rather than one cohesive product.
- Visual hierarchy is too flat in places.
- Tables are functional but overly mechanical.
- The dashboard can become a collection of equal-weight KPI/chart cards instead of an operational command center.
- Navigation and shell need stronger product identity.
- Some typography is too small for sustained admin use.
- Semantic status colors need to be separated from brand colors.
- Repeated card/table/input patterns need a stronger component system.
- Loading, empty, error and success states need deliberate design.
- Actions should be more contextual and less button-heavy.
- Large page files need gradual component/feature extraction.
- Responsive behavior needs to be treated as a first-class desktop-web requirement.

### Target feeling

**Modern food-commerce operations platform — warm, precise, premium, operational, data-dense without feeling cramped.**

---

## 4. Visual Design System

### 4.1 Brand palette

For `admin_web/`, use the approved admin palette:

| Token | Hex | Intended use |
|---|---|---|
| Brand yellow | `#F2D022` | Primary highlights, selected states, warm emphasis |
| Brand amber | `#F2AE2E` | Secondary emphasis, progress, supporting accents |
| Deep red | `#A61C1C` | Strong red emphasis and warning states |
| Food red | `#D92929` | Primary destructive/error accents and key actions |
| Ink | `#0D0D0D` | Main text and high-contrast elements |

Supporting neutrals:

| Token | Hex |
|---|---|
| Canvas | `#F7F7F5` |
| Surface | `#FFFFFF` |
| Subtle surface | `#FAFAF8` |
| Border | `#E7E7E2` |
| Primary text | `#171717` |
| Secondary text | `#6B6B67` |
| Tertiary text | `#999993` |

Semantic colors must remain distinct from the brand palette:

| Token | Hex | Meaning |
|---|---|---|
| Success | `#16803C` | Successful/healthy/completed |
| Warning | `#B7791F` | Attention/caution |
| Error | `#C53030` | Failure/destructive |
| Info | `#2563EB` | Informational |

**Important:** Do not map success/warning/error to arbitrary brand colors merely because they look attractive. Status meaning must remain predictable.

### 4.2 Typography

Preferred admin typeface: **Inter** for dense operational readability. If the existing project already has a stable Plus Jakarta Sans implementation that is visually stronger and technically reliable, evaluate it before changing the font. Do not introduce a second typography system without reason.

Target hierarchy:

| Role | Size | Weight |
|---|---:|---:|
| Display | 32px | 700 |
| Page title | 24px | 700 |
| Section title | 18px | 600–700 |
| Card title | 14–16px | 600 |
| Body | 14px | 400 |
| Small | 12px | 500 |
| Caption | 11–12px | 500 |

Avoid using 10px or 11px for normal content. Small text should remain readable during long admin sessions.

### 4.3 Spacing

Use a consistent rhythm:

`4, 8, 12, 16, 20, 24, 32, 40, 48, 64`

Typical page values:

- Page horizontal padding: 24–32px on wide desktop.
- Section gap: 24–32px.
- Card internal padding: 16–24px.
- Table cell padding: generous enough for scanning.
- Do not use arbitrary one-off spacing without a clear reason.

### 4.4 Shape

Recommended:

- Small controls: 6–8px
- Inputs/buttons: 8–10px
- Standard cards: 12px
- Large feature surfaces: 16px
- Pills/badges: full radius

Avoid excessive rounding. Premium does not mean every element is a pill.

### 4.5 Elevation

Prefer borders and surface contrast over heavy shadows.

- Level 0: canvas.
- Level 1: white surface + subtle border.
- Level 2: drawer/popover/floating surface.
- Level 3: modal/command palette.

Avoid large dark shadows, glassmorphism and decorative gradients.

### 4.6 Icons

Use HugeIcons consistently.

Recommended sizes:

- Navigation: 18px
- Toolbar: 18px
- Inline: 16px
- Primary action: 18px
- Empty-state illustration/icon: 32–40px
- Feature icon: 40–48px

Do not mix multiple icon libraries casually.

---

## 5. Application Shell

Target navigation:

```
SNAP FOODD

WORKSPACE
  Overview

OPERATIONS
  Orders
  Delivery Partners

CATALOGUE
  Products
  Categories

CUSTOMERS
  Users

FINANCE
  Invoices

----------------
System status
Admin profile
```

Requirements:

- Rename/reframe Dashboard as **Overview** where technically appropriate.
- Sidebar target width: roughly 240–256px.
- Group navigation by workflow rather than presenting a flat list.
- Active navigation should be clear but restrained.
- Header should provide page context, search, notifications if supported, and profile access.
- Add responsive collapsed/drawer navigation.
- Keep the shell visually consistent on every page.
- Do not add restaurant navigation.
- Add subtle system-status/admin identity treatment only where supported by existing data.
- Introduce a global command/search experience in a later dedicated task.

---

## 6. Snap Foodd Admin Component System

Create or evolve a reusable component layer, preferably under a clear design-system/widgets structure:

```
admin_web/lib/
  design_system/
    colors.dart
    typography.dart
    spacing.dart
    radii.dart
    shadows.dart
    motion.dart
    theme.dart

  widgets/
    sf_button.dart
    sf_input.dart
    sf_card.dart
    sf_table.dart
    sf_badge.dart
    sf_avatar.dart
    sf_drawer.dart
    sf_page_header.dart
    sf_empty_state.dart
    sf_error_state.dart
    sf_skeleton.dart
    sf_filter_bar.dart
    sf_stat.dart
    sf_status_badge.dart
    sf_command_palette.dart
    sf_entity_drawer.dart
```

Exact file organization may follow the existing architecture when cleaner. The important requirement is central reuse.

Core components:

- `SfButton`
- `SfIconButton`
- `SfSearchField`
- `SfInput`
- `SfSelect`
- `SfBadge`
- `SfStatusBadge`
- `SfStat`
- `SfCard`
- `SfPageHeader`
- `SfFilterBar`
- `SfDataTable`
- `SfAvatar`
- `SfDrawer`
- `SfEntityDrawer`
- `SfEmptyState`
- `SfErrorState`
- `SfSkeleton`
- `SfCommandPalette`

Each reusable component should define appropriate default, hover, pressed, selected, disabled, loading and focus behavior where applicable.

---

# 7. Phased Task Plan

## Phase 1 — Design Foundation

### Task 1 — Establish the Admin Design System
**Status:** ⬜ Not Started

Implement the centralized visual foundation.

Requirements:

- Audit current `AdminColors`, theme and shared widgets.
- Correct semantic color mappings.
- Add centralized typography tokens.
- Add spacing tokens.
- Add radius tokens.
- Add elevation/shadow tokens.
- Add motion tokens.
- Ensure `shadcn_flutter` theme integration is intentional.
- Remove duplicated hard-coded visual values where practical.
- Keep the approved admin palette.
- Do not modify customer/mobile design tokens as part of this task.

**Done when:** all subsequent admin screens can consume the same design tokens without scattering raw design values.

---

### Task 2 — Build Snap Foodd Admin Core Components
**Status:** ⬜ Not Started

Build/adapt reusable branded primitives:

- buttons;
- icon buttons;
- inputs/search;
- badges/status badges;
- cards;
- stat blocks;
- page headers;
- avatars;
- filter bars;
- table primitives;
- empty/error/loading/skeleton states.

Use `shadcn_flutter` underneath where useful, but make the final visual language Snap Foodd-specific.

**Done when:** repeated page UI can be replaced by shared components instead of private one-off widgets.

---

## Phase 2 — Shell & Navigation

### Task 3 — Redesign Admin Shell and Sidebar
**Status:** ⬜ Not Started

Redesign:

- sidebar;
- navigation grouping;
- active state;
- header;
- page title context;
- responsive collapse/drawer behavior;
- profile area;
- system-status area where supported.

Requirements:

- Modern SaaS-quality composition.
- No oversized navigation buttons.
- Strong spacing and typography hierarchy.
- No restaurant concepts.
- Preserve routing and authentication behavior.

**Done when:** every admin page feels like part of one product before page-specific redesign begins.

---

### Task 4 — Add Global Search / Command Palette
**Status:** ⬜ Not Started

Create a command/search experience inspired by modern operations tools.

Target header affordance:

**Search orders, users, products…  `⌘ K`**

Requirements:

- Keyboard shortcut where supported.
- Search across supported entities.
- Recent items/quick actions only if real data exists.
- Clear empty/loading states.
- Escape closes.
- Focus is obvious.
- Do not fabricate search results.

**Done when:** admins can quickly reach supported entities/actions without manually navigating multiple pages.

---

## Phase 3 — Shared Data UX

### Task 5 — Build Premium Data Tables
**Status:** ⬜ Not Started

Create a reusable admin table experience.

Requirements:

- Strong table header hierarchy.
- Row height around 64–72px where content permits.
- Comfortable cell padding.
- Row hover state.
- Selected state.
- Sticky header where useful.
- Horizontal overflow handled intentionally.
- Search/filter toolbar.
- Filter chips.
- Pagination.
- Column alignment.
- Contextual kebab menu instead of multiple visible action buttons.
- Clickable rows where appropriate.
- Avatars/status badges where meaningful.
- Empty/loading/error states.
- No clipping or accidental overflow.

**Done when:** Users, Orders, Partners and Invoices can share the same table language.

---

### Task 6 — Build Drawers, Dialogs and Feedback States
**Status:** ⬜ Not Started

Create reusable:

- right-side entity drawer;
- confirmation dialog;
- form dialog;
- empty state;
- error state;
- skeleton;
- inline validation;
- success feedback.

Target entity-detail pattern:

**List → right-side detail drawer → contextual action**

Avoid navigating away from an operational list unnecessarily.

---

## Phase 4 — Overview

### Task 7 — Redesign Overview as an Operations Command Center
**Status:** ⬜ Not Started

The Overview should answer:

1. How is the business doing?
2. What needs my attention?
3. What is happening right now?

Suggested structure:

- concise KPI strip;
- Attention Required section;
- live operational summary;
- order activity;
- delivery-partner availability;
- sales/revenue trend;
- useful recent activity.

Example attention items, only when supported by real data:

- delayed orders;
- orders without delivery assignment;
- delivery partners awaiting approval;
- invoice anomalies.

Avoid turning the page into a chart museum.

**Done when:** the first viewport communicates operational health and actionable work immediately.

---

## Phase 5 — Orders

### Task 8 — Redesign Orders as the Core Operations Workspace
**Status:** ⬜ Not Started

Orders are the operational heart of the admin application.

Requirements:

- Status filters: All / New / Preparing / Ready / Out for delivery / Delivered, adapted to actual backend states.
- Search.
- Useful filter bar.
- Scan-friendly table/list.
- Status badges with accessible labels.
- Clear customer/order/value hierarchy.
- Delivery assignment visibility where supported.
- Contextual actions.
- Right-side order detail drawer.

Order drawer should show supported:

- order identity;
- customer;
- items;
- quantities;
- amounts;
- status;
- delivery assignment;
- timeline/history;
- supported actions.

Do not invent restaurant information.

---

## Phase 6 — Catalogue

### Task 9 — Redesign Catalogue / Products
**Status:** ⬜ Not Started

Move beyond a database-only presentation.

Requirements:

- Product image-led cards/grid.
- Table/list toggle.
- Strong product name/price hierarchy.
- Availability status.
- Category metadata.
- Add Product action must remain clearly visible.
- Search/filter/sort.
- Responsive layout.
- Product detail/edit drawer or polished form flow.
- Use actual backend data only.

Recommended product card:

- image;
- product name;
- category;
- price;
- availability;
- contextual actions.

Do not add restaurant metadata.

---

### Task 10 — Redesign Categories Management
**Status:** 🟢 Complete

Requirements:

- Clear category hierarchy.
- Search/filter where useful.
- Add/edit/delete actions.
- Strong empty state.
- Clear confirmation for destructive actions.
- Reuse shared form/table components.
- Keep the interaction lightweight and fast.

---

## Phase 7 — Users

### Task 11 — Redesign Users
**Status:** ⬜ Not Started

Requirements:

- Modern table hierarchy.
- Avatar/initials.
- Name and contact hierarchy.
- Role/status badges where supported.
- Search/filter.
- Comfortable row spacing.
- No clipped columns.
- Responsive overflow.
- Right-side user detail drawer.
- Contextual row actions.

Avoid presenting every possible action as a visible button.

---

## Phase 8 — Delivery Partners

### Task 12 — Redesign Delivery Partners as an Operations View
**Status:** ⬜ Not Started

This page should communicate operational availability, not just CRUD records.

Use supported metrics/states such as:

- online;
- offline;
- active delivery;
- awaiting approval;
- suspended/inactive where supported.

Requirements:

- status-first visual hierarchy;
- availability indicators;
- assignment context where supported;
- search/filter;
- responsive table;
- detail drawer;
- approval/status actions where supported.

Do not fabricate live-location or telemetry data if the backend does not provide it.

---

## Phase 9 — Finance

### Task 13 — Redesign Invoices / Billing
**Status:** ⬜ Not Started

The finance surface should feel precise and quieter than operations screens.

Requirements:

- invoice number;
- customer/order relationship where supported;
- amount;
- status;
- date;
- search/filter;
- date/amount/status filtering where supported;
- detail drawer;
- clear totals;
- export/download only if an existing supported capability exists.

Avoid excessive brand color. Precision and readability take priority.

---

## Phase 10 — Forms & Interaction Polish

### Task 14 — Premium Form UX
**Status:** ⬜ Not Started

Standardize:

- form sections;
- labels;
- helper text;
- validation;
- error placement;
- required-field treatment;
- focus states;
- disabled states;
- save/cancel behavior;
- destructive confirmations.

Suggested product form sections:

1. Basic information
2. Category
3. Pricing
4. Availability
5. Product image

Adapt sections to actual API fields.

---

### Task 15 — Loading, Empty, Error and Success UX
**Status:** ⬜ Not Started

Audit every admin page.

Replace:

- generic spinners;
- plain empty text;
- unexplained failures;
- inconsistent snackbars.

Use reusable branded states with useful next actions.

Examples:

- Empty catalogue → “Add your first product”
- No orders → explain the state and provide refresh/filter action
- API failure → concise explanation + retry
- Loading tables → skeleton rows

---

## Phase 11 — Responsive & Accessibility

### Task 16 — Responsive Admin Web Pass
**Status:** ⬜ Not Started

Target behavior:

| Width | Strategy |
|---|---|
| ≥1440 | Full sidebar + spacious operational layout |
| 1200–1439 | Full sidebar + denser content |
| 900–1199 | Collapsed sidebar + responsive content |
| 600–899 | Drawer navigation + responsive tables |
| <600 | Mobile-specific admin fallback where required |

Requirements:

- no clipped content;
- no accidental horizontal page overflow;
- tables scroll intentionally when necessary;
- drawers/dialogs fit viewport;
- controls remain usable.

---

### Task 17 — Accessibility and Keyboard UX
**Status:** ⬜ Not Started

Audit:

- semantic labels;
- keyboard navigation;
- focus rings;
- contrast;
- tooltip/label clarity;
- table interaction;
- dialog focus management;
- command palette keyboard flow;
- non-color-only status communication.

Ensure interactive controls have comfortable targets.

---

## Phase 12 — Motion & Final Polish

### Task 18 — Add Restrained Motion and Micro-interactions
**Status:** ⬜ Not Started

Use motion only to clarify state and hierarchy.

Target ranges:

- Navigation: 150–180ms
- Drawer: 200–250ms
- Table hover: 100–150ms
- Dialog: 180–220ms
- KPI updates: 300–500ms

Requirements:

- subtle hover/pressed feedback;
- drawer transitions;
- status changes;
- skeleton transitions;
- reduced-motion consideration.

Avoid decorative animation that slows admin work.

---

### Task 19 — Final Visual QA and Cleanup
**Status:** ⬜ Not Started

Perform a complete audit of:

- Overview;
- Orders;
- Catalogue;
- Categories;
- Users;
- Delivery Partners;
- Invoices;
- Login;
- shell/navigation.

Check:

- typography;
- spacing;
- colors;
- hierarchy;
- alignment;
- borders;
- radius;
- overflow;
- loading/empty/error states;
- hover/focus/pressed states;
- responsive layouts;
- accessibility;
- consistency of components;
- unused/dead UI;
- duplicate styling.

Refactor obvious duplication and remove obsolete UI artifacts where safe.

**Done when:** the admin feels like one cohesive premium operations product rather than a collection of individually styled CRUD pages.

---

## 8. Explicitly Avoid

Do not introduce:

- restaurant concepts;
- restaurant navigation;
- restaurant cards;
- restaurant menus;
- restaurant filters;
- fake ratings/reviews;
- fake analytics;
- fake live delivery telemetry;
- excessive gradients;
- glassmorphism;
- giant shadows;
- excessive yellow backgrounds;
- giant cards;
- tiny text;
- multiple competing icon libraries;
- three or more visible row action buttons;
- unnecessary animations;
- chart-heavy dashboards with little operational value;
- arbitrary hard-coded colors;
- arbitrary screen-specific spacing;
- backend/business-logic rewrites during UI-only tasks.

---

## 9. Definition of Done

The admin UI/UX modernization is complete when:

1. The admin has one coherent visual language.
2. Design tokens are centralized.
3. Core components are reusable.
4. Navigation and shell feel modern and consistent.
5. Overview is operationally useful.
6. Orders are a strong command-center workflow.
7. Catalogue is visual and efficient.
8. Users, Delivery Partners and Invoices share a consistent data UX.
9. Tables no longer feel like raw database grids.
10. Drawers reduce unnecessary navigation.
11. Forms are consistent and trustworthy.
12. Loading/empty/error states are polished.
13. Responsive behavior is intentional.
14. Accessibility has been reviewed.
15. Motion is restrained and purposeful.
16. No restaurant concept has been introduced.
17. Existing business/API behavior remains intact unless explicitly documented.
18. Relevant formatting, analysis, tests and builds have been run where available.
19. This document accurately records all completed, blocked and not-applicable work.

---

## 10. Progress Tracker

| Task | Status | Last Updated | Notes |
|---|---|---|---|
| Task 1 — Admin Design System | 🟢 Complete | 2026-10-03 | Centralized admin color, typography, spacing, radius, elevation, motion and Material/shadcn theme tokens; legacy AdminColors now aliases the semantic token layer. Validation commands could not be executed through the available GitHub connector. |
| Task 2 — Core Components | 🟢 Complete | 2026-10-03 | Added branded reusable buttons, icon buttons, inputs/search, badges/status badges, cards, stat blocks, page headers, filter bars, empty/error/skeleton states and avatars; legacy AdminCard now consumes SfCard. Validation commands could not be executed through the available GitHub connector. |
| Task 3 — Admin Shell & Sidebar | 🟢 Complete | 2026-10-03 | Redesigned the admin shell with grouped navigation, restrained active states, responsive drawer navigation, contextual header, section search, admin profile access and supported system-status treatment. Preserved routing/authentication and did not introduce restaurant concepts. Validation commands could not be executed through the available GitHub connector. |
| Task 4 — Global Search / Command Palette | 🟢 Complete | 2026-10-03 | Added a reusable command palette with ⌘K/Ctrl+K access, section navigation, supported catalogue quick actions, Escape/Enter handling, focus management and query handoff into the existing section search APIs. No fabricated entity results were introduced. |
| Task 5 — Premium Data Tables | 🟢 Complete | 2026-10-03 | Reusable SfDataTable/SfTablePagination added; Users, Delivery Partners and Invoices migrated to shared table language with intentional overflow, density, status badges, avatars and pagination. |
| Task 6 — Drawers, Dialogs & Feedback | 🟢 Complete | 2026-10-03 | Added shared side-drawer, confirmation-dialog and success/error/info feedback primitives; integrated shared feedback into Catalogue and Delivery Partner action flows while preserving existing supported dialogs and backend behavior. |
| Task 7 — Overview | 🟢 Complete | 2026-10-03 | Reworked the admin overview hierarchy around shared design-system spacing, responsive KPI grouping, operational snapshot and preview sales trend; removed restaurant/kitchen-specific terminology and clarified that the current aggregates are preview data rather than fabricated live metrics. |
| Task 8 — Orders | 🟢 Complete | 2026-10-03 | Refined the operational order queue/detail experience with centralized design tokens, responsive hierarchy, truthful API-state messaging, shared confirmation/feedback primitives, cleaner status progression and removal of unsupported POS/node/sync/KOT/charge metadata. |
| Task 9 — Catalogue / Products | 🟢 Complete | 2026-10-03 | Refined the product catalogue and category-management experience with centralized tokens, readable hierarchy, responsive editor sizing, shared feedback and truthful item/category workflows while preserving existing API behavior. |
| Task 10 — Categories | 🟢 Complete | 2026-10-03 | Added a dedicated Categories admin area with searchable shared-table presentation, active/inactive state management, create/edit/delete workflows, confirmation for destructive actions, preview/live data clarity and responsive empty/error/loading states. |
| Task 11 — Users | ⬜ Not Started | 2026-10-03 | **NEXT** — redesign the Users experience using the shared table/drawer language while preserving existing user APIs and detail flows. |
| Task 12 — Delivery Partners | ⬜ Not Started | 2026-10-03 | |
| Task 13 — Invoices / Billing | ⬜ Not Started | 2026-10-03 | |
| Task 14 — Premium Form UX | ⬜ Not Started | 2026-10-03 | |
| Task 15 — Loading / Empty / Error / Success | ⬜ Not Started | 2026-10-03 | |
| Task 16 — Responsive Admin Web | ⬜ Not Started | 2026-10-03 | |
| Task 17 — Accessibility / Keyboard UX | ⬜ Not Started | 2026-10-03 | |
| Task 18 — Motion & Micro-interactions | ⬜ Not Started | 2026-10-03 | |
| Task 19 — Final Visual QA & Cleanup | ⬜ Not Started | 2026-10-03 | |

### Status meanings

- ⬜ Not Started
- 🟡 In Progress
- 🟢 Complete
- 🔴 Blocked
- ⏭️ Not Applicable

---

## 11. Change Log

### 2026-10-03

- Removed the completed customer mobile UI/UX task plan so it does not compete with the active work.
- Established this document as the single working source of truth for the admin Flutter Web UI/UX modernization.
- Established **Modern Food-Commerce Operations Platform** as the admin visual direction.
- Confirmed that Snap Foodd has no restaurant concept and that restaurant-specific admin UX must not be introduced.
- Defined the admin color, typography, spacing, shape, elevation, icon and motion direction.
- Defined the phased implementation order from design foundation through final QA.

### 2026-10-03 — Task 1
- Status: 🟢 Complete
- Implemented:
  - Added centralized admin design-system tokens for colors, typography, spacing, radii, shadows and motion.
  - Added intentional Material 3 and shadcn_flutter theme factories using the approved admin palette and semantic status colors.
  - Updated the existing admin theme wiring to consume the centralized theme.
  - Migrated the legacy AdminColors surface to aliases of the new centralized tokens without changing customer/mobile tokens.
  - Kept the existing HugeIcons and shadcn_flutter architecture intact.
- Files/components changed:
  - `admin_web/lib/design_system/colors.dart`
  - `admin_web/lib/design_system/typography.dart`
  - `admin_web/lib/design_system/spacing.dart`
  - `admin_web/lib/design_system/radii.dart`
  - `admin_web/lib/design_system/shadows.dart`
  - `admin_web/lib/design_system/motion.dart`
  - `admin_web/lib/design_system/theme.dart`
  - `admin_web/lib/main.dart`
  - `admin_web/lib/app/admin_shell.dart`
  - `admin_web/lib/widgets/admin_shared.dart`
- Validation:
  - Inspected the existing admin Flutter structure, `pubspec.yaml`, current shared colors/theme, shell and admin CI workflow.
  - Confirmed the repository has an Admin Flutter Web CI workflow configured to run formatting, analyzer, tests and release web build.
  - No local formatter/analyzer/test/build command was executed because the available GitHub connector exposes repository operations but no shell/CI execution action; no successful validation run is being claimed.
  - Inspected the final changed shared-widget content after correction and confirmed the legacy color alias section is structurally restored.
- Limitations/follow-up:
  - CI execution results were not available from the connector, so Task 1's validation remains dependent on the repository CI runner.
  - Existing page-level hard-coded styling remains intentionally untouched; migrating those values is deferred to the reusable component/page tasks.

### 2026-10-03 — Task 2
- Status: 🟢 Complete
- Implemented:
  - Added a reusable Snap Foodd admin core-component layer in `sf_core_components.dart`.
  - Added `SfButton` with primary, secondary, outline, ghost and destructive variants plus loading/disabled behavior.
  - Added `SfIconButton` with tooltip, selected, hover and focus feedback.
  - Added `SfInput` and `SfSearchField` using the centralized typography and input theme.
  - Added `SfBadge` and semantic `SfStatusBadge` so status meaning is not tied to brand colors.
  - Added `SfCard` and `SfStat` for consistent surfaces and operational metrics.
  - Added responsive `SfPageHeader` and `SfFilterBar`.
  - Added reusable `SfEmptyState`, `SfErrorState` and animated `SfSkeleton`.
  - Added accessible `SfAvatar` with image and initials fallback.
  - Registered the component layer in the main admin library and migrated the existing `AdminCard` wrapper to consume `SfCard`.
  - Kept HugeIcons as the admin icon system and avoided restaurant-specific UI or fabricated backend behavior.
- Files/components changed:
  - `admin_web/lib/widgets/sf_core_components.dart`
  - `admin_web/lib/main.dart`
  - `admin_web/lib/widgets/admin_shared.dart`
- Validation:
  - Inspected the existing shared admin widgets, shell, pubspec and design-system layer before implementation.
  - Reviewed the new component source after correcting a border-construction issue.
  - No local formatter/analyzer/test/build command was executed because the available GitHub connector exposes repository operations but no shell/CI execution action; no successful validation run is being claimed.
- Limitations/follow-up:
  - `SfDataTable`, `SfDrawer`, `SfEntityDrawer` and `SfCommandPalette` remain intentionally deferred to their dedicated tasks because they require broader interaction/API context.
  - Existing page-specific widgets have not yet been migrated wholesale; that migration belongs to the table, drawer and individual page tasks.

### 2026-10-03 — Task 3
- Status: 🟢 Complete
- Implemented:
  - Redesigned the admin shell around the centralized design-system tokens and a consistent 248px desktop sidebar.
  - Reframed Dashboard as **Overview** and grouped navigation into Workspace, Operations, Catalogue, Customers and Finance.
  - Replaced the oversized shadcn navigation buttons with compact reusable navigation items with restrained active, hover and pressed feedback.
  - Added supported system-status and admin identity treatment to the sidebar.
  - Added responsive navigation behavior: full sidebar on desktop and a shadcn drawer overlay on narrower widths.
  - Added responsive header context with section title, search field, notifications affordance and admin profile/logout menu.
  - Standardized page heading treatment across all sections, including Partners and Invoices, and retained Catalogue-specific actions.
  - Updated shell spacing, canvas/surface treatment and typography to consume centralized design tokens.
  - Preserved existing section switching, authentication/logout callbacks, catalogue actions and page-level API behavior.
  - Confirmed no restaurant concept was introduced.
- Files/components changed:
  - admin_web/lib/app/admin_shell.dart
- Validation:
  - Re-fetched and inspected the final shell source after implementation.
  - Verified the final shell contains the new grouped navigation, responsive navigation trigger/drawer, profile/system-status treatment and shared page heading path.
  - Verified no restaurant terminology was introduced in the shell implementation.
  - Checked GitHub Actions workflow runs associated with the final commit; no workflow run was returned by the available connector.
  - No local formatter/analyzer/test/build command was executed because the available GitHub connector exposes repository operations but no shell/CI execution action; no successful validation run is being claimed.
- Limitations/follow-up:
  - Browser screenshot/interactive visual QA remains to be performed in an environment capable of running the Flutter Web app.
  - Global command-palette behavior remains intentionally deferred to Task 4.
  - Detailed table/drawer/page redesign remains deferred to Tasks 5 onward.

### 2026-10-03 — Task 4
- Status: 🟢 Complete
- Implemented:
  - Added a reusable SfCommandPalette for the admin web application.
  - Added global ⌘ K / Ctrl + K keyboard activation through the browser keydown stream.
  - Added a clear header search affordance with the supported shortcut hint and a responsive search icon on narrower widths.
  - Added searchable navigation across the existing admin sections: Overview, Orders, Products & Catalogue, Users, Delivery Partners and Invoices & Billing.
  - When a query is entered, the palette can hand that query to the selected section's existing search flow rather than fabricating cross-entity results.
  - Added supported catalogue quick actions for Add product and Manage categories when the admin is already in Catalogue.
  - Added Escape-to-close, Enter-to-submit, visible focus, semantic labels and an explicit empty state.
  - Preserved existing page APIs, routing and authentication behavior.
  - Confirmed no restaurant concept or fabricated entity data was introduced.
- Files/components changed:
  - admin_web/lib/widgets/sf_command_palette.dart
  - admin_web/lib/main.dart
  - admin_web/lib/app/admin_shell.dart
- Validation:
  - Re-fetched and inspected the final command-palette component and shell integration after the sequential edits.
  - Verified the widget is registered in main.dart.
  - Verified the shell owns the global keyboard listener and cancels the subscription during disposal.
  - Verified command-palette queries are routed to the existing section search query rather than invented result records.
  - Verified the implementation uses existing HugeIcons and centralized admin design tokens.
  - No local formatter/analyzer/test/build command was executed because the available GitHub connector exposes repository operations but no shell/CI execution action; no successful validation run is being claimed.
- Limitations/follow-up:
  - The palette currently navigates/searches through supported admin sections; it does not invent a separate global entity index because the browser has no authoritative aggregated search endpoint.
  - Full browser interaction and visual QA remain dependent on a runnable Flutter Web environment.
  - Dedicated data-table, drawer and feedback work remains deferred to Tasks 5 and 6.
### 2026-10-03 — Task 5
- Status: 🟢 Complete
- Implemented:
  - Added reusable `SfDataTable` and `SfTablePagination` primitives.
  - Standardized table headers, cell padding, row height, hover behavior, borders and horizontal overflow handling.
  - Added contextual row interaction through whole-row tap plus compact icon action affordances.
  - Migrated Users to the shared table component with avatars, role/status badges, aligned numeric columns and detail access.
  - Migrated Delivery Partners to the shared table component with operational status, approval state and compact approval action.
  - Migrated Invoices to the shared table component with invoice/order hierarchy, customer information, totals, payment state and pagination.
  - Kept existing API models, backend contracts, filters and page-specific detail flows intact.
  - Orders already have page-specific operational behavior and remain a follow-up integration candidate where its current layout can be safely migrated without changing business behavior.
  - No restaurant concept or fabricated backend data was introduced.
- Files/components changed:
  - admin_web/lib/widgets/sf_data_table.dart
  - admin_web/lib/main.dart
  - admin_web/lib/pages/users_page.dart
  - admin_web/lib/pages/partners_page.dart
  - admin_web/lib/pages/invoices_page.dart
- Validation:
  - Re-fetched and inspected the updated component and migrated pages after implementation.
  - Verified the shared component is registered in `main.dart`.
  - Verified Users, Delivery Partners and Invoices reference `SfDataTable`.
  - Verified table sizing uses explicit minimum/natural widths and horizontal scrolling rather than clipping cells.
  - Verified status badges and avatars use shared components/design tokens.
  - No local formatter/analyzer/test/build command was executed because the available GitHub connector exposes repository operations but no shell/CI execution action; no successful validation run is being claimed.
- Limitations/follow-up:
  - Orders retain their existing specialized operational list/table implementation pending a safe migration pass.
  - Sticky headers, advanced sorting and multi-select are not added because current backend/page contracts do not require them.
  - Full browser visual/overflow QA remains dependent on a runnable Flutter Web environment.

### 2026-10-03 — Task 6
- Status: 🟢 Complete
- Implemented:
  - Added reusable `SfSideDrawer` with right-side slide transition, barrier dismissal, safe-area handling, close affordance and scrollable content.
  - Added reusable `SfConfirmDialog` with destructive/non-destructive confirmation variants.
  - Added `SfFeedback` success/error/info messaging with consistent floating feedback treatment and semantic icons.
  - Integrated shared feedback into Catalogue save/deactivate/error flows.
  - Integrated shared feedback into Delivery Partner approval/error flows.
  - Preserved the existing Catalogue product editor dialog and other page-specific overlays rather than replacing working business flows unnecessarily.
  - No fabricated backend operations, KYC capabilities or restaurant concepts introduced.
- Files/components changed:
  - `admin_web/lib/widgets/sf_feedback_components.dart`
  - `admin_web/lib/main.dart`
  - `admin_web/lib/pages/catalogue_page.dart`
  - `admin_web/lib/pages/partners_page.dart`
- Validation:
  - Re-fetched final component and integration files.
  - Verified the feedback component is registered in `main.dart`.
  - Verified Catalogue and Delivery Partner flows reference shared feedback.
  - Verified shared drawer/dialog primitives use centralized motion, spacing, typography and semantic color tokens.
  - No local formatter/analyzer/test/build command was executed because the available GitHub connector exposes repository operations but no shell/CI execution action; no successful validation run is being claimed.
- Limitations/follow-up:
  - Existing page-specific dialogs remain in place where they encapsulate active form/business logic.
  - Full browser interaction, focus-trap and visual QA remain dependent on a runnable Flutter Web environment.

### 2026-10-03 — Task 7
- Status: 🟢 Complete
- Implemented:
  - Refined the Overview page into a clearer operational hierarchy: environment notice → KPI summary → sales/operations split → recent orders.
  - Replaced arbitrary spacing in the primary overview layout with centralized admin spacing tokens.
  - Improved responsive KPI and content-column behavior for wide, medium and narrow admin widths.
  - Reused the shared `SfDataTable`, `SfBadge`, `SfStatusBadge` and design-system typography language for the recent-orders surface.
  - Reframed the dashboard connection banner so preview mode is explicit and live aggregates are not implied.
  - Removed restaurant/cloud-kitchen terminology and replaced it with Snap Foodd operational concepts such as orders, preparation, dispatch and delivery partners.
  - Preserved the existing preview dataset rather than inventing new backend metrics or API capabilities.
- Files/components changed:
  - `admin_web/lib/pages/dashboard_page.dart`
- Validation:
  - Re-fetched the final Overview source after both implementation commits.
  - Verified the final source no longer contains restaurant, kitchen, cloud-kitchen or menu-item terminology.
  - Verified the shared table/design-system components are used by the Overview.
  - No local formatter/analyzer/test/build command was executed because the available GitHub connector exposes repository operations but no shell/CI execution action; no successful validation run is being claimed.
- Limitations/follow-up:
  - Overview figures remain the application's existing preview dataset and are explicitly presented as preview data.
  - Live dashboard aggregation should be implemented only when the authoritative backend/API contract exposes those aggregates.

### 2026-10-03 — Task 8
- Status: 🟢 Complete
- Implemented:
  - Modernized the Orders header and action hierarchy around the existing live order API and CSV export capability.
  - Replaced scattered legacy `AdminColors` usage with centralized admin design tokens.
  - Reworked spacing, typography, borders, status treatments and responsive queue/detail layout to match the shared admin language.
  - Removed unsupported/fabricated UI claims including a specific node identifier, fixed five-second sync claim, manual POS action, estimated dispatch time, hard-coded tax/packaging charge, KOT ticket metadata and unsupported print/share actions.
  - Replaced the existing cancellation overlay with the shared `SfConfirmDialog`.
  - Replaced order mutation/invoice feedback with shared `SfFeedback` success/error/info messaging.
  - Kept the existing authoritative endpoints for order listing, status transitions and invoice retrieval.
  - Preserved CSV export and existing order filtering/status progression behavior.
  - Removed restaurant/kitchen terminology from the order workflow.
- Files/components changed:
  - `admin_web/lib/pages/orders_page.dart`
- Validation:
  - Re-fetched the final Orders source after implementation refinements.
  - Verified zero restaurant, kitchen, cloud-kitchen and KOT terminology remains in the final source.
  - Verified legacy `AdminColors` references were removed from Orders.
  - Verified shared `SfFeedback` and `SfConfirmDialog` usage.
  - No local formatter/analyzer/test/build command was executed because the available GitHub connector exposes repository operations but no shell/CI execution action; no successful validation run is being claimed.
- Limitations/follow-up:
  - Full browser interaction, visual overflow QA and compile-time validation still require a runnable Flutter Web environment.
  - Existing backend/API behavior remains authoritative; no new order capabilities were invented.

### 2026-10-03 — Task 9
- Status: 🟢 Complete
- Implemented:
  - Refined Catalogue spacing, typography, borders, category tabs, product-list hierarchy and editor presentation using the shared admin design system.
  - Preserved the existing grid/list toggle, search, category filtering, food-type filtering, stock filtering, availability filtering and pagination behavior.
  - Preserved existing product create/edit/deactivate flows, image selection/upload and category management API contracts.
  - Replaced Catalogue success/error notices with shared `SfFeedback` messaging.
  - Improved category-management typography and action treatment.
  - Removed legacy `AdminColors` usage from the Catalogue page.
  - Removed invalid restaurant terminology from the catalogue implementation.
  - Kept preview/live behavior explicit rather than inventing new catalogue capabilities or data.
- Files/components changed:
  - `admin_web/lib/pages/catalogue_page.dart`
- Validation:
  - Re-fetched the final Catalogue source after each implementation refinement.
  - Verified zero `AdminColors` references remain in Catalogue.
  - Verified zero restaurant/kitchen/cloud-kitchen terminology remains.
  - Verified shared `SfFeedback` adoption.
  - Reviewed existing editor, category manager, filtering and API-facing repository usage for preservation.
  - No local formatter/analyzer/test/build command was executed because the available GitHub connector exposes repository operations but no shell/CI execution action; no successful validation run is being claimed.
- Limitations/follow-up:
  - Full Flutter Web compile, browser interaction, visual overflow QA and focus behavior still require a runnable Flutter Web environment.
  - Task 10 is complete; Task 11 — Users is the next implementation target.

### 2026-10-03 — Task 10
- Status: 🟢 Complete
- Implemented:
  - Added a dedicated **Categories** admin area instead of keeping category management only inside the Catalogue overlay.
  - Added a searchable category list using the shared SfDataTable, with intentional horizontal overflow, readable column spacing and row-level interaction.
  - Added category name, slug, product count, active/inactive status and sort-order presentation using existing backend fields only.
  - Added create and edit category flows using the shared SfInput and SfButton primitives.
  - Added active/inactive toggling using the existing category PATCH contract.
  - Added destructive delete confirmation through SfConfirmDialog; categories with assigned products remain protected from deletion and are directed toward deactivation instead.
  - Added shared success/error/info feedback plus branded empty, error and loading states.
  - Added explicit Live API / Preview data treatment so preview records are not presented as live backend data.
  - Added Categories to the existing admin navigation and section search/command-palette section list without changing authentication or backend contracts.
  - Preserved the existing Catalogue category-management flow for compatibility; the new page provides the dedicated operational destination requested by Task 10.
  - No restaurant concept or fabricated category capability/data was introduced.
- Files/components changed:
  - admin_web/lib/pages/categories_page.dart
  - admin_web/lib/main.dart
  - admin_web/lib/app/admin_shell.dart
  - ADMIN_WEB_UI_UX_DEVELOPMENT_PLAN.md
- Validation:
  - Re-fetched and inspected the final Categories page, main library registration and admin shell navigation after the sequential implementation edits.
  - Verified the page uses existing _CatalogueRepository category endpoints: /admin/categories, category create/update, active-state update and delete.
  - Verified the page uses shared SfDataTable, SfInput, SfButton, SfStatusBadge, SfIconButton, SfEmptyState, SfErrorState, SfSkeleton, SfConfirmDialog and SfFeedback.
  - Verified Categories is included in AdminSection.values, so existing command-palette navigation/search picks it up automatically.
  - No local formatter/analyzer/test/build command was executed because the available GitHub connector exposes repository operations but no shell/CI execution action; no successful validation run is being claimed.
- Limitations/follow-up:
  - Browser screenshot/interactive visual QA and actual Flutter Web compile validation remain dependent on a runnable environment or CI execution path.
  - The existing Catalogue embedded category manager remains for compatibility and is not removed in this task.
  - Task 11 — Users is now the next implementation target.
### Future entries

After every task, append an entry containing:

- date;
- task;
- status;
- concise implementation summary;
- files/components changed;
- validation performed;
- known limitations/follow-up work.

---

## 12. Task Update Template

When completing a task, update both the **Progress Tracker** and **Change Log**.

Use this structure in the change log:

```
### YYYY-MM-DD — Task N
- Status: 🟢 Complete / 🔴 Blocked / ⏭️ Not Applicable
- Implemented:
  - ...
- Files/components changed:
  - ...
- Validation:
  - ...
- Limitations/follow-up:
  - ...
```

Never claim tests, builds, screenshots or visual checks were performed unless they were actually performed.
