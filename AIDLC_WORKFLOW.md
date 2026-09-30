# Snap Foodd — AI Development Lifecycle (AIDLC)

This file defines how AI coding agents plan, implement, verify and integrate changes. It is a workflow, not a claim that autonomous CI/deployment is configured.

## 1. Branch model

```text
frontend  (shared integration/base branch)
├── developer-1-backend-admin  (Laravel, MySQL, admin/API)
└── developer-2-flutter        (Flutter customer/delivery apps)
```

Work branches should start from the latest `frontend` commit and remain independent siblings. Follow the task owner's explicit branch instruction. Do not commit directly to `frontend` for application implementation unless the repository owner explicitly directs it; documentation-only maintenance may be performed on the branch explicitly requested by the owner.

## 2. Start instructions

Before coding:
1. Read `README.md`, `AI_RULES.md`, `AIDLC_WORKFLOW.md`, `AI_TASK_BOARD.md`, and relevant product/architecture/API/auth/database/design docs.
2. Confirm the target branch and inspect the current implementation and recent history.
3. Identify the next incomplete task from `AI_TASK_BOARD.md`, open issues, or the user's explicit request. Do not depend on deleted per-developer plan files.
4. Preserve existing architecture and UI unless the task explicitly calls for a change.

## 3. Parallel work boundaries

| Area | Backend/Admin owner | Flutter owner |
|---|---|---|
| Laravel app, migrations, policies, API | Owns | Do not modify |
| Laravel Blade admin | Owns | Do not modify |
| Flutter screens, Riverpod, routing | Do not modify | Owns |
| Maps UI/GPS adapter | Backend endpoint/authorization only | Owns client |
| API contract | Coordinate changes | Coordinate changes |
| Shared root docs | Coordinate changes and avoid conflicting edits | Coordinate changes and avoid conflicting edits |

Avoid concurrent edits to the same files. Coordinate API/schema changes before implementing incompatible assumptions.

## 4. Contract-first integration

Before parallel implementation, confirm:
- method/path and API version;
- authentication mechanism and role requirement;
- request and response examples;
- validation/error shape;
- pagination, timestamps and money representation;
- state transitions and side effects;
- ownership checks and concurrency/idempotency behavior.

When backend implementation is not ready, Flutter may use a fake repository matching the written contract. Do not invent a different payload to unblock UI work.

## 5. Required task loop

1. **Read** task, related docs and existing implementation.
2. **Plan** the smallest implementation and identify files/tests.
3. **Implement** only the scoped change.
4. **Verify** with formatter, static analysis, tests or build commands available.
5. **Inspect diff** for secrets, generated files, unrelated edits, broken navigation and architecture drift.
6. **Document** changed contracts/config/setup and actual test outcomes.
7. **Commit** focused changes to the explicitly assigned branch.
8. **Report** commit SHA, changed files, commands/results, limitations and next task.
9. **Integrate** through a reviewable PR to `frontend`, unless the repository owner explicitly directs a different workflow.

Never claim a command ran if it did not. If a test cannot be run, mark it **NOT RUN** and explain why.

## 6. Commit convention

Use focused Conventional Commit-style messages, for example:
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

One logical change per commit where practical. Do not rewrite shared remote history without permission.

## 7. Pull request checklist

Every PR should include:
- [ ] Summary and scope
- [ ] Related task/milestone
- [ ] API/schema/config changes
- [ ] Tests run with exact results, or why not run
- [ ] Security and authorization considerations
- [ ] Screenshots/video for meaningful UI changes
- [ ] Migration/deployment/rollback notes where relevant
- [ ] Known limitations and follow-up tasks
- [ ] Confirmation no secrets or personal data were added

PR target is normally `frontend`.

## 8. Integration sequence

1. Keep `frontend` as the shared integration base.
2. Merge small, reviewable PRs; do not wait for an entire plan to finish.
3. Integrate auth contract first, then catalogue, checkout/orders, admin operations, delivery and tracking.
4. After a PR merges, each developer brings the updated `frontend` into their work branch carefully.
5. Do not force-push shared branches.
6. Run relevant tests on the combined branch after integration.
7. Keep release/deployment separate from feature integration.

If one branch depends on code not yet merged from the other, use the documented contract/fakes rather than cherry-picking unrelated work without agreement.

## 9. Definition of ready / done

**Ready:** task has an owner, acceptance criteria, relevant contract, dependencies and test approach.

**Done:** implementation exists, authorization/validation is present, relevant tests were actually run where possible, docs updated, diff reviewed and report completed. Deployment readiness additionally requires hosting verification, cross-client checks and human release approval.

## 10. Human approval gates

AI agents must not independently:
- deploy to production or run destructive production migrations;
- rotate/change production credentials;
- alter hosting/domain/DNS settings;
- change Google OAuth/Maps billing or access policies;
- introduce payment providers or collect real customer data;
- merge around failing checks or unresolved security findings.

## 11. Current integration milestones

Use `AI_TASK_BOARD.md` for the shared milestone state and evidence. Current high-level sequence:
- confirm external hosting capabilities;
- verify Flutter authentication/session restoration against the Laravel contract;
- complete cross-client integration and browser/device checks;
- document release acceptance and obtain explicit human approval.

## 12. Reusable kickoff prompts

### Backend/Admin
"Work on the explicitly assigned backend/admin branch. Read `AI_RULES.md`, `AIDLC_WORKFLOW.md`, `AI_TASK_BOARD.md` and the relevant architecture/API/auth/database/admin docs. Inspect existing code, continue from the next incomplete task, preserve existing architecture, verify with actual commands, and report commit SHA, files, test results, blockers and next task. Do not deploy or change production infrastructure."

### Flutter
"Work on the explicitly assigned Flutter branch. Read `AI_RULES.md`, `AIDLC_WORKFLOW.md`, `AI_TASK_BOARD.md` and relevant architecture/API/auth/design/tracking docs. Inspect existing code, preserve existing UI unless explicitly asked to change it, and use repositories matching the documented API contract. Verify with actual commands and report commit SHA, files, test results, blockers and next task. Do not deploy or change production infrastructure."
