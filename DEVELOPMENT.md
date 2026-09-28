# Snap Foodd — Development Plan

## Team
**Developer A:** Laravel/MySQL/Admin — hosting discovery, backend, migrations, Google verification, API, authz, orders, delivery, tracking, invoices, admin.

**Developer B:** Flutter/Maps — API client, auth state/UI, customer flows, checkout, orders, delivery flows, Maps, GPS and tracking UI.

Shared: API contract, integration tests, security review and release testing.

## Sequence
1. **Hosting discovery:** verify GoDaddy plan, PHP/MySQL, HTTPS, domain/subdomain, Composer, SSH, cron, storage, public-directory deployment and worker restrictions. Do not assume WebSockets/workers.
2. **Laravel foundation:** app, env, MySQL, migrations, seeds, API versioning, errors and authz.
3. **Google SSO:** verification, users, session/token, `/me`, secure Flutter session and role routing. **Milestone: authenticated Flutter session.**
4. **Catalogue:** admin CRUD, customer APIs, repositories, search/filter, availability.
5. **Cart + COD:** address, server pricing, transactional order creation, item snapshots, history. **Milestone: real MySQL COD order.**
6. **Admin operations:** orders, transitions/history, partner provisioning, assignment.
7. **Delivery:** availability, requests, accept, pickup, navigation, active trip, completion, history.
8. **Maps/tracking:** config, permissions, GPS, location API, polling, markers, stale states. **Milestone: customer sees active delivery.**
9. **Invoices:** numbering, generation, customer/admin access.
10. **Hardening:** authz, price manipulation, assignment conflicts, auth/network failures, device tests, full flow, production config and backups.

Build vertical slices: **auth → catalogue → checkout → delivery**. A change is done when code, tests, migrations and docs agree.
