# Snap Foodd — Development Guide

This document describes the high-level implementation sequence. It is not a second task tracker: use `AI_TASK_BOARD.md` for shared milestone status and evidence, and use focused GitHub issues/task descriptions for detailed work.

## Ownership

- **Backend/Admin:** Laravel, MySQL, migrations, API contracts and authorization, server-side workflows, and Laravel Blade admin.
- **Flutter:** customer/delivery client under `mobile_app/`, admin web client under `admin_web/` when explicitly assigned, UI state, routing, API integration, maps and client-side error states.
- **Shared:** API contract, cross-client integration, security review and release verification. Coordinate changes to shared docs and contracts.

Follow the branch and integration rules in `AIDLC_WORKFLOW.md`. Do not assume ownership of a file based only on the table above when the task explicitly assigns a different scope.

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
