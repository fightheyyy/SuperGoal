# supergoal.app-src Plan

## Current Status

- The app compiles selected text using either the built-in compiler prompt or a saved custom compiler prompt.
- Settings support API key, base URL, model, and custom global shortcut.
- A separate `Custom Compiler Prompt...` menu item opens custom prompt editing.
- Empty custom prompt input falls back to the built-in compiler prompt.
- App icon remains stable while the menu-bar icon is generated as a smaller monochrome rounded template mark.
- Release packaging creates a `.dmg` instead of a zip.

## Milestones

- Done: document current and target architecture for custom prompt support.
- Done: add custom prompt storage key.
- Done: move custom prompt editing out of Settings into a dedicated menu item/window.
- Done: pass effective prompt into `OpenAIClient`.
- Done: verify default and custom prompt paths.
- Done: keep the app icon stable and regenerate the menu-bar icon as a black/white template asset.
- Done: add `package_dmg.sh` for a drag-to-Applications disk image.

## Next Steps

- Upload the generated `.dmg` to GitHub Release and remove the old zip asset.

## Owners

- Codex owns code and verification for this feature.
- User owns final UX preference.

## Acceptance Criteria

- Default path uses the built-in compiler prompt when custom prompt is empty.
- Custom path uses the saved custom compiler prompt in API payloads.
- Empty prompt input does not break compilation.
- Code changes remain local to settings, app state loading, and API payload wiring.
- App icon remains unchanged; menu-bar icon is a smaller rounded black/white template mark.
- GitHub Release provides `SuperGoal-v0.1.2.dmg`.

## Verification Log

- Passed: `./supergoal.app-src/build.sh`.
- Passed: app launch log check after install.
- Passed: default path log showed `compiler prompt mode=default`.
- Passed: custom path log showed `compiler prompt mode=custom`; temporary prompt `Output exactly CUSTOM_PROMPT_USED` produced `CUSTOM_PROMPT_USED`.
- Passed: Settings menu action opens the settings window after fixing prompt-row constraint ordering; UI script observed `windows=1` and log showed `settings window shown`.
- Passed: menu contains `Custom Compiler Prompt...`; UI script opened Settings and Custom Compiler Prompt as separate windows and logs showed both `settings window shown` and `compiler prompt window shown`.
- Passed: `./package_dmg.sh` created `release/SuperGoal-v0.1.2.dmg`.
- Passed: `codesign --verify --deep --strict /Applications/supergoal.app`.
- Passed: installed app resources include `AppIcon.icns` and `MenuBarIconTemplate.png`; colored `MenuBarIcon.png` is no longer packaged.

## Risks / Open Questions

- Very long custom prompts can make requests larger and slower; settings caps prompt length at 8000 characters.
- Keep custom prompt editing as one dedicated menu window; do not add presets or profile management without a new request.
- DMG is ad-hoc signed but not Apple-notarized.

## Status Maintenance Rules

- Update this plan after implementation and verification.
