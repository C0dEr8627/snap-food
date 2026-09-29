# Flutter API Client Configuration

The Flutter app uses one JSON API client under the documented /api/v1 contract. Configure the environment-specific base URL at build/run time; do not place credentials or private keys in --dart-define.

## Local development

Default base URL: http://localhost:8000/api/v1

- Android emulator: pass --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1 when Laravel runs on the host machine.
- iOS simulator / desktop: localhost is usually appropriate when the API server is reachable on the host.
- Physical device: use the development machine LAN address and ensure the server is reachable. Use only on a trusted development network.

Example command: flutter run --dart-define=API_BASE_URL=https://api.example.com/api/v1

The example domain is illustrative. Use HTTPS for shared, staging, and production environments. Do not commit tokens, OAuth secrets, server keys, or production environment files.

## Client behavior

- JSON requests and responses; empty successful responses return null.
- Adds Accept: application/json, JSON content type when a body is present, and an optional bearer token.
- Token access is injected through a callback for future secure session storage.
- Defaults to a 15-second request timeout.
- Normalizes Laravel message, errors, and code fields into ApiException.
- Maps timeouts and connection failures to safe messages; never logs payloads or tokens.
- The API contract does not yet specify a common success envelope, so decoded JSON is returned unchanged.

The default URL is for local development only. Production builds must explicitly set API_BASE_URL to the deployed HTTPS API base URL.
