# SuperGoal

SuperGoal 是一套给 Codex goal mode 用的轻量工作流工具：一个 macOS 菜单栏 App，加两个本地 Codex Skill。

它解决的问题很简单：很多时候我们随手写给 Codex 的需求太散、边界不清，goal mode 就容易把事情做复杂，甚至堆出不必要的代码。SuperGoal 会先把粗糙需求优化成结构化、可执行、有边界的 goal prompt，再交给 Codex 执行。

[English README](./README.md)

## 演示

![SuperGoal 宣传预览](./docs/supergoal-promo.gif)

[查看高清 MP4 演示](https://github.com/fightheyyy/SuperGoal/releases/download/v0.1.2/SuperGoal-promo.mp4)

## 包含什么

- `plugin/supergoal.app-src`：macOS 菜单栏 App，可以把 Codex 输入框中选中的粗需求直接替换成结构化 goal prompt。
- `skills/supergoal`：负责把自然语言需求整理成目标、范围、非目标、停止条件和验收标准。
- `skills/superdev`：负责让长期仓库开发有 SPEC / PLAN 约束，减少无意义重构和发散。

## macOS App

App 会出现在 macOS 右上角菜单栏，是一个很小的黑白键盘图标。

在 Codex 里使用：

1. 在输入框写一段粗需求。
2. 选中这段文字。
3. 按 SuperGoal 快捷键。
4. 等待小键盘动效。
5. 选中文字会被替换成更清晰的 goal-mode prompt。
6. 直接发送给 Codex。

功能：

- 直接替换 Codex 输入框里选中的文字。
- 默认快捷键：`Control + Option + Command + G`。
- 支持自定义快捷键。
- 支持配置 API key、Base URL 和 model。
- 支持自定义 prompt 优化提示词，适配不同开发习惯。
- 支持 OpenAI-compatible 网关。
- 未填写自定义 prompt 时，默认使用内置 `$supergoal` 和 `$superdev` 逻辑。

## 下载

从最新 GitHub Release 下载 macOS 包：

[GitHub Releases](https://github.com/fightheyyy/SuperGoal/releases/latest)

下载 `.dmg` 文件，例如：

```text
SuperGoal-v0.1.2.dmg
```

打开磁盘镜像，把 `supergoal.app` 拖到 `Applications`，然后启动。

注意：当前 App 是 ad-hoc 签名，还没有做 Apple notarization。第一次打开时，macOS 可能要求你在“隐私与安全性”里手动确认。

## 配置

1. 打开 `supergoal.app`。
2. 点击右上角菜单栏里的键盘图标。
3. 打开 `Settings...`。
4. 配置：
   - API key
   - Base URL
   - model
   - 快捷键
5. 如需个性化，打开 `Custom Compiler Prompt...`，写入你自己的 prompt 优化提示词。

Base URL 示例：

```text
https://api.openai.com
https://api.openai.com/v1
https://api.openai.com/v1/responses
https://your-gateway.example.com/v1
https://your-gateway.example.com/v1/chat/completions
https://your-gateway.example.com/v1/responses
```

如果 Base URL 是根地址或 `/v1`，SuperGoal 会优先尝试 OpenAI-compatible chat completions，再回退到 responses。

## 自定义 Prompt

内置 prompt 是给 Codex goal mode 设计的，默认会使用：

```text
$supergoal
$superdev
```

如果 `Custom Compiler Prompt...` 留空，就使用内置逻辑。

如果你填写了自定义 prompt，SuperGoal 会优先使用你的配置。这个适合有自己开发习惯的人，比如更偏好某种验收标准、测试方式、代码风格或任务结构。

## 安装两个 Skill

克隆仓库后，把两个 skill 复制到 Codex skills 目录：

```bash
mkdir -p ~/.codex/skills
cp -R skills/supergoal ~/.codex/skills/
cp -R skills/superdev ~/.codex/skills/
```

之后就可以在 Codex 里这样引用：

```text
Use $supergoal and $superdev.
```

## 从源码构建

要求：

- macOS
- Xcode Command Line Tools
- Swift compiler

构建：

```bash
cd plugin/supergoal.app-src
./build.sh
```

本地安装：

```bash
./install.sh
open /Applications/supergoal.app
```

生成 release 用的磁盘镜像：

```bash
./package_dmg.sh
```

生成结果在：

```text
plugin/supergoal.app-src/release/
```

## 安全说明

- 仓库里不包含任何 API key。
- API key 存在本机 macOS keychain。
- Base URL、model、快捷键和自定义 prompt 存在本机。
- 选中的文本只会发送到你配置的 Base URL。
- 不要把真实 API key 或私有项目内容提交到仓库。

## License

MIT. See [LICENSE](./LICENSE).
