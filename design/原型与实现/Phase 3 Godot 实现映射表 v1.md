# Phase 3 Godot 实现映射表 v1

#项目设计 #原型实现 #Godot #Phase3 #实现映射 #政治系统

> 文档定位：本文件不是新的玩法设计稿，而是把 Phase 3 已冻结的政治设计内容映射到 Godot 原型的模块、Resource、运行时状态、UI 面板、月度时序与验收点的桥接文档。目标是让开发 AI 明确“由谁做、放哪里、谁读取、何时结算、如何验收”。

---

## 1. 文档定位与使用方式

### 1.1 本文档解决的问题
本文件主要回答以下实现问题：

1. Phase 3 的政治设计项分别落到哪些 Godot 模块。
2. 哪些内容属于静态 Resource，哪些属于运行时快照与月末结果。
3. 月初任务来源扩展、月内支持变化、月末候选评估与任命解释分别由谁负责。
4. UI 面板应读取哪些对象，而不直接承担政治演算。
5. Phase 3 的最小闭环应按什么顺序搭建与验收。

### 1.2 本文档不负责的内容
- 不重新定义 Phase 3 玩法规则。
- 不替代《Phase 3 仕途、势力与可解释政治 详细规划 v1》。
- 不替代《Phase 3 政治与任命数据字段设计 v1》。
- 不直接给出代码实现。

### 1.3 使用顺序
开发 AI 在进入 Phase 3 实现前，建议按以下顺序阅读：

1. `design/总纲/Phase 3 仕途、势力与可解释政治 详细规划 v1.md`
2. `design/数据/Phase 3 政治与任命数据字段设计 v1.md`
3. `design/总纲/官职与任务原型部署 Phase 2.1 v1.md`
4. `design/数据/官职与任务原型部署数据字段设计 v1.md`
5. `design/原型与实现/Phase 2.1 Godot 实现映射表 v1.md`
6. **本文档《Phase 3 Godot 实现映射表 v1》**

---

## 2. 上游文档依赖

| 上游文档 | 作用 | 本文档如何使用 |
|---|---|---|
| `design/总纲/Phase 3 仕途、势力与可解释政治 详细规划 v1.md` | 定义阶段目标、范围、成功标准 | 作为 Phase 3 实现范围与验收标准来源 |
| `design/数据/Phase 3 政治与任命数据字段设计 v1.md` | 定义政治 Resource、运行时快照与月报扩展字段 | 作为 Resource / State / Save 结构依据 |
| `design/总纲/官职与任务原型部署 Phase 2.1 v1.md` | 定义月初领任务、月内推进、月末结算骨架 | 作为复用基础闭环来源 |
| `design/数据/官职与任务原型部署数据字段设计 v1.md` | 定义 Phase 2.1 的官职、任务、升官状态字段 | 用于对齐旧对象扩展位 |
| `design/原型与实现/Phase 2.1 Godot 实现映射表 v1.md` | 明确上一阶段模块边界与月度时序 | 作为 Phase 3 叠加政治层的基准 |
| `.planning/phases/03-仕途、势力与可解释政治/03-01-PLAN.md` 至 `03-07-PLAN.md` | 给出执行顺序与阶段拆分 | 作为实现优先级与分批落地依据 |

---

## 3. Phase 3 实现范围冻结

### 3.1 本文档只覆盖以下内容
- 推荐规则、反对规则、派系块、政治快照与候选评估接入。
- 月任务来源从上级指派扩展到至少两类政治来源。
- 关系、功绩、任务结果写入政治支持快照。
- 月末候选资格、空缺、竞争与任命解释。
- 官职变化带来的权限、信息可见性与政治后果差异。
- 人物政治摘要、势力政治总览、月末政治报告读取链路。

### 3.2 本文档明确不覆盖以下内容
- 君主全局人事调度界面。
- 复杂派系议程投票与资源运营。
- 玩家自建派系与公开站队系统。
- 全国级政治地图与全职位实时排行榜。
- 家族婚姻深度联动与继承政治。

这些内容属于后续阶段，不在 Phase 3 首版中解决。

---

## 4. 设计章节 → Godot 模块映射表

| 设计项 | Godot 模块 | 主负责人系统 | 辅助模块 | 实现说明 | 验收点 |
|---|---|---|---|---|---|
| 推荐规则定义 | `RecommendationRuleData` Resource | `DataRepository` | `PoliticalSystem` | 作为静态推荐规则载入，供月内写回与月末评估查询 | 可按 ID 稳定查询规则 |
| 反对规则定义 | `OppositionRuleData` Resource | `DataRepository` | `PoliticalSystem` | 作为静态反对规则载入 | 反对规则可与推荐规则并行读取 |
| 派系块定义 | `FactionBlocData` Resource | `FactionSystem` | `DataRepository` | 作为势力内政治块静态定义 | 势力页可读取派系块摘要 |
| 月初来源扩展任务池 | `TaskSystem` | `TimeManager` | `PoliticalSystem` / `DataRepository` | 在既有月初任务池生成上叠加来源类型、请求方与派系偏向 | 候选任务中稳定出现两类来源 |
| 月内支持 / 反对写回 | `PoliticalSystem` | `RelationSystem` | `TaskSystem` / `CharacterSystem` | 监听关系变化、任务进度与行动结果，更新 `PoliticalSupportSnapshot` | 人物摘要中的支持 / 阻力会变化 |
| 候选资格判定 | `CareerSystem` | `PoliticalSystem` | `FactionSystem` | 月末基于官职、功绩、信任、阻断标签筛资格 | 可输出资格通过或不足 |
| 多候选评估 | `AppointmentResolver` | `CareerSystem` | `PoliticalSystem` / `FactionSystem` | 对玩家与 1~2 名 AI 候选进行有限比较 | 可输出排名与败因 |
| 任命原因分解 | `AppointmentResolver` | `PoliticalSystem` | `CareerSystem` | 统一生成 `PoliticalReasonLine` 列表并写入月报 | 月报可展示成功 / 失败原因 |
| 官职权限与后果变化 | `CareerSystem` | `CharacterSystem` | `MainHUD` / `TaskSystem` | 升官或落选后刷新权限标签、候选资格与下月政治机会 | 下月行为与反馈出现差异 |
| 势力政治总览 | `FactionPanel` | UI 层 | `FactionSystem` / `PoliticalSystem` | 只读势力、派系块与玩家位置摘要 | 面板可读但不承担计算 |
| 月末政治报告 | `MonthReportPanel` | UI 层 | `CareerSystem` / `PoliticalSystem` | 读取 `MonthlyEvaluationResult` 扩展字段 | 报告先结论后原因 |

---

## 5. 模块职责边界

| 系统 | 只做什么 | 不做什么 |
|---|---|---|
| `TimeManager` | 管月初、月末时点与广播 | 不做政治计算 |
| `TaskSystem` | 管任务池生成、主任务状态与任务结果 | 不直接决定任命结果 |
| `RelationSystem` | 管人物关系变化与关系事件写回 | 不直接输出月报解释 |
| `CharacterSystem` | 管功绩、名望、信任、权限标签写入 | 不做候选竞争排序 |
| `PoliticalSystem` | 聚合推荐、反对、派系态度与原因行 | 不直接改官职 |
| `FactionSystem` | 提供势力结构、派系块与倾向查询 | 不接管人物页或月报 UI |
| `CareerSystem` | 管资格判定、官职状态与权限变化 | 不处理任务月内推进 |
| `AppointmentResolver` | 输出候选评估、竞争结果与任命结论 | 不负责持久化静态定义 |
| `DataRepository` | 统一提供 Resource 查询入口 | 不做业务结算 |
| `EventManager` | 只负责事件广播与 UI 刷新通知 | 不做政治演算 |

---

## 6. 数据定义 → Resource / 运行时状态映射表

| 对象 | 类型 | 存储位置 | 主要读取方 | 主要写入方 | 存档是否保存 |
|---|---|---|---|---|---|
| `RecommendationRuleData` | 静态定义 Resource | `res://data/politics/recommendations/` | `PoliticalSystem` / `AppointmentResolver` | 无运行时写入 | 否 |
| `OppositionRuleData` | 静态定义 Resource | `res://data/politics/oppositions/` | `PoliticalSystem` / `AppointmentResolver` | 无运行时写入 | 否 |
| `FactionBlocData` | 静态定义 Resource | `res://data/factions/blocs/` | `FactionSystem` / UI | 无运行时写入 | 否 |
| 扩展后的 `TaskTemplateData` | 静态定义 Resource | `res://data/tasks/` | `TaskSystem` / UI | 无运行时写入 | 否 |
| 扩展后的 `TaskPoolRuleData` | 静态定义 Resource | `res://data/task_rules/` | `TaskSystem` | 无运行时写入 | 否 |
| `PoliticalSupportSnapshot` | 运行时状态 | Save JSON / Runtime State | `PoliticalSystem` / UI / `AppointmentResolver` | `PoliticalSystem` | 是 |
| `AppointmentCandidateEvaluation` | 运行时结果对象 | Runtime State / Save JSON | `CareerSystem` / UI | `AppointmentResolver` | 是 |
| `PoliticalReasonLine` | 运行时子结构 | Snapshot / Evaluation / MonthlyEvaluationResult 内部 | UI / `PoliticalSystem` | `PoliticalSystem` / `AppointmentResolver` | 是 |
| 扩展后的 `PlayerCareerState` | 运行时状态 | Save JSON / Runtime State | `CareerSystem` / UI | `CareerSystem` / `CharacterSystem` | 是 |
| 扩展后的 `MonthlyEvaluationResult` | 运行时结果对象 | Runtime State / Save JSON | `MonthReportPanel` / `MainHUD` | `TaskSystem` + `PoliticalSystem` + `CareerSystem` | 是 |

### 6.1 核心规则
1. 推荐、反对、派系块规则全部进 Resource，不进存档。
2. 支持快照、候选评估与原因行全部属于运行时状态或月报结果。
3. `MonthlyEvaluationResult` 继续作为月报唯一读取入口，不新增平行月报结构。

---

## 7. Resource / 运行时状态分层原则

### 7.1 Resource 层
用于描述“这个世界有哪些政治来源与倾向规则”。

包括：
- `RecommendationRuleData`
- `OppositionRuleData`
- `FactionBlocData`
- 扩展后的任务与官职 Resource

### 7.2 运行时状态层
用于描述“本月玩家当前政治处境如何”。

包括：
- `PoliticalSupportSnapshot`
- 扩展后的 `PlayerCareerState`
- 当月候选评估缓存

### 7.3 月末结果层
用于描述“本月结算后玩家得到什么政治结果、为什么、下月怎么办”。

包括：
- `AppointmentCandidateEvaluation`
- 扩展后的 `MonthlyEvaluationResult`
- `PoliticalReasonLine` 列表

---

## 8. UI 面板读取边界

| UI 面板 | 可读取数据 | 可触发动作 | 不应承担的职责 |
|---|---|---|---|
| `TaskSelectPanel` | 候选任务卡、来源类型、请求方、来源摘要 | 选择 1 个主任务 | 不负责计算来源权重或推荐链 |
| `MainHUD` 政治摘要区 | 当前支持快照、主要推荐人、主要阻力、资格提示 | 打开人物页 / 势力页 / 月报 | 不直接写入支持值 |
| `CharacterPanel` | `PlayerCareerState` + `PoliticalSupportSnapshot` | 查看政治处境与权限摘要 | 不负责生成资格判定 |
| `FactionPanel` | 势力高层、派系块、玩家所在位置、机会摘要 | 只读浏览 | 不负责改变派系态度 |
| `MonthReportPanel` | `MonthlyEvaluationResult` 扩展字段、原因行、下月建议 | 阅读结果、确认关闭 | 不重新计算任命结论 |
| `PromotionPopup` 或任命结果子面板 | 任命结论、官职变化、后果摘要 | 确认继续 | 不修改 `PlayerCareerState` |

### 8.1 UI 读取边界原则
1. UI 只读 Resource、运行时状态与月报结果。
2. UI 不直接写支持分、反对分、派系倾向或候选排名。
3. 所有原因文本均来自 `PoliticalReasonLine`，不在面板脚本里现场拼规则解释。

---

## 9. 月度流程节点与时序映射

## 9.1 时序总览

```text
进入新月
→ TimeManager 发出 month_started
→ TaskSystem 按来源规则生成候选任务
→ TaskSelectPanel 打开并展示来源摘要
→ 玩家选择主任务
→ 月内行动推进任务与关系变化
→ PoliticalSystem 累积支持 / 反对 / 派系态度变化
→ TimeManager 发出 month_ended
→ TaskSystem 结算任务结果
→ CharacterSystem 写入功绩 / 名望 / 信任
→ PoliticalSystem 生成本月 PoliticalSupportSnapshot
→ CareerSystem 判定资格层
→ AppointmentResolver 执行空缺 / 竞争 / 任命判定
→ 生成 AppointmentCandidateEvaluation 与原因行
→ CareerSystem 写回官职变化与权限后果
→ 汇总 MonthlyEvaluationResult
→ MonthReportPanel 展示
→ 清理月度临时状态，保留可复盘结果
```

## 9.2 流程节点映射表

| 流程节点 | 触发时机 | 调用系统 | 主要输入 | 主要输出 |
|---|---|---|---|---|
| 生成来源扩展任务池 | 月初 | `TaskSystem` | `TaskPoolRuleData`、任务模板来源字段、官职层级 | 候选任务列表 |
| 锁定当月主任务 | 月初界面确认时 | `TaskSystem` | 选中任务模板 ID | `MonthlyTaskState` |
| 更新政治支持快照 | 月内行动 / 关系变化 / 月末前 | `PoliticalSystem` | `ActionResult`、关系变化、任务状态 | `PoliticalSupportSnapshot` |
| 结算任务结果 | 月末 | `TaskSystem` | 当前任务进度、成功条件 | 任务结果与奖励快照 |
| 写入角色收益 | 月末 | `CharacterSystem` | 任务结算结果 | 更新后的 merit / fame / trust |
| 判定资格层 | 月末 | `CareerSystem` | 当前官职、功绩、信任、阻断标签 | 资格结果 |
| 候选比较 | 月末 | `AppointmentResolver` | 支持快照、空缺、AI 候选样本 | 候选评估结果 |
| 写回官职与后果 | 月末 | `CareerSystem` | 任命结论、旧官职、权限规则 | 新官职、权限标签、后果标签 |
| 生成月报 | 月末 | `TaskSystem` + `PoliticalSystem` + `CareerSystem` | 数值变化、评估结果、原因行 | 扩展后的 `MonthlyEvaluationResult` |

---

## 10. 事件总线建议

| 事件名 | 发送方 | 监听方 | 用途 |
|---|---|---|---|
| `month_started` | `TimeManager` | `TaskSystem` / UI | 新月开始，准备候选任务 |
| `political_task_candidates_ready` | `TaskSystem` | `TaskSelectPanel` | 候选任务可展示 |
| `task_selected` | `TaskSelectPanel` | `TaskSystem` | 锁定当月主任务 |
| `relation_or_task_signal_changed` | `RelationSystem` / `TaskSystem` | `PoliticalSystem` | 触发支持 / 反对快照更新 |
| `political_snapshot_updated` | `PoliticalSystem` | `MainHUD` / `CharacterPanel` | 刷新政治摘要 |
| `month_ended` | `TimeManager` | `TaskSystem` / `CareerSystem` / `PoliticalSystem` | 进入统一结算 |
| `candidate_evaluation_ready` | `AppointmentResolver` | `CareerSystem` / `MonthReportPanel` | 候选评估完成 |
| `monthly_political_evaluation_ready` | `CareerSystem` | `MonthReportPanel` / `MainHUD` | 月报可展示 |
| `office_changed` | `CareerSystem` | `MainHUD` / `CharacterPanel` / `TaskSystem` | 刷新官职、权限与任务可见性 |

---

## 11. 目录与脚本落位建议

## 11.1 数据目录建议

```text
res://data/
  politics/
    recommendations/
      rec_superior_task_excellent.tres
      rec_relation_trust_high.tres
    oppositions/
      opp_task_failure_visible.tres
      opp_incumbent_resistance.tres
  factions/
    blocs/
      bloc_yingchuan_scholars.tres
      bloc_campaign_hawks.tres
  tasks/
    ...Phase 2.1 既有任务模板，补 Phase 3 来源字段
  task_rules/
    ...Phase 2.1 既有规则，补来源混合字段
```

## 11.2 脚本落位建议

```text
res://scripts/autoload/
  game_root.gd
  time_manager.gd
  data_repository.gd
  event_manager.gd

res://scripts/systems/
  task_system.gd
  relation_system.gd
  character_system.gd
  career_system.gd
  faction_system.gd
  political_system.gd
  appointment_resolver.gd

res://scripts/ui/
  task_select_panel.gd
  character_panel.gd
  faction_panel.gd
  month_report_panel.gd
  promotion_popup.gd
```

## 11.3 状态对象建议

```text
res://scripts/state/
  political_support_snapshot.gd
  appointment_candidate_evaluation.gd
  political_reason_line.gd
```

若原型阶段仍使用 Dictionary，实现上可暂缓建类，但字段名与层次必须和字段设计稿一致。

---

## 12. 开发顺序建议

### P0：必须先打通
1. `RecommendationRuleData` / `OppositionRuleData` / `FactionBlocData` 查询能力。
2. `TaskTemplateData` / `TaskPoolRuleData` 的来源扩展字段接入。
3. `PoliticalSupportSnapshot` 的月内写回与月末固化。
4. 候选资格、空缺与最小竞争判定。
5. `MonthlyEvaluationResult` 扩展字段与月报读取。

### P1：建议补齐
1. `FactionPanel` 势力政治摘要。
2. `CharacterPanel` 政治支持摘要。
3. 政治失败后果与下月建议。

### P2：为下一阶段预留
1. 更深门阀与婚姻修正接入口。
2. 更复杂派系议程系统。
3. 多职位并发竞争。

---

## 13. Phase 3 做 / 不做清单

| 项目 | 是否在 Phase 3 实现 | 说明 |
|---|---|---|
| 推荐规则正式合同 | 做 | 03-01 的基础 |
| 反对规则正式合同 | 做 | 03-01 的基础 |
| 派系块定义 | 做 | 以轻量政治块实现 |
| 两类任务来源 | 做 | 势力指派 + 人际/士族请求 |
| 政治支持快照 | 做 | 供人物页与月报共读 |
| 候选资格与有限竞争 | 做 | 玩家与 1~2 名 AI 候选 |
| 月末任命原因分解 | 做 | 支持 explainable-politics |
| 官职权限与政治后果差异 | 做 | 让升迁真正有手感 |
| 势力政治总览页 | 做 | 只做摘要面板 |
| 君主全局人事控制台 | 不做 | 违反单角色边界 |
| 复杂派系议程投票 | 不做 | 留给后续阶段 |
| 全国级政治地图 | 不做 | 超出原型范围 |
| 家族婚姻深度联动 | 不做 | 留给 Phase 4 |

---

## 14. 验收映射表

| 设计成功标准 | Godot 验收点 | 负责模块 |
|---|---|---|
| 月初出现至少两类任务来源 | `TaskSelectPanel` 展示来源标签与请求方 | `TaskSystem` / UI |
| 玩家能看到主要推荐人与阻力来源 | `MainHUD` 或 `CharacterPanel` 展示政治摘要 | `PoliticalSystem` / UI |
| 派系支持会影响任命结果 | 同月不同派系态度导致不同评估输出 | `FactionSystem` / `AppointmentResolver` |
| 任命失败可分解为不同失败类型 | `MonthReportPanel` 显示资格不足 / 推荐不足 / 无空缺 / 竞争落败等 | `CareerSystem` / `AppointmentResolver` |
| 官职变化影响权限与信息可见性 | 升官后 HUD 或面板开放更多摘要或任务入口 | `CareerSystem` / UI |
| 月报、人物页、势力页共用同一解释数据 | 三处面板读取相同原因行结构 | `PoliticalSystem` / UI |
| 整体流程仍保持单角色月度循环 | 无新增全局控制面板，仍以月初选任务到月末结算推进 | `GameRoot` / `TimeManager` |

---

## 15. 与 Phase 2.1 的衔接方式

### 15.1 必须复用的基础能力
1. 月初候选任务选择流程。
2. 月内任务推进与行动结果写回。
3. 月末任务结算与官职变化主轴。
4. `MonthlyEvaluationResult` 作为月报主入口。

### 15.2 Phase 3 不应破坏的内容
1. 仍然每月只接 1 个主任务。
2. 不把政治支持演算拆成另一个独立回合系统。
3. 不让 UI 变成逻辑主导层。

---

## 16. 本章结论
《Phase 3 Godot 实现映射表 v1》用于把 Phase 3 的政治设计稿转化为可执行的 Godot 落地方案。

它的核心价值不在于新增概念，而在于统一以下四件事：

1. **模块职责**：政治逻辑、任命逻辑、UI 读取边界清晰。
2. **数据分层**：Resource、运行时快照与月报结果不混写。
3. **月度时序**：月初来源扩展、月内支持变化、月末候选评估与任命解释接到同一骨架上。
4. **验收路径**：每个成功标准都能在具体模块与具体界面上验证。

只要开发阶段严格以本表为桥接层，Phase 3 就能在不破坏 Phase 2.1 月度闭环的前提下，稳定完成“任务来源扩展—推荐 / 反对累积—派系支持—任命解释—权限后果反馈”的最小可验证原型。
