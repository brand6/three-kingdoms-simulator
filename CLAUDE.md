<!-- GSD:project-start source:PROJECT.md -->

## Project (简化)

三国模拟器（原型）：单角色历史模拟，目标在 15–30 分钟内验证“个人命运嵌入势力政治”的核心体验。

关键约束：

- 技术：Godot 原型、数据驱动（Resource 优先）。
- 范围：样本规模可控（首版 3–5 城、2–3 势力、30–50 人）。
- 视角：坚持单角色、不做传统全局 4X 君主玩法。
- UX：关键状态常驻、关键行动 ≤3 次点击；月末/事件需解释因果。
- 交付：先做最小可玩闭环，再扩展系统与内容。

## Technology Stack（精简）

要点：优先快速可验证的 Godot 原型、Typed GDScript 为主、Resource 作为静态数据载体。UI 全面使用 Control/Container/Theme；存档用 JSON（user://）。仅在工具/导表需要时引入 .NET/C#。

核心选择（摘要）：

- Engine: Godot 4.6.2 (stable)
- Scripting: Typed GDScript（主逻辑）；C# 仅限工具链
- Data: Custom Resource (.tres) 作定义；表格→导入→Resource 的管线
- Save: JSON 快速可读方案（schema_version）
- Optional: Godot .NET（工具）、Inspector Plugin（编辑优化）、第三方对话工具为可选项

## Prescriptive Decisions

### 1. 主逻辑：**用 Typed GDScript，不用 C# 起步**

- 你的原型核心是规则系统、UI 面板、数据对象、事件联动，不是数值密集型实时战斗。
- GDScript 与 Godot 的 Resource、Inspector、Autoload、信号、工具脚本结合最顺。
- 使用godot-remote-executor技能来操作godot,所需的token在broker-server-token.txt文件内，调用技能时带上token
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

| Do not use                                             | Why not                                                                            |
| ------------------------------------------------------ | ---------------------------------------------------------------------------------- |
| **C# as default gameplay language**              | 对当前原型没有决定性收益，却会增加 .NET 工具链复杂度。                             |
| **SQLite / 外部数据库做主游戏数据层**            | 样本规模太小，不值得引入数据库迁移、查询层和额外调试成本。                         |
| **运行时直接读取项目内 CSV/JSON 作为正式数据层** | 官方更推荐项目资源走 ResourceLoader / Resource；直接文件读取在导出后也更容易踩坑。 |
| **ResourceSaver 直接保存整局运行对象树当主存档** | 会把定义数据和动态状态耦死；调试和版本迁移都更差。                                 |
| **过早做自定义大地图/复杂场景切换架构**          | 当前目标是验证 UI 驱动闭环，不是世界表现。                                         |
| **P0 引入大型对话/剧情插件**                     | 当前真正风险不在文本编辑，而在核心循环是否成立。                                   |

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

## Sources（保留引用简表）

- Godot 文档与下载（4.6.2）
- 官方 API 文档（GDScript、Resource、Autoload、UI、FileAccess 等）

## Conventions

待补充（按开发过程中逐步形成）。

## Architecture

参照代码库现有模式与本文件中的核心决策进行实现。

## GSD Workflow Enforcement (简要)

修改仓库文件前请使用 GSD 命令（例如 /gsd:quick）以保持规划与变更记录一致。若用户明确要求可直接修改。

## Developer Profile

未配置。运行 `/gsd:profile-user` 以生成开发者配置（自动管理）。

<!-- GSD:profile-end -->
