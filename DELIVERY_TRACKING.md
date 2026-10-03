# Snap Foodd — Maps & Active Delivery Tracking

## Scope
Active-trip tracking only. No continuous background GPS or geofencing.

## Flow
```text
Delivery GPS → Flutter adapter → POST /api/v1/delivery/assignments/{id}/location → Laravel auth/validation → MySQL latest location → customer polling → GET /api/v1/consumer/orders/{id}/tracking → Google Maps driver marker
```

Delivery app requests permission and sends throttled updates only during an active trip. Include latitude, longitude, accuracy when available and recorded timestamp. Start around 5–10 seconds and tune after device tests. Server time is authoritative for freshness.

Customer UI distinguishes recent, stale, no-location, permission and network states. Partners may submit only their own active-trip location; customers may read only authorized order tracking.

Google Maps client keys must be restricted to the intended platforms. Customer Android uses a Gradle manifest placeholder and web uses the Google Maps JavaScript API key. The delivery partner app uses the device GPS source; server credentials remain in Laravel environment config.

Current implementation: Google Maps customer view, destination coordinates from the order snapshot, foreground GPS collection in the delivery partner app, throttled location publishing, and 10-second customer polling. Deferred: WebSockets/broadcasting, background location, geofencing, advanced ETA/routing and push notifications.
