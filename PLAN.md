# SuperGoal Plan

## Current Status

- Initial repository contents are being published.
- The repo contains two Codex skills and one macOS app source tree.
- Release artifact is built from `plugin/supergoal.app-src`.

## Milestones

- Done: add `skills/supergoal`.
- Done: add `skills/superdev`.
- Done: add `plugin/supergoal.app-src`.
- Done: write bilingual README.
- Done: build release app from repository source.
- Pending: push initial commit to `fightheyyy/SuperGoal`.
- Pending: create GitHub Release and upload zipped app.

## Next Steps

- Commit and push to GitHub as `fightheyyy`.
- Create release `v0.1.0`.

## Owners

- Codex owns packaging and verification for this publishing pass.
- Repository owner owns future product direction and releases.

## Acceptance Criteria

- GitHub repository has the bilingual README.
- GitHub repository includes both skills.
- GitHub repository includes the macOS plugin source.
- GitHub Release includes a compiled zipped app.

## Verification Log

- Passed: `plugin/supergoal.app-src/build.sh`.
- Passed: ad-hoc codesign verify for `build/supergoal.app`.
- Passed: release zip created at `/tmp/SuperGoal-release-artifacts/supergoal-macos-v0.1.0.zip`.
- Passed: clean release zip contains no AppleDouble `._` files.
- Passed: unzipped release app satisfies its designated code-signing requirement.

## Risks / Open Questions

- The app is ad-hoc signed, not notarized.

## Status Maintenance Rules

- Keep this plan focused on current release state and fresh verification evidence.
