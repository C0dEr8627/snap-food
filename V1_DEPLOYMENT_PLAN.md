# Snap Foodd — V1 Deployment & Integration Plan

## Delivery target

**V1 target: 3 October 2026.**

This document is the execution source of truth for the V1 hosting and integration direction. The goal is to modularize the existing work cleanly, not to restart completed implementation.

## 1. Target V1 topology

```
Flutter Mobile (Consumer + Delivery)
            \
             \ HTTPS/JSON
              \
Flutter Web (Consumer + Delivery) ----> Laravel/PHP API ----> MySQL
              /
             /
Admin Flutter Web --------------------/

                 GoDaddy cPanel
       API + Admin Web + Consumer/Delivery Web
```

### Hard database boundary

**Only Laravel/PHP may access MySQL.**

- Flutter mobile: API only.
- Consumer/delivery Flutter Web: API only.
- Admin Flutter Web: API only.
- No browser-side database connection.
- No database credentials in Flutter or Web bundles.
- Laravel remains responsible for validation, authorization, business rules and persistence.

## 2. Hosting plan

### Phase A — Laravel/PHP API

Host the existing backend on GoDaddy cPanel.

Verify before deployment:
- PHP 8.3 availability.
- Required PHP extensions.
- MySQL database/user creation and connectivity.
- Composer/dependency deployment approach.
- Laravel public document root.
- Writable storage/cache directories.
- HTTPS/domain configuration.
- CORS configuration.
- Environment-variable/secret configuration.
- SSH/cron limitations if needed.

### Phase B — Admin Flutter Web

Build the Flutter Web release from admin_web/ and host the generated static files on GoDaddy cPanel.

Verify:
- HTTPS.
- SPA route/deep-link fallback.
- API base URL points to production Laravel API.
- CORS and authentication behavior.
- Responsive browser behavior.
- Admin authorization on every protected operation.

### Phase C — Mobile + hosted API

Configure the Flutter mobile application to use the production HTTPS Laravel API.

Verify the complete path:
Google authentication -> Laravel verification -> application session/token -> catalogue -> cart/COD checkout -> orders -> delivery -> tracking -> invoices.

### Phase D — Consumer + Delivery Partner Web

After the mobile/API integration is stable, produce the Web deployment of the consumer + delivery-partner Flutter application and host it on GoDaddy cPanel.

Verify:
- authentication/session restoration,
- customer flows,
- delivery-partner flows,
- API authorization,
- responsive Web UX,
- browser refresh/deep links,
- tracking/network failure states.

## 3. Separation of concerns

| Component | Responsibility | Direct MySQL access |
|---|---|---|
| Laravel/PHP API | Auth, authorization, validation, business rules, persistence, integrations | YES |
| Flutter mobile | Consumer/delivery UI and client state | NO |
| Consumer/Delivery Web | Consumer/delivery UI and client state | NO |
| Admin Flutter Web | Admin UI and API operations | NO |
| MySQL | Persistent application data | Accessed by Laravel only |

## 4. V1 implementation sequence

1. Freeze the architecture and database boundary.
2. Verify GoDaddy cPanel capabilities.
3. Finish Flutter mobile/API integration against the documented contract.
4. Finish admin Web authentication and API integration.
5. Deploy API + admin Web to a GoDaddy staging/verification environment.
6. Run end-to-end admin and mobile workflows.
7. Finish consumer/delivery Web deployment.
8. Run cross-client security, authorization, browser/device and network-failure checks.
9. Production configuration, backup verification and release acceptance.
10. Deploy V1 by 3 October 2026.

## 5. Migration rule

Existing Laravel Blade admin functionality remains available during the transition. It is retired only after the Flutter Web admin has feature parity, API/security verification and explicit release acceptance.

## 6. What is explicitly out of scope for this hosting plan

- A second backend.
- Direct database access from any Flutter application.
- Firebase/Supabase as a replacement backend.
- WebSockets as a V1 hosting requirement.
- Background workers unless the verified GoDaddy plan supports and the product requires them.
- Unverified GoDaddy capabilities being treated as guaranteed.

## 7. Definition of V1 deployment readiness

V1 is deployment-ready when:
- Laravel API runs on GoDaddy cPanel against MySQL.
- Only Laravel has database credentials/access.
- Mobile app uses the hosted API successfully.
- Admin Flutter Web uses the hosted API successfully.
- Consumer/delivery Flutter Web uses the hosted API successfully.
- Authentication and authorization are verified for each client surface.
- HTTPS/CORS/SPA routing are verified.
- Critical end-to-end workflows pass.
- Production secrets are configured outside source control.
- Final release checks are documented.
