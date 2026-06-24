---
name: supergoal
description: >-
  Use when a user wants to optimize, rewrite, compile, start, or execute a
  Codex goal-mode task for repository work, especially broad changes,
  refactors, cleanup, slimming passes, architecture migrations, stability
  work, or long-running tasks. Turn messy natural-language requirements into
  acceptance-first execution: define when Codex should stop, create or
  activate a detailed main goal when the user asks to do the work, and when
  useful launch bounded subagent goals for parallel discovery or
  implementation. Only return a pasteable prompt when the user explicitly asks
  for prompt-writing without execution. Keep scope, non-goals,
  anti-complexity rules, stop conditions, acceptance criteria, verification,
  and SuperDev SPEC.md / PLAN.md discipline explicit so goal-mode execution
  stays narrow and avoids over-engineered code.
---

# SuperGoal

SuperGoal is an acceptance-first goal starter and execution stabilizer for SuperDev repositories. Use it before and during long-running Codex goals to convert a user's natural-language intent into stop conditions, a detailed main Goal Contract, and optional subagent Goal Contracts that keep architecture docs, execution state, implementation, and verification aligned. It can also compile pasteable prompts, but only when the user explicitly asks for prompt-writing instead of execution.

## Core Behavior

Before substantial repository work, draft a Goal Contract internally. Output that contract as the final artifact only in compile-only mode. Do not treat the user's raw natural-language request as the execution plan when it is broad, emotional, ambiguous, example-heavy, or multi-module.

Start from acceptance, not activity:

- Translate what the user wants into observable stop conditions before deciding what Codex should do.
- Treat the user's request as "what must be true when the goal stops", not as a list of implementation steps to obey blindly.
- If the user provides tactics, examples, or complaints, preserve them as context only when they help define acceptance.
- Make Codex write the detailed main goal from those acceptance criteria instead of merely expanding the user's wording.
- When subagents are useful and available, launch bounded subagent goals with their own stop conditions and deliverables. In compile-only mode, write those subagent goals into the prompt instead.

Use the SuperDev skill as the architecture gate when available. SuperGoal does not replace SuperDev; it narrows the goal so SuperDev can be applied cleanly.

During execution, keep the contract alive:

- Re-check scope before each phase.
- Update relevant `SPEC.md` and `PLAN.md` as architecture or execution state changes.
- Prefer the smallest implementation that satisfies the contract.
- Stop when the target architecture is unclear, scope expands materially, or acceptance cannot be verified.

## Mode Selection

Within a SuperGoal-triggered goal-mode request, default to execution when the user asks Codex to do, build, fix, implement, refactor, clean, migrate, verify, or otherwise perform repository work. Do not stop after drafting a prompt in those cases.

Use compile-only mode only when the user explicitly asks to write, optimize, rewrite, or compile a prompt for later use and does not ask Codex to execute the underlying work.

If intent is mixed, prefer execution and keep the compiled Goal Contract internal. Mention the goal contract briefly, then start the work.

## Goal Execution Mode

When the user asks Codex to actually do the work, create or activate the goal and continue execution instead of returning a text prompt as the final artifact.

Execute in this order:

1. Draft observable acceptance metrics and stop conditions.
2. Write a detailed parent Goal Contract from those metrics.
3. Use the available goal-mode mechanism to start or update the parent goal, such as `create_goal` when that tool exists in the environment.
4. If subagent tools are available and the work has independent slices, start bounded subagents in parallel. Give each subagent its own Goal Contract with scope, forbidden work, stop condition, expected output, and merge plan.
5. Continue the parent task while subagents run when there is non-overlapping work to do.
6. Integrate subagent findings or patches, then verify acceptance.

If goal tools or subagent tools are unavailable, say so briefly and continue with the closest safe fallback. Do not pretend a goal or subagent was started.

## Shared Goal Drafting Rules

Use these rules in both execution and compile-only mode. In execution mode, apply them internally before starting or updating the goal. In compile-only mode, turn them into a directly pasteable goal-mode prompt.

Compile the request in this order:

1. Extract acceptance and stop conditions.
   - Convert the request into "Codex may stop when..." statements before writing task steps.
   - Define observable success: behavior, files, UI states, tests, docs, performance, or absence of regressions.
   - Convert vague quality words such as "clean", "stable", "simple", "elegant", "not messy", or "less shit-code" into measurable acceptance criteria and anti-complexity rules.
   - If acceptance is underspecified, infer conservative checks and mark them as assumptions.

2. Extract the core outcome.
   - Treat complaints, background, examples, and possible approaches as context, not automatic scope.
   - Preserve only the outcome that must be true when the goal finishes.
   - If the request contains several independent outcomes, split them into ordered phases and recommend starting with phase 1.

3. Make Codex write the detailed main goal.
   - The compiled prompt should instruct Codex to formulate a precise main goal from the acceptance criteria before editing code.
   - The main goal must include objective, repository/module boundaries, in-scope work, non-goals, assumptions, implementation constraints, stop conditions, acceptance criteria, and verification evidence.
   - The main goal should state what to prove, not just what to change.

4. Bound the work.
   - Name the repository root when known.
   - Name the few paths, modules, or behavior surfaces that are in scope.
   - Make nearby tempting work explicit non-goals.

5. Add implementation constraints.
   - Prefer local edits and existing patterns.
   - Forbid speculative abstractions, broad rewrites, new central systems, registries, runners, schemas, CI gates, package scripts, or framework creation unless the user explicitly requested them.
   - Require proof before moving, renaming, deleting, or consolidating files.
   - Require stop-and-ask behavior when scope expands or verification cannot prove acceptance.

6. Add subagent goals when useful.
   - Use subagents only for independent slices: codebase reconnaissance, alternative implementation options, risky-file inventory, test strategy, regression search, or isolated module work.
   - Each subagent must receive its own mini Goal Contract: purpose, allowed files/modules, forbidden work, stop condition, expected output, and how its findings will be merged into the parent goal.
   - Prefer read-only scout subagents unless implementation work is explicitly assigned to a bounded path.
   - Do not ask subagents to "help broadly"; give them concrete acceptance criteria and require concise evidence.

7. Add verification.
   - Include focused checks that match the goal: tests, type checks, lint, build, smoke tests, targeted searches, or manual verification.
   - Require evidence to be recorded in relevant `PLAN.md` files when SuperDev docs exist.

When compile-only mode is requested, the compiled prompt should be opinionated, narrow, and easy to paste into Codex goal mode. It should not be a motivational essay or a long project plan.

## Compile-Only Mode

Use compile-only mode only when the user explicitly asks to "write a goal", "optimize this prompt", "turn this into a Codex goal", "make this stable for goal mode", or similar for later use. Do not execute repository changes in compile-only mode.

## Goal Contract

For broad tasks, first draft a compact contract with these fields. If the user only asked for a goal prompt, output the contract as the final artifact. If the user asked you to execute, use the contract to start or update the active goal, then proceed.

- `Objective`: one sentence describing the exact outcome.
- `Acceptance / Stop Metrics`: the observable conditions that tell Codex the goal is done.
- `Repository / Modules`: the root and module boundaries affected.
- `In Scope`: the few concrete changes allowed.
- `Non-Goals`: nearby work that must not be done in this run.
- `Assumptions`: conservative assumptions made because the request did not specify something.
- `SuperDev Docs`: root and module `SPEC.md` / `PLAN.md` files that must be read or updated.
- `Architecture Gate`: what must be true before production code changes begin.
- `Execution Phases`: inventory, docs gate, implementation, verification, doc sync, closeout.
- `Anti-Complexity Rules`: constraints that prevent broad rewrites, new central systems, speculative abstractions, or accidental framework creation.
- `Stop Conditions`: conditions that require pausing for user input instead of improvising.
- `Acceptance Criteria`: observable completion requirements.
- `Verification Evidence`: checks to run and where results must be recorded.
- `Subagent Goals`: optional bounded goals for parallel subagents, each with scope, stop condition, and deliverable.

For a reusable template, read `references/goal-contract-template.md`.

## Workflow

1. Parse the user's natural language into a narrow outcome.
   - Separate desired outcome from examples, complaints, historical context, and optional ideas.
   - First write the acceptance/stop metrics: what Codex must prove before it is allowed to stop.
   - Convert vague verbs such as "clean up", "slim", "make stable", "fix the architecture", or "make it elegant" into concrete scope, non-goals, and acceptance criteria.
   - Do not promote "while here" ideas into scope.
   - If the request has multiple independent outcomes, split it into ordered phases and recommend starting with the smallest phase.

2. Draft the main goal.
   - Make the main goal detailed enough that another Codex run can execute it without reading the prior conversation.
   - Prefer acceptance-driven phrasing: "Stop when X is true and verified", not "Do these steps".
   - Include explicit proof requirements before allowing file moves, abstractions, or broad cleanup.
   - In execution mode, start or update the active parent goal after drafting this contract when goal tools are available.

3. Draft subagent goals when parallelism would reduce uncertainty.
   - Use subagents for discovery or independent work only when their outputs can be merged cleanly.
   - Give each subagent its own scope, forbidden areas, stop condition, and required evidence.
   - Tell subagents to return findings, file references, and recommended next action, not broad essays.
   - In execution mode, launch available subagent tools for those goals instead of only listing them.
   - If subagents are not available or the task is small, omit subagent goals or state the fallback briefly.

4. Establish the SuperDev gate.
   - Identify whether the request touches repository-wide behavior, one durable module, or multiple modules.
   - Read root `docs/SPEC.md` and `docs/PLAN.md` when present.
   - Read relevant module `SPEC.md` and `PLAN.md` files when present.
   - Confirm each relevant `SPEC.md` has truthful `Current Architecture` and clear `Target Architecture` Mermaid diagrams.
   - If the target architecture is missing, stale, or inconsistent with the request, update or propose the docs before production implementation.

5. Keep implementation narrow.
   - Follow existing repo patterns unless the contract explicitly authorizes a change.
   - Prefer local edits over new abstractions.
   - Avoid creating new orchestrators, registries, runners, schemas, CI gates, or package scripts unless they are named in scope.
   - Do not move files, rename concepts, or delete historical artifacts before inventory proves they belong to the current objective.
   - Treat "while here" improvements as out of scope unless required for acceptance.

6. Maintain SuperDev docs while the goal runs.
   - If implementation changes architecture, update the relevant `Current Architecture`.
   - If the intended direction changes, update `Target Architecture`.
   - If `SPEC.md` adds or removes concepts, boundaries, phases, files, contracts, or ownership, update `PLAN.md`.
   - If a milestone becomes complete, record only current status and recent effective verification in `PLAN.md`.
   - Do not let `PLAN.md` become a command dump or long historical log; git carries old history.

7. Verify and close.
   - Run focused tests, type checks, lint, schema validation, or searches that match the contract.
   - Record verification evidence in the relevant `PLAN.md` when the change is substantial.
   - Final response should summarize what changed, what was verified, and any remaining risks or stop conditions encountered.

## Stop Conditions

Pause and ask or propose a doc update before continuing when:

- The requested goal conflicts with the current `Target Architecture`.
- The relevant `SPEC.md` lacks a clear target Mermaid diagram.
- The work would require a new central system not named in the contract.
- The scope expands into another durable module.
- Verification cannot be run or cannot prove the acceptance criteria.
- The implementation would become larger than the contract justifies.

## Output Style

When asked to execute repository work, do not merely return a prompt. Start or update the goal, launch useful bounded subagents when available, then proceed. Keep the contract concise in user updates.

When asked to "write a goal" or "optimize a prompt" for later use, produce a concise goal-mode prompt with the Goal Contract embedded. Make it directly pasteable into Codex goal mode. Include at most a short note after it if assumptions or unresolved inputs matter.

When tools required for true goal or subagent startup are unavailable, say that plainly and continue with the closest safe sequential execution path. Do not bury the user in process text.

Use direct language. The point is stable execution, not ceremony.
