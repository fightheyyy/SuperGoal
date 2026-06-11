# supergoal.app-src Plan

## Current Status

- The app compiles selected text using either the built-in compiler prompt or a saved custom compiler prompt.
- Settings support API key, base URL, model, and custom global shortcut.
- A separate `Custom Compiler Prompt...` menu item opens custom prompt editing.
- Empty custom prompt input falls back to the built-in compiler prompt.

## Milestones

- Done: document current and target architecture for custom prompt support.
- Done: add custom prompt storage key.
- Done: move custom prompt editing out of Settings into a dedicated menu item/window.
- Done: pass effective prompt into `OpenAIClient`.
- Done: verify default and custom prompt paths.

## Next Steps

- Keep the custom prompt editor lightweight; avoid presets or prompt profile systems unless explicitly requested.

## Owners

- Codex owns code and verification for this feature.
- User owns final UX preference.

## Acceptance Criteria

- Default path uses the built-in compiler prompt when custom prompt is empty.
- Custom path uses the saved custom compiler prompt in API payloads.
- Empty prompt input does not break compilation.
- Code changes remain local to settings, app state loading, and API payload wiring.

## Verification Log

- Passed: `./supergoal.app-src/build.sh`.
- Passed: app launch log check after install.
- Passed: default path log showed `compiler prompt mode=default`.
- Passed: custom path log showed `compiler prompt mode=custom`; temporary prompt `Output exactly CUSTOM_PROMPT_USED` produced `CUSTOM_PROMPT_USED`.
- Passed: Settings menu action opens the settings window after fixing prompt-row constraint ordering; UI script observed `windows=1` and log showed `settings window shown`.
- Passed: menu contains `Custom Compiler Prompt...`; UI script opened Settings and Custom Compiler Prompt as separate windows and logs showed both `settings window shown` and `compiler prompt window shown`.

## Risks / Open Questions

- Very long custom prompts can make requests larger and slower; settings caps prompt length at 8000 characters.
- Keep custom prompt editing as one dedicated menu window; do not add presets or profile management without a new request.

## Status Maintenance Rules

- Update this plan after implementation and verification.
