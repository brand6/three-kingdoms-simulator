# Phase 1: 190样本数据骨架与单角色入口 - Context

**Gathered:** 2026-04-05
**Status:** Ready for planning

<domain>
## Phase Boundary

本阶段只交付 190 年局部样本的最小可启动骨架：项目基础结构、默认主角入口、基础 HUD 信息、主干数据对象与加载流程，以及单角色统一底层规则的第一版实现边界。它负责证明“项目能启动、数据能装载、主 HUD 能展示、后续系统有稳定地基”，不负责完整行动闭环、关系系统、任命反馈或多身份开局体验。

</domain>

<decisions>
## Implementation Decisions

### 样本范围与入口流程
- **D-01:** Phase 1 使用**最小烟雾样本**，目标是优先跑通启动、装载、查询与 HUD 展示，而不是一开始做代表性高密度内容样本。
- **D-02:** 启动后**直接进入默认主角**，自动加载默认 190 烟雾样本；本阶段不实现剧本选择或人物选择 UI。
- **D-03:** 虽然首批内容是最小烟雾样本，但数据结构与仓库接口必须按后续可扩展到多人物、多城市、多势力来设计，不能写死成单实例 demo。

### HUD 信息层级
- **D-04:** Phase 1 的主 HUD 采用**原型总览型**而不是纯调试面板路线。
- **D-05:** HUD 直接显示当前时间、人物、身份、势力、官职、AP、精力、压力、名望、功绩这些核心状态，让它从 Phase 1 起就成为后续原型界面的真实基础。
- **D-06:** 对后续页面入口采取**可见但禁用**策略：先把未来入口位置稳定下来，但在 Phase 1 标注为未开放/禁用，不跳占位页。

### 身份与验证边界
- **D-07:** Phase 1 **只做默认身份路径**，不把多身份开局、切换验证或对外可见的多身份入口作为本阶段目标。
- **D-08:** “不同身份共用同一底层规则”在 Phase 1 中只作为架构约束保留给数据模型与入口扩展点，不要求本阶段对玩家直接展示多身份验证流程。

### 数据来源与加载流程
- **D-09:** Excel 是策划数据的正式源头，不使用“先手写临时 JSON、后续再迁移”的过渡路线。
- **D-10:** Phase 1 **直接接入 Luban** 作为正式数据管线的一部分，让 DataRepository 从一开始就建立在正式数据生产流程上。
- **D-11:** Godot 运行时在 Phase 1 **优先读取 Luban 导出的 JSON**，以保证早期调试、查错与对比修改成本最低，不采用二进制优先路线。
- **D-12:** Phase 1 的 Luban schema 采取**主干优先**策略：先覆盖 `Scenario / Character / Faction / City` 四类主干对象；`Clan / Family / Action / Event` 在本阶段仅保留未来扩展位，不要求完整落地。

### 场景骨架
- **D-13:** Phase 1 使用**单 MainScene 骨架**承载 UI root、管理器挂点和默认主角入口，不在本阶段过早拆出复杂子场景体系。
- **D-14:** 主场景骨架应服务于“先稳住入口与数据展示”的目标；更细的场景/组件拆分留给后续 phase 在不破坏入口结构的前提下逐步演进。

### the agent's Discretion
- Luban 的具体命令行包装方式、目录命名、生成脚本放置位置。
- JSON 导出后的 Godot 侧解析层具体组织方式（仓库、DTO、缓存装配细节）。
- HUD 中禁用入口的视觉呈现样式（灰掉、锁图标、说明文案等）。
- MainScene 内部节点命名与 manager placeholder 的精确分层。

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Project and phase scope
- `.planning/PROJECT.md` — 项目核心价值、单角色边界、原型范围与整体约束。
- `.planning/REQUIREMENTS.md` §Core Loop, §Data Foundation, §Character State — Phase 1 对应的可验证要求来源，尤其是 CORE-01/02、DATA-01..04、CHAR-01/02/04。
- `.planning/ROADMAP.md` §Phase 1: 190样本数据骨架与单角色入口 — 本阶段目标、成功标准与原始 canonical refs。
- `.planning/STATE.md` §Accumulated Context — 当前阶段前置判断：先冻结局部样本、Definition/Runtime 分离与统一 ID。

### Architecture and data model
- `design/总纲/GDD 框架 v1.md` §§8-12 — 时间结构、样本规模、Godot 架构指引与原型优先数据对象。
- `design/原型与实现/Godot 原型开发拆解 v1.md` §§4-7 — 单主场景、管理器、UI 面板、数据驱动与阶段开发顺序。
- `design/数据/Godot 数据结构草案 v1.md` §§2-16 — `ScenarioData / CharacterData / FactionData / CityData` 主干对象、ID 规则、静态定义与运行时状态分离原则。

### Task decomposition and HUD expectations
- `design/原型与实现/原型任务拆解清单 v1.md` T01-T05 — 本阶段直接参考的任务拆解来源：项目基础骨架、数据仓库与剧本装载、时间推进、人物状态、主 HUD 原型。
- `design/UIUX/原型 UI 流程图 v1.md` §§4-5 — 主 HUD 必显信息、核心入口与原型阶段信息架构原则。

### Data pipeline
- `https://github.com/focus-creative-games/luban` — 用户指定的数据管理方案；用于确认 Excel 作为数据源、Luban 生成 Godot 相关代码/多种导出格式、并支持 JSON 导出路线。

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- 当前仓库中**没有现成 Godot 项目代码**：未发现 `project.godot`、`.gd`、`.tscn`、`.tres` 等运行时代码/资源文件。
- 因此本阶段不会复用现有运行时资产；Phase 1 自身会建立后续 phase 复用的第一批资产与模式。

### Established Patterns
- 目前代码层尚未形成 Godot 运行时模式；已锁定的“既有模式”来自项目文档而非实现代码。
- 已明确要遵守的模式：**单主场景 + 数据管理器 + UI 面板 + 单角色入口 + Definition/Runtime 分离 + Excel→Luban→JSON 数据管线**。

### Integration Points
- Phase 1 的新代码将从零建立 Godot 项目入口，后续 phases 将在此基础上接入行动、关系、仕途、士族、事件等系统。
- DataRepository、MainScene、MainHUD 与默认主角启动流程将成为 Phase 2 及以后所有系统的主要接入点。

</code_context>

<specifics>
## Specific Ideas

- 用户明确要求：**数据希望用 Excel 管理，并可使用 Luban 管理这条数据管线。**
- 用户明确指出：**Phase 1 要参考 `design/原型与实现/原型任务拆解清单 v1.md`。**
- 本阶段整体取向是：**正式管线先立住，但玩法范围尽量收窄，只证明入口、装载、展示和骨架成立。**

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 01-190*
*Context gathered: 2026-04-05*
