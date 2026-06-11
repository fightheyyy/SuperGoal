# SuperGoal Contract Template

Use this template when drafting a pasteable goal-mode prompt for Codex. Replace every placeholder. Keep the result narrow enough that a goal-mode agent can execute it without inventing extra architecture.

```text
Goal: <one concrete outcome>

Use $supergoal and $superdev.
Work in <absolute repository path>.

Raw request boundary:
- Treat the original request as context, not as an unlimited execution plan.
- Preserve the intended outcome, but do not automatically include examples, complaints, optional ideas, or "while here" improvements as scope.

Objective:
- <exact outcome in one or two bullets>

Repository / module scope:
- Root: <repo root>
- In scope: <paths/modules>
- Out of scope: <paths/modules or kinds of work>

Assumptions:
- <conservative assumption made because the request did not specify it, or "None">

SuperDev architecture gate:
- Read root docs/SPEC.md and docs/PLAN.md when present.
- Read relevant module SPEC.md and PLAN.md files before substantial edits.
- Confirm Current Architecture and Target Architecture Mermaid diagrams exist and match the requested direction.
- If target architecture is missing, stale, or inconsistent, update or propose docs before production implementation.

Execution phases:
1. Inventory current state with focused file/search reads.
2. Confirm or repair the SuperDev docs gate.
3. Implement the smallest change that satisfies this goal.
4. Run focused verification.
5. Update SPEC.md / PLAN.md with current architecture, status, next steps, risks, and verification evidence.
6. Close with changed files, verification, and remaining risks.

Anti-complexity rules:
- Do not introduce new central orchestrators, registries, runners, schemas, CI gates, or package scripts unless explicitly required.
- Do not do broad rewrites, speculative abstractions, or unrelated cleanup.
- Do not move or rename files before inventory proves it is necessary.
- Prefer existing patterns and local helpers.
- Prefer the smallest local implementation that satisfies the acceptance criteria.
- Treat "make it cleaner/elegant/stable" as a requirement for simpler implementation, not permission to redesign unrelated code.
- Keep PLAN.md current-state focused; do not add long command dumps or stale history.

Stop conditions:
- Stop if the target architecture is unclear or conflicts with this goal.
- Stop if scope expands into another durable module.
- Stop if acceptance requires verification that cannot be run.
- Stop if the implementation is becoming larger than the goal justifies.
- Stop before creating a new abstraction or central system not explicitly allowed above.

Acceptance criteria:
- <observable completion criterion>
- <doc sync criterion>
- <verification criterion>

Verification evidence:
- Run: <commands/checks/searches>
- Record results in: <PLAN.md path(s)>
```

Keep the final prompt specific. Replace placeholders before handing it to the user or goal mode.
