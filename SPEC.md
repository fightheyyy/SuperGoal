# SuperGoal Spec

SuperGoal packages two Codex skills and one macOS menu-bar app for stabilizing Codex goal-mode repository work.

## Scope

- In scope: `skills/supergoal`, `skills/superdev`, and `plugin/supergoal.app-src`.
- Out of scope: hosted services, prompt marketplaces, cloud sync, multi-user account systems, and unrelated Codex tooling.

## Current Architecture

```mermaid
flowchart LR
    subgraph Inputs["Inputs"]
        A["Rough Codex request"]
        B["Local skill files"]
        C["App settings"]
    end

    subgraph Runtime["Current Runtime"]
        D["supergoal macOS app"]
        E["supergoal skill"]
        F["superdev skill"]
    end

    subgraph Outputs["Outputs"]
        G["Compiled goal prompt"]
        H["Spec/plan-guided Codex execution"]
    end

    A --> D
    C --> D
    D --> G
    B --> E
    B --> F
    E --> H
    F --> H
```

## Target Architecture

```mermaid
flowchart LR
    subgraph Inputs["Inputs"]
        A["Rough Codex request"]
        B["Installed SuperGoal skills"]
        C["Configured macOS app"]
    end

    subgraph Runtime["Target Runtime"]
        D["Prompt compiler app"]
        E["Goal contract skill"]
        F["SuperDev architecture gate"]
    end

    subgraph Outputs["Outputs"]
        G["Bounded goal-mode prompt"]
        H["Narrow verified implementation"]
    end

    A --> D
    C --> D
    D --> G
    G --> E
    E --> F
    B --> E
    B --> F
    F --> H
```

## Repository Layout

- `skills/supergoal`: goal contract compiler skill.
- `skills/superdev`: spec/plan architecture gate skill.
- `plugin/supergoal.app-src`: macOS menu-bar app source.

## Data Contracts

- Skill entry points are `SKILL.md`.
- The app bundle identifier is `com.guowei.supergoal`.
- Release artifacts are zipped `.app` bundles uploaded to GitHub Releases.
