# design 文档整理变更记录

## 2026-04-08

### 新增文件
- `design/UIUX/中部三摘要修改方案 v1.md`：明确主界面中部三摘要区的职责、信息边界、状态分层与显示原则，将其从静态说明卡调整为动态提醒卡。
- `design/UIUX/中部三摘要文案模板 v1.md`：为关键关系、势力/派系、家族/士族三摘要提供统一文风、句式模板、状态样本与禁用写法，便于后续数据驱动生成与 Godot 原型联调。
- `design/总纲/Phase 3 仕途、势力与可解释政治 详细规划 v1.md`：Phase 3 正式 GDD 章节稿，定义单角色视角下的仕途推进、势力信息可见性、推荐 / 反对链、派系支持、任命解释、官职权限变化与月末政治结算范围。
- `design/数据/Phase 3 政治与任命数据字段设计 v1.md`：Phase 3 配套字段设计稿，冻结推荐规则、反对规则、派系块、政治支持快照、候选评估、原因行与月末政治结果字段。
- `design/原型与实现/Phase 3 Godot 实现映射表 v1.md`：将 Phase 3 的政治设计内容映射到 Godot 模块、Resource、运行时状态、UI 面板、月度时序与验收点。
- `design/数据/Phase 3 最小数据录入清单 v1.md`：明确 Phase 3 为跑通最小 explainable-politics 闭环，哪些政治规则、世界样本、竞争样本与成功 / 失败月报样本必须先录。
- `design/剧情与样本/Phase 3 首批政治样本名单 v1.md`：将 Phase 3 首批推荐规则、反对规则、派系块、关键人物、竞争样本、任务来源样本与成功 / 失败月报样本压缩成可直接录入的名单，并冻结荀彧—曹操势力内部政治圈的最小样本范围。
  - `design/数据/Phase 3 ID 与样本命名冻结表 v1.md`：冻结 Phase 3 首批样本 ID 命名、交叉引用与支撑占位 ID，解决命名漂移、ID 不统一与样本条目未冻结的问题，供 Godot 原型数据录入直接使用。

### 索引更新
- 更新 `design/Agent.md`：补充中部三摘要修改方案与文案模板的说明，并将其纳入 UI 检索路径。
- 更新 `design/machine_index.json`：新增两份 UIUX 文档索引，并补充 `hud_summary_cards` 检索路线。
- 更新 `design/Agent.md`：补充 Phase 3 最小数据录入清单与 `场景 I：Phase 3 数据录入` 检索路径。
- 更新 `design/machine_index.json`：新增 Phase 3 最小数据录入清单索引，并补充 `scenario_data_entry`、`phase_3_explainable_politics`、`phase_3_data_entry` 检索路线。
- 更新 `design/Agent.md`：补充 `design/剧情与样本/Phase 3 首批政治样本名单 v1.md` 的说明，并将其纳入 `场景 I：Phase 3 数据录入` 路径。
- 更新 `design/machine_index.json`：新增 `design/剧情与样本/Phase 3 首批政治样本名单 v1.md` 索引，并将其纳入 `scenario_data_entry` 与 `phase_3_data_entry` 路由。

## 2026-04-07

### 新增文件
- `design/总纲/官职与任务原型部署 Phase 2.1 v1.md`：Phase 2.1 正式 GDD 章节稿，定义荀彧开局、月初领任务、月末结算与功绩驱动升官闭环。
- `design/数据/官职与任务原型部署数据字段设计 v1.md`：Phase 2.1 配套字段设计稿，定义官职、任务、任务池、升官规则与月末结算数据结构。
- `design/原型与实现/Phase 2.1 Godot 实现映射表 v1.md`：将 Phase 2.1 的设计内容映射到 Godot 模块、Resource、运行时状态、UI 面板与验收点。
- `design/数据/Phase 2.1 最小数据录入清单 v1.md`：明确 Phase 2.1 的最小录入对象、最小条数、录入顺序与验收方式。

### 索引更新
- 更新 `design/Agent.md`：补充 Phase 2.1 文档说明与推荐检索路径。
- 更新 `design/machine_index.json`：新增两份文档索引并增加 `phase_2_1_career_prototype` 检索路线。

## 2026-04-04

### 索引与规范补充
- 将 `design/文档创建规范.md` 改为 `design/AI_WORKFLOW.md`，改写为面向开发 AI 的超短操作清单。
- 更新 `design/Agent.md`：将规范文件入口替换为 `AI_WORKFLOW.md`。
- 更新 `design/machine_index.json`：将规范索引替换为 `AI_WORKFLOW.md`。

### 目录整理
- 按用途重组 `design/` 目录，拆分为：
  - `总纲/`
  - `系统设计/`
  - `数值/`
  - `数据/`
  - `原型与实现/`
  - `UIUX/`
  - `剧情与样本/`

### 文件移动记录
1. `design/GDD 框架 v1.md` -> `design/总纲/GDD 框架 v1.md`
2. `design/项目总设计方案 v1.md` -> `design/总纲/项目总设计方案 v1.md`
3. `design/核心系统详细设计 v1.md` -> `design/系统设计/核心系统详细设计 v1.md`
4. `design/士族门阀系统专项设计 v2.md` -> `design/系统设计/士族门阀系统专项设计 v2.md`
5. `design/主循环与数值骨架 v1.md` -> `design/数值/主循环与数值骨架 v1.md`
6. `design/精力-压力-AP 三资源设计方案 v1.md` -> `design/数值/精力-压力-AP 三资源设计方案 v1.md`
7. `design/Godot 数据结构草案 v1.md` -> `design/数据/Godot 数据结构草案 v1.md`
8. `design/Godot 原型开发拆解 v1.md` -> `design/原型与实现/Godot 原型开发拆解 v1.md`
9. `design/Godot 系统模块拆分清单 v1.md` -> `design/原型与实现/Godot 系统模块拆分清单 v1.md`
10. `design/原型任务拆解清单 v1.md` -> `design/原型与实现/原型任务拆解清单 v1.md`
11. `design/原型 UI 流程图 v1.md` -> `design/UIUX/原型 UI 流程图 v1.md`
12. `design/190 剧本原型人物-势力样本表 v1.md` -> `design/剧情与样本/190 剧本原型人物-势力样本表 v1.md`
13. `design/190 剧本原型事件样本表 v1.md` -> `design/剧情与样本/190 剧本原型事件样本表 v1.md`

### 新增文件
- `design/Agent.md`：design 文档人工 / AI 检索入口
- `design/CHANGELOG.md`：design 文档整理变更记录
- `design/machine_index.json`：design 文档机器可读索引
- `design/AI_WORKFLOW.md`：design 文档创建、修改、移动时的 AI 操作清单

### 说明
- 本次整理未修改任何设计文档正文，仅进行了目录归类与索引文件新增。
