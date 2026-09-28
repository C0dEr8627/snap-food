# Snap Foodd — Product Scope

## Release objective
Google SSO → catalogue → cart → COD checkout → admin processing → delivery assignment → pickup → active tracking → delivery completion → order history/invoice.

## Roles
- **Customer:** Google SSO, browse/search, products, cart, address, COD checkout, orders, active delivery map, profile/favorites where implemented.
- **Delivery Partner:** approved accounts only; Google SSO, duty, requests, accept, pickup/delivery navigation, active-trip GPS and completion.
- **Admin:** separate Laravel web dashboard for categories, products, availability, customers, delivery partners, orders, assignments, status and invoices.
- **Restaurant Partner:** **deferred**; existing UI is reference only.

## Payment
COD only. Start with `payment_method=COD`, `payment_status=PENDING`; finalize collection/reconciliation before production.

## Order lifecycle
`PLACED → ACCEPTED → PREPARING → READY_FOR_PICKUP → ASSIGNED → PICKED_UP → OUT_FOR_DELIVERY → DELIVERED`; exceptional `CANCELLED`. Server owns transitions.

## Tracking
Active-trip only. Delivery app sends authorized GPS to Laravel; customer polls while tracking is active. Background GPS/geofencing are deferred.

## Explicitly out of scope
OTP, Firebase, Supabase, online payments, restaurant workflow, continuous background tracking, geofencing, push infrastructure, advanced recommendations/analytics, complex tax/accounting and WebSocket dependency for MVP.
