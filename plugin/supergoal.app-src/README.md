# supergoal macOS app

Small macOS menu-bar helper that replaces selected text in Codex with a compiled goal-mode prompt.

中文：一个轻量 macOS 菜单栏插件，用来把 Codex 输入框中选中的粗需求替换成更稳定的 goal-mode prompt。

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

## Use

1. Open `/Applications/supergoal.app`.
2. Click the keyboard menu-bar icon and open `Settings...`.
3. Enter an OpenAI API key, Base URL, and model.
4. Optional: open `Custom Compiler Prompt...` to use your own compiler prompt.
5. In Codex, type a rough request into the message box.
6. Select that rough request.
7. Press `Control + Option + Command + G` or your custom shortcut.
8. supergoal replaces the selected text with a Codex goal-mode prompt.

supergoal uses macOS keyboard automation to copy and replace the selected text. The first run may require Accessibility permission for `/Applications/supergoal.app`.

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
