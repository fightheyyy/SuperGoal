# testCodexClaudecode Plan

## Current Status

- `supergoal.app-src` is the active durable module.
- Root SuperDev docs were added because the repository previously had no spec or plan files.
- Release packaging now targets a macOS `.dmg` instead of a zip.

## Milestones

- Done: identify `supergoal.app-src` as the only module touched by custom prompt work.
- Done: add a settings-backed custom compiler prompt while preserving default behavior.
- Done: keep the app icon stable while switching the menu-bar icon to a smaller monochrome template mark.
- Done: add a release DMG packaging script.
- Done: add a visible README promo preview while keeping the full MP4 attached to the release.

## Next Steps

- Monitor release feedback and keep future release artifacts on the `.dmg` path.

## Owners

- Codex owns implementation and verification in this thread.
- User owns product preference decisions.

## Acceptance Criteria

- Supergoal app behavior remains default-compatible when no custom prompt is set.
- A user can save a custom compiler prompt from the menu bar's dedicated prompt editor.
- Saved custom prompt is used for future compile requests.
- Release users can download a `.dmg` package directly.
- App icon remains unchanged; menu-bar icon uses a smaller rounded black/white template mark.
- The README shows a visible animated promo preview and links to the full MP4 release asset.

## Verification Log

- Passed: Swift build via `./supergoal.app-src/build.sh`.
- Passed: runtime smoke checks for default and custom compiler prompt modes.
- Passed: generated `supergoal.app-src/release/SuperGoal-v0.1.2.dmg`.
- Passed: installed `/Applications/supergoal.app`; app resources no longer include the colored menu-bar icon.
- Passed: uploaded `SuperGoal-v0.1.2.dmg` to GitHub Release.
- Passed: generated `docs/supergoal-promo.gif` from the MP4 promo so GitHub README can display it inline.

## Risks / Open Questions

- Custom prompt editing now lives in a dedicated menu window; no presets or profile system were added.
- App is still ad-hoc signed and not notarized, so macOS may require manual confirmation on first open.

## Status Maintenance Rules

- Keep this plan focused on current state and recent verification evidence.
