---
name: supergoal
description: Use when a user wants to optimize, rewrite, compile, or execute a Codex goal-mode prompt for repository work, especially broad changes, refactors, cleanup, slimming passes, architecture migrations, stability work, or long-running tasks. Turn messy natural-language requirements into a bounded Goal Contract with scope, non-goals, anti-complexity rules, stop conditions, acceptance criteria, and SuperDev SPEC.md / PLAN.md discipline so goal-mode execution stays narrow and avoids over-engineered code.
---

# SuperGoal

SuperGoal is a goal-mode prompt compiler and execution stabilizer for SuperDev repositories. Use it before and during long-running Codex goals to convert a user's natural-language intent into a narrow, verifiable Goal Contract that keeps architecture docs, execution state, implementation, and verification aligned.

## Core Behavior

Before substantial repository work, produce or internalize a Goal Contract. Do not treat the user's raw natural-language request as the execution plan when it is broad, emotional, ambiguous, example-heavy, or multi-module.

Use the SuperDev skill as the architecture gate when available. SuperGoal does not replace SuperDev; it narrows the goal so SuperDev can be applied cleanly.

During execution, keep the contract alive:

- Re-check scope before each phase.
- Update relevant `SPEC.md` and `PLAN.md` as architecture or execution state changes.
- Prefer the smallest implementation that satisfies the contract.
- Stop when the target architecture is unclear, scope expands materially, or acceptance cannot be verified.

## Prompt Compiler Mode

When the user asks to "write a goal", "optimize this prompt", "turn this into a Codex goal", "make this stable for goal mode", or similar, output a directly pasteable goal-mode prompt. Do not execute repository changes unless the user explicitly asks to execute.

Compile the request in this order:

1. Extract the core outcome.
   - Treat complaints, background, examples, and possible approaches as context, not automatic scope.
   - Preserve only the outcome that must be true when the goal finishes.
   - If the request contains several independent outcomes, split them into ordered phases and recommend starting with phase 1.

2. Bound the work.
   - Name the repository root when known.
   - Name the few paths, modules, or behavior surfaces that are in scope.
   - Make nearby tempting work explicit non-goals.
   - Convert vague quality words such as "clean", "stable", "simple", "elegant", "not messy", or "less shit-code" into observable acceptance criteria and anti-complexity rules.

3. Add implementation constraints.
   - Prefer local edits and existing patterns.
   - Forbid speculative abstractions, broad rewrites, new central systems, registries, runners, schemas, CI gates, package scripts, or framework creation unless the user explicitly requested them.
   - Require proof before moving, renaming, deleting, or consolidating files.
   - Require stop-and-ask behavior when scope expands or verification cannot prove acceptance.

4. Add verification.
   - Include focused checks that match the goal: tests, type checks, lint, build, smoke tests, targeted searches, or manual verification.
   - Require evidence to be recorded in relevant `PLAN.md` files when SuperDev docs exist.

The compiled prompt should be opinionated, narrow, and easy to paste into Codex goal mode. It should not be a motivational essay or a long project plan.

## Goal Contract

For broad tasks, first draft a compact contract with these fields. If the user only asked for a goal prompt, output the contract as the final artifact. If the user asked you to execute, use the contract internally and then proceed.

- `Objective`: one sentence describing the exact outcome.
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

For a reusable template, read `references/goal-contract-template.md`.

## Workflow

1. Parse the user's natural language into a narrow outcome.
   - Separate desired outcome from examples, complaints, historical context, and optional ideas.
   - Convert vague verbs such as "clean up", "slim", "make stable", "fix the architecture", or "make it elegant" into concrete scope, non-goals, and acceptance criteria.
   - Do not promote "while here" ideas into scope.
   - If the request has multiple independent outcomes, split it into ordered phases and recommend starting with the smallest phase.

2. Establish the SuperDev gate.
   - Identify whether the request touches repository-wide behavior, one durable module, or multiple modules.
   - Read root `docs/SPEC.md` and `docs/PLAN.md` when present.
   - Read relevant module `SPEC.md` and `PLAN.md` files when present.
   - Confirm each relevant `SPEC.md` has truthful `Current Architecture` and clear `Target Architecture` Mermaid diagrams.
   - If the target architecture is missing, stale, or inconsistent with the request, update or propose the docs before production implementation.

3. Keep implementation narrow.
   - Follow existing repo patterns unless the contract explicitly authorizes a change.
   - Prefer local edits over new abstractions.
   - Avoid creating new orchestrators, registries, runners, schemas, CI gates, or package scripts unless they are named in scope.
   - Do not move files, rename concepts, or delete historical artifacts before inventory proves they belong to the current objective.
   - Treat "while here" improvements as out of scope unless required for acceptance.

4. Maintain SuperDev docs while the goal runs.
   - If implementation changes architecture, update the relevant `Current Architecture`.
   - If the intended direction changes, update `Target Architecture`.
   - If `SPEC.md` adds or removes concepts, boundaries, phases, files, contracts, or ownership, update `PLAN.md`.
   - If a milestone becomes complete, record only current status and recent effective verification in `PLAN.md`.
   - Do not let `PLAN.md` become a command dump or long historical log; git carries old history.

5. Verify and close.
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

When asked to "write a goal", produce a concise goal-mode prompt with the Goal Contract embedded. Make it directly pasteable into Codex goal mode.

When asked to "optimize a prompt", return the optimized goal prompt first. Include at most a short note after it if assumptions or unresolved inputs matter.

When asked to execute, keep the contract concise in user updates, then do the work. Do not bury the user in process text.

Use direct language. The point is stable execution, not ceremony.
