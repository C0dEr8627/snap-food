# Snap Foodd Delivery Partner App

This Flutter project is a separate mobile application for delivery partners. It is copied from the shared mobile app baseline, but its router is scoped to delivery partner authentication, delivery requests, navigation, pickup/drop verification, duty map, and earnings.

The consumer app remains in `mobile_app/`. The Laravel API remains shared in `backend/`.

## Run locally

From the repository root:

```bash
cd delivery_partner_app
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
```

Use your machine's reachable API URL for physical devices. The default API URL may need to be overridden depending on the target device.

## Build Android APK

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://YOUR_API_HOST/api/v1
```

The delivery partner app has its own Flutter package name and Android application ID. It uses the existing backend delivery partner login endpoint and requires an approved, active delivery partner account.
