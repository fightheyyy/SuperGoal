# SuperGoal

SuperGoal is a small Codex workflow kit with three parts:

- `skills/supergoal`: a Codex skill for compiling messy requests into bounded goal-mode contracts.
- `skills/superdev`: a Codex skill for spec/plan-gated repository work.
- `plugin/supergoal.app-src`: a macOS menu-bar app that turns selected text in Codex into a better goal prompt.

中文：SuperGoal 是一套面向 Codex goal mode 的轻量工作流工具，包含两个 Skill 和一个 macOS 菜单栏插件。它的目标不是替你写更多流程，而是把需求边界、非目标、停止条件和验证方式说清楚，让 Codex 在长任务里少发散、少堆复杂代码。

## What It Does

### macOS app

The SuperGoal app sits in the macOS menu bar. In Codex, write a rough request, select it, press the global shortcut, and the app replaces that selection with a cleaner goal-mode prompt.

Features:

- Global hotkey, default `Control + Option + Command + G`.
- Custom global shortcut.
- Custom compiler prompt from the menu bar.
- OpenAI-compatible API support via configurable Base URL and model.
- Pixel keyboard progress animation while compiling.
- In-place replacement of selected text in Codex.

中文功能：

- 默认快捷键：`Control + Option + Command + G`。
- 支持自定义快捷键。
- 支持用户自己的 compiler prompt，用来匹配个人开发习惯。
- 支持 OpenAI-compatible 网关，可配置 Base URL 和 model。
- 编译过程中有像素键盘小动画。
- 直接替换 Codex 输入框中选中的粗需求。

### SuperGoal skill

`skills/supergoal` turns a broad or messy repository request into a narrow goal contract:

- objective
- in-scope work
- non-goals
- anti-complexity rules
- stop conditions
- acceptance criteria
- verification evidence

中文：`supergoal` skill 负责把自然语言需求压成可执行的 Goal Contract，避免 Codex 在 goal mode 下扩大范围、随手重构、引入不必要抽象。

### SuperDev skill

`skills/superdev` adds a lightweight architecture gate for durable repository work:

- maintain `SPEC.md`
- maintain `PLAN.md`
- require current and target Mermaid architecture diagrams
- keep implementation, docs, and verification aligned

中文：`superdev` skill 负责让长期仓库工作有活的架构契约。它要求维护 `SPEC.md` / `PLAN.md`，并用 Current / Target Architecture 图约束实现方向。

## Why The App Still Mentions Skills

The app and the skills do different jobs.

- The app compiles text before you send it to Codex.
- The skills guide Codex after the prompt enters a Codex conversation.

So a compiled prompt may still say `Use $supergoal and $superdev`. That is intentional: it tells Codex which local skills to load while executing the generated goal.

中文：插件只是“生成更好的 prompt”。真正进入 Codex 后，Codex 仍然需要知道要使用哪些本地 skill 来执行。因此生成结果里保留 `Use $supergoal and $superdev` 并不重复。

## Repository Layout

```text
SuperGoal/
  README.md
  SPEC.md
  PLAN.md
  skills/
    supergoal/
      SKILL.md
      agents/
      references/
    superdev/
      SKILL.md
      agents/
  plugin/
    supergoal.app-src/
      Sources/main.swift
      Scripts/make_icons.swift
      Assets/
      build.sh
      install.sh
```

## Install The macOS App

1. Download `supergoal-macos-v0.1.0.zip` from the latest GitHub Release.
2. Unzip it.
3. Move or keep `supergoal.app` wherever you prefer.
4. Open the app.
5. Grant Accessibility permission when macOS asks.
6. Click the menu-bar keyboard icon, open `Settings...`, and configure:
   - API key
   - Base URL
   - model
   - shortcut
7. Optional: click `Custom Compiler Prompt...` to use your own compiler prompt.

中文安装：

1. 从 GitHub Release 下载 `supergoal-macos-v0.1.0.zip`。
2. 解压。
3. 打开 `supergoal.app`。
4. 按 macOS 提示授予 Accessibility 权限。
5. 点击菜单栏键盘图标，打开 `Settings...` 配置 API key、Base URL、model 和快捷键。
6. 如需个性化开发习惯，点击 `Custom Compiler Prompt...` 配置自己的 prompt。

Note: this app is ad-hoc signed, not notarized. macOS may ask you to confirm opening it from Privacy & Security.

## Use The App In Codex

1. In Codex, type a rough request.
2. Select the text you want to improve.
3. Press your SuperGoal shortcut.
4. Wait for the pixel keyboard animation.
5. The selected text is replaced with a goal-mode prompt.
6. Send it to Codex.

中文使用方式：

1. 在 Codex 输入框写一段粗需求。
2. 选中这段需求。
3. 按 SuperGoal 快捷键。
4. 等像素键盘动画结束。
5. 插件会把选中文本替换成更稳定的 goal prompt。
6. 直接发送给 Codex。

## Install The Skills

Clone this repository, then copy the skills into your Codex skills directory:

```bash
mkdir -p ~/.codex/skills
cp -R skills/supergoal ~/.codex/skills/
cp -R skills/superdev ~/.codex/skills/
```

中文：克隆仓库后，把两个 skill 复制到 `~/.codex/skills`。

```bash
mkdir -p ~/.codex/skills
cp -R skills/supergoal ~/.codex/skills/
cp -R skills/superdev ~/.codex/skills/
```

After installation, you can mention them in Codex prompts:

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

The install script ad-hoc signs the app with a stable bundle identifier so macOS Accessibility permission remains stable across rebuilds.

中文：源码构建需要 macOS、Xcode Command Line Tools 和 Swift。运行 `build.sh` 构建，运行 `install.sh` 安装到 `/Applications/supergoal.app`。

## API Configuration

Base URL examples:

```text
https://api.openai.com
https://api.openai.com/v1
https://api.openai.com/v1/responses
https://your-gateway.example.com/v1
https://your-gateway.example.com/v1/chat/completions
https://your-gateway.example.com/v1/responses
```

When the Base URL is a root or `/v1` URL, SuperGoal tries OpenAI-compatible chat completions first, then falls back to responses.

## Custom Compiler Prompt

Open `Custom Compiler Prompt...` from the menu bar to provide your own compiler prompt.

- Empty prompt: use the built-in default.
- Non-empty prompt: use your custom prompt.
- Maximum length: 8000 characters.

中文：如果你有自己的开发习惯，可以在 `Custom Compiler Prompt...` 里配置。留空走默认 prompt；填写后优先使用你的 prompt。

## Security Notes

- No API key is bundled in this repository.
- Your API settings are stored locally in macOS user defaults for the app.
- Selected text is sent only to the Base URL you configure.
- Do not commit real API keys or private project data.

## License

MIT. See `LICENSE`.
