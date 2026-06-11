# SuperGoal

SuperGoal is a Codex goal-mode workflow kit: one macOS menu-bar app plus two local Codex skills.

It helps turn rough, messy requirements into clear goal-mode prompts before Codex starts working. The point is not to make prompts longer for their own sake. The point is to define the objective, scope, non-goals, stop conditions, acceptance criteria, and verification path so Codex produces cleaner repository changes with fewer accidental detours.

[中文 README](./README.zh-CN.md)

## What Is Included

- `plugin/supergoal.app-src`: a macOS menu-bar app that rewrites selected text in Codex into a structured goal prompt.
- `skills/supergoal`: a skill for shaping broad requests into bounded goal contracts.
- `skills/superdev`: a skill for spec/plan-guided repository implementation.

## macOS App

The app sits in the menu bar as an `SG` keyboard icon.

In Codex:

1. Type a rough request in the input box.
2. Select the text.
3. Press the SuperGoal shortcut.
4. Wait for the small keyboard animation.
5. The selected text is replaced with a clearer goal-mode prompt.
6. Send it to Codex.

Features:

- In-place replacement inside the Codex input box.
- Default shortcut: `Control + Option + Command + G`.
- Custom shortcut from the menu bar settings.
- API key, Base URL, and model configuration.
- Custom compiler prompt for personal development habits.
- OpenAI-compatible gateways via configurable Base URL.
- Built-in fallback prompt using `$supergoal` and `$superdev` when no custom prompt is set.

## Download

Download the latest macOS package from:

[GitHub Releases](https://github.com/fightheyyy/SuperGoal/releases/latest)

Use the `.dmg` file, for example:

```text
SuperGoal-v0.1.1.dmg
```

Open the disk image, drag `supergoal.app` to `Applications`, then launch it.

The app is ad-hoc signed but not notarized. macOS may ask you to confirm opening it in Privacy & Security.

## Setup

1. Open `supergoal.app`.
2. Click the menu-bar `SG` keyboard icon.
3. Open `Settings...`.
4. Configure:
   - API key
   - Base URL
   - model
   - shortcut
5. Optional: open `Custom Compiler Prompt...` and write your own prompt optimizer instruction.

Base URL examples:

```text
https://api.openai.com
https://api.openai.com/v1
https://api.openai.com/v1/responses
https://your-gateway.example.com/v1
https://your-gateway.example.com/v1/chat/completions
https://your-gateway.example.com/v1/responses
```

If the Base URL is a root or `/v1` URL, SuperGoal tries OpenAI-compatible chat completions first, then falls back to responses.

## Custom Compiler Prompt

The built-in compiler prompt is designed for Codex goal mode and defaults to using:

```text
$supergoal
$superdev
```

If you leave the custom compiler prompt empty, SuperGoal uses that built-in behavior.

If you fill in a custom compiler prompt, SuperGoal uses your prompt instead. This is useful if you have your own development style, preferred constraints, testing habits, or prompt structure.

## Install The Skills

Clone this repository and copy the skills into your Codex skills directory:

```bash
mkdir -p ~/.codex/skills
cp -R skills/supergoal ~/.codex/skills/
cp -R skills/superdev ~/.codex/skills/
```

Then you can mention them in Codex:

```text
Use $supergoal and $superdev.
```

## Build From Source

Requirements:

- macOS
- Xcode Command Line Tools
- Swift compiler

Build:

```bash
cd plugin/supergoal.app-src
./build.sh
```

Install locally:

```bash
./install.sh
open /Applications/supergoal.app
```

Build a release disk image:

```bash
./package_dmg.sh
```

The `.dmg` is written to:

```text
plugin/supergoal.app-src/release/
```

## Security Notes

- No API key is bundled in this repository.
- API keys are stored locally in the macOS keychain.
- Base URL, model, shortcut, and custom prompt are stored locally.
- Selected text is sent only to the Base URL you configure.
- Do not commit real API keys or private project data.

## License

MIT. See [LICENSE](./LICENSE).
