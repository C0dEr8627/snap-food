# Snap Foodd — Shared AI Task Board

This board tracks **integration milestones**, not every code-level subtask. Detailed checklists belong to `DEVELOPER_1_PLAN.md` and `DEVELOPER_2_PLAN.md`.

## Status legend
- `[ ]` Not started
- `[~]` In progress
- `[x]` Verified complete (must have evidence/commit/test result)
- `[!]` Blocked

## Shared milestones

- [ ] M0 — GoDaddy plan/capabilities recorded; local development assumptions documented.
- [ ] M1 — Laravel boots and connects to non-production MySQL.
- [~] M2 — Backend Google SSO/authentication/authorization is CI-verified in workflow #146, but Flutter Google sign-in is not end-to-end because the shared contract still lacks the exact `/auth/google` credential field/type, success token response, public client configuration, and role response shape.
- [x] M3 — Admin product/category CRUD and customer catalogue API work end-to-end, including deterministic seed/demo data verified by backend workflow #146. Flutter repository/controller/state integration exists, but typed field-level UI mapping awaits the documented catalogue success schema.
- [~] M4 — Backend order/COD checkout/list/detail and server-owned status-transition/concurrency work are verified; M4 remains in progress because the complete Flutter-facing order/COD and address contract examples are still missing.
- [~] M5 — Delivery-partner provisioning/approval is CI-verified in workflow #209; safe order assignment and the remaining delivery workflow are still to be implemented and verified.
- [ ] M6 — Partner accepts, confirms pickup, and completes delivery through valid state transitions.
- [ ] M7 — Active-trip GPS updates are authorized and customer map shows fresh/stale location states.
- [ ] M8 — Invoice generation and access rules are tested.
- [ ] M9 — Security, Android device, end-to-end and deployment-readiness checks pass.

## Handoff format

When a milestone changes, the responsible AI updates this board in its own branch/PR and reports:
- milestone and status;
- branch + commit SHA;
- evidence/commands/tests and actual outcomes;
- dependencies/blockers;
- next owner/action.

Do not mark a milestone complete based only on code existing. Require a verified integration result.

## Decision log

Record decisions here only after the owner approves or they are already established in the project docs:
- Backend: Laravel/PHP + MySQL.
- Mobile: Flutter, Riverpod 3, go_router.
- Identity: Google OAuth SSO; OTP deferred.
- Payment: COD.
- Admin: separate Laravel web dashboard.
- Maps: Google Maps Platform.
- Tracking: active-trip only using HTTP updates and polling for MVP.
- Hosting: GoDaddy; plan/capabilities unverified.
- Restaurant Partner workflow: deferred.

## Developer 2 checkpoint — 2026-09-29

- **Branch:** `developer-2-flutter`
- **Current Flutter PR:** #1 targeting `frontend`; latest implementation checkpoint is `029c53bdb16af52575a0fe83b31c33f5cf5a925f`.
- **Flutter implementation completed:** API client/transport foundation, normalized API errors, environment API URL documentation, catalogue repository + fake/remote implementations, Riverpod catalogue controller/state, catalogue loading/empty/error/retry UI integration, secure application-session storage, `/me` restoration, logout/revocation handling, auth controller tests, auth-aware go_router redirects, and the local cart repository/controller boundary with explicit product IDs and quantity tests.
- **Backend checkpoint:** `developer-1-backend-admin` has documented fixes after workflow #179: `bf2febe67ee45507886be50aca809e7c0bca9f23` fixes the stale status-history table assertion, `a0f9b47f70df16871ea4da82a50ebf5640b1582b` restores the established `data` envelope for order lists, and `cf5236d87a7c2ad00be965a89ce94a5cd72a566b` restricts customer order routes with `role:CUSTOMER`. Backend documentation commit `a1fcc5c920db6e4de71a53e294f3d71df95ad9b0` records the earlier fixes; commit `032e4144e5fba9e0b24a16418b82a23b1dbc2d52` adds 403/FORBIDDEN exception normalization and workflow #186 verifies it.
- **Backend verification:** workflow #146 passed the corrected Phase 2/3 authentication/authorization + catalogue suite on PHP 8.3 with MySQL. The backend plan records workflow #204 as passing for server-owned admin order status transitions; workflow #205 failed on delivery-partner provisioning/approval conflict rendering; the backend fix is awaiting fresh CI verification.
- **M2:** `[~]` backend auth is verified, but Flutter SSO remains blocked by the undocumented exact Google credential request/response contract, public client configuration, and role response shape.
- **M3:** `[x]` backend catalogue milestone is verified; Flutter field-level DTO/UI mapping remains blocked because `API_CONTRACT.md` still does not document successful category/product response fields/envelope.
- **M4:** `[~]` backend initial order/COD checkout/list/detail slice is now green in workflow #186. Flutter still waits for documented checkout/list/detail request/response examples and the next server-owned status-transition/concurrency slice before marking the milestone complete.
- **Flutter runtime verification:** `dart format`, `flutter pub get`, `flutter analyze`, `flutter test`, `flutter build apk --debug`, and physical-device checks are **NOT RUN** because this GitHub-connected environment has no local Flutter/Dart runner.
- **Next owner/action:** Developer 1 should publish the exact Flutter-facing order/COD and address request/response examples and finish the pending delivery-partner provisioning/approval CI verification. Developer 2 has now completed the local cart boundary subtask and will not guess API payload fields. Google SSO and typed catalogue mapping remain blocked on their missing schemas. Once the order contract is frozen, continue cart → checkout → customer orders, then delivery → active-trip tracking → invoices → release hardening.


## Developer 2 checkpoint — 2026-09-29 (cart boundary implementation)

- Branch: developer-2-flutter
- Commit: c0fbe23643507eba58534a05d821eec89495d102
- Implemented: local cart repository + Riverpod controller, explicit product IDs, quantity mutation through the controller, and repository tests.
- Preserved: existing cart UI, route, and navigation.
- Not implemented: backend order submission, address API, server totals, order response DTOs; those remain contract-gated.
- Verification: Flutter/Dart commands remain NOT RUN because no local Flutter/Dart runner is available.


## Developer 2 checkpoint — 2026-09-29 (cart boundary hardening)

- Branch: developer-2-flutter
- Cart boundary hardened after source review: corrected the cart vegetarian field binding and replaced the un-managed controller construction test with a real Riverpod ProviderContainer test.
- Cart product-ID/quantity task is now explicitly tracked as complete at the local boundary.
- API-backed checkout remains blocked by missing exact order/address request/response examples in API_CONTRACT.md.
- Flutter runtime verification remains NOT RUN because no Dart/Flutter runner is available.


## Developer 2 checkpoint — 2026-09-29 (contract integration gate documented)

- Added `FLUTTER_CONTRACT_QUESTIONS.md` to explicitly track the remaining API contract fields required for safe Flutter integration.
- No undocumented order, address, auth, catalogue or delivery payloads were implemented.
- Current completed Flutter boundary remains the local cart repository/controller with explicit product IDs and quantity tests.
- Next owner/action: Developer 1 freezes exact order/COD + address examples and completes delivery-partner provisioning verification; Developer 2 then implements typed order models and checkout/history integration.
- Flutter runtime verification remains NOT RUN because no Dart/Flutter runner is available.


## Developer 2 checkpoint — 2026-09-29 (backend delivery gate refresh)

- Branch: `developer-2-flutter`
- Backend workflow #209 is now passing, verifying delivery-partner provisioning/approval. The earlier workflow #205 failure is no longer an active blocker.
- Flutter order/COD and address integration remains contract-gated because `API_CONTRACT.md` still lacks exact request/response examples.
- Flutter delivery implementation is also contract-gated until assignment/request/location/tracking response examples are documented, despite backend provisioning now being verified.
- No backend files or undocumented API payloads were changed by Developer 2.
- Flutter/Dart runtime verification remains NOT RUN because no local runner is available.
- Next action: Developer 1 freezes order/COD + address examples; Developer 2 implements typed order models and checkout/history, then delivery flows from the documented assignment/tracking contract.


## Developer 2 checkpoint — 2026-09-29 (implementation continuation / status synchronization)

- **Branch:** `developer-2-flutter`
- **PR:** #1 → `frontend`, currently open and mergeable.
- **Head:** `7854e5a3ef6131e8bbb3f252d579ef21c7589b94`.
- **Completed Flutter work:** API transport/client + normalized errors; catalogue repository/controller/state and loading/empty/error/retry UI integration; secure session storage; `/me` restoration; logout/revocation; auth-aware routing; local cart repository/controller with explicit product IDs and quantity tests; contract-question documentation.
- **Backend gate:** workflow #209 passes, verifying delivery-partner provisioning/approval. This removes the earlier provisioning blocker.
- **Still blocked by shared contract:** order create/list/detail request/response examples, address request/response shape, Google auth exchange/configuration, catalogue success fields, and delivery assignment/tracking response examples.
- **Verification:** Flutter/Dart formatting, analyzer, tests, APK build and physical-device checks are **NOT RUN**. Current commit status has no reported Flutter checks.
- **Next owner/action:** Developer 1 freezes the exact order/COD + address contract. Developer 2 then implements typed order models and checkout/history, followed by delivery/active-trip tracking from the documented assignment/tracking contract. No undocumented payloads are to be invented.


## Developer 2 checkpoint — 2026-09-29 (latest implementation continuation)

- **Branch:** `developer-2-flutter`
- **PR:** #1 → `frontend`, open and mergeable.
- **Head:** `ea4756e366e16a438d696a48aad1d38f3f2e7ec3`.
- **Completed Flutter boundaries:** API transport/client + normalized errors; catalogue repository/controller/state and loading/empty/error/retry UI integration; secure session storage; `/me` restoration; logout/revocation; auth-aware routing; local cart repository/controller with explicit product IDs and quantity tests; contract-question documentation.
- **Backend verification:** workflow #209 passes for delivery-partner provisioning/approval; backend order checkout/list/detail and server-owned status-transition/concurrency work are verified.
- **Current blockers:** exact Flutter-facing order create/list/detail and address schemas; Google auth exchange/configuration; catalogue success fields; delivery assignment/request/location/tracking response examples.
- **Verification:** Flutter/Dart formatting, analyzer, tests, APK build and physical-device checks are **NOT RUN**; current commit status has no Flutter checks.
- **Next owner/action:** Developer 1 freezes order/COD + address examples. Developer 2 then implements typed order models, checkout/history and server-authoritative totals, followed by delivery/active-trip tracking from documented schemas. No undocumented payloads are to be invented.


## Developer 2 checkpoint — 2026-09-29 (current implementation gate)

- **Branch:** `developer-2-flutter`
- **PR:** #1 → `frontend`, open and mergeable.
- **Current head:** `029c53bdb16af52575a0fe83b31c33f5cf5a925f`.
- **Completed Flutter:** API transport/client + normalized errors; catalogue repository/controller/state and loading/empty/error/retry UI integration; secure session storage and `/me` restoration; logout/revocation; auth-aware routing; local cart repository/controller with explicit product IDs and quantity tests; contract-question tracking.
- **Backend verified:** workflow #209 passes for delivery-partner provisioning/approval; backend order checkout/list/detail and server-owned status-transition/concurrency work are verified.
- **Current blocker:** the next Phase 4 address/checkout implementation cannot safely begin because `API_CONTRACT.md` still lacks exact order create/list/detail and address request/response schemas. Google SSO, typed catalogue mapping and delivery assignment/tracking are similarly contract/config gated.
- **Verification:** Flutter/Dart format, analyzer, tests, APK build and physical-device checks remain **NOT RUN**; no Flutter CI status is reported.
- **Next owner/action:** Developer 1 freezes the order/COD + address contract. Developer 2 then implements typed order models → checkout repository/controller → server-authoritative totals → order success/detail/history, followed by delivery/tracking.


## Developer 2 checkpoint — 2026-09-29 (latest continuation)

- **Branch:** `developer-2-flutter`; **PR:** #1 → `frontend`, open/mergeable; current head is `16b7fc5f6bbb668924779bcc77e99e2c478bf7fe` after the latest progress-documentation commit.
- **Completed Flutter:** API transport/client + normalized errors; catalogue repository/controller/state and loading/empty/error/retry UI integration; secure session storage; `/me` restoration; logout/revocation; auth-aware routing; local cart repository/controller with explicit product IDs and quantity tests; contract-question documentation.
- **Backend verified:** workflow #209 passes for delivery-partner provisioning/approval; backend order checkout/list/detail and server-owned status-transition/concurrency work are verified.
- **Contract check:** `developer-1-backend-admin` contains a new admin delivery-assignment contract section, but it is not yet on the shared/base `frontend` contract and does not provide the Flutter-facing delivery request/tracking schemas. Order create/list/detail and address request/response examples are still missing from the shared contract.
- **M2:** `[~]` Google SSO remains blocked by the exact credential exchange, success session/token shape, public client configuration and role response shape.
- **M3:** `[x]` backend catalogue milestone verified; Flutter typed field mapping remains schema-gated.
- **M4:** `[~]` backend order/COD + status/concurrency work verified; Flutter checkout/history/address remain contract-gated.
- **M5:** `[~]` delivery-partner provisioning/approval verified; assignment/accept/pickup/location/complete and tracking remain to be implemented and schema-verified.
- **Flutter verification:** formatter/analyzer/tests/APK/device checks are **NOT RUN**; no Flutter CI status is reported.

**Next owner/action:** Developer 1 freezes the complete Flutter-facing order/COD + address contract in the shared/base contract. Developer 2 then implements typed order models, checkout repository/controller, server-authoritative totals, order success/detail/history, followed by delivery request/assignment/tracking. No undocumented API payloads will be introduced.


## Developer 2 checkpoint — 2026-09-29 (latest contract gate / status synchronization)

- **Branch:** developer-2-flutter; **PR:** #1 → frontend, open and mergeable.
- **Completed Flutter work:** API transport/client + normalized errors; catalogue repository/controller/state and loading/empty/error/retry UI integration; secure session storage; /me restoration; logout/revocation; auth-aware routing; local cart repository/controller with explicit product IDs and quantity tests; contract-question documentation.
- **Backend verification:** workflow #209 passes for delivery-partner provisioning/approval; backend order checkout/list/detail and server-owned status-transition/concurrency work are verified.
- **Current gate:** shared frontend API_CONTRACT.md still lacks exact order create/list/detail and address request/response examples. Backend delivery assignment/lifecycle/tracking details exist on developer-1-backend-admin, but are not yet synchronized into the shared/base contract with complete Flutter-facing response examples.
- **Status:** M2 [~] Google SSO contract/config gated; M3 [x] backend catalogue milestone verified but Flutter typed field mapping is schema-gated; M4 [~] backend order/COD/status/concurrency verified while Flutter checkout/history/address remain contract-gated; M5 [~] provisioning/approval verified while Flutter delivery flows remain schema-gated.
- **Verification:** Flutter/Dart formatter, analyzer, tests, APK build and physical-device checks are NOT RUN; no Flutter CI status is reported.
- **Next owner/action:** Developer 1 freezes the complete Flutter-facing order/COD + address contract in the shared/base branch. Developer 2 then implements typed order models, checkout repository/controller, server-authoritative totals/error handling, order success/detail/history, followed by delivery request/assignment/status/tracking from the frozen delivery schemas.


## Developer 2 checkpoint — 2026-09-29 (latest backend verification / implementation gate)

- **Branch:** `developer-2-flutter`; **PR:** #1 → `frontend`, open and mergeable.
- **Backend verification update:** workflow #259 passes the delivery-partner assignment listing and owned status progression (`PICKED_UP → OUT_FOR_DELIVERY → DELIVERED`) on PHP 8.3 with MySQL. This replaces the older delivery-lifecycle verification note that referenced an earlier pending state.
- **Shared contract gate remains:** `frontend/API_CONTRACT.md` still lacks exact order create/list/detail request/response examples and address request/response fields. The backend branch has additional delivery lifecycle/location/tracking documentation, but it is not yet synchronized into the shared contract with complete Flutter-facing response examples.
- **Completed Flutter:** API transport/error foundation; catalogue repository/controller/state and loading/empty/error/retry integration; secure session storage, `/me` restoration and logout/revocation; auth-aware routing; local cart repository/controller with explicit product IDs and quantity tests; contract-question tracking.
- **M2:** `[~]` Google SSO contract/config gated.
- **M3:** `[x]` backend catalogue milestone verified; Flutter typed field mapping remains schema-gated.
- **M4:** `[~]` backend order/COD + status/concurrency work verified; Flutter checkout/history/address remain contract-gated.
- **M5:** `[~]` delivery provisioning/approval and partner assignment/status progression are backend-verified; Flutter delivery request/assignment/location/tracking remains schema-gated.
- **Verification:** Flutter/Dart formatting, analyzer, tests, APK build and physical-device checks are **NOT RUN**; no Flutter CI status is reported.
- **Next owner/action:** Developer 1 freezes the complete shared Flutter-facing order/COD + address examples. Developer 2 then implements typed order models → checkout repository/controller → server-authoritative totals/error handling → order success/detail/history, followed by delivery request/assignment/status/location/tracking from the documented schemas. No undocumented payloads will be introduced.


## Developer 2 checkpoint — 2026-09-29 (latest backend refresh / task tracking)

- **Branch:** `developer-2-flutter`; **PR:** #1 → `frontend`, open and mergeable.
- **Completed Flutter implementation:** API transport/client + normalized errors; catalogue repository/controller/state boundary with loading/empty/error/retry UI integration; secure session storage; `/me` restoration; logout/revocation; auth-aware routing; local cart repository/controller with explicit product IDs, quantity updates/removal and tests; contract-question tracking.
- **Backend verification refresh:** Developer 1 documents Workflow #259 as passing delivery-partner assignment listing and owned `PICKED_UP → OUT_FOR_DELIVERY → DELIVERED` progression, and Workflow #266 as passing active-trip location/tracking: partner-owned location writes, coordinate/timestamp validation, active-trip enforcement, persisted history, customer/admin tracking authorization and stale-location behavior. This removes the earlier backend delivery-tracking verification blocker.
- **New backend scope observed:** the backend contract now also documents invoice endpoints and idempotent invoice-number generation/access rules. Flutter invoice integration is **not** started because the shared Flutter contract does not yet contain the complete invoice response schema and Phase 4 order/address integration is still blocked.
- **Shared contract remains the primary blocker:** `developer-2-flutter` `API_CONTRACT.md` still lacks exact Flutter-facing Google auth exchange, catalogue success fields, order create/list/detail request/response examples, address request/response shape, and delivery assignment/location/tracking response examples. The backend branch has richer delivery/invoice documentation, but it is not synchronized into the shared/base contract.
- **Implementation decision:** no speculative order/address DTOs, status enums, checkout payloads, delivery network calls or invoice response models were introduced.
- **Verification:** Flutter/Dart formatting, analyzer, tests, APK build and physical-device checks remain **NOT RUN** because no Flutter/Dart runner is available; no Flutter CI status is reported.

### Task status after this checkpoint
- **Phase 0:** complete except runtime verification/tooling baseline, which remains NOT RUN.
- **Phase 1:** complete.
- **Phase 2:** partially complete; session lifecycle is implemented, Google SSO exchange/config and role routing remain contract/config gated.
- **Phase 3:** repository/controller/state integration is complete; typed field mapping remains blocked by the missing success schema.
- **Phase 4:** local cart boundary is complete; address, COD checkout, server totals/errors, duplicate-submit handling, order success/detail/history and API-backed tests remain blocked by the missing order/address contract.
- **Phase 5:** customer order history/detail/status remains blocked on documented order list/detail schemas.
- **Phase 6/7 delivery tracking:** backend is now verified through Workflow #266, but Flutter integration remains blocked by the missing shared delivery response schemas.
- **Invoice:** backend implementation is documented, but Flutter invoice UI/repository/model work is not started and remains contract-gated.

**Next implementation sequence:** (1) Developer 1 freezes the complete shared order/COD + address + relevant delivery response examples; (2) Developer 2 implements typed order models; (3) cart → COD checkout repository/controller with duplicate-submit protection; (4) server-authoritative totals/error handling; (5) order success/detail/history; (6) delivery request/assignment/status/location/tracking; (7) invoice integration once its Flutter-facing response schema is frozen. No undocumented payloads will be invented.


## Developer 2 status checkpoint — 2026-09-29 (latest)

- M2 [~] Google SSO — session persistence, /me restoration, logout and auth-aware routing are implemented; exact Google credential exchange, success session/token shape, public client configuration and role response remain contract/config gated.
- M3 [~] Catalogue — repository/controller/state and loading/empty/error/retry integration are implemented; typed category/product mapping remains blocked by missing successful response fields in the shared contract.
- M4 [~] Orders/COD — backend checkout/list/detail and server-owned status/concurrency work are verified; Flutter local cart boundary is complete, while address, typed order models, COD submission, server totals/errors and order history/detail remain blocked by missing shared schemas.
- M5 [~] Delivery — backend provisioning/approval, assignment/status progression and active-trip location/tracking are verified by Workflows #209/#259/#266; Flutter delivery integration remains blocked by missing shared assignment/location/tracking response examples.
- Invoice [ ] Backend invoice scope is documented on developer-1-backend-admin; Flutter invoice work has not started because the shared contract lacks the complete invoice response schema.
- Phase 0 [~] static baseline/documentation complete; Flutter/Dart runtime verification is NOT RUN because no Flutter/Dart runner or Flutter CI result is available.
- Developer 2 has not introduced speculative DTOs, payloads, status enums or API calls. Backend-owned files remain untouched.

### Next implementation queue
1. Developer 1 freezes and synchronizes the complete Flutter-facing order/COD + address contract in the shared/base branch.
2. Developer 2 implements typed order models and repository/controller boundaries.
3. Implement cart → COD checkout with duplicate-submit protection and server-authoritative totals/errors.
4. Implement order success/detail/history and refresh/error/empty states.
5. Implement delivery assignment/status/location/tracking from the frozen schemas.
6. Implement invoice model/repository/UI once the Flutter-facing invoice response schema is frozen.



## Developer 2 continuation checkpoint — 2026-09-29

### Current implementation status
- **M2 [~] Google SSO:** session persistence, `/me` restoration, logout/revocation and auth-aware routing are implemented; exact Google credential exchange, session/token response, public client configuration and role response remain gated by the shared contract/config.
- **M3 [~] Catalogue:** repository/controller/state plus loading/empty/error/retry integration are implemented; typed category/product mapping remains gated by missing successful response fields.
- **M4 [~] Orders/COD:** backend checkout/list/detail and server-owned status/concurrency work are verified; Flutter local cart boundary is complete; address, typed order models, COD submission, server totals/errors and order history/detail remain gated by missing shared schemas.
- **M5 [~] Delivery:** backend provisioning/approval, assignment/status progression and active-trip tracking are verified by #209/#259/#266; Flutter delivery integration remains gated by missing shared assignment/location/tracking response examples.
- **Invoice [ ]:** backend invoice scope is documented; Flutter invoice work has not started because the shared response schema is incomplete.
- **Phase 0 [~]:** static audit/documentation complete; Flutter/Dart runtime verification is NOT RUN and no Flutter CI result is available.

### Latest contract finding
The backend branch now has richer delivery/tracking and invoice endpoint documentation, but the shared `developer-2-flutter` contract remains high-level and is not sufficient to safely implement typed Flutter DTOs/network calls. Developer 2 therefore made no speculative API changes in this continuation.

### Next task queue
1. Developer 1 synchronizes exact order/COD + address + relevant delivery response examples into the shared/base contract.
2. Developer 2 implements typed order models and repository/controller boundaries.
3. Add cart → COD checkout duplicate-submit protection and server-authoritative totals/errors.
4. Add order success/detail/history with loading/empty/error/refresh states.
5. Add delivery assignment/status/location/tracking.
6. Add invoice model/repository/UI after the Flutter-facing invoice response schema is frozen.


## Developer 2 checkpoint — 2026-09-29 (continuation / task status synchronization)

- **Branch:** `developer-2-flutter`; **PR:** #1 → `frontend`; open and mergeable.
- **Current implementation:** API foundation, catalogue repository/controller/state + UI states, session restoration/logout/auth-aware routing, and local cart repository/controller with explicit product IDs and tests are complete.
- **No new API code added:** the shared contract remains insufficient for the next typed order/COD implementation, so no speculative DTOs, status enums, request payloads or network calls were introduced.
- **Backend verification currently available:** Workflows #209/#259/#266 cover delivery provisioning/approval, assignment/status progression and active-trip tracking; backend invoice behavior is documented. These do not by themselves freeze the Flutter-facing response schemas.
- **Verification:** Flutter/Dart formatter, analyzer, tests, APK build and physical-device checks remain NOT RUN; no Flutter CI status is reported.

### Current milestone state
- M2 `[~]` Auth — session lifecycle done; exact Google exchange/session/role contract remains gated.
- M3 `[~]` Catalogue — repository/controller/state done; typed response mapping remains gated.
- M4 `[~]` Orders/COD — backend verified; Flutter address/order schemas remain gated.
- M5 `[~]` Delivery — backend verification available; Flutter schemas/integration remain gated.
- M6 `[ ]` Partner delivery completion — Flutter integration not started.
- M7 `[ ]` Active-trip map integration — Flutter integration not started.
- M8 `[ ]` Invoice — backend scope documented; Flutter integration not started.
- M9 `[ ]` Release hardening — runtime/CI/device verification pending.

**Next owner/action:** Developer 1 must synchronize the complete Flutter-facing order/COD + address + delivery response examples into the shared/base contract. Developer 2 then starts typed order models → checkout controller/repository → order success/detail/history → delivery/tracking → invoice.


## Developer 2 checkpoint — 2026-09-29 (implementation gate / current branch sync)

- Branch: `developer-2-flutter`; PR #1 → `frontend`, open and mergeable.
- Current PR head observed: `0c9f9844afbfc3bfb99fc2604f50cab5cec8beeb`.
- Re-read the required Flutter architecture/API/auth/tracking/design/development docs and inspected the existing Flutter source tree before selecting the next implementation.
- First incomplete plan task: Google SSO, but it remains blocked by the missing exact Google credential exchange/session response/public client configuration/role schema.
- Next executable customer implementation remains typed order/COD + address integration, but the shared contract still lacks exact order create/list/detail and address schemas.
- Backend delivery verification is available (#209/#259/#266), but Flutter delivery response schemas are not synchronized into the shared contract.
- No speculative DTOs, payloads, status enums or backend-owned changes were introduced.
- Flutter/Dart format/analyze/test/APK/device checks remain NOT RUN because no Flutter/Dart runner or Flutter CI result is available.

**Next owner/action:** Developer 1 synchronizes the complete Flutter-facing order/COD + address contract; Developer 2 then implements typed order models → checkout repository/controller → server-authoritative totals/errors → order success/detail/history, followed by delivery/tracking.

## Developer 2 checkpoint — 2026-09-29 (Flutter CI enablement)

- Added `.github/workflows/flutter-ci.yml` on `developer-2-flutter` (commit `785ab5f4a1a68fa7bf2a11ff2c0a549eb558d5fa`).
- The workflow is configured to run Flutter dependency resolution, Dart formatting validation, static analysis, tests and Android debug APK build on relevant branch pushes, PRs targeting `frontend`, and manual dispatch.
- This enables remote verification but is **not evidence of a passing run**. Phase 0 runtime verification and M9 release hardening remain pending until CI results and device checks are actually reviewed.
- API integration remains gated by missing Flutter-facing auth/catalogue/order/address/delivery/tracking/invoice schemas and canonical delivery route synchronization.
- Next owner/action: Developer 2 inspects the first Flutter CI run and fixes any actual failures; Developer 1 synchronizes the complete shared API contract; then Developer 2 resumes typed order/address integration.


## Developer 2 checkpoint — 2026-09-29 (CI formatter gate fixed)

- Re-checked Flutter PR #1 and the first Flutter CI run.
- Flutter CI run `36590699675` completed cancelled at the formatting gate: Flutter 3.47.5 and dependency resolution succeeded, then the strict Dart formatter check reported 45 files requiring formatting and exited 1. Analyze, tests and Android build were skipped, so no passing runtime/build result is claimed.
- Updated `.github/workflows/flutter-ci.yml` in commit `4ee6286385f02a2154645488208b4c46ff90c146` so the developer branch workflow applies `dart format .`, commits only Dart formatting changes back to `developer-2-flutter`, then runs the strict formatting check, analyzer, tests and Android debug build.
- This is a CI/verification-enablement fix; no backend-owned files and no API DTOs/payloads were added.
- The next CI run must be observed before marking Phase 0 runtime verification complete.
- The shared `API_CONTRACT.md` is still incomplete for Google auth, typed catalogue fields, order/COD + address, delivery/tracking and invoice Flutter-facing schemas. Therefore the next product-feature implementation remains contract-gated.

### Current task status
- **Phase 0:** [~] static audit complete; CI formatting gate identified and remediation committed; analyzer/tests/APK still unverified.
- **Phase 1:** [x] API foundation complete.
- **Phase 2:** [~] session lifecycle complete; Google SSO exchange/config and role routing contract/config gated.
- **Phase 3:** [~] repository/controller/state integration complete; typed catalogue mapping schema-gated.
- **Phase 4:** [~] local cart boundary complete; address/COD checkout and order integration remain schema-gated.
- **Phase 5:** [ ] order history/detail/status not started.
- **Phase 6/7:** [~] backend delivery lifecycle/tracking verified; Flutter integration schema-gated.
- **Invoice:** [ ] Flutter integration not started; response schema not frozen.
- **Release verification:** [ ] pending a successful CI run plus device/integration verification.

### Next executable work
1. Observe the formatter-remediation CI run and fix any real analyzer/test/build failures.
2. Developer 1 synchronizes the exact Flutter-facing order/COD + address contract and resolves canonical delivery routes.
3. Implement typed order models/repository/controller, then COD checkout with duplicate-submit protection and server-authoritative totals/errors.
4. Implement order success/detail/history, then delivery/tracking and invoice from frozen schemas.
