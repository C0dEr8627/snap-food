# Snap Foodd — Shared AI Task Board

This board tracks shared integration milestones and their evidence. Keep code-level task details in focused GitHub issues or task descriptions based on `AI_TASK_TEMPLATE.md`; do not depend on deleted historical plan/status documents.

## Status legend
- `[ ]` Not started
- `[~]` In progress / integration gates remain
- `[x]` Verified complete with evidence
- `[!]` Blocked

## Shared milestones

- [~] **M0 — Hosting/environment discovery:** local development assumptions are documented; GoDaddy plan/capabilities still require owner verification.
- [x] **M1 — Laravel/MySQL foundation:** Laravel boots and connects to non-production MySQL; clean migrations/tests are verified by Backend CI.
- [x] **M2 — Backend Google SSO/authz slice:** verified by workflow #146. Flutter session restoration/revocation still requires end-to-end integration validation.
- [x] **M3 — Catalogue:** admin product/category CRUD and customer catalogue API, including deterministic seed/demo data, verified by workflow #146.
- [x] **M4 — Orders/COD:** server-calculated totals, customer order ownership/history, server-owned admin status transitions and concurrency-safe assignment implemented and CI-verified through workflows #189, #204 and #386.
- [x] **M5 — Admin and partner operations:** partner provisioning/approval, protected Laravel admin operations, catalogue management, partner controls/directories/dashboard counts and web/API assignment verified through workflows #209, #244, #324, #349, #363, #371 and #386.
- [x] **M6 — Delivery progression:** partner assignment listing and pickup → out-for-delivery → delivered transitions, with ownership/conflict tests, verified by workflow #259. Assignment is created by ADMIN; the current contract does not define a separate partner-accept endpoint.
- [x] **M7 — Active-trip tracking:** GPS updates, latest-location reads, stale-state reporting and customer/admin authorization verified by workflow #266.
- [x] **M8 — Invoices:** schema, deterministic numbering, immutable snapshots and customer/admin access verified by workflow #301.
- [~] **M9 — Release integration/readiness:** backend workflow #423 passed on its recorded branch head with PHP 8.3, Composer, Pint, MySQL migrations and PHPUnit. Remaining gates include external GoDaddy capability confirmation, broader cross-client/device/browser validation and explicit human release approval.

## Required milestone handoff

Whenever status changes, report:
- milestone and status;
- branch and commit SHA;
- evidence, exact commands and actual test outcomes;
- dependencies/blockers;
- next owner/action.

Do not mark work complete merely because code exists. Require relevant verification evidence. If evidence becomes stale because the branch has changed, rerun the check or qualify the status.

## Decision log

- Backend: Laravel/PHP + MySQL.
- Mobile customer/delivery client: Flutter, Riverpod 3 and go_router under `mobile_app/`.
- Identity: Google OAuth SSO; OTP deferred.
- Payment: COD.
- Admin: separate Flutter Web GUI under `admin_web/`, integrated with shared Laravel API; existing Blade dashboard remains during migration.
- Maps: Google Maps Platform.
- Tracking: active-trip only, HTTP updates and polling for MVP.
- Hosting: GoDaddy; exact plan/capabilities unverified.
- Restaurant Partner workflow: deferred.

## Current next gates

1. Verify hosting capabilities with the account owner/provider before deployment assumptions become commitments.
2. Run and document Flutter auth/session restoration and revocation against the integrated backend.
3. Verify the admin Flutter Web workflows against the actual API, including build/analyzer and browser checks.
4. Complete cross-client end-to-end, authorization, responsive UI and device/browser failure-state checks.
5. Document release acceptance; do not mark V1 deployed until the owner approves and deployment is actually verified.
