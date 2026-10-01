# Snap Foodd — Development Guide

This document describes the high-level implementation sequence. It is not a second task tracker: use `AI_TASK_BOARD.md` for shared milestone status and evidence, and use focused GitHub issues/task descriptions for detailed work.

## Ownership

- **Backend/Admin:** Laravel, MySQL, migrations, API contracts and authorization, server-side workflows, and Laravel Blade admin.
- **Flutter:** customer/delivery client under `mobile_app/`, admin web client under `admin_web/` when explicitly assigned, UI state, routing, API integration, maps and client-side error states.
- **Shared:** API contract, cross-client integration, security review and release verification. Coordinate changes to shared docs and contracts.

Follow the branch and integration rules in `AIDLC_WORKFLOW.md`. Do not assume ownership of a file based only on the table above when the task explicitly assigns a different scope.

## Local mobile API integration

The mobile Flutter app reads its API base URL from `--dart-define=API_BASE_URL=...`. The value must include the API prefix `/api/v1`.

Start the Laravel API from the `backend/` directory using the project's normal local setup. Keep the backend running while testing the app.

### Flutter web / Chrome
```bash
cd mobile_app
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000/api/v1
```

### Android emulator
The Android emulator cannot reach the host machine's `localhost` directly. Use the emulator host bridge `10.0.2.2`:
```bash
cd mobile_app
flutter pub get
flutter run -d android --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
```

The Android debug manifest permits cleartext HTTP for local development only. The main manifest includes the INTERNET permission. Do not enable cleartext traffic in release builds; use HTTPS for deployed environments.

### iOS simulator
```bash
cd mobile_app
flutter pub get
flutter run -d ios --dart-define=API_BASE_URL=http://localhost:8000/api/v1
```

For a physical device, replace `localhost` with the development machine's LAN IP and ensure the device and machine can reach each other. The backend must listen on an address reachable from the device, and local firewall rules must allow the port.

The configured base URL is not a substitute for testing the endpoint: verify Laravel is responding at `/api/v1`, and check backend logs for request validation/authorization errors. A browser client may also require correct Laravel CORS configuration.

## Implementation sequence

Work in small, verifiable vertical slices. The intended dependency order is:

1. **Environment discovery:** verify the actual hosting plan and local setup; do not assume SSH, Composer, cron, queues, workers, WebSockets or PHP extensions are available in production.
2. **Backend foundation and identity:** migrations, error format, Google credential verification, application token/session, `/me`, logout and role/ownership enforcement.
3. **Catalogue:** admin product/category management and customer catalogue reads.
4. **Cart and COD checkout:** server-calculated prices/totals, transactional order creation, immutable item/address snapshots and order history.
5. **Admin operations:** order status transitions/history, delivery-partner provisioning/approval and assignment.
6. **Delivery and tracking:** authorized assignment progression, active-trip location updates, customer/admin tracking access and stale/no-location states.
7. **Invoices:** deterministic numbering, immutable snapshots and authorized customer/admin access.
8. **Client integration and release gates:** Flutter auth/session restoration, API integration, browser/device/responsive checks, authorization regression checks, deployment configuration and documented release acceptance.

Some implementation slices above are already recorded as complete in `AI_TASK_BOARD.md`; do not restart them or infer remaining work from this sequence alone.

## Definition of done

A change is complete when:
- acceptance criteria are met in the actual implementation;
- server-side validation and authorization are present where relevant;
- relevant tests/formatter/analyzer/build commands have actually run, with outcomes recorded;
- contracts and setup docs are updated when behavior changes;
- the diff has been inspected for unrelated edits and secrets;
- limitations and follow-up work are reported honestly.

Deployment readiness additionally requires verified hosting capabilities, cross-client end-to-end checks, production configuration review, backup/recovery considerations and explicit human release approval.
