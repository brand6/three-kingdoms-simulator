<!-- GSD:project-start source:PROJECT.md -->
## Project

**三国模拟器**

一款基于 190 年群雄割据剧本、以单角色扮演为核心的三国历史模拟单机游戏。玩家以具体历史人物的身份行动，在旬制时间循环中通过个人成长、人物关系、仕途经营、士族门阀网络、婚姻家族关系与势力派系斗争参与并改写三国历史。当前目标是先完成可验证核心体验的 Godot 原型，而不是一次做成完整大作。

**Core Value:** 让玩家在 15 到 30 分钟内明确感受到“个人命运嵌入势力政治”的单角色历史模拟体验。

### Constraints

- **Tech stack**: 使用 Godot 构建单机原型，并以数据驱动方式组织角色、势力、城市、关系、行动与事件数据 — 这是当前设计文档反复强调的落地方向。
- **Scope**: 先做 3 到 5 座城市、2 到 3 个势力、30 到 50 名人物、5 到 8 个士族的局部样本 — 需要在可控规模内验证玩法。
- **Product**: 必须坚持单角色视角，君主玩法也不能退化为传统全局 4X/SLG — 这是项目最核心的设计边界。
- **Architecture**: 统一底层规则优先于身份深度差异化 — 否则全身份设计会导致系统爆炸与实现失控。
- **UX**: 关键状态常驻显示，关键行动不超过 3 次点击，月末与事件反馈必须解释因果 — 原型 UI 的价值在于快速验证而不是美术完成度。
- **Delivery**: 优先做最小可玩闭环，再扩展士族、派系、婚姻、战争与历史事件 — 项目目标是验证核心体验，不是一次性完成全部设计野心。
<!-- GSD:project-end -->

<!-- GSD:stack-start source:research/STACK.md -->
## Technology Stack

## Executive Recommendation
- **原型速度快**：不先背 .NET / 第三方数据库 / 复杂插件成本。
- **数据驱动强**：Godot 官方明确把 `Resource` 定位为数据容器，且比直接用 JSON/CSV 更适合项目内游戏数据。
- **UI 适配好**：Godot 的 `Control` / `Container` / `Theme` 就是为面板式、信息密集型界面准备的。
- **后续可扩**：后面要补编辑器插件、导表、更多剧本、更多事件时，不需要推倒重来。
## Recommended Stack
### Core Runtime Stack
| Technology | Version | Purpose | Why | Confidence |
|------------|---------|---------|-----|------------|
| Godot Engine | **4.6.2 stable** | 引擎、编辑器、导出 | 这是当前官方稳定版；原型期优先用稳定版，不追 4.7 dev。 | HIGH |
| GDScript | Godot 4.6 内置 | 主游戏逻辑 | 对 Godot 原型最省摩擦；和 Inspector、Resource、Autoload、信号、工具脚本结合最好。**本项目首选，不用 C# 做主逻辑。** | HIGH |
| Typed GDScript | Godot 4.6 内置 | 系统脚本类型约束 | 原型仍需可维护；静态类型能降低数据字段、系统接口、UI 绑定错误。 | HIGH |
| Control + Container | Godot 4.6 内置 | 全部主 UI | 你的原型是**UI-heavy**，不是地图表现优先。Godot 官方 UI 系统就是 `Control` 系列。 | HIGH |
| Theme | Godot 4.6 内置 | 统一 UI 风格 | 用一个项目级 Theme 管理字体、字号、间距、按钮样式，避免后期 UI 全局返工。 | HIGH |
| Autoload Singletons | Godot 4.6 内置 | GameRoot / TimeManager / DataRepository / EventBus | Godot 官方推荐用 Autoload 保存跨场景持久信息。非常适合你的“单主场景 + 多管理器”原型结构。 | HIGH |
### Data Model and Authoring Stack
| Technology | Version | Purpose | Why | Confidence |
|------------|---------|---------|-----|------------|
| Custom Resource (`.tres`) | Godot 4.6 内置 | 静态定义数据：人物、城市、势力、士族、家族、官职、行动、事件 | 官方文档明确说明：**项目内游戏数据优先用 Resource，而不是直接用 JSON/CSV**。它可序列化、可嵌套、可在 Inspector 直接编辑、适合版本控制。 | HIGH |
| ResourceLoader / ResourceSaver | Godot 4.6 内置 | 读取/保存项目资源 | 适合定义数据与编辑器侧生成结果；不要把它当运行时存档主方案。 | HIGH |
| Editor script / EditorPlugin | Godot 4.6 内置 | 编辑器导表、批量生成资源 | 当历史人物/城市/事件量上来后，手填 `.tres` 会变慢；Godot 官方支持 EditorPlugin / InspectorPlugin 扩展编辑器。 | HIGH |
| Spreadsheet → CSV/JSON → Resource 导入 | 外部工具无强依赖 | 内容源文件管线 | **表格做作者输入，Resource 做游戏消费格式。** 这样策划可批量维护，运行时仍吃 Godot 原生数据。 | MEDIUM |
### Save / Load Stack
| Technology | Version | Purpose | Why | Confidence |
|------------|---------|---------|-----|------------|
| FileAccess | Godot 4.6 内置 | 存档文件读写 | 官方标准文件 I/O 入口，支持 `user://`。 | HIGH |
| JSON + `JSON.stringify/parse` | Godot 4.6 内置 | **原型期主存档格式** | 你的样本规模小（3~5 城、30~50 人），JSON 最利于调试、回放、比对和修坏档。原型期优先可读性。 | HIGH |
| DirAccess | Godot 4.6 内置 | 存档目录 / 多槽位管理 | 用于建立 `user://saves/slot_x/` 目录结构。 | HIGH |
| Binary serialization (`store_var/get_var`) | Godot 4.6 内置 | 后续优化方案 | 官方说明其更适合复杂/更大状态；**但 4.6 文档该页标注 WIP**，所以只建议作为后续优化，不作为首版主方案。 | MEDIUM |
### Optional Tooling
| Tool | Version | Purpose | When to Use | Confidence |
|------|---------|---------|-------------|------------|
| Godot .NET build | 4.6.2 + **.NET 8+** | 仅用于少量工具脚本或团队已有 C# 资产时 | **不要作为主逻辑默认栈。** 只在必须复用 C# 库、写复杂导表工具时启用。 | HIGH |
| Inspector plugins | Godot 4.6 内置 | 自定义 Resource 编辑面板 | 当 `CharacterData` / `EventData` 字段多到 Inspector 难用时再做。不是 P0。 | HIGH |
| Dialogue Manager 3 | 3.10.2（Asset Library） | 可选对话/分支文本工具 | 只有当事件文本编辑开始成为瓶颈时再引入。当前更应该先做自己的 `EventData`。 | LOW |
## Prescriptive Decisions
### 1. 主逻辑：**用 Typed GDScript，不用 C# 起步**
- 你的原型核心是规则系统、UI 面板、数据对象、事件联动，不是数值密集型实时战斗。
- GDScript 与 Godot 的 Resource、Inspector、Autoload、信号、工具脚本结合最顺。
- C# 会额外引入 .NET 构建链和编辑器版本区分；这对原型速度是负担，不是收益。
- `GameRoot`、`TimeManager`、`CharacterSystem`、`RelationSystem`、`CareerSystem`、`ActionResolver` 全部用 **typed GDScript**。
- 若未来要写复杂导表器，再局部引入 C#，不要反过来。
### 2. UI：**全部基于 Control，不先做地图/Node2D 驱动 UI**
- 文档目标已经明确：先验证“面板驱动的单角色主循环”。
- Godot 官方 UI 体系就是 `Control` + `Container` + `Theme`。
- 你需要的是：稳定布局、分页、列表、详情面板、弹窗、焦点、滚动，不是炫技场景表现。
- `MainScene` 下以 `Control` 为 UI 根。
- `HUD / CharacterPanel / CityPanel / RelationPanel / FactionPanel / EventDialog` 都用 Control 树。
- 所有面板共享一个项目级 `Theme`。
### 3. 静态数据：**游戏定义数据用 Resource，不用 SQLite 当主数据库**
- 官方文档对 `Resource` 的定位非常明确：它是数据容器，可序列化、可嵌套、Inspector 友好。
- 你的数据天然是“带 ID 的定义对象”：人物、势力、城市、官职、行动、事件。
- 原型规模下，SQLite 只会增加查询层、迁移层、调试复杂度。
- `CharacterData`, `FactionData`, `CityData`, `ClanData`, `FamilyData`, `ActionData`, `OfficeData`, `EventData` 全部建成自定义 Resource 类。
- 运行时通过 ID 关联，不在 Resource 里深拷贝对象图。
- 把 `.tres` 视为“游戏消费格式”。
### 4. 内容管线：**表格是来源，Resource 是落地**
- 历史模拟最终一定有大量内容录入与平衡调整。
- 直接手改 `.tres` 适合早期样本，不适合中期扩量。
- 但运行时直接吃 CSV/JSON 又会失去 Resource 的 Inspector 优势和 Godot 原生加载能力。
- 策划源文件：Spreadsheet / CSV / JSON。
- 编辑器导入脚本：把源文件转换成 `.tres`。
- 游戏运行时：只读 `.tres` / `.res`，不直接读策划源表。
### 5. 存档：**动态状态存 JSON，不把定义数据和存档混在一起**
- 官方存档文档明确：简单状态可用 JSON，复杂状态再考虑二进制。
- 你现在最需要的是**可读、可 diff、可修复、可做版本迁移**。
- 你的设计文档已经强调“静态定义”和“运行时状态”分离，这正适合 JSON 快照。
- 静态定义：`res://data/.../*.tres`
- 运行时存档：`user://saves/slot_x/save.json`
- 存档内容只保存：ID、数值、关系变化、时间进度、事件标记、任命状态等动态内容。
- 每个存档必须带 `schema_version`。
## Recommended Minimal Package Set
### Engine / Runtime
- Godot **4.6.2 stable**
- 标准版编辑器（默认）
- 导出模板（与 4.6.2 匹配）
### If and only if you need C#
- Godot **4.6.2 .NET**
- **.NET SDK 8+**
### No mandatory third-party gameplay addons in P0
- 首版**不要求**对话插件、状态机插件、数据库插件、ECS 插件。
- 先用 Godot 原生能力把“旬循环 + 行动 + 关系 + 功绩/任命 + 门阀修正”跑通。
## Suggested Project Layout
## What NOT to Use
| Do not use | Why not |
|------------|---------|
| **C# as default gameplay language** | 对当前原型没有决定性收益，却会增加 .NET 工具链复杂度。 |
| **SQLite / 外部数据库做主游戏数据层** | 样本规模太小，不值得引入数据库迁移、查询层和额外调试成本。 |
| **运行时直接读取项目内 CSV/JSON 作为正式数据层** | 官方更推荐项目资源走 ResourceLoader / Resource；直接文件读取在导出后也更容易踩坑。 |
| **ResourceSaver 直接保存整局运行对象树当主存档** | 会把定义数据和动态状态耦死；调试和版本迁移都更差。 |
| **过早做自定义大地图/复杂场景切换架构** | 当前目标是验证 UI 驱动闭环，不是世界表现。 |
| **P0 引入大型对话/剧情插件** | 当前真正风险不在文本编辑，而在核心循环是否成立。 |
## Confidence Notes
### HIGH confidence
- Godot 当前稳定版为 **4.6.2**。
- Godot 官方 UI 体系应以 `Control` / `Container` / `Theme` 为主。
- Godot 官方推荐使用 `Resource` 作为项目内数据容器。
- Autoload 适合跨场景全局管理器。
- `FileAccess` / `DirAccess` / `user://` 是标准存档路径方案。
- C# 需要使用 .NET 版 Godot；Godot 4.4 起最低为 **.NET 8**。
### MEDIUM confidence
- “Spreadsheet/CSV 作为作者源、Resource 作为运行时格式”是强工程建议，虽然不是单一官方固定工作流。
- 原型期优先 JSON 而不是二进制，是基于项目规模和调试成本的判断。
### LOW confidence
- `Dialogue Manager 3` 作为可选插件，只基于 Asset Library 可见性做弱推荐；不是核心栈依赖。
## Final Stack Choice for This Project
## Sources
- Godot 官方下载页（4.6.2 stable / .NET 版，2026-04-01）  
- Godot 官方文档：GDScript  
- Godot 官方文档：Resources  
- Godot 官方文档：Singletons (Autoload)  
- Godot 官方文档：User interface (UI)  
- Godot 官方文档：Control  
- Godot 官方文档：Theme  
- Godot 官方文档：Saving games  
- Godot 官方文档：FileAccess  
- Godot 官方文档：DirAccess  
- Godot 官方文档：ResourceLoader  
- Godot 官方文档：ResourceSaver  
- Godot 官方文档：Inspector plugins  
- Godot 官方文档：C#/.NET  
- Godot 官方公告：Godot C# packages move to .NET 8（2025-01-02）  
- Godot 官方文档：Binary serialization API（4.6 页标注 WIP）  
- Godot Asset Library：Dialogue Manager 3  
<!-- GSD:stack-end -->

<!-- GSD:conventions-start source:CONVENTIONS.md -->
## Conventions

Conventions not yet established. Will populate as patterns emerge during development.
<!-- GSD:conventions-end -->

<!-- GSD:architecture-start source:ARCHITECTURE.md -->
## Architecture

Architecture not yet mapped. Follow existing patterns found in the codebase.
<!-- GSD:architecture-end -->

<!-- GSD:workflow-start source:GSD defaults -->
## GSD Workflow Enforcement

Before using Edit, Write, or other file-changing tools, start work through a GSD command so planning artifacts and execution context stay in sync.

Use these entry points:
- `/gsd:quick` for small fixes, doc updates, and ad-hoc tasks
- `/gsd:debug` for investigation and bug fixing
- `/gsd:execute-phase` for planned phase work

Do not make direct repo edits outside a GSD workflow unless the user explicitly asks to bypass it.
<!-- GSD:workflow-end -->



<!-- GSD:profile-start -->
## Developer Profile

> Profile not yet configured. Run `/gsd:profile-user` to generate your developer profile.
> This section is managed by `generate-claude-profile` -- do not edit manually.
<!-- GSD:profile-end -->
