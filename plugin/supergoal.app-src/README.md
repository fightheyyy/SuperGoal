# supergoal

Small macOS menu-bar helper that replaces selected text in Codex with a compiled goal-mode prompt.

## Build

```bash
./build.sh
```

The app bundle is created at:

```text
build/supergoal.app
```

## Install

```bash
./install.sh
open /Applications/supergoal.app
```

## Package

```bash
./package_dmg.sh
```

The release disk image is created at:

```text
release/SuperGoal-v0.1.1.dmg
```

## Use

1. Open `/Applications/supergoal.app`.
2. Click the `SG` keyboard menu-bar item and open `Settings...`.
3. Enter an OpenAI API key, Base URL, and model.
4. In Codex, type a rough request into the message box.
5. Select that rough request.
6. Press `Control + Option + Command + G`.
7. supergoal replaces the selected text with a Codex goal-mode prompt.

supergoal uses macOS keyboard automation to copy and replace the selected text. The first run may require Accessibility permission for `/Applications/supergoal.app`.

Fallback if Accessibility is stubborn:

1. Select the rough request in Codex.
2. Press `Command + C`.
3. Click `sg` -> `Compile Clipboard`.
4. Press `Command + V` in Codex.

Base URL examples:

```text
https://api.openai.com
https://api.openai.com/v1
https://api.openai.com/v1/responses
https://your-gateway.example.com/v1
https://your-gateway.example.com/v1/chat/completions
https://your-gateway.example.com/v1/responses
```

When the Base URL is a root or `/v1` URL, supergoal tries `/v1/chat/completions` first for OpenAI-compatible gateways, then falls back to `/v1/responses`.
