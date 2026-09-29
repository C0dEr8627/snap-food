# Snap Foodd — AI Development Lifecycle (AIDLC)

This file defines how two AI coding agents work in parallel, test their changes, and integrate safely. It is a workflow, not a claim that autonomous CI/deployment has already been configured.

## 1. Branch model

```text
frontend  (integration/base branch; documentation and accepted integration)
├── developer-1-backend-admin  (Laravel, MySQL, admin, API)
└── developer-2-flutter        (Flutter, auth UI, customer/delivery app, Maps)
```

Both work branches must be created from the latest `frontend` commit. They are independent siblings, not branches created from each other.

**Important:** GitHub branch names are shared repository refs. If an AI agent uses a local checkout, it must push commits to its assigned remote branch. An agent must not commit directly to `frontend`.

## 2. Start instructions for each AI

### AI 1 — Backend/Admin
1. Open `DEVELOPER_1_PLAN.md` and all referenced docs.
2. Confirm the active branch is `developer-1-backend-admin`.
3. Inspect the repo before changing anything.
4. Start at the first incomplete task in the plan.
5. Commit focused changes to its own branch only.
6. Update task checkboxes only for work actually completed; include tests/results.
7. Open a PR targeting `frontend` when a coherent slice is ready.

### AI 2 — Flutter
1. Open `DEVELOPER_2_PLAN.md` and all referenced docs.
2. Confirm the active branch is `developer-2-flutter`.
3. Inspect the repo before changing anything.
4. Start at the first incomplete task in the plan.
5. Commit focused changes to its own branch only.
6. Update task checkboxes only for work actually completed; include tests/results.
7. Open a PR targeting `frontend` when a coherent slice is ready.

## 3. Parallel work boundaries

| Area | Developer 1 | Developer 2 |
|---|---|---|
| Laravel app, migrations, policies, API | Owner | Do not modify |
| Admin web dashboard | Owner | Do not modify |
| Flutter screens, Riverpod, routing | Do not modify | Owner |
| Maps UI/GPS adapter | Backend endpoint/authorization only | Owner |
| API contract | Propose/coordinate changes | Propose/coordinate changes |
| Shared root docs | Propose changes via PR; avoid conflicting edits | Propose changes via PR; avoid conflicting edits |

Avoid both agents editing the same files. Shared API/schema docs should be changed only with a coordinated contract update. If a change affects the other agent, create a concise contract proposal and communicate it in the PR before implementing incompatible assumptions.

## 4. Contract-first integration

Before a feature is built in parallel, confirm:
- method/path and API version;
- authentication mechanism and role requirement;
- request and response examples;
- validation/error shape;
- pagination/timestamps/money representation;
- state transitions and side effects;
- ownership checks and concurrency/idempotency behavior.

If backend is not ready, Developer 2 may use fake repositories matching the written contract. Do not make up a different payload just to unblock the UI.

## 5. Required task loop

For every task, each AI follows this sequence:

1. **Read** the task plan, related docs and existing implementation.
2. **Plan** the smallest implementation and identify files/tests.
3. **Implement** only the scoped change.
4. **Verify** with formatter, static analysis, unit/integration tests or build commands available.
5. **Inspect diff** for secrets, generated files, unrelated edits, broken navigation and architecture drift.
6. **Document** changed contracts/config/setup and actual test outcomes.
7. **Commit** to its assigned branch with a conventional, focused message.
8. **Report** commit SHA, changed files, test commands/results, limitations and next task.
9. **PR** to `frontend`; do not merge automatically unless the repository owner explicitly asks.

Never claim a command ran if it did not. If tooling or hosting prevents a test, mark it **NOT RUN** and explain why.

## 6. Commit convention

Use focused Conventional Commit-style messages:
- `docs: ...`
- `chore(backend): ...`
- `feat(auth): ...`
- `feat(catalogue): ...`
- `feat(orders): ...`
- `feat(delivery): ...`
- `feat(tracking): ...`
- `feat(admin): ...`
- `test(...): ...`
- `fix(...): ...`

One logical change per commit where practical. Do not squash/rewrite shared remote history without permission.

## 7. Pull request checklist

Every PR must include:
- [ ] Summary and scope
- [ ] Related plan/task phase
- [ ] API/schema/config changes
- [ ] Tests run with exact results, or why not run
- [ ] Security and authorization considerations
- [ ] Screenshots/video for meaningful UI changes
- [ ] Migration/deployment/rollback notes where relevant
- [ ] Known limitations and follow-up tasks
- [ ] Confirmation no secrets or personal data were added

PR target is `frontend`, never the production/default branch unless explicitly changed by the owner.

## 8. Integration sequence

1. Keep `frontend` as the shared integration base.
2. Merge small, reviewable PRs into `frontend`; avoid waiting for each developer's entire plan to finish.
3. Integrate auth contract first, then catalogue, checkout/orders, admin operations, delivery and tracking.
4. After a PR is merged, each developer fetches the updated `frontend` and rebases/merges it into their work branch carefully. Resolve conflicts without overwriting the other developer's work.
5. Do not force-push shared branches.
6. Run the relevant test suite on the combined branch after each integration.
7. Keep release/deployment separate from ordinary feature merges.

If one branch depends on code not yet merged from the other, use the documented contract/fakes rather than cherry-picking unrelated work without agreement.

## 9. Definition of ready / done

**Ready:** task has an owner, acceptance criteria, relevant contract, dependencies and test approach.

**Done:** implementation exists, validation/authz is present, tests were actually run where possible, docs updated, diff reviewed and PR report is complete.

## 10. Human approval gates

AI agents must not independently:
- deploy to production or run destructive production migrations;
- rotate/change production credentials;
- alter GoDaddy hosting/domain/DNS settings;
- change Google OAuth/Maps billing or access policies;
- introduce payment providers or collect real customer data;
- merge around failing checks or unresolved security findings.

## 11. Current starting order

- **Developer 1:** Phase 0 hosting/environment discovery, then Phase 1 Laravel/MySQL foundation.
- **Developer 2:** Phase 0 Flutter audit/baseline, then Phase 1 API client foundation using the written contract.
- **Shared gate:** freeze Google SSO request/response and session-token format before end-to-end auth integration.
- **First end-to-end milestone:** Google sign-in → Laravel verification → MySQL user → Flutter authenticated session.
- **Second milestone:** admin creates product → customer sees product → customer places COD order → admin sees order.
- **Third milestone:** admin assigns delivery → partner accepts → active location updates → customer sees partner → partner completes delivery.

## 12. Reusable kickoff prompts

### Developer 1 prompt
"You are AI Developer 1 for Snap Foodd. Work only on branch `developer-1-backend-admin`. Read `AI_RULES.md`, `AIDLC_WORKFLOW.md`, `DEVELOPER_1_PLAN.md` and all relevant architecture/API/auth/database/admin docs first. Inspect existing code, continue from the first incomplete task, and follow the plan in small tested slices. Do not modify Flutter-owned files. Commit to your branch only, never `frontend`. Report actual commands/results, commit SHA, blockers and next task. Do not deploy or change production infrastructure."

### Developer 2 prompt
"You are AI Developer 2 for Snap Foodd. Work only on branch `developer-2-flutter`. Read `AI_RULES.md`, `AIDLC_WORKFLOW.md`, `DEVELOPER_2_PLAN.md` and all relevant architecture/API/auth/design/tracking docs first. Inspect existing code, preserve current UI and continue from the first incomplete task. Do not modify Laravel/backend-owned files. Commit to your branch only, never `frontend`. Use fake repositories matching the contract when APIs are not ready. Report actual commands/results, commit SHA, blockers and next task. Do not deploy or change production infrastructure."
