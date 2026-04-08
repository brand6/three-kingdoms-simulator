# Phase 3: 仕途、势力与可解释政治 - Research

**Researched:** 2026-04-08  
**Domain:** Godot 单场景月度政治闭环扩展  
**Confidence:** HIGH

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
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

### Deferred Ideas (OUT OF SCOPE)
- **完整按官职铺开动作树** — 已明确不作为 Phase 3 首批目标；本阶段只做少量代表性官职专属动作以验证玩法差异。
- **君主全局人事控制台 / 完整势力操盘界面** — 仍然超出 Phase 3 单角色边界。
- **复杂派系议程投票与派系资源运营** — 保留给后续更深政治阶段，不进入本次 explainable-politics 首版。
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| RELA-04 | 关系值影响后续推荐、任务机会或任命结果 | 用 `PoliticalSystem` 将 `RuntimeRelationState` 写入 `PoliticalSupportSnapshot`，并在 `AppointmentResolver` 中消费。 |
| CARE-01 | 至少两类任务来源 | 任务来源冻结为 `faction_order` + `relation_request`，由 `TaskTemplateData`/`TaskPoolRuleData` 扩展字段保障。 |
| CARE-02 | 行动/任务影响功绩名望 | 继续复用 `TaskSystem.settle_month_task()` 写回 merit/fame/trust，不重做。 |
| CARE-03 | 月末给出任命/升迁/驳回/错失机会 | `CareerSystem` + `AppointmentResolver` 输出 `appointment_result` 与候选评估。 |
| CARE-04 | 结果解释含 support/opposition/merit/trust/blockers | 五层原因树统一落到 `PoliticalReasonLine` 和扩展后的 `MonthlyEvaluationResult`。 |
| CARE-05 | 官职变化改变权限/行动/政治待遇 | `OfficeData` 增加 permission / panel / candidate 字段；Action 菜单遵守 hidden vs disabled 新规则。 |
| FACT-01 | 查看势力主君、城市、重臣、资源、战略姿态 | 新 `FactionPanel`/popup 只读展示 `FactionDefinition` + `FactionBlocData` + 资源摘要。 |
| FACT-02 | 跟踪势力级资源 | 先做原型所需最小资源摘要，不扩成内政系统；作为 faction overview 只读字段。 |
| FACT-03 | 展示影响政治结果的主要派系/集团 | `FactionBlocData` + `bloc_attitudes` 是唯一标准接口。 |
| POLI-01 | 跟踪内部派系并显示其对玩家态度 | `FactionSystem` 提供 bloc 列表，`PoliticalSupportSnapshot.bloc_attitudes` 提供运行时态度。 |
| POLI-02 | 派系可支持/反对/中立 | 仅冻结三态：支持 / 观望 / 反对，并写入任命修正。 |
| POLI-03 | 玩家能看到是谁推动或阻碍结果 | `primary_recommender_ids` / `primary_opposer_ids` + 2~3 条 `PoliticalReasonLine`。 |
</phase_requirements>

## Summary

Phase 3 不应重做 Phase 2.1 的月循环；应在既有 `GameRoot -> TaskSystem -> CareerSystem -> MainHUD` 骨架上，插入一层**轻量政治聚合**与一层**任命竞争解释**。最小可控实现是：`TaskSystem` 负责“本月谁递来任务”，`PoliticalSystem` 负责“本月谁在推我/压我”，`AppointmentResolver` 负责“月末为何成/败”，`FactionSystem` 只负责“势力与派系信息查询”，`CareerSystem` 继续负责“资格和官职后果写回”。

当前代码已经有稳定的月初选任务、月内推进、月末月报→任命弹窗顺序，以及 headless 回归脚本。Phase 3 的关键不是增加更多系统，而是**冻结数据合同并让所有 UI 只读同一份结构化结果**：任务来源字段、政治支持快照、候选评估、统一原因行、官职权限标签。这样能保持 Definition/Runtime 分离，也能避免 UI 各自拼政治文案。

**Primary recommendation:** 按“合同先行 → 任务来源 → 支持快照 → 任命解释 → 官职后果 → UI 接通 → 回归校准”的 7 计划顺序实施，且只做 2 类任务来源、2~3 个派系块、玩家 + 1~2 名 AI 候选。

## Project Constraints (from CLAUDE.md / current workflow)

- 保持 **Godot + Typed GDScript + Control/Container/Theme + Autoload** 栈，不切 C# 主逻辑。
- 保持 **单角色视角**；不能滑向君主控制台或全局 SLG 仪表盘。
- 保持 **HUD + 弹窗 + 详情面板** 单场景流，不切主场景。
- 保持 **Definition/Runtime 分离**；静态规则不写回运行时定义。
- 先验证 **3–5 城、2–3 势力、30–50 人、5–8 士族** 的最小样本，不扩全国政治系统。
- 关键政治信息必须 **3 点击内可达**；月末反馈必须解释因果。

## Standard Stack

### Core
| Library / Module | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Godot Engine | 4.6.x stable | 运行时、UI、资源系统 | 当前项目已固定为 Godot 单场景原型；官方文档支持 Resource / Autoload / Control 模式。 |
| Typed GDScript | Godot built-in | 主逻辑与 DTO | 现有代码已稳定使用 `RefCounted`/autoload 脚本；Phase 3 应沿用。 |
| Control + PopupPanel + AcceptDialog | Godot built-in | HUD、任务选择、月报、任命、势力弹窗 | 现有 `MainScene.tscn` 已是 overlay 架构；扩展成本最低。 |
| RefCounted runtime DTOs | Godot built-in | `GameSession`、`MonthlyEvaluationResult`、新政治快照对象 | 与现有运行时状态模型一致，便于 headless 测试。 |
| Existing generated JSON + DataRepository adapters | current project pattern | 现有 office/task/character/faction/city 定义来源 | 当前代码已依赖该管线；Phase 3 不应回退成手写散乱字典。 |

### Supporting
| Library / Module | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| Custom Resource classes | Godot built-in | `RecommendationRuleData` / `OppositionRuleData` / `FactionBlocData` | 新政治规则和派系块应作为静态定义载入。 |
| FileAccess + JSON | Godot built-in | 后续持久化政治快照/评估 | 本阶段只需保持字段可序列化；不必先做完整存档 UI。 |
| Headless script regressions | current project pattern | 月度闭环与 UI 顺序验证 | 作为 Phase 3 验收主路径。 |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| 独立 `PoliticalSystem` + `AppointmentResolver` | 继续把逻辑塞进 `TaskSystem`/`CareerSystem` | 会让任务、仕途、解释耦死，难以复用到 HUD / 月报 / 势力页。 |
| 轻量 `FactionSystem` 查询层 | UI 直接读 `DataRepository` | 短期可行，但 FACT-01/03 与玩家位置摘要会在多个面板复制逻辑。 |
| 统一 `PoliticalReasonLine` | 每个 UI 自己拼文案 | 会立刻破坏 explainable-politics 一致性。 |

**Installation:**
```bash
# 无新增第三方包；继续使用 Godot 内置能力与现有项目脚本。
```

**Version verification:**
- 官方 Godot 4.6 文档已核验：Resources / Autoload / Saving games / UI。  
- 本机可用 CLI：`D:/Godot/Godot_v4.6.1-stable_mono_win64/Godot_v4.6.1-stable_mono_win64_console.exe --version` → `4.6.1.stable.mono.official.14d19694e`。  
- 项目研究栈建议为 4.6.2 stable，但当前机器实际可跑 4.6.1；Phase 3 计划应使用显式 Godot 路径，不依赖 `godot`/`godot4` 别名。

## Recommended Architecture / Modules

### Recommended Project Structure
```text
three-kingdoms-simulator/
├── scripts/
│   ├── autoload/
│   │   ├── GameRoot.gd              # 继续做月度编排
│   │   └── DataRepository.gd        # 继续做定义查询与加载
│   ├── systems/
│   │   ├── TaskSystem.gd            # 扩任务来源和月任务快照
│   │   ├── PoliticalSystem.gd       # 新增：聚合推荐/反对/派系态度
│   │   ├── FactionSystem.gd         # 新增：势力/派系块查询层
│   │   ├── CareerSystem.gd          # 保留资格/官职后果写回
│   │   └── AppointmentResolver.gd   # 新增：空缺/竞争/五层原因树
│   ├── runtime/
│   │   ├── PoliticalSupportSnapshot.gd
│   │   ├── AppointmentCandidateEvaluation.gd
│   │   └── PoliticalReasonLine.gd
│   └── ui/
│       ├── MainHUD.gd
│       ├── TaskSelectPanel.gd
│       ├── MonthReportPanel.gd
│       ├── PromotionPopup.gd
│       └── FactionPanel.gd          # 新增 popup，不切场景
└── data/
    ├── politics/recommendations/
    ├── politics/oppositions/
    └── factions/blocs/
```

### Pattern 1: Keep GameRoot as orchestrator, not calculator
**What:** `GameRoot` 继续只负责时序：月初生成候选任务，月末串接任务结算 → 政治快照 → 资格判定 → 候选竞争 → 月报结果。  
**When to use:** 整个 Phase 3。  
**Rule:** 不要把推荐、派系、竞争评分塞回 `MainHUD` 或 `GameRoot`。

### Pattern 2: PoliticalSystem owns the current political truth
**What:** `PoliticalSystem` 以关系、trust、任务来源/结果、office tags、bloc attitudes 为输入，产出唯一 `PoliticalSupportSnapshot`。  
**When to use:** 月内刷新 HUD 摘要、月末生成任命输入、人物/势力详情读取。  
**Rule:** `TaskSystem` 只产出任务事实，`PoliticalSystem` 再解释其政治含义。

### Pattern 3: AppointmentResolver owns layered explainability
**What:** `AppointmentResolver` 对玩家和 1~2 名 AI 候选做有限比较，并按 **资格 → 空缺 → 推荐 → 阻力 → 竞争** 五层生成 `PoliticalReasonLine`。  
**When to use:** 仅月末。  
**Rule:** `CareerSystem` 只负责资格/官职写回，不负责多候选排序。

### Pattern 4: FactionSystem must stay thin
**What:** `FactionSystem` 只做“势力有哪些 bloc、主君/核心重臣/城市/资源摘要是什么、玩家处于哪一侧”的查询聚合。  
**When to use:** `FactionPanel`、HUD 的“当前机会/资格短板”补文案。  
**Rule:** 不做 faction-level 回合模拟，不做资源运营器。

### Anti-Patterns to Avoid
- **把 Phase 3 做成第二套月循环：** 政治不是并行回合系统，只是扩展 Phase 2.1 月度结算。
- **UI 拼接业务结论：** 任务卡、月报、任命弹窗、势力页都只能读结果对象。
- **派系块建成全组织树：** Phase 3 只需要 2~3 个 bloc 和三态态度。
- **一次做全官职专属动作：** 只做 0–2 个代表性动作验证权限差异。
- **继续用大 Dictionary 漫灌：** Phase 3 新字段一旦分散，后续回归会很脆弱。

## Data Contracts

### New static definitions
| Object | Required fields for planning | Why |
|--------|------------------------------|-----|
| `RecommendationRuleData` | `id`, `source_type`, `trigger_phase`, `target_scope`, relation/trust/merit thresholds, bloc filters, `support_delta`, `reason_text_key`, `priority`, `sort_order` | 冻结推荐链来源与排序。 |
| `OppositionRuleData` | `id`, `source_type`, `trigger_phase`, relation/trust lower bounds, competition tags, `opposition_delta`, `blocker_tags`, `reason_text_key`, `priority` | 冻结阻力/压制链。 |
| `FactionBlocData` | `id`, `faction_id`, `name`, `bloc_type`, `core_character_ids`, `influence_weight`, `agenda_tags`, `default_attitude` | 提供派系块与 UI 摘要。 |

### Existing definitions that must be extended
| Object | Required new fields | Planning note |
|--------|---------------------|---------------|
| `TaskTemplateData` | `task_source_type`, `request_character_id`, `related_bloc_id`, `political_reward_tags`, `political_risk_tags`, `recommendation_hint_tags`, `opposition_hint_tags`, `source_summary`, `source_priority` | 任务来源解释的最低合同。 |
| `TaskPoolRuleData` | `required_source_types`, `source_weight_rules`, `source_mix_policy`, `related_bloc_bias`, `fallback_source_types` | 用来保证“至少两类来源稳定出现”。 |
| `OfficeData` | `office_tags`, `visible_political_panels`, `recommendation_power`, `candidate_office_tags`, `political_risk_level` | 用来驱动资格、权限、面板可见性。 |

### New runtime contracts
| Object | Required fields | Why |
|--------|-----------------|-----|
| `PoliticalSupportSnapshot` | `month_key`, `character_id`, `primary_recommender_ids`, `primary_opposer_ids`, `bloc_attitudes`, `support_score_total`, `opposition_score_total`, `qualification_tags`, `blocker_tags`, `candidate_office_ids`, `opportunity_tags` | HUD、人物页、任命输入共读。 |
| `AppointmentCandidateEvaluation` | `office_id`, `candidate_character_id`, `evaluation_status`, `qualification_passed`, `vacancy_available`, recommendation/opposition/bloc/merit/trust scores, `competition_rank`, `reason_lines`, `final_decision`, `next_goal_hint` | 统一月末候选评估。 |
| `PoliticalReasonLine` | `reason_type`, `stage`, `source_type`, source ids, `direction`, `weight_tier`, `summary_text`, `ui_group`, `sort_order`, `is_major` | explainable-politics 的唯一原因单位。 |

### Existing runtime contracts that must be extended
| Object | Required new fields | Why |
|--------|---------------------|-----|
| `MonthlyTaskState` | `task_source_type`, `request_character_id`, `related_bloc_id`, accepted-time source snapshot | 避免月末报告因为 live task 被清空而丢失来源信息。 |
| `PlayerCareerState` | `political_support_snapshot`, `last_candidate_evaluation`, `current_permission_tags`, `recent_political_result` | 保持 career 与 politics 读写边界清晰。 |
| `MonthlyEvaluationResult` | `task_source_type`, `request_character_id`, `political_support_snapshot`, `candidate_evaluation_results`, `appointment_result`, `primary_support_lines`, `primary_blocker_lines`, `missed_opportunity_note`, `new_permission_tags`, `political_consequence_tags`, `next_month_political_hint` | 月报/任命 UI 的唯一读取入口。 |
| `GameSession` | `current_political_support_snapshot`, `last_candidate_evaluations`, optional `last_faction_overview_cache` | 让 HUD 与月末流程读当前政治结果，而不重新计算。 |

### Canonical contract rules
1. **静态规则不进存档。** Recommendation/Opposition/Bloc 定义由 `DataRepository` 读取，绝不写回。  
2. **月内政治状态只保留结构，不保留 UI 文案副本。** 文案来自 `PoliticalReasonLine.summary_text`。  
3. **`MonthlyEvaluationResult` 继续是月报主入口。** 不新建第二套月报对象。  
4. **同一事实只存一份。** 例如“任务来源类型”应在 `MonthlyTaskState` 和 `MonthlyEvaluationResult` 是快照，不要再让 UI 逆向查 live task。  
5. **永久权限与临时阻断分离。** 永久权限走 office/action 配置；临时阻断走 action resolver reason。  

## Runtime State Changes

### Month start
- `TaskSystem.generate_month_candidates()` 从“按 tag 选任务”升级为“按 source mix 生成 2–3 张候选卡”。
- 每张候选卡 payload 至少包含：`task_source_type`、`issuer/request_character_id`、`related_bloc_id`、`source_summary`、`political tags`。
- `GameSession.pending_month_task_candidates` 继续存在，但候选项必须是稳定结构，而不是 UI 专用临时字典。

### During the month
- 每次影响关系/任务推进的行动后，`PoliticalSystem` 增量更新当前 `PoliticalSupportSnapshot`。
- HUD 中部三卡应读 snapshot 的三类摘要，不直接读原始关系值。
- 任务成功/失败标签只记“政治输入事实”，不直接得出任命结论。

### Month end
- 顺序必须保持：
```text
Task settlement
→ merit/fame/trust writeback
→ PoliticalSupportSnapshot finalize
→ Career qualification gate
→ AppointmentResolver candidate comparison
→ Career office/permission consequences
→ MonthlyEvaluationResult build
→ MonthReportPanel
→ PromotionPopup
```
- 失败 headline 只取**最早阻断层**；其余原因进入 2–3 条原因行。
- 下月政治机会/阻力要在月报结果中固化，供下月 HUD 首帧读取。

## UI Integration Notes

### MainHUD
- 直接复用现有三张 summary card；建议重命名语义为：`主要推荐人` / `主要阻力` / `当前机会或资格短板`。
- 不新增第四张卡；详细派系结构进入 popup。
- `FactionButton` 需从 disabled 切为可用，1 点击打开 `FactionPanel` popup。
- HUD 刷新时机：任务确认后、政治快照更新后、月末结算完成后都应同帧/同 deferred pass 刷新。

### TaskSelectPanel
- 卡片首屏固定顺序：任务名 → 来源类型 → 请求方/发布者 → 关联人物/派系 → 一句话目标 → 预期收益 → 2–4 个政治标签。
- 保持 `SelectedRewardLabel` 不占位显示；政治详情应进卡片正文，不要回到按钮上方区域。
- 候选任务必须全可选；不存在 unavailable 卡。
- `source_mix_policy=ensure_diversity` 应成为计划级验收点，否则 CARE-01 很容易随机失效。

### MonthReportPanel
- 继续先于 `PromotionPopup` 打开。
- 至少新增 4 个逻辑块：顶部结论、2–3 条原因行、政治力量行、下月建议行。
- 现有单个 `BodyLabel` 可先保留，但 planner 应预留拆成多 label/container；否则文案会迅速失控。

### PromotionPopup
- 只负责任命/落选结论与官职后果摘要；不重复整份月报。
- 成功态：新官职、任命人、1 条缘由、1 条新权限/待遇后果。
- 失败态：top-line headline + earliest blocking label + 1 条具体缺口 + “下月建议”短句。

### Faction overview popup
- 作为 `PopupPanel` 接入，不切场景。
- 首页顺序固定：玩家位置摘要 → 派系块 → 主君/核心高层 → 控制城市/战略姿态 → 原型资源摘要。
- 每个核心人物行应能 2 点击内进入 `CharacterProfilePanel`。
- bloc 行只展示 `支持 / 观望 / 反对`，不要暴露后台分数表。

### CharacterProfilePanel implications
- 最小扩展即可：在 notes 或新增区域中展示该角色与玩家的“政治角色标签”（推荐人/阻力/观望者）。
- 不必在本阶段把角色面板扩成完整 dossier。

## Recommended Plan Sequencing

| Plan | Recommended focus | Why this order |
|------|-------------------|----------------|
| 03-01 | 冻结静态/运行时合同；加 Resource 类、DTO 类、DataRepository 查询入口 | 先锁字段，避免后 6 计划继续猜结构。 |
| 03-02 | 扩两类任务来源 + TaskSelectPanel 卡片合同 + source mix 稳定生成 | CARE-01 是后续推荐/反对链的入口。 |
| 03-03 | 实现 `PoliticalSystem` 与 `PoliticalSupportSnapshot` 月内累积 | 没有 snapshot，就无法做 HUD、任命或派系态度。 |
| 03-04 | 实现资格/空缺/推荐/阻力/竞争五层任命解释；接 `AppointmentResolver` | explainable-politics 的核心后端。 |
| 03-05 | 官职权限/代表性专属动作/hidden-vs-disabled 行为 | 把 CARE-05 从“文案变化”变成真实玩法变化。 |
| 03-06 | 接 MainHUD、MonthReportPanel、PromotionPopup、Faction popup、Character profile 摘要 | 后端稳定后再接 UI，避免反复返工。 |
| 03-07 | 联调、失败样本、回归脚本、权重校准与 acceptance gate | 最后做端到端与坏结果验证。 |

## Scope Cuts / Anti-Goals

- 不做全国派系图谱。
- 不做君主人事控制台。
- 不做完整官职动作树；每个关键 office 只做 0–2 个代表性动作。
- 不做全势力所有官员实时候选排行榜。
- 不做复杂派系议程投票、站队 UI、资源运营层。
- 不把 FACT-02 扩成完整经济系统；只做政治反馈所需的最小势力资源摘要。

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| 月末解释 | UI 临时字符串拼接 | `PoliticalReasonLine` | 同一原因要被月报/HUD/势力页共用。 |
| 候选竞争 | `if/else` 散落在 `CareerSystem` | `AppointmentResolver` | 五层判定和 AI 候选比较需要单点维护。 |
| 派系系统 | 全国级组织树 | 2–3 个 `FactionBlocData` + 三态 attitude | 这是原型，不是朝堂模拟器。 |
| 任务来源多样性 | 靠随机或 UI 补文案 | `TaskPoolRuleData.source_mix_policy` | 否则 CARE-01 难稳定回归。 |
| 权限限制 | 永久限制也显示禁用态 | action catalog filter + temporary disabled reason | 已被 D-13/D-14 明确覆盖。 |

**Key insight:** Phase 3 的复杂度不在“算法高级”，而在“同一事实是否被多处重复建模”。只要原因、快照、候选评估三类结构统一，范围就可控。

## Common Pitfalls

### Pitfall 1: 把政治支持只在月末一次性计算
**What goes wrong:** HUD 整月显示占位文案，玩家感受不到“月内行为正在改变政治处境”。  
**Why it happens:** 想偷懒，把推荐/反对只放到月末。  
**How to avoid:** `PoliticalSystem` 在行动/关系变动后就增量刷新 snapshot；月末只 finalize。  
**Warning signs:** 月内任何行动后，三张政治摘要卡完全不变。

### Pitfall 2: 任务来源信息只有文案，没有结构字段
**What goes wrong:** 月初卡片能显示文字，但月末无法稳定回溯“这件事是谁递来的”。  
**Why it happens:** 只改 `TaskSelectPanel._card_text()`，没扩 `TaskTemplateData` / `MonthlyTaskState`。  
**How to avoid:** 来源类型、请求方、关联 bloc 必须进入定义和 runtime snapshot。  
**Warning signs:** 月报要靠 live task 或 task template 反查来源。

### Pitfall 3: 把 faction overview 做成势力控制台
**What goes wrong:** UI 膨胀成 SLG 仪表盘，违反单角色边界。  
**Why it happens:** FACT-01/02 容易被误解为“展示所有势力数据”。  
**How to avoid:** 首页只回答“我在局中的位置是什么”。  
**Warning signs:** 面板开始出现批量任命、全局资源调度、全国地图入口。

### Pitfall 4: 失败原因 headline 和原因行互相打架
**What goes wrong:** 月报主标题说“竞争落败”，原因行却先说“资格不足”，玩家读不懂。  
**Why it happens:** 没按 earliest blocking layer 统一排序。  
**How to avoid:** headline 只取最早阻断层；其他命中项进入 2–3 条原因行。  
**Warning signs:** 一次失败同时出现多个并列主因标签。

### Pitfall 5: 官职变化只改名称，不改玩法
**What goes wrong:** CARE-05 形式上完成，玩家体验上无差异。  
**Why it happens:** 只更新 `OfficeInfoLabel`。  
**How to avoid:** 至少同时改变 task source access 与 0–2 个 office-only actions。  
**Warning signs:** 升官前后 `get_available_phase2_actions()` 列表和任务来源完全一样。

## Code Examples

Verified patterns from official docs and current codebase:

### Custom Resource for new political rules
```gdscript
# Source: Godot 4.6 Resources docs
class_name RecommendationRuleData
extends Resource

@export var id: String = ""
@export var source_type: String = ""
@export var support_delta: int = 0
@export var reason_text_key: String = ""
```

### Autoload orchestrator pattern
```gdscript
# Source: Godot 4.6 Autoload docs + current project pattern
func _process_month_end_evaluation() -> void:
	var settlement := _task_system.settle_month_task(current_session, _data_repository())
	var snapshot := _political_system.finalize_month_snapshot(current_session, _data_repository(), settlement)
	var qualification := _career_system.evaluate_qualification(current_session, _data_repository(), snapshot)
	var evaluation := _appointment_resolver.evaluate_month_end(current_session, _data_repository(), snapshot, qualification)
	_career_system.apply_office_consequences(current_session, _data_repository(), evaluation)
	current_session.set_last_month_evaluation(_build_monthly_result(settlement, snapshot, evaluation))
```

### JSON-friendly runtime snapshot rule
```gdscript
# Source: Godot 4.6 Saving games docs
func to_save_dict() -> Dictionary:
	return {
		"month_key": month_key,
		"character_id": character_id,
		"primary_recommender_ids": primary_recommender_ids,
		"primary_opposer_ids": primary_opposer_ids,
		"bloc_attitudes": bloc_attitudes,
		"qualification_tags": qualification_tags,
		"blocker_tags": blocker_tags,
	}
```

## Verification Strategy

### Automated command baseline
Use the installed explicit Godot path:
```powershell
& "D:/Godot/Godot_v4.6.1-stable_mono_win64/Godot_v4.6.1-stable_mono_win64_console.exe" --headless --path "three-kingdoms-simulator" --script "res://scripts/tests/<test>.gd"
```

### Acceptance / verification hooks the planner should encode
| Area | Hook |
|------|------|
| Two task sources | Month-start regression asserts candidate set includes both `faction_order` and `relation_request` across a controlled seed/data fixture. |
| Task card contract | UI regression asserts first card text includes source type, requester/issuer, linked person or bloc, reward summary, and political tags. |
| Relationship influence | Backend regression mutates a key `RuntimeRelationState` and verifies `PoliticalSupportSnapshot.primary_recommender_ids` or `primary_opposer_ids` changes. |
| Five-layer reason tree | Month-end regression asserts `appointment_result`, 2–3 visible reason lines, and headline derived from earliest blocking layer. |
| Competition | Regression feeds same vacancy with player + rival candidate and verifies `lost_to_rival` path exists. |
| Hidden vs disabled | Action menu regression verifies office-forbidden action is absent, while temporary-blocked action remains visible with `—— reason`. |
| Office consequence | Promotion success regression verifies next-month task pool or visible action list differs after office change. |
| Faction popup | UI regression verifies `FactionButton` opens popup and shows player position + bloc rows + inspectable major officers. |
| Sequence preservation | Existing month-end regression extended to assert MonthReportPanel opens before PromotionPopup and next-month task picker stays hidden until confirmation chain ends. |

### Recommended regression file additions
- `phase3_task_source_regression.gd`
- `phase3_political_snapshot_regression.gd`
- `phase3_appointment_resolver_regression.gd`
- `phase3_office_permission_regression.gd`
- extend `phase21_monthly_hud_regression.gd` for Phase 3 month-end UI sequence + faction button

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Phase 2.1 阈值式升官 | Phase 3 五层 explainable appointment | Phase 3 design docs | 任命从黑箱阈值变成可解释政治结果。 |
| 单一上级指派任务 | 两类政治来源任务 | Phase 3 design docs | 月初选任务开始承载政治意义。 |
| 占位式势力摘要 | politics-first HUD + faction popup | Phase 3 UI spec | 玩家能读懂自身政治位置。 |

**Deprecated/outdated:**
- “权限不足动作也继续显示禁用态” —— 已被 D-13 / D-14 覆盖；Phase 3 不再使用。
- “任命失败只用四类固定标签” —— 仍可保留 headline 标签，但后台必须升级为五层原因树。

## Open Questions

1. **玩家与 AI 候选的精确权重如何定标？**
   - What we know: 文档已冻结比较维度：推荐、反对、派系、功绩、信任、竞争。
   - What's unclear: 各维度相对权重和阈值尚未校准。
   - Recommendation: 03-07 才做权重校准；03-04 先做 deterministic sample weights，保证成功/失败样本都能稳定复现。

2. **Phase 3 扩展字段应先走生成 JSON 还是直接手写 `.tres`？**
   - What we know: 当前 `OfficeData`/`TaskTemplateData`/世界样本由现有 JSON 管线进入，政治规则新对象更适合 `.tres`。
   - What's unclear: 是否立即扩 Luban 表来承载全部 Phase 3 字段。
   - Recommendation: 世界定义沿用现有 JSON 管线；新政治规则先用 `.tres`。不要同一对象双来源并存。

3. **FACT-02 的“势力资源”最小集合是什么？**
   - What we know: 需要支撑政治与简化战争反馈，但不做内政系统。
   - What's unclear: 具体字段列表尚未在现有代码体现。
   - Recommendation: 只规划 2–4 个摘要字段（如军务压力、政务负担、粮秣余裕、用人紧张度），并作为只读 faction overview 文案来源。

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Godot CLI explicit path | Headless regressions, UI/backend verification | ✓ | 4.6.1 stable mono | Use explicit console exe path in every test command |
| `godot` / `godot4` alias | Shortcut commands in plans | ✗ | — | Use explicit `D:/Godot/.../Godot_v4.6.1-stable_mono_win64_console.exe` |
| Node.js | GSD init/tools, data helper scripts | ✓ | v24.13.0 | — |
| Python | Optional data scripts/tooling | ✓ | 3.11.9 | — |
| npm | Optional JS tooling | ✓ | 11.12.0 | — |

**Missing dependencies with no fallback:**
- None for planning/verification.

**Missing dependencies with fallback:**
- `godot` / `godot4` shell alias missing — use explicit installed console exe path.

## Sources

### Primary (HIGH confidence)
- Project context: `.planning/phases/03-仕途、势力与可解释政治/03-CONTEXT.md`
- Project UI contract: `.planning/phases/03-仕途、势力与可解释政治/03-UI-SPEC.md`
- Project roadmap/requirements/state: `.planning/ROADMAP.md`, `.planning/REQUIREMENTS.md`, `.planning/STATE.md`
- Project design docs: `design/总纲/Phase 3 仕途、势力与可解释政治 详细规划 v1.md`; `design/数据/Phase 3 政治与任命数据字段设计 v1.md`; `design/原型与实现/Phase 3 Godot 实现映射表 v1.md`; `design/数据/Phase 3 最小数据录入清单 v1.md`
- Current code inspection: `GameRoot.gd`, `TaskSystem.gd`, `CareerSystem.gd`, `DataRepository.gd`, `MainHUD.gd`, `TaskSelectPanel.gd`, `MonthReportPanel.gd`, `PromotionPopup.gd`, `GameSession.gd`, `PlayerCareerState.gd`, `MonthlyEvaluationResult.gd`
- Context7 `/websites/godotengine_en_4_6` — Resources, Autoload, Saving games, UI building blocks
- Official docs: https://docs.godotengine.org/en/4.6/tutorials/scripting/resources.html
- Official docs: https://docs.godotengine.org/en/4.6/tutorials/scripting/singletons_autoload.html
- Official docs: https://docs.godotengine.org/en/4.6/tutorials/io/saving_games.html
- Official docs: https://docs.godotengine.org/en/4.6/tutorials/ui/index.html

### Secondary (MEDIUM confidence)
- Existing Phase 2.1 regression scripts and verification notes for month-start/month-end flow preservation.

### Tertiary (LOW confidence)
- None.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - Godot official docs + existing project architecture agree.
- Architecture: HIGH - design docs and current codebase align on module boundaries and month-loop reuse.
- Pitfalls: HIGH - directly derived from current code seams, locked decisions, and Phase 2.1 regression behavior.

**Research date:** 2026-04-08  
**Valid until:** 2026-05-08
