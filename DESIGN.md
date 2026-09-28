# Snap Foodd — Design System

## 1. Design authority

The Google Stitch Snap Foodd export is the source of truth for the initial visual product. The repository contains the exported reference images under design-images/ and the complete Stitch export in stitch_snap_food_design_system.zip.

Production Flutter code must reproduce the Stitch screens faithfully. Responsive behavior may adapt layout for viewport, input method, and platform, but must not casually redesign the product.

If implementation and Stitch disagree:
1. Verify the reference.
2. Prefer the documented token/component contract.
3. Record intentional deviations.
4. Fix token/component problems centrally rather than patching individual screens.

## 2. Brand character

Snap Foodd is energetic, appetizing, warm, tactile, and operationally clear.

The system communicates:
- hunger and immediacy for customers,
- clarity and speed for restaurant operations,
- confidence and situational awareness for delivery partners.

Mascot/illustrative moments are selective: onboarding, empty states, and order progress/celebration.

## 3. Color system

The Stitch export defines these semantic colors:

| Token | Value | Use |
|---|---|---|
| surface | #FFF8F5 | Main warm canvas |
| surface-container-low | #FDF1EA | Soft sections |
| surface-container | #F7ECE5 | Tonal containers |
| surface-container-high | #F1E6DF | Elevated tonal surfaces |
| surface-container-highest | #EBE0D9 | Stronger separation |
| surface-container-lowest | #FFFFFF | Cards/modals |
| on-surface | #201B17 | Primary text |
| on-surface-variant | #4E4634 | Secondary text |
| outline | #7F7662 | Strong outlines |
| outline-variant | #D1C5AE | Soft borders |
| primary | #755B00 | Primary semantic color |
| primary-container | #E4B935 | Brand gold |
| on-primary | #FFFFFF | Text on primary |
| secondary | #B32910 | Red semantic action |
| secondary-container | #FA5B3D | Red container |
| on-secondary | #FFFFFF | Text on red |
| tertiary | #686000 | Tertiary semantic color |
| tertiary-container | #D1C100 | Accent surface |
| error | #BA1A1A | Error/destructive |

The generated Stitch style also describes these practical brand values:
- Golden Yellow: #E4B935
- Food Red: #D54126
- Accent Yellow: #FBE929
- Warm Black: #1E1915
- Cream canvas: #FFFDF7
- Soft border: #E9E4D8
- Soft yellow: #FFF3C4
- Soft red: #FBE3DC

Flutter implementation must map these into semantic tokens/ColorScheme rather than scattering hex values through widgets.

## 4. Typography

Typeface: Plus Jakarta Sans.

| Token | Size | Weight | Line height |
|---|---:|---:|---:|
| headline-xl | 40 | 800 | 48 |
| headline-xl-mobile | 32 | 800 | 38 |
| headline-lg | 32 | 700 | 40 |
| headline-lg-mobile | 26 | 700 | 32 |
| headline-md | 24 | 700 | 30 |
| headline-sm | 20 | 700 | 26 |
| title-md | 18 | 600 | 24 |
| title-sm | 16 | 600 | 22 |
| body-lg | 16 | 400 | 24 |
| body-md | 14 | 400 | 20 |
| body-sm | 12 | 400 | 16 |
| label-lg | 14 | 700 | 18 |
| label-md | 12 | 700 | 16 |
| label-sm | 11 | 600 | 14 |

Prices use bold/extra-bold styles. Restaurant metadata, ETA, distance, and ratings use compact body/label styles.

## 5. Spacing

Snap Foodd follows a 4/8 px rhythm:

    space-xs  = 4px
    space-sm  = 8px
    space-md  = 16px
    space-lg  = 24px
    space-xl  = 32px
    space-xxl = 48px

Primary layout values:
- Mobile gutter: 12px
- Mobile outer margin: 16px
- Desktop baseline margin: 24px
- Stitch base gutter: 16px
- Stitch desktop max content width: 1200px

Avoid arbitrary spacing values without a visual/platform reason.

## 6. Shape language

    sm   = 4px
    base = 8px
    md   = 12px
    lg   = 16px
    xl   = 24px
    full = 9999px

Cards, inputs, and list tiles generally use 12–16px radii. Chips, badges, and high-frequency actions use pill/full radius.

## 7. Elevation

### Level 0
Warm cream canvas, no shadow.

### Level 1
White cards/sections with:

    0 2px 8px -2px rgba(30, 25, 21, 0.04)

### Level 2
Floating/interactive food and merchant surfaces:

    0 6px 16px -4px rgba(30, 25, 21, 0.08)

### Level 3
Sticky checkout/cart, bottom navigation, and modal surfaces:

    0 12px 32px -6px rgba(30, 25, 21, 0.12)

## 8. Responsive layout

### Compact — phone / narrow browser
- 4-column conceptual grid
- 12px gutters
- 16px outer margins
- Safe-area-aware bottom clearance
- Bottom navigation where specified
- Horizontal dish rows
- Sticky cart/checkout actions

### Medium — tablet / small desktop
- 8-column conceptual grid
- 16px gutters
- 24px margins
- Dual-pane patterns where operational context benefits from them

### Expanded — desktop / wide web
- 12-column grid
- 24px baseline gutters
- Customer content capped around 1200px
- Persistent operational navigation/panels where appropriate
- Multi-column KDS/order layouts

Responsive code must use centralized layout primitives and semantic breakpoints, not repeated raw pixel checks.

## 9. Core components

### Buttons

Primary conversion/action:
- Food-red treatment where the Stitch screen calls for immediate conversion.
- White text.
- Bold/extra-bold label.
- Minimum mobile height: 52px.
- Full pill radius.
- Optional subtle 0.98 press scale.

Secondary:
- Golden #E4B935.
- Warm-dark text.

Utility:
- White surface.
- 1–1.5px soft border.
- Warm-dark text.

### Chips / filters

Inactive:
- white background
- 1px soft border
- warm-dark text

Active:
- #FFF3C4 background
- 1.5px #E4B935 border
- bold text

### Merchant card

- White surface
- 16px radius
- Soft border
- 16:9 food image
- ETA/delivery badges where shown
- Restaurant title in title-md
- Rating/metadata in compact styles
- Yellow rating-star accent

### Dish row

- Text/details on left
- Bold price
- Compact description
- Square 84px thumbnail
- Floating + action overlapping image edge where shown

### Inputs

- 48px height
- White surface
- 1.5px soft border
- 12px radius
- Golden focus border
- Subtle 3px golden focus ring

### Quantity stepper

- Pill container
- Soft yellow background
- Chunky + / − affordances
- Centered quantity

### Selection controls

- Food-red selected state
- White indicator
- Warm-dark outline when unselected
- Never communicate state through color alone

## 10. Navigation

### Customer
Fast discovery and one-thumb browsing on compact screens. Bottom navigation is the mobile pattern; expanded layouts may use a sidebar/header while retaining the same destinations.

Core destinations include Home, discovery/search, Cart, Orders, and Profile according to the supplied Stitch flow.

### Restaurant Partner is deferred for the current release; keep any existing restaurant visuals as reference only.


## 11. Safe areas

The Stitch HTML uses viewport-fit/safe-area behavior. Flutter implementations must use platform-aware SafeArea and insets rather than hard-coded system-bar offsets.

Sticky bottom controls must reserve content space.

## 12. Images and media

Food imagery is a major product element.

Production implementation must:
- Preserve reference crop/aspect ratio.
- Use appropriate image variants.
- Provide loading placeholders.
- Handle failed/missing images.
- Avoid downloading full originals when unnecessary.
- Use controlled, licensed production media via object storage/CDN.

Remote image URLs from Stitch are reference content, not the production asset-hosting strategy.

## 13. Maps and tracking

Delivery/live-order screens use map concepts. Phase 1 may use deterministic mock map content.

Production maps must sit behind a Snap Foodd map abstraction so order/delivery business logic is not coupled to one SDK.

Location state and map rendering state are separate. GPS/network/map failures have explicit degraded states.

## 14. Mascot and illustration

Primary contexts:
- Onboarding
- Empty search/cart states
- Live order progress
- Order celebration

Do not place mascot artwork into ordinary rows/cards without a design reason.

## 15. Accessibility

Visual fidelity does not override accessibility.

Required:
- Semantic labels for actions/icons.
- Keyboard navigation on desktop/web where applicable.
- Visible focus states.
- Comfortable touch targets.
- Text scaling support where practical.
- Order/delivery state cannot rely on color alone.
- Form errors have textual/semantic representation.
- Reduced-motion path for meaningful animations.

## 16. Motion

Motion communicates state.

High-value examples:
- Button press feedback
- Cart quantity transitions
- Order progress
- Delivery marker movement
- Mascot/order celebration

Animation must not block critical operations or make KDS/delivery workflows slower.

## 17. Implementation rules

### Do
- Centralize tokens.
- Reuse repeated Stitch patterns.
- Compare screenshots against Stitch references.
- Make responsive changes intentional.
- Keep logic out of widgets.
- Fix token problems centrally.

### Do not
- Copy generated Stitch HTML directly into Flutter.
- Duplicate the same component across domains unnecessarily.
- Hard-code random dimensions to match one screenshot.
- Fall back to default Material styling that conflicts with Snap Foodd.
- Introduce package widgets whose visual language conflicts with the design.
- Put backend calls or business calculations inside widgets.

## 18. Visual QA contract

Every completed Stitch screen is reviewed at:
1. Reference viewport
2. Compact phone
3. Medium/tablet
4. Expanded desktop/web

Review:
- Geometry
- Typography
- Color
- Spacing
- Image crop
- Radius
- Elevation
- Navigation
- Interaction states
- Accessibility

A mismatch caused by a token/component error is fixed centrally, not with a screen-specific patch.
