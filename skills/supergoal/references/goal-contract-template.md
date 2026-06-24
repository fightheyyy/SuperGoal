# SuperGoal Contract Template

Use this template when drafting a pasteable goal-mode prompt for Codex or when starting an active goal from a rough request. Replace every placeholder. Keep the result narrow enough that a goal-mode agent can execute it without inventing extra architecture.

Start by defining when Codex should stop. The user does not need to describe every implementation step; the goal prompt should turn their rough request into acceptance metrics, then require Codex to write the detailed main goal and any useful subagent goals from those metrics.

```text
Goal: <one concrete outcome>

Use $supergoal and $superdev.
Work in <absolute repository path>.

Acceptance-first instruction:
- Treat my request as the desired end state, not as a step-by-step implementation plan.
- First define the observable acceptance metrics and stop conditions.
- Then write the detailed main Goal Contract from those metrics before editing code.
- Before implementation, scan for independent discovery, implementation, and verification slices. If any exist and subagent tools are available, create bounded subagent Goal Contracts too.

Goal startup instruction:
- If this is being used inside an active Codex session and goal tools are available, create or activate this as the parent goal instead of only returning this block as text.
- If subagent tools are available, launch the bounded subagent goals below in parallel where their scopes are independent.
- If no subagent is launched, state the reason plainly: no tool, no independent slice after scanning, unsafe write overlap, or user explicitly requested solo work. A small feature is not by itself a valid skip reason when read-only reconnaissance or independent verification would help.
- If goal or subagent tools are unavailable, state the fallback plainly and continue sequentially with the same acceptance metrics.

Raw request boundary:
- Treat the original request as context, not as an unlimited execution plan.
- Preserve the intended outcome, but do not automatically include examples, complaints, optional ideas, or "while here" improvements as scope.

Objective:
- <exact outcome in one or two bullets>

Acceptance / stop metrics:
- Codex may stop when <observable outcome is true>.
- Codex may stop when <verification command/search/manual check passes>.
- Codex must not stop merely because code was changed; it must prove the acceptance metrics.

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
1. Translate the request into acceptance metrics and stop conditions.
2. Write the detailed main Goal Contract from those metrics.
3. Create or activate the parent goal when goal-mode tools are available.
4. Run a subagent opportunity scan for independent discovery, implementation, and verification slices.
5. Create and launch subagent Goal Contracts for every independent slice that can run in parallel.
6. If no subagent is launched, state the skip reason before continuing.
7. Inventory current state with focused file/search reads.
8. Confirm or repair the SuperDev docs gate.
9. Implement the smallest change that satisfies this goal.
10. Run focused verification.
11. Update SPEC.md / PLAN.md with current architecture, status, next steps, risks, and verification evidence.
12. Close with changed files, verification, and remaining risks.

Subagent goals:
- Subagent A goal: <read-only discovery, independent verification, or bounded implementation slice>
  - Scope: <files/modules it may inspect or edit>
  - Non-goals: <what it must not touch>
  - Stop condition: <what evidence means this subagent is done>
  - Deliverable: <concise findings, file references, recommendation, or patch summary>
- Subagent B goal: <another independent slice, or "None: <skip reason>">

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
- Stop if a subagent goal returns evidence that invalidates the main goal or acceptance metrics.

Acceptance criteria:
- <observable completion criterion>
- <doc sync criterion>
- <verification criterion>

Verification evidence:
- Run: <commands/checks/searches>
- Record results in: <PLAN.md path(s)>
```

Keep the final prompt specific. Replace placeholders before handing it to the user or goal mode.
