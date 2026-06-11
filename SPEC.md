# testCodexClaudecode Spec

This repository contains small local experiments plus the durable `supergoal.app-src` macOS helper app and release packaging flow.

## Scope

- In scope: maintain the `supergoal.app-src` app as the current durable product surface.
- Out of scope: redesign unrelated root-level web/game files during supergoal app work.

## Current Architecture

```mermaid
flowchart LR
    subgraph Inputs["Inputs"]
        A["Root workspace files"]
        B["supergoal.app-src"]
    end

    subgraph Runtime["Current Runtime"]
        C["macOS menu bar helper"]
    end

    subgraph Outputs["Outputs"]
        D["/Applications/supergoal.app"]
        E["Release DMG"]
    end

    B --> C
    C --> D
    C --> E
    A -. unrelated .-> B
```

## Target Architecture

```mermaid
flowchart LR
    subgraph Inputs["Inputs"]
        A["User selection in Codex"]
        B["supergoal settings"]
    end

    subgraph Runtime["Target Runtime"]
        C["supergoal compiler app"]
        E["Configurable compiler prompt"]
    end

    subgraph Outputs["Outputs"]
        D["Replaced goal prompt in Codex"]
        F["Downloadable macOS DMG"]
    end

    A --> C
    B --> E
    E --> C
    C --> D
    C --> F
```

## Main Boundaries

- `supergoal.app-src` owns macOS UI, settings, hotkey handling, prompt compilation, icons, installation scripts, and DMG packaging.
- Root files outside `supergoal.app-src` are not part of current supergoal feature work.
