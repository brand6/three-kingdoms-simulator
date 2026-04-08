# Phase 3: 仕途、势力与可解释政治 - Context

**Gathered:** 2026-04-08
**Status:** Ready for planning

<domain>
## Phase Boundary

本阶段在 Phase 2.1 已成立的“月初领 1 个主任务 → 月内用既有行动推进 → 月末结算与任命反馈”闭环上，补上**可解释政治层**：月初任务开始体现政治来源；月内关系、功绩与任务表现写入推荐、反对与派系态度；月末任命改为可解释的资格 / 空缺 / 推荐 / 阻力 / 竞争判定；官职变化开始真实影响可见信息、任务来源与可执行行动。它负责证明“个人仕途嵌在势力政治中”，不负责君主全局人事控制台、复杂派系议程、全国政治地图、家族婚姻深度联动或完整官职动作树。

</domain>

<decisions>
## Implementation Decisions

### 任命竞争与失败解释
- **D-01:** Phase 3 的任命解释采用**五层原因树**：资格层、制度/空缺层、推荐层、阻力层、竞争层。
- **D-02:** 玩家界面只展示**顶层结论 + 2~3 条命中的关键原因行 + 1 条下月建议**；不直接展开完整后台评分表。
- **D-03:** 当同月存在多个失败原因时，**顶层失败标签按最早阻断层判定**；后续层级只进入原因行，不抢月报主标题。

### 任务来源信息密度
- **D-04:** 月初任务卡采用**中密度首屏**，默认显示：任务名称、来源类型、请求方/发布者、关联人物或派系、预期收益、潜在政治风险。
- **D-05:** 任务卡中的政治收益 / 风险采用**标签词组**表达（如 `上级支持+`、`旧吏阻力↑`、`主战派保留`），而不是长叙事短句或直接数值。
- **D-06:** 任务卡的政治信息目标是让玩家能快速比较“这件事是谁递来的、可能帮到谁、会得罪谁”，但不把月初选任务界面做成后台数据表。

### 势力与人物政治摘要
- **D-07:** `MainHUD` 常驻政治摘要只保留 3 项：**主要推荐人、主要阻力、当前机会/资格短板**。
- **D-08:** 更完整的**派系态度、职位机会、势力结构与玩家位置**放到人物/势力详情面板，不在主 HUD 一次铺满。
- **D-09:** 势力政治总览页第一页优先展示**派系块 + 玩家位置**；主君与核心高层是背景层，核心是让玩家读懂“我在局中处于什么政治位置”。

### 官职后果与行动权限
- **D-10:** Phase 3 首批只做**少量代表性官职专属动作**，不按全部官职完整铺开动作树；目标是先验证“官职真的改变玩法”。
- **D-11:** 官职变化的首批正反馈优先体现在两类后果：**按官职历史定位解锁不同任务类型**，以及**按官职权限解锁 0–2 个代表性额外行动**。
- **D-12:** 行动配置表新增**`官职限定`**字段；留空表示全部官职可用，填写后表示仅指定官职/官职组可用。
- **D-13:** **覆盖整个行动菜单的显示规则**：玩家**没有权限**执行的动作不显示；玩家**有权限但当前旬因临时原因无法执行**的动作继续显示为禁用态，并给出明确原因。
- **D-14:** `D-13` 明确**取代 Phase 2 中“权限不足动作也继续显示禁用态”**的旧口径；从 Phase 3 起，禁用态只用于 AP 不足、受伤、生病、战争中、地点不符、目标缺失等临时阻断。

### the agent's Discretion
- 各任务卡的标签词组数量、排序与视觉样式，只要维持“可扫读、不数值化”原则即可。
- 五层原因树的具体原因行模板与字段命名，只要能稳定映射到资格 / 空缺 / 推荐 / 阻力 / 竞争五层即可。
- `MainHUD` 三项政治摘要具体映射到现有哪几块摘要卡位，以及 `CharacterProfilePanel` / 未来 `FactionPanel` 的具体布局。
- 各关键官职对应的 0–2 个代表性专属动作的精确命名与触发条件，只要符合历史职能定位且不膨胀成完整动作树即可。

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Project and scope anchors
- `.planning/PROJECT.md` — 项目核心价值、单角色边界、原型规模约束与 Godot 落地原则。
- `.planning/REQUIREMENTS.md` §Relationships, §Career, §Factions, §Politics, §UI Feedback — Phase 3 对应的 `RELA-04`、`CARE-01..05`、`FACT-01..03`、`POLI-01..03` 与界面解释要求来源。
- `.planning/ROADMAP.md` §Phase 3: 仕途、势力与可解释政治 — 本阶段目标、成功标准、计划拆分与原始 canonical refs。
- `.planning/STATE.md` §Accumulated Context, §Blockers/Concerns — 前序 phase 已锁定的 HUD/面板模式，以及“任命、派系支持与解释层权重仍需校准”的项目提醒。

### Prior phase decisions and carry-forward constraints
- `.planning/phases/01-190/01-CONTEXT.md` — 单角色入口、数据管线、Definition/Runtime 分离与 MainScene 骨架的前置约束。
- `.planning/phases/02-旬内行动—关系闭环/02-CONTEXT.md` — HUD + 面板主循环、行动菜单、角色选择器与结果反馈的既有实现边界；其中动作显示规则被本次 Phase 3 决策部分覆盖。
- `.planning/phases/02.1-/02.1-CONTEXT.md` — 月初领 1 个主任务、月内推进、月末先月报后任命反馈、简化任命制与荀彧默认开局的直接前置约束。

### Phase 3 design and implementation specs
- `design/总纲/项目总设计方案 v1.md` §§5.5-5.7 — 仕途、势力信息可见性与可解释政治在总设计中的目标定位。
- `design/总纲/官职与任务原型部署 Phase 2.1 v1.md` §§12-16 — Phase 2.1 月度闭环、任命反馈与范围保护，说明 Phase 3 在何处继续扩展而不是重做。
- `design/总纲/Phase 3 仕途、势力与可解释政治 详细规划 v1.md` — Phase 3 的正式 GDD 章节稿；定义任务来源扩展、推荐/反对链、派系支持、任命竞争、官职权限变化与月末政治结算。
- `design/系统设计/核心系统详细设计 v1.md` §§3, 6-7 — 关系、仕途推进与势力政治相关的系统级约束来源。
- `design/数据/官职与任务原型部署数据字段设计 v1.md` §16 — Phase 2.1 字段合同与向 Phase 3 扩展的衔接点。
- `design/数据/Phase 3 政治与任命数据字段设计 v1.md` — `RecommendationRuleData`、`OppositionRuleData`、`FactionBlocData`、`PoliticalSupportSnapshot`、`AppointmentCandidateEvaluation`、`PoliticalReasonLine` 与扩展后的任务/官职/月报字段合同。
- `design/数据/Phase 3 最小数据录入清单 v1.md` — Phase 3 为跑通最小 explainable-politics 闭环所需的对象、条数、录入顺序与验收点。
- `design/数据/Phase 3 ID 与样本命名冻结表 v1.md` — Phase 3 首批样本 ID、命名冻结与交叉引用关系表。
- `design/剧情与样本/Phase 3 首批政治样本名单 v1.md` — 荀彧—曹操内部政治圈的首批推荐/反对/派系/竞争/任务来源样本清单。
- `design/原型与实现/Phase 2.1 Godot 实现映射表 v1.md` §§14-16 — 上一阶段模块边界、月度时序与 UI 接入点。
- `design/原型与实现/Phase 3 Godot 实现映射表 v1.md` — Phase 3 设计项到 Godot 模块、Resource、运行时状态、UI 面板与验收点的映射桥接文档。
- `design/原型与实现/Godot 原型开发拆解 v1.md` §§5.5-5.7, 8C-8D — Godot 原型开发顺序、月度闭环接入与政治层扩展位置。
- `design/原型与实现/原型任务拆解清单 v1.md` T09-T12 — Phase 3 对应的任务拆解来源。

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `three-kingdoms-simulator/scenes/main/MainScene.tscn` — 已有主 HUD、右侧任务区、中部三张摘要卡、`TaskSelectPanel`、`MonthReportPanel`、`PromotionPopup` 的场景挂点；Phase 3 可以直接在这套单场景结构上扩展。
- `three-kingdoms-simulator/scripts/ui/MainHUD.gd` — 已接通月初任务选择、月末月报→任命弹窗顺序、行动菜单、角色选择器与摘要卡刷新；当前“关系/势力/家族摘要”仍是占位文案，正好是 Phase 3 政治摘要的现成接入口。
- `three-kingdoms-simulator/scripts/ui/TaskSelectPanel.gd` — 已有任务卡式选择面板，当前只显示任务名/发布人/描述/奖励；可直接扩展来源类型、关联派系、收益/风险标签而无需重做弹窗。
- `three-kingdoms-simulator/scripts/ui/MonthReportPanel.gd` 与 `three-kingdoms-simulator/scripts/ui/PromotionPopup.gd` — 已有月报与任命反馈壳，可继续复用“先月报、后任命反馈”的既有 UI 顺序。
- `three-kingdoms-simulator/scripts/autoload/GameRoot.gd` — 已掌握月初候选任务生成、月末结算、`MonthlyEvaluationResult` 组装与 HUD 消费时序，是接入 `PoliticalSystem` / `AppointmentResolver` 的主钩子位。
- `three-kingdoms-simulator/scripts/systems/TaskSystem.gd` — 已能生成候选任务、锁定主任务、按行动累计进度、在月末结算结果；适合作为 Phase 3 任务来源扩展与政治标签写回入口。
- `three-kingdoms-simulator/scripts/systems/CareerSystem.gd` — 已提供最小升迁判定与四类失败标签，是 Phase 3 扩展成五层原因树与候选竞争逻辑的基线实现。
- `three-kingdoms-simulator/scripts/autoload/DataRepository.gd` — 已负责 JSON 定义加载、`.tres` 资源加载、开局 patch、Office/Task/Rule 查询，可继续作为政治规则与派系块资源的统一入口。
- `three-kingdoms-simulator/scripts/runtime/GameSession.gd`、`PlayerCareerState.gd`、`MonthlyEvaluationResult.gd` — 已形成月度运行时状态与月报结果对象，是扩展政治快照、原因行与候选评估的直接落位点。

### Established Patterns
- 当前项目稳定采用 **Autoload 管理器 + RefCounted 运行时状态 + MainHUD 统一渲染** 的结构；Phase 3 应继续沿用，不应切新主场景。
- 当前实现坚持 **Definition/Runtime 分离**：静态定义由 JSON / `.tres` 提供，月内与月末结算状态写入 `GameSession` / `PlayerCareerState` / `MonthlyEvaluationResult`；Phase 3 的政治规则也应遵守这一分层。
- 现有月度反馈已固定为 **月报先行、任命结果后置**；Phase 3 的 explainable-politics 应叠加到这一顺序上，而不是另起一条平行结算 UI。
- 当前 UI 已以“读取结果对象”为主：`MainHUD` / `MonthReportPanel` / `PromotionPopup` 负责展示，不承担主要业务计算；Phase 3 仍应由系统层统一生成解释结构，UI 只读。

### Integration Points
- `TaskSystem.generate_month_candidates()`、`_candidate_payload()` 与 `TaskSelectPanel._card_text()` 是接入“来源类型 / 请求方 / 关联派系 / 风险收益标签”的直接入口。
- `GameRoot._process_month_end_evaluation()` 是把 Phase 2.1 的简化升迁判定升级成“政治支持快照 → 资格判定 → 候选评估 → 原因分解 → 月报结果”的关键钩子位。
- `MonthlyEvaluationResult.gd` 目前字段仍是 Phase 2.1 版本；Phase 3 需要扩成可承载五层原因树、主要推荐人、主要阻力、派系态度与下月建议的正式月报对象。
- `MainHUD` 的中部摘要卡和右侧任务区是 Phase 3 最直接的 HUD 接入口，但当前没有 `PoliticalSystem`、`FactionSystem`、`AppointmentResolver`、`FactionPanel` 等实现，planner 应将其视为新增模块而不是已有代码小修。
- `TaskTemplateData.gd`、`TaskPoolRuleData.gd`、`OfficeData.gd` 当前仍缺少 Phase 3 文档所需的来源字段、官职权限字段与政治面板可见性字段；需要扩展静态定义合同后，再由 `DataRepository` 统一加载。

</code_context>

<specifics>
## Specific Ideas

- 任务卡上的政治收益 / 风险不是长文解释，而是**可扫读的标签词组**；月初比较任务时强调“快速判断政治走向”。
- `MainHUD` 不承担完整政治面板职责，只常驻保留**主要推荐人 / 主要阻力 / 当前机会或资格短板**三项，避免主界面被政治细节挤满。
- 势力总览第一页要让玩家先读懂“**有哪些派系块、我站在哪一边、谁在观望我**”，而不是先看到资源表或宏观势力控制台。
- 官职专属动作应优先贴近历史职能定位；用户给出的示例方向是“监察型官职可以获得监察他官类动作”，其价值在于说明官职要带来真实可玩的权限差异，而不是只改文案。
- 动作显示规则必须区分“**永久无权限**”与“**当前旬临时不可做**”：前者不显示，后者置灰并说明原因。

</specifics>

<deferred>
## Deferred Ideas

- **完整按官职铺开动作树** — 已明确不作为 Phase 3 首批目标；本阶段只做少量代表性官职专属动作以验证玩法差异。
- **君主全局人事控制台 / 完整势力操盘界面** — 仍然超出 Phase 3 单角色边界。
- **复杂派系议程投票与派系资源运营** — 保留给后续更深政治阶段，不进入本次 explainable-politics 首版。

</deferred>

---

*Phase: 03-仕途、势力与可解释政治*
*Context gathered: 2026-04-08*
