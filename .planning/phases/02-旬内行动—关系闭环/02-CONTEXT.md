# Phase 2: 旬内行动—关系闭环 - Context

**Gathered:** 2026-04-05
**Status:** Revised for UAT gap closure (2026-04-06)

<domain>
## Phase Boundary

本阶段在现有单角色主 HUD 骨架内，交付一个完整的旬内主循环：玩家打开行动入口，在一个旬内连续执行多次行动，看到即时结算与关系/状态变化，随后手动结束本旬并查看旬末总结。它负责证明“行动选择、可解释反馈、关系变化、旬推进”已经形成可玩的最小闭环，不负责月末任命、派系政治、家族门阀、婚姻或战争扩展内容。

</domain>

<decisions>
## Implementation Decisions

### UAT gap-closure overrides (2026-04-06)
- **D-05R:** **Supersedes D-05 for gap-closure plans 02-05..02-07.** 行动浮层首屏不再是“一级分类 -> 二级动作”的 category-first 入口；首屏必须直接显示五个基础行动 `训练 / 读书 / 休整 / 拜访 / 巡察`。点击其中一项后，右侧详情区再展示说明、消耗、禁用原因与主操作按钮，形成“首屏五行动 -> 右侧详情/操作”的两层结构。
- **D-07R:** **Supersedes D-07 for gap-closure plans 02-05..02-07.** `成长 / 关系 / 政务 / 军事 / 家族` 仍可作为数据标签、筛选元信息或未来扩展 taxonomy 保留，但**不是**当前 UAT 修复后的首屏菜单轨道；执行 gap plans 时不得把它们继续实现为首层点击入口。
- **D-11R:** **Supersedes D-11 for gap-closure plans 02-05..02-07.** 身份/权限不满足的动作必须继续显示在行动菜单中，呈现禁用态，并给出明确锁定原因；动作与身份/权限映射必须改成可配置资源，而不是硬编码隐藏规则。
- **D-14R:** “关系”入口改为 **通用角色选择器 -> 角色信息面板**，不再以 `RelationPopup` 作为主流程。
- **D-15R:** “拜访”与“关系”必须复用同一套可排序表格选择器，只允许在确认对象后的后续动作不同。

### 延续前置约束
- **D-01:** 继续坚持 `HUD + 面板` 的主循环实现，不转为地图优先或大地图探索式流程。
- **D-02:** 继续沿用单角色、统一底层规则架构；身份差异通过权限与动作可用性体现，不做独立玩法模式。
- **D-03:** Phase 2 直接接在现有 `MainScene + MainHUD + GameRoot + DataRepository + TimeManager` 骨架上扩展，不另起入口体系。

### 行动菜单结构
- **D-04:** 行动入口采用**底部按钮向上展开的轻量浮动面板**，保持主 HUD 常驻可见，不切走整页主界面。
- **D-05:** 浮动行动面板在内部完成前两层流程：**一级分类 -> 二级动作**。
- **D-06:** 若动作需要目标选择，则第三层改为**单独目标弹窗**承载，而不是把完整三级流程都塞进浮层里。
- **D-07:** 一级分类保持固定五类：**成长、关系、政务、军事、家族**；即使 Phase 2 只实装部分动作，一级分类结构也先完整出现。

### 首批动作范围
- **D-08:** Phase 2 先只实装需求中要求的五个基础行动，用最小动作集验证闭环，而不是一次铺开 12 到 15 个动作。
- **D-09:** 五个基础行动采用中文落地名：`拜访`、`训练`、`读书`、`巡察`、`休整`。
- **D-10:** 需求中的 `inspect` 在 Phase 2 具体映射为**巡察**，优先作为政务类基础动作处理。

### 动作可见性与过滤
- **D-11:** 由**身份权限**决定的动作直接隐藏，例如武将不显示君主专有行动，用于维持统一菜单结构下的身份差异。
- **D-12:** 由**当前条件不足**导致不可执行的动作继续显示，但需要**灰显并明确写出原因**，例如 AP 不足、精力不足、地点不符或缺少目标。
- **D-13:** Phase 2 的动态过滤重点先覆盖身份权限、AP/精力、地点和目标可用性这些直接影响主循环验证的条件；更复杂的事件/派系/婚姻过滤后置到后续 phase。

### the agent's Discretion
- 浮动行动面板相对底部导航的精确锚点、尺寸与动画表现。
- 一级分类与二级动作在浮层内的具体布局方式，只要保持“先类后动作”的两层顺序即可。
- 五个一级分类中暂无已实装动作的分类，采用空状态、未开放提示或灰态提示的具体文案与视觉方式。
- 目标弹窗的具体版式与控件命名。

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Project and phase scope
- `.planning/PROJECT.md` — 项目核心价值、单角色边界、局部样本范围与原型交付约束。
- `.planning/REQUIREMENTS.md` §Core Loop, §Character State, §Actions, §Relationships, §UI Feedback — Phase 2 对应的验收来源，尤其是 `CORE-03..05`、`CHAR-03`、`ACTN-01..05`、`RELA-01..03`、`UI-01..02`、`UI-04`。
- `.planning/ROADMAP.md` §Phase 2: 旬内行动—关系闭环 — 本阶段目标、成功标准与 canonical refs。
- `.planning/STATE.md` §Accumulated Context — 当前项目状态与从 Phase 1 延续下来的实现约束。

### Prior phase decisions and existing runtime base
- `.planning/phases/01-190/01-CONTEXT.md` — Phase 1 已锁定的入口、HUD、数据管线与单角色边界。
- `.planning/phases/01-190/01-190-05-PLAN.md` — 当前运行时入口、HUD 绑定与默认主角开局的最近实现规划。

### Action loop and UI behavior
- `design/系统设计/核心系统详细设计 v1.md` §§2-3 — 主循环、行动与关系闭环的系统设计依据。
- `design/原型与实现/原型任务拆解清单 v1.md` §§7-9 (`T06`-`T08`) — 行动菜单、关系系统、旬末结算的任务拆解。
- `design/UIUX/原型 UI 流程图 v1.md` §§4-7, 11-13 — 主 HUD、行动菜单、关系页与旬末结算的 UI 流程约束。
- `design/行动菜单结构设计 v1.md` — 行动菜单三级结构、五大分类、动态过滤规则、目标类型与原型动作清单；本 phase 已明确要求按这份文档对齐。

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `three-kingdoms-simulator/scenes/main/MainScene.tscn` — 已有主 HUD 场景骨架、顶部状态条、中部三栏和底部导航，可作为行动浮层与关系页的承载底板。
- `three-kingdoms-simulator/scripts/ui/MainHUD.gd` — 已负责启动入口、成功/失败状态切换和 HUD 数据绑定；Phase 2 应继续从这里接行动入口和主界面刷新。
- `three-kingdoms-simulator/scripts/autoload/GameRoot.gd` — 已承担默认开局 bootstrap，可继续作为行动执行和旬切换的高层协调点。
- `three-kingdoms-simulator/scripts/autoload/DataRepository.gd` — 已提供 scenario/character/faction/city 查询，是动作条件检查和目标展示的现成数据入口。
- `three-kingdoms-simulator/scripts/autoload/TimeManager.gd` — 已持有当前年/月/旬标签，Phase 2 可在此基础上扩展旬推进。
- `three-kingdoms-simulator/scripts/runtime/GameSession.gd` 与 `three-kingdoms-simulator/scripts/runtime/RuntimeCharacterState.gd` — 已有基础运行时状态容器，可继续承载 AP、精力、压力、名望、功绩等行动后变更。

### Established Patterns
- 当前运行时以 **Autoload 管理器 + RefCounted 运行时状态 + MainHUD 统一渲染** 为核心模式。
- HUD 当前是**状态常驻 + 中部内容区 + 底部导航**的信息架构，适合在不切场景的前提下插入浮层、弹窗与详情面板。
- 数据层继续遵守 **Definition/Runtime 分离**，因此动作系统应修改 `GameSession` / `RuntimeCharacterState` / 新运行时关系状态，而不是回写定义数据。

### Integration Points
- “行动”底部按钮是最直接的 Phase 2 入口位，应从禁用态切换为真实入口。
- 右侧上下文区可继续承载任务提示、最近事件或行动结果摘要。
- 中间主区域适合作为被行动结果、关系详情或旬末总结临时改写/覆盖的主展示区。

</code_context>

<specifics>
## Specific Ideas

- 用户明确希望“行动”入口保持**轻量感**，因此拒绝整页切换，倾向于从底部导航向上展开的小型浮动菜单。
- 用户明确要求：浮层只承载**分类和动作两层**；若动作有目标选择，再单独弹出目标相关弹窗。
- 用户明确指定：动作相关实现需要参照 `design/行动菜单结构设计 v1.md`。
- 用户确认：Phase 2 先用五个基础行动验证闭环，不追求一次做完文档中的完整原型动作清单。
- `2026-04-06 UAT gap closure` 明确改口：身份权限造成的差异也必须**显示禁用态并说明原因**，不再隐藏动作。
- `2026-04-06 UAT gap closure` 明确改口：行动入口首屏展示的是**五个基础行动**，不是五大类分类轨；五大类只保留为元信息。
- `2026-04-06 UAT gap closure` 明确改口：关系入口必须走**通用角色选择器 -> 角色信息面板**。

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 02-旬内行动—关系闭环*
*Context gathered: 2026-04-05*
