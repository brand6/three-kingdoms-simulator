# Phase 3 政治与任命数据字段设计 v1

#项目设计 #数据结构 #Phase3 #政治系统 #任命系统 #派系系统

> 文档定位：本文件用于为 Phase 3《仕途、势力与可解释政治》冻结一版政治扩展字段合同，供 Godot Resource、运行时状态、月末政治结算与 UI 解释层实现时参考。重点是统一推荐、反对、派系支持、候选评估、原因行与月末政治结果的数据落点，避免后续继续依赖临时 Dictionary。

---

## 1. 设计目标

### 1.1 本文档解决的问题
- Phase 3 需要新增哪些政治数据对象。
- 推荐、反对、派系支持、候选评估与原因解释分别落在哪些字段上。
- 哪些字段属于静态定义，哪些字段属于运行时快照与月末结果。
- 月任务扩展来源与月末政治结果需要新增哪些正式字段。

### 1.2 设计原则
1. 直接复用 Phase 2.1 的月度闭环，不另起一套平行政治状态树。
2. 静态定义、运行时快照、月末结果三层分离。
3. 所有政治解释统一落到 `PoliticalReasonLine`，不允许各 UI 面板各自拼文案结构。
4. 推荐、反对与派系支持优先复用现有关系、信任、功绩、官职与任务结果输入。
5. 字段优先服务原型可解释性，而不是一次性追求复杂政治仿真。

---

## 2. 数据对象总览

Phase 3 建议新增或强化以下对象：

### 静态定义对象
- `RecommendationRuleData`：推荐规则定义。
- `OppositionRuleData`：反对规则定义。
- `FactionBlocData`：派系块定义。

### 运行时状态对象
- `PoliticalSupportSnapshot`：角色当月政治支持快照。
- `AppointmentCandidateEvaluation`：候选评估结果。
- `PoliticalReasonLine`：统一原因行对象。

### 需要补字段的既有对象
- `TaskTemplateData`
- `TaskPoolRuleData`
- `OfficeData`
- `PlayerCareerState`
- `MonthlyEvaluationResult`

---

## 3. 静态定义与运行时状态分层

## 3.1 静态定义
静态定义建议存放在 `res://data/.../*.tres`，用于描述“有哪些政治规则、哪些派系块、哪些任务来源标签与官职资格约束存在”。

特点：
- 可在 Inspector 中维护。
- 可被多个系统重复查询。
- 不在运行时直接改写。

## 3.2 运行时快照
运行时快照建议写入月度运行时状态与存档 JSON，用于描述“本月谁在支持我、谁在阻挠我、我是否进入候选、落选原因是什么”。

特点：
- 每月刷新。
- 依赖当月任务、关系与官职状态。
- 直接供人物页、势力页与月报读取。

## 3.3 月末结果
月末结果用于把本月政治过程压缩成可复盘的结论对象。

特点：
- 面向 `MonthReportPanel` 与存档。
- 保留核心原因、关键支持者、关键阻力与下月建议。
- 不重复保存完整静态规则全文。

---

## 4. RecommendationRuleData（推荐规则定义）

## 4.1 作用
描述在什么条件下、由谁、以何种力度对玩家形成推荐支持，并统一推荐原因与排序规则。

## 4.2 最小字段
| 字段 | 类型 | 必须 | 说明 |
|------|------|------|------|
| id | string | 是 | 规则唯一 ID |
| name | string | 是 | 规则名称 |
| source_type | string | 是 | 来源类型，如 superior / relation / clan / bloc |
| trigger_phase | string | 是 | 触发阶段，如 month_progress / month_end / appointment |
| target_scope | string | 是 | 作用目标，如 office_candidate / task_access / monthly_support |
| condition_tags | Array[string] | 是 | 触发条件标签 |
| required_task_source_tags | Array[string] | 否 | 任务来源要求 |
| required_task_result_tags | Array[string] | 否 | 任务结果要求 |
| required_relation_tags | Array[string] | 否 | 关系标签要求 |
| min_relation_value | int | 否 | 最低关系值 |
| min_trust | int | 否 | 最低信任值 |
| min_merit | int | 否 | 最低功绩值 |
| office_tier_min | int | 否 | 最低官职层级 |
| office_tier_max | int | 否 | 最高官职层级 |
| supported_bloc_ids | Array[string] | 否 | 仅在指定派系块支持时生效 |
| blocked_bloc_ids | Array[string] | 否 | 遇到这些派系块时失效 |
| support_delta | int | 是 | 支持增量 |
| reason_text_key | string | 是 | 原因文案键 |
| reason_summary_template | string | 否 | 可直接用于原型 UI 的摘要文案模板 |
| priority | int | 是 | 冲突时优先级 |
| sort_order | int | 是 | 同层排序值 |
| is_phase3_available | bool | 是 | 是否用于 Phase 3 |

## 4.3 推荐规则推荐范围
- 优先覆盖上级赏识、关系举荐、任务优秀完成、士族同门加成、派系目标契合五类来源。
- 不在 Phase 3 首版中引入高度隐蔽的历史宿怨网与长期朝廷履历演算。

---

## 5. OppositionRuleData（反对规则定义）

## 5.1 作用
描述在什么条件下、由谁、以何种力度对玩家形成反对、保留或压制，并统一反对原因与阻断标签。

## 5.2 最小字段
| 字段 | 类型 | 必须 | 说明 |
|------|------|------|------|
| id | string | 是 | 规则唯一 ID |
| name | string | 是 | 规则名称 |
| source_type | string | 是 | 来源类型，如 rival / bloc / incumbent / superior |
| trigger_phase | string | 是 | 触发阶段 |
| target_scope | string | 是 | 作用目标 |
| condition_tags | Array[string] | 是 | 触发条件标签 |
| required_task_fail_tags | Array[string] | 否 | 失败相关标签 |
| required_competition_tags | Array[string] | 否 | 候选竞争标签 |
| relation_below_value | int | 否 | 关系低于该值时触发 |
| trust_below_value | int | 否 | 信任低于该值时触发 |
| office_tier_min | int | 否 | 最低官职层级 |
| office_tier_max | int | 否 | 最高官职层级 |
| opposing_bloc_ids | Array[string] | 否 | 指定派系块产生额外反对 |
| blocker_tags | Array[string] | 否 | 命中后写入候选阻断标签 |
| opposition_delta | int | 是 | 反对增量 |
| reason_text_key | string | 是 | 原因文案键 |
| reason_summary_template | string | 否 | 原型摘要文案模板 |
| priority | int | 是 | 冲突时优先级 |
| sort_order | int | 是 | 同层排序值 |
| is_phase3_available | bool | 是 | 是否用于 Phase 3 |

## 5.3 反对规则推荐范围
- 优先覆盖旧吏留任、竞争者压制、关系恶化、任务失败、门第不合、派系保留六类来源。
- Phase 3 首版的反对结果以“保留 / 反对 / 压制”三档表达为主，不扩到复杂清洗与政治清算。

---

## 6. FactionBlocData（派系块定义）

## 6.1 作用
描述势力内部的主要政治块、核心人物、立场摘要与任命偏向，是派系支持的静态来源。

## 6.2 最小字段
| 字段 | 类型 | 必须 | 说明 |
|------|------|------|------|
| id | string | 是 | 派系块 ID |
| faction_id | string | 是 | 所属势力 ID |
| name | string | 是 | 派系块名称 |
| bloc_type | string | 是 | 派系类型，如 scholar / military / local / court |
| summary | string | 是 | 派系摘要 |
| visible_label | string | 否 | UI 展示标签 |
| core_character_ids | Array[string] | 是 | 核心人物列表 |
| influence_weight | int | 是 | 影响权重 |
| agenda_tags | Array[string] | 是 | 当前议题或偏好标签 |
| preferred_task_source_tags | Array[string] | 否 | 倾向支持的任务来源 |
| preferred_task_tags | Array[string] | 否 | 倾向支持的任务类型 |
| supported_office_tags | Array[string] | 否 | 倾向支持的职位标签 |
| opposed_office_tags | Array[string] | 否 | 倾向反对的职位标签 |
| affinity_clan_ids | Array[string] | 否 | 天然亲近的士族 |
| friction_clan_ids | Array[string] | 否 | 天然摩擦的士族 |
| default_attitude | string | 是 | 初始态度，如 support / reserve / oppose |
| reason_text_key | string | 否 | 默认原因文案键 |
| sort_order | int | 是 | 展示排序 |
| is_phase3_available | bool | 是 | 是否用于 Phase 3 |

## 6.3 派系块表达建议
- 以“派系块”而非高度拟真组织树实现。
- UI 优先展示名称、核心人物、立场摘要与对玩家态度，不展示完整后台分数表。

---

## 7. TaskTemplateData 扩展字段（任务来源扩展）

## 7.1 作用
为 Phase 2.1 的任务模板补齐“这件事是谁递到你面前”的政治来源字段。

## 7.2 建议新增字段
| 字段 | 类型 | 必须 | 说明 |
|------|------|------|------|
| task_source_type | string | 是 | 任务来源类型，如 faction_order / relation_request |
| request_character_id | string | 否 | 请求方角色 ID |
| related_bloc_id | string | 否 | 关联派系块 |
| political_reward_tags | Array[string] | 否 | 完成后可能增加支持的标签 |
| political_risk_tags | Array[string] | 否 | 失败后可能增加阻力的标签 |
| recommendation_hint_tags | Array[string] | 否 | 易触发推荐链的提示标签 |
| opposition_hint_tags | Array[string] | 否 | 易触发反对链的提示标签 |
| source_summary | string | 否 | 月初任务卡摘要文本 |
| source_priority | int | 否 | 同月来源优先级 |

## 7.3 来源类型建议冻结
- `faction_order`：势力指派。
- `relation_request`：人际 / 士族请求。

Phase 3 首版先冻结为上述两类，其他来源仅预留标签，不进入正式样本范围。

---

## 8. TaskPoolRuleData 扩展字段（任务来源筛选）

## 8.1 作用
控制哪些政治来源会在月初进入候选池，并保证来源分布稳定可解释。

## 8.2 建议新增字段
| 字段 | 类型 | 必须 | 说明 |
|------|------|------|------|
| required_source_types | Array[string] | 否 | 必须出现的来源类型 |
| source_weight_rules | Dictionary | 否 | 不同来源的权重 |
| source_mix_policy | string | 否 | 来源混合策略，如 ensure_diversity |
| related_bloc_bias | Dictionary | 否 | 派系块对来源的权重修正 |
| fallback_source_types | Array[string] | 否 | 候选不足时的保底来源 |

---

## 9. OfficeData 扩展字段（政治资格与权限）

## 9.1 作用
让官职开始正式影响推荐资格、任命竞争与信息可见性。

## 9.2 建议新增字段
| 字段 | 类型 | 必须 | 说明 |
|------|------|------|------|
| office_tags | Array[string] | 否 | 官职标签 |
| visible_political_panels | Array[string] | 否 | 可见政治面板 |
| recommendation_power | int | 否 | 对他人产生推荐影响的能力 |
| candidate_office_tags | Array[string] | 否 | 可竞争的目标职位标签 |
| political_risk_level | int | 否 | 失败时政治后果等级 |

---

## 10. PoliticalSupportSnapshot（政治支持快照）

## 10.1 作用
记录角色当前月度政治支持、阻力、派系态度与候选入口，是人物页与月末结算的共同读取对象。

## 10.2 最小字段
| 字段 | 类型 | 必须 | 说明 |
|------|------|------|------|
| month_key | string | 是 | 月份键 |
| character_id | string | 是 | 角色 ID |
| faction_id | string | 是 | 所属势力 |
| primary_recommender_ids | Array[string] | 否 | 主要推荐人 |
| primary_opposer_ids | Array[string] | 否 | 主要反对者 |
| bloc_attitudes | Array[Dictionary] | 是 | 派系块态度摘要 |
| support_score_total | int | 是 | 总支持值 |
| opposition_score_total | int | 是 | 总反对值 |
| recommendation_lines | Array[Dictionary] | 是 | 推荐原因行列表 |
| opposition_lines | Array[Dictionary] | 是 | 反对原因行列表 |
| qualification_tags | Array[string] | 否 | 当前资格标签 |
| blocker_tags | Array[string] | 否 | 当前阻断标签 |
| candidate_office_ids | Array[string] | 否 | 当前可争职位 |
| opportunity_tags | Array[string] | 否 | 下月机会标签 |
| updated_at_month_end | bool | 是 | 是否已写回本月月末 |

## 10.3 bloc_attitudes 建议结构
```text
bloc_attitudes = [
  {
    bloc_id,
    attitude,
    support_delta,
    summary_text
  }
]
```

---

## 11. AppointmentCandidateEvaluation（候选评估结果）

## 11.1 作用
统一保存玩家或 AI 候选人在某一职位竞争中的评估结论，避免月末报告重新拼装资格与竞争信息。

## 11.2 最小字段
| 字段 | 类型 | 必须 | 说明 |
|------|------|------|------|
| month_key | string | 是 | 月份键 |
| office_id | string | 是 | 目标职位 ID |
| candidate_character_id | string | 是 | 候选角色 ID |
| candidate_role_type | string | 是 | player / ai |
| evaluation_status | string | 是 | eligible / blocked / reserve / appointed / rejected |
| qualification_passed | bool | 是 | 是否过资格层 |
| vacancy_available | bool | 是 | 是否存在空缺 |
| recommendation_score | int | 是 | 推荐分 |
| opposition_score | int | 是 | 反对分 |
| bloc_support_score | int | 是 | 派系支持修正 |
| merit_score | int | 是 | 功绩修正 |
| trust_score | int | 是 | 信任修正 |
| competition_rank | int | 否 | 在候选中的排名 |
| competition_note | string | 否 | 竞争摘要 |
| blocker_tags | Array[string] | 否 | 命中的阻断标签 |
| reason_lines | Array[Dictionary] | 是 | 原因行列表 |
| final_decision | string | 是 | appointed / lost_to_rival / no_vacancy / not_nominated |
| next_goal_hint | string | 否 | 下月改进建议 |

## 11.3 失败类型建议冻结
- `not_qualified`：资格不足。
- `not_nominated`：推荐不足，未正式提名。
- `blocked_by_opposition`：遭遇反对或压制。
- `no_vacancy`：暂无空缺。
- `lost_to_rival`：竞争落败。

---

## 12. PoliticalReasonLine（统一原因行）

## 12.1 作用
为推荐、反对、派系态度、候选评估与月末报告提供统一解释单元。

## 12.2 最小字段
| 字段 | 类型 | 必须 | 说明 |
|------|------|------|------|
| id | string | 是 | 原因行 ID |
| month_key | string | 否 | 月份键 |
| reason_type | string | 是 | recommendation / opposition / bloc / qualification / competition |
| stage | string | 是 | month_progress / month_end / appointment |
| source_type | string | 是 | source_character / source_bloc / system_rule / task |
| source_character_id | string | 否 | 来源人物 |
| source_bloc_id | string | 否 | 来源派系块 |
| source_rule_id | string | 否 | 来源规则 |
| related_task_id | string | 否 | 相关任务 |
| related_office_id | string | 否 | 相关职位 |
| direction | string | 是 | positive / negative / neutral |
| weight_tier | string | 是 | minor / normal / major |
| numeric_delta | int | 否 | 对支持或反对的数值影响 |
| summary_text | string | 是 | 摘要文本 |
| detail_text | string | 否 | 详细解释文本 |
| ui_group | string | 否 | UI 分组，如 support / blocker / advice |
| sort_order | int | 是 | 展示顺序 |
| is_major | bool | 是 | 是否为主要原因 |

## 12.3 原因行约束
1. 月报、人物页、势力页统一消费该结构。
2. 不在 UI 层现场生成新的原因对象。
3. 一条原因行应只表达一个主要因果，不混合多段逻辑。

---

## 13. PlayerCareerState 扩展字段

为承接 Phase 3，建议在 `PlayerCareerState` 中新增：

| 字段 | 类型 | 必须 | 说明 |
|------|------|------|------|
| political_support_snapshot | Dictionary | 否 | 当前政治支持快照引用或内嵌结构 |
| last_candidate_evaluation | Dictionary | 否 | 最近一次候选评估结果 |
| current_permission_tags | Array[string] | 否 | 当前官职带来的权限标签 |
| recent_political_result | string | 否 | 最近政治结果摘要 |

---

## 14. MonthlyEvaluationResult 扩展字段（月末政治结果）

## 14.1 作用
把 Phase 2.1 的月末任务结果升级为带政治解释的月报结果对象。

## 14.2 建议新增字段
| 字段 | 类型 | 必须 | 说明 |
|------|------|------|------|
| task_source_type | string | 否 | 本月任务来源类型 |
| request_character_id | string | 否 | 请求方 / 发布方 |
| political_support_snapshot | Dictionary | 否 | 月末支持快照 |
| candidate_evaluation_results | Array[Dictionary] | 否 | 相关职位的候选评估列表 |
| appointment_result | string | 否 | 任命结果 |
| primary_support_lines | Array[Dictionary] | 否 | 主要支持原因 |
| primary_blocker_lines | Array[Dictionary] | 否 | 主要阻力原因 |
| missed_opportunity_note | string | 否 | 错失机会说明 |
| new_permission_tags | Array[string] | 否 | 因官职变化新增的权限 |
| political_consequence_tags | Array[string] | 否 | 政治后果标签 |
| next_month_political_hint | string | 否 | 下月政治建议 |

## 14.3 月末政治结果推荐输出
- 先给任务结果与任命结论。
- 再给主要支持原因与主要阻力原因。
- 再给错失机会或下月建议。

---

## 15. 推荐 ID 与标签规范

### 15.1 推荐规则 ID
- `rec_superior_task_excellent`
- `rec_relation_trust_high`
- `rec_clan_network_match`
- `rec_bloc_goal_alignment`

### 15.2 反对规则 ID
- `opp_task_failure_visible`
- `opp_incumbent_resistance`
- `opp_rival_candidate_pressure`
- `opp_bloc_background_mismatch`

### 15.3 派系块 ID
- `bloc_yingchuan_scholars`
- `bloc_campaign_hawks`
- `bloc_local_administrators`

### 15.4 来源标签
- `task_source:faction_order`
- `task_source:relation_request`
- `politics:support_gain`
- `politics:opposition_risk`

---

## 16. 最小配表清单

为跑通 Phase 3 文档合同，至少应准备：

### 推荐规则表
- 4 条推荐规则定义。

### 反对规则表
- 4 条反对规则定义。

### 派系块表
- 2~3 条派系块定义。

### 扩展任务来源样本
- 至少 2 类任务来源。

### 月末政治结果样本
- 至少 1 条成功样本与 1 条失败样本。

---

## 17. 实现建议

### 17.1 Godot 侧建议
- `RecommendationRuleData`、`OppositionRuleData`、`FactionBlocData` 使用自定义 `Resource`。
- `PoliticalSupportSnapshot`、`AppointmentCandidateEvaluation`、`PoliticalReasonLine` 作为运行时状态类或结构化 Dictionary。
- `MonthlyEvaluationResult` 继续作为月报读取主入口，只扩字段不另起新月报对象。

### 17.2 UI 侧建议
- 人物页读取 `PoliticalSupportSnapshot` 中的推荐、反对与资格摘要。
- 势力页读取 `FactionBlocData` 与快照中的派系态度。
- 月报页读取 `MonthlyEvaluationResult` 扩展字段，不自行计算推荐或竞争结果。

---

## 18. 本章结论
Phase 3 的字段设计重点不是把政治系统做成隐藏分数黑箱，而是把“谁在推我、谁在压我、我为何入选或落选”稳定建模。

只要 `RecommendationRuleData`、`OppositionRuleData`、`FactionBlocData`、`PoliticalSupportSnapshot`、`AppointmentCandidateEvaluation`、`PoliticalReasonLine` 与扩展后的月任务来源、月末结果字段被正式冻结，Phase 3 的实现与 UI 就能在同一套数据合同上推进，而不再继续猜字段。
