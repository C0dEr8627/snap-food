# Snap Foodd — Maps & Active Delivery Tracking

## Scope
Active-trip tracking only. No continuous background GPS or geofencing.

## Flow
```text
Delivery GPS → Flutter adapter → POST /api/v1/delivery/assignments/{id}/location → Laravel auth/validation → MySQL latest location → customer polling → GET /api/v1/orders/{id}/tracking → map marker
```

Delivery app requests permission and sends throttled updates only during an active trip. Include latitude, longitude, accuracy when available and recorded timestamp. Start around 5–10 seconds and tune after device tests. Server time is authoritative for freshness.

Customer UI distinguishes recent, stale, no-location, permission and network states. Partners may submit only their own active-trip location; customers may read only authorized order tracking.

Google Maps client keys must be restricted to intended platforms; server credentials remain in Laravel environment config. Keep map SDK details behind an app abstraction.

Deferred: WebSockets/broadcasting, background location, geofencing, advanced ETA/routing and push notifications.
