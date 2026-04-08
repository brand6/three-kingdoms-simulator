# Phase 3 最小数据录入清单 v1

#项目设计 #数据录入 #Phase3 #Godot #原型数据 #政治系统

> 文档定位：本文件用于把 Phase 3 的政治字段稿、实现映射表与实际 Godot 数据录入工作连接起来，明确**先补什么、至少补多少、按什么顺序补、补完如何验收**。它不是字段定义文档，也不是完整史实样本表，而是面向开发 AI 与数据录入阶段的执行清单。

---

## 1. 文档目标

### 1.1 本文档解决的问题
1. Phase 3 为跑通最小 explainable-politics 闭环，哪些数据对象必须先录；
2. 每类对象至少要有多少条，才足以支撑单角色视角下的推荐、反对、派系支持与任命解释；
3. 数据录入应该按什么顺序推进，避免先把世界样本铺大、却缺关键政治规则；
4. 每类数据录完后，如何快速验证它已能被 Godot 原型消费并产出可解释月报。

### 1.2 本文档不负责的内容
- 不重新定义字段结构；
- 不替代《Phase 3 政治与任命数据字段设计 v1》；
- 不直接提供全国、全势力、全官员录表；
- 不把 Phase 3 扩成完整君主人事系统或全国政治数据库。

### 1.3 关联文档
建议与以下文档配合使用：

1. `design/总纲/Phase 3 仕途、势力与可解释政治 详细规划 v1.md`
2. `design/数据/Phase 3 政治与任命数据字段设计 v1.md`
3. `design/原型与实现/Phase 3 Godot 实现映射表 v1.md`
4. `design/数据/Phase 2.1 最小数据录入清单 v1.md`
5. `design/剧情与样本/190 剧本原型人物-势力样本表 v1.md`
6. `design/数据/Godot 数据结构草案 v1.md`

---

## 2. Phase 3 最小可验证闭环的录入目标

本阶段的数据录入不是为了把 190 剧本扩成完整政治数据库，而是为了稳定跑通以下闭环：

```text
荀彧开局
→ 月初出现两类来源的任务候选
→ 玩家选择 1 个主任务
→ 月内推进任务并累积推荐 / 反对 / 派系态度变化
→ 月末生成 PoliticalSupportSnapshot
→ 进入 AppointmentCandidateEvaluation 候选资格与竞争判定
→ MonthlyEvaluationResult 输出成功 / 失败政治结果与原因
→ 下月任务来源、机会与阻力刷新
```

因此，所有数据录入都应服务于上面这条链，而不是追求内容全面。

### 2.1 范围约束
1. 只围绕荀彧在曹操势力内部的单角色仕途闭环录入。
2. 只需要 1 个主体验样本圈，外加 1 个对照势力与少量竞争样本。
3. 不要求全国城市、全国官职、全国人物、全势力派系一次录齐。
4. 若某条数据不能直接支撑“任务来源解释、支持阻力解释、任命结果解释”，就不应进入首批 P0。

---

## 3. 录入优先级总览

## 3.1 P0：闭环必录对象

| 对象 | 是否必录 | 最小条数 | 作用 |
|---|---|---:|---|
| `ScenarioData` | 是 | 1 | 提供 190 原型剧本入口与默认玩家角色 |
| `FactionData` | 是 | 2–3 | 支撑曹操势力、1 个对照势力与派系块挂接 |
| `CityData` | 是 | 3–5 | 支撑荀彧所在城市、政治任务发生地与任命上下文 |
| `CharacterData` | 是 | 14–22 | 支撑荀彧、曹操、推荐人、反对者、请求方、竞争者 |
| `OfficeData` | 是 | 4 | 支撑官职链、候选资格与职位空缺样本 |
| `TaskTemplateData` | 是 | 4–6 | 支撑两类任务来源与月初候选任务展示 |
| `TaskPoolRuleData` | 是 | 1–2 | 支撑荀彧当前官职下的来源混合任务池 |
| `RecommendationRuleData` | 是 | 4 | 支撑推荐链最小规则骨架 |
| `OppositionRuleData` | 是 | 4 | 支撑反对 / 压制链最小规则骨架 |
| `FactionBlocData` | 是 | 2–3 | 支撑势力内部派系块与派系态度解释 |
| `CharacterSetupPatchData` | 是 | 1 | 锁定荀彧开局状态与可验证政治入口 |
| `RelationData` | 是 | 10–16 | 支撑推荐、反对与请求来源的人际基础 |
| `ClanData` | 是 | 3–5 | 支撑士族请求、同门加成与派系块亲疏 |

## 3.2 P1：为解释稳定性补足

| 对象 | 是否建议录入 | 最小条数 | 作用 |
|---|---|---:|---|
| `FamilyData` | 建议 | 0–3 | 仅在需要更细的门第来源文案时补充 |
| `EventData` | 建议 | 0–2 | 可为月末政治成功 / 失败添加演出事件 |
| `AdditionalTaskTemplateData` | 建议 | 1–2 | 补强第二个月的任务来源差异 |

## 3.3 P2：后续再扩，不进入首批

| 对象 | 是否首批必录 | 最小条数 | 说明 |
|---|---|---:|---|
| 全国级 `FactionBlocData` | 否 | 0 | 不做全国派系录表 |
| 全官职空缺表 | 否 | 0 | 只做荀彧仕途链相关职位 |
| 全国 `RelationData` 网络 | 否 | 0 | 只做关键关系对 |
| 全势力任务来源库 | 否 | 0 | 只做荀彧能接触到的来源样本 |

---

## 4. 总体录入执行表

| 对象 | P级 | 最小条数 | 依赖对象 | 来源文档 | 录入完成定义 |
|---|---|---:|---|---|---|
| `OfficeData` | P0 | 4 | 无 | 字段设计稿 / Phase 2.1 清单 | 4 级官职可按 ID 查询，且目标职位可用于候选评估 |
| `TaskTemplateData` | P0 | 4–6 | `OfficeData`, `CharacterData`, `FactionBlocData` | 字段设计稿 / Phase 3 GDD | 两类来源任务都能显示来源人物与政治摘要 |
| `TaskPoolRuleData` | P0 | 1–2 | `TaskTemplateData`, `OfficeData` | 字段设计稿 / 实现映射表 | 月初可稳定产出 2–3 个不同来源候选任务 |
| `RecommendationRuleData` | P0 | 4 | `TaskTemplateData`, `RelationData`, `OfficeData`, `FactionBlocData` | 字段设计稿 | 月末可产出至少 2 条推荐原因行 |
| `OppositionRuleData` | P0 | 4 | `TaskTemplateData`, `RelationData`, `OfficeData`, `FactionBlocData` | 字段设计稿 | 月末可产出至少 2 条阻力原因行 |
| `FactionBlocData` | P0 | 2–3 | `FactionData`, `CharacterData`, `ClanData` | 字段设计稿 / Phase 3 GDD | 势力页可读取派系块摘要与默认态度 |
| `FactionData` | P0 | 2–3 | `CharacterData`, `CityData` | 样本表 / 数据草案 | 曹操势力与对照势力可查询 |
| `CityData` | P0 | 3–5 | `FactionData`, `CharacterData` | 样本表 / 数据草案 | 任务与任命相关城市可查询 |
| `CharacterData` | P0 | 14–22 | `FactionData`, `CityData`, `OfficeData`, `ClanData` | 样本表 / 数据草案 | 推荐人、反对者、请求方、竞争者全部可查询 |
| `RelationData` | P0 | 10–16 | `CharacterData` | 数据草案 / 关系需要 | 推荐 / 反对规则可读取关键关系值 |
| `ClanData` | P0 | 3–5 | `CharacterData`, `CityData` | 样本表 / 数据草案 | 士族请求与同门加成可落地 |
| `CharacterSetupPatchData` | P0 | 1 | `CharacterData`, `ScenarioData`, `OfficeData`, `FactionData`, `CityData` | 字段设计稿 | 新开局默认玩家角色仍为荀彧，且政治入口有效 |
| `ScenarioData` | P0 | 1 | 全部核心对象 | 数据草案 / 样本表 | 190 原型剧本可装载并包含 Phase 3 必要对象 |

---

## 5. 推荐录入顺序

## 5.1 先录政治规则骨架，再录世界样本

建议严格按以下顺序推进：

1. `OfficeData`（确认可竞争职位链）
2. `TaskTemplateData`（补齐 `task_source_type`、请求方、关联派系）
3. `TaskPoolRuleData`（保证两类来源都会出现）
4. `RecommendationRuleData`
5. `OppositionRuleData`
6. `FactionBlocData`
7. `FactionData`
8. `CityData`
9. `ClanData`
10. `CharacterData`
11. `RelationData`
12. `CharacterSetupPatchData`
13. `ScenarioData`
14. 最后用运行结果核对 `PoliticalSupportSnapshot`、`AppointmentCandidateEvaluation`、`MonthlyEvaluationResult`

### 原因
- Phase 3 首先缺的不是世界规模，而是推荐 / 反对 / 派系 / 来源这些政治骨架；
- 任务来源与规则不先冻结，后录人物与关系时容易反复返工；
- `PoliticalSupportSnapshot`、`AppointmentCandidateEvaluation`、`MonthlyEvaluationResult` 都是运行时产物，应在静态样本齐备后统一验收，而不是先手工假造后再回填世界依赖。

---

## 6. 各对象录入分表

## 6.1 ScenarioData 录入要求

### 最小条数
- 1 条：190 原型剧本

### 必填要点
| 项目 | 最小样例 / 建议值 | 说明 |
|---|---|---|
| `id` | `scenario_190_prototype` | 原型剧本唯一 ID |
| `default_player_character_id` | `char_xun_yu` 或等价命名 | 默认玩家角色必须继续为荀彧 |
| `faction_ids` | 至少包含曹操与 1 个对照势力 | 支撑派系块与竞争样本 |
| `city_ids` | 3–5 个城市 ID | 支撑任务来源与政治场景 |
| `character_ids` | 14–22 个角色 ID | 支撑推荐、反对、请求与竞争 |
| `available_office_ids` | 4 个官职 ID | 支撑候选资格与升迁链 |
| `available_task_template_ids` | 4–6 个任务模板 ID | 支撑两类来源任务池 |
| `available_political_rule_ids` | 推荐 / 反对规则 ID 集合 | 便于 Phase 3 入口校验 |

### 验收点
- 剧本可加载；
- 默认玩家角色显示为荀彧；
- Phase 3 任务来源、派系块与规则引用不报缺失 ID。

---

## 6.2 FactionData 录入要求

### 最小条数
- 2–3 条

### 推荐势力
1. 曹操集团（必录）
2. 袁绍集团或同级对照势力（推荐）
3. 1 个地方中立 / 过渡势力（可选）

### 每条至少要有
| 字段 | 最小要求 |
|---|---|
| `id` / `name` | 唯一可识别 |
| `ruler_id` | 对应核心君主人物 |
| `city_ids` | 至少 1 个城市 |
| `officer_ids` | 至少覆盖主君、核心幕僚与竞争职位相关人物 |
| `bloc_ids` 或等价挂接字段 | 曹操势力至少能挂 2 个派系块 |

### 验收点
- 荀彧所属势力可正常显示为曹操集团；
- 曹操势力可读取至少 2 个 `FactionBlocData`；
- 势力面板不会因派系引用缺失而报错。

---

## 6.3 CityData 录入要求

### 最小条数
- 3–5 条

### 推荐城市
1. 陈留
2. 濮阳
3. 许县
4. 邺城（可选，对照势力政治中心）
5. 河内 / 洛阳样本位（可选）

### 每条至少要有
| 字段 | 最小要求 |
|---|---|
| `id` / `name` | 唯一可识别 |
| `owner_faction_id` | 指向有效势力 |
| `governor_id` | 指向有效角色 |
| `character_ids` | 至少包含驻城关键角色 |
| `tags` / `values` | 能支撑任务来源与派系摘要文案 |

### 验收点
- 荀彧当前城市可显示；
- 任务描述中涉及的城市可正常读取；
- 派系请求或任命说明中出现的城市上下文不缺失。

---

## 6.4 CharacterData 录入要求

### 最小条数
- 严格最小：14–22 条
- 若沿用既有样本：可扩至 20–30 条，但不是首批硬要求

### 必录角色组

#### A. 核心主角与主君组
- 荀彧
- 曹操

#### B. 推荐链人物组
- 荀攸
- 郭嘉
- 程昱

#### C. 反对 / 保留链人物组
- 1 名旧吏或既有候选人
- 1 名与荀彧关系一般或存疑的上级 / 同僚

#### D. 请求来源人物组
- 1 名士族代表
- 1 名同僚请求方或被举荐对象

#### E. 竞争样本人物组
- 1 名与玩家争夺职位的 AI 候选
- 1 名可作为第二竞争位或保留位的 AI 候选（可选但推荐）

#### F. 对照势力组
- 袁绍
- 1 名对照势力幕僚即可

### 荀彧必须具备的最小字段状态
| 字段 | 建议值 |
|---|---|
| `faction_id` | 曹操势力 |
| `city_id` | 当前主样本城 |
| `office_id` | 从事 |
| `clan_id` | 颍川荀氏 |
| `reputation_values.merit` | 接近但未直接越过首轮政治竞争线 |
| `reputation_values.fame` | 中等偏上 |
| `trust` 或等价字段 | 高于普通幕僚 |

### 验收点
- 荀彧角色卡可正常显示；
- 请求方、推荐人、反对者、竞争者都能在任务与月报系统中被查询；
- 单角色范围内的关键政治人物已够用，不需要再扩到全官员表。

---

## 6.5 OfficeData 录入要求

### 最小条数
- 4 条

### 必录官职链
1. 白身
2. 从事
3. 主簿级辅官
4. 中枢幕僚级

### 每条至少要有
| 字段 | 最小要求 |
|---|---|
| `id` / `name` | 唯一可识别 |
| `tier` | 0–3 递增 |
| `unlock_task_tags` | 能影响任务来源与政治可见性 |
| `candidate_office_tags` | 能参与的目标职位标签 |
| `political_risk_level` | 可区分落选或失误后果 |
| `next_office_id` / `prev_office_id` | 形成完整链条 |

### 验收点
- 当前官职与下一级官职可读取；
- 候选资格可按官职层级过滤；
- 升官后任务或信息可见性至少有 1 项变化。

---

## 6.6 TaskTemplateData 录入要求

### 最小条数
- 严格最小：4 条
- 推荐：6 条

### 来源覆盖要求
1. `faction_order` 至少 2 条
2. `relation_request` 至少 2 条

### 推荐最小任务模板
1. 整理军粮（`faction_order`）
2. 整顿文书（`faction_order`）
3. 安抚士族（`relation_request`）
4. 举荐人才（`relation_request`）
5. 核校军报（可选，`faction_order`）
6. 调解同僚 / 访求名士（可选，`relation_request`）

### 每条至少要有
| 字段 | 最小要求 |
|---|---|
| `id` / `name` | 唯一可识别 |
| `task_source_type` | 明确为 `faction_order` 或 `relation_request` |
| `issuer_character_id` / `request_character_id` | 指向有效人物 |
| `related_bloc_id` | 至少部分任务能挂接派系块 |
| `task_type` | politics / admin / personnel / logistics 等 |
| `min_office_tier` | 与官职链一致 |
| `political_reward_tags` | 能触发推荐或派系支持 |
| `political_risk_tags` | 失败后能触发反对或保留 |
| `source_summary` | 月初任务卡可直接展示 |

### 验收点
- 月初任务卡片能正确展示来源类型、来源人物、潜在政治意义；
- 两类来源任务都能被玩家选中；
- 月末至少能把任务结果写回为推荐 / 反对原因输入。

---

## 6.7 TaskPoolRuleData 录入要求

### 最小条数
- 1 条可跑通
- 2 条更稳妥

### 必录思路
| 规则 | 用途 |
|---|---|
| 荀彧 Phase 3 前期混合任务池 | 保证月初稳定出现 2–3 个候选，且两类来源至少各 1 |
| 荀彧升至主簿级后的任务池（可选） | 保证升官后任务来源与政治压力有所变化 |

### 每条至少要有
| 字段 | 最小要求 |
|---|---|
| `character_id` | 指向荀彧或等价角色限制 |
| `office_tier_min/max` | 与当前官职阶段匹配 |
| `required_source_types` | 至少包含两类来源 |
| `source_mix_policy` | 建议为 `ensure_diversity` |
| `candidate_count` | 2 或 3 |
| `fallback_task_ids` | 至少 1 个保底任务 |

### 验收点
- 月初一定出现任务；
- 候选任务不会全是同一来源；
- 不会因过滤过严导致空池。

---

## 6.8 RecommendationRuleData 录入要求

### 最小条数
- 4 条

### 必录推荐规则
1. 上级因任务优秀而举荐
2. 高信任同僚因关系良好而举荐
3. 士族 / 同门网络因背景契合而支持
4. 派系块因议题一致而给予支持

### 每条至少要有
| 字段 | 最小要求 |
|---|---|
| `id` / `name` | 唯一可识别 |
| `source_type` | superior / relation / clan / bloc |
| `trigger_phase` | 至少覆盖 `month_end` 或 `appointment` |
| `target_scope` | 至少覆盖 `office_candidate` |
| `condition_tags` | 与任务结果 / 关系 / 派系目标对应 |
| `support_delta` | 可形成强弱区分 |
| `reason_text_key` 或 `reason_summary_template` | 可输出解释文本 |

### 验收点
- 月末支持快照中能稳定出现 2 条以上推荐原因；
- 至少 1 条推荐来自任务表现，至少 1 条来自关系或派系；
- 原因行可读，不依赖 UI 临时拼文案。

---

## 6.9 OppositionRuleData 录入要求

### 最小条数
- 4 条

### 必录反对规则
1. 任务失败导致上级保留
2. 旧吏或现任候选人产生留任阻力
3. 竞争者阵营对玩家形成压制
4. 门第 / 派系不匹配导致部分士人不愿支持

### 每条至少要有
| 字段 | 最小要求 |
|---|---|
| `id` / `name` | 唯一可识别 |
| `source_type` | incumbent / rival / superior / bloc |
| `trigger_phase` | 至少覆盖 `month_end` 或 `appointment` |
| `target_scope` | 至少覆盖 `office_candidate` |
| `condition_tags` | 与失败结果 / 竞争关系 / 派系摩擦对应 |
| `opposition_delta` | 可形成不同阻力等级 |
| `blocker_tags` | 能写入资格或竞争阻断 |
| `reason_text_key` 或 `reason_summary_template` | 可输出解释文本 |

### 验收点
- 月末支持快照或候选评估中能稳定出现 2 条以上阻力原因；
- 至少 1 条阻力来自任务或表现，至少 1 条来自竞争或派系；
- 失败时月报能指出主要反对来源。

---

## 6.10 FactionBlocData 录入要求

### 最小条数
- 2 条可跑通
- 3 条更稳妥

### 推荐最小集合
1. 颍川士人块
2. 主战实务块
3. 地方行政 / 旧吏块（可选但推荐）

### 每条至少要有
| 字段 | 最小要求 |
|---|---|
| `id` / `name` | 唯一可识别 |
| `faction_id` | 曹操势力 |
| `core_character_ids` | 至少 1–2 名核心人物 |
| `agenda_tags` | 能与任务类型或职位偏好对应 |
| `supported_office_tags` / `opposed_office_tags` | 能影响候选竞争 |
| `affinity_clan_ids` / `friction_clan_ids` | 至少有 1 组亲疏关系 |
| `default_attitude` | support / reserve / oppose |

### 验收点
- 势力页可显示至少 2 个派系块摘要；
- 不同任务或关系结果能影响至少 1 个派系块对玩家的态度；
- 月报可引用派系块名而不是只显示匿名数值。

---

## 6.11 ClanData 录入要求

### 最小条数
- 3–5 条

### 推荐最小集合
1. 颍川荀氏
2. 汝南袁氏
3. 谯郡曹氏 / 夏侯系
4. 1 个地方名门（可选）
5. 1 个寒门 / 新兴家族样本（可选）

### 验收点
- 荀彧能正确显示所属士族；
- `relation_request` 来源中的士族请求不会缺失对象；
- 至少 1 条推荐或反对规则可读取 clan 相关条件。

---

## 6.12 RelationData 录入要求

### 最小条数
- 10–16 条关键关系

### 建议优先录入的关系对
- 荀彧 → 曹操
- 曹操 → 荀彧
- 荀彧 ↔ 荀攸
- 荀彧 ↔ 郭嘉
- 荀彧 ↔ 程昱
- 荀彧 ↔ 士族代表
- 荀彧 ↔ 竞争候选人
- 曹操 ↔ 旧吏 / 现任候选人

### 验收点
- 推荐规则能读取高信任关系；
- 反对规则能读取低关系或竞争关系；
- 不要求首批做全人物对关系网。

---

## 6.13 CharacterSetupPatchData 录入要求

### 最小条数
- 1 条

### 必填要点
| 字段 | 最小要求 |
|---|---|
| `default_player_character_id` | 荀彧 |
| `start_faction_id` | 曹操势力 |
| `start_city_id` | 主样本城 |
| `start_office_id` | 从事 |
| `start_merit` | 接近但未直接锁定任命成功 |
| `start_fame` | 中等偏上 |
| `start_trust` | 高于普通幕僚 |
| `start_permission_tags` | 足以看到 Phase 3 最小政治摘要 |

### 验收点
- 新游戏开局后，默认主角就是荀彧；
- 开局即可进入 Phase 3 任务选择与政治摘要闭环；
- 开局状态不会直接跳过竞争样本。

---

## 7. PoliticalSupportSnapshot 所依赖的世界样本

`PoliticalSupportSnapshot` 不是静态 Resource，但它能否稳定生成，完全取决于首批世界样本是否齐备。

### 7.1 严格最小依赖
1. 1 名玩家角色：荀彧
2. 2 名推荐来源人物：如曹操、荀攸
3. 2 名阻力来源人物：如旧吏、竞争候选人
4. 2 个派系块：如颍川士人块、主战实务块
5. 2 类任务来源：`faction_order`、`relation_request`
6. 1 组同门 / 士族网络样本
7. 1 组竞争关系样本

### 7.2 最少应能产出的快照类型
| 快照类型 | 最小要求 | 用途 |
|---|---|---|
| 支持占优快照 | 2 条推荐原因 + 1 条阻力原因 | 验证“表现良好时为何被支持” |
| 阻力占优快照 | 1 条推荐原因 + 2 条阻力原因 | 验证“表现不佳或竞争激烈时为何受压” |

### 7.3 验收点
- 人物政治摘要区能读取主要推荐人与主要反对者；
- 至少 1 条原因来自任务结果，至少 1 条来自关系 / 派系；
- 快照不是空壳对象，能真实反映世界样本中的人物与派系。

---

## 8. AppointmentCandidateEvaluation 所需的竞争样本

`AppointmentCandidateEvaluation` 的关键不是字段齐全，而是必须有足够小但真实的竞争上下文。

### 8.1 严格最小竞争配置
1. 1 个目标职位：主簿级或等价中层职位
2. 1 个玩家候选：荀彧
3. 1 个 AI 竞争者：旧吏 / 现任候选人
4. 1 名关键推荐人：如曹操或荀攸
5. 1 名关键反对者：如旧吏上级或反对派核心人物
6. 1 个支持型派系块
7. 1 个保留 / 反对型派系块

### 8.2 推荐至少准备的两组竞争样本
| 样本 | 配置 | 用途 |
|---|---|---|
| 样本 A：玩家胜出 | 玩家任务表现优秀，推荐链完整，空缺存在 | 验证 `appointed` |
| 样本 B：玩家落选 | 玩家资格接近达标，但遭旧吏或派系压制 | 验证 `lost_to_rival` / `not_nominated` / `blocked_by_opposition` |

### 8.3 验收点
- 候选评估能比较玩家与至少 1 名 AI 候选；
- 评估结果能指出是资格不足、推荐不足、无空缺还是竞争落败；
- 原因行中能出现具体人物或派系，而不是纯数值排序。

---

## 9. MonthlyEvaluationResult 的成功 / 失败样本

### 9.1 至少要准备的两类月报样本
| 样本 | 任务来源 | 任命结果 | 说明 |
|---|---|---|---|
| 成功样本 | `faction_order` 或 `relation_request` 皆可 | `appointed` | 验证成功时的推荐链、派系态度与新权限提示 |
| 失败样本 | 与成功样本不同来源更佳 | `not_nominated` / `lost_to_rival` / `no_vacancy` 之一 | 验证失败时的阻力分解、错失机会说明与下月建议 |

### 9.2 成功样本最低要求
1. 明确展示本月任务来源；
2. 至少 2 条主要支持原因；
3. 至少 1 条次要阻力但不足以翻盘；
4. 明确显示任命成功；
5. 显示新增权限或新职责提示。

### 9.3 失败样本最低要求
1. 明确展示本月任务来源；
2. 至少 2 条主要阻力原因；
3. 至少 1 条资格、空缺或竞争说明；
4. 明确显示失败类型；
5. 给出下月建议或错失机会说明。

### 9.4 验收点
- 月报界面能稳定展示一条成功样本与一条失败样本；
- 成功 / 失败不是只改一行结果字样，而是原因结构明显不同；
- 玩家能从月报直接回答“为什么成功 / 为什么失败 / 下月该做什么”。

---

## 10. 最小样本建议值表

| 对象 | 建议最小条数 | 严格最小可跑条数 | 备注 |
|---|---:|---:|---|
| Scenario | 1 | 1 | 190 原型剧本 |
| Faction | 3 | 2 | 曹操 + 对照势力 |
| City | 5 | 3 | 主城、政务城、对照城 |
| Character | 20 | 14 | 以荀彧政治闭环为主 |
| Office | 4 | 4 | 固定仕途链 |
| TaskTemplate | 6 | 4 | 每类来源至少 2 条 |
| TaskPoolRule | 2 | 1 | 混合来源更稳 |
| RecommendationRule | 4 | 4 | 固定四类推荐来源 |
| OppositionRule | 4 | 4 | 固定四类阻力来源 |
| FactionBloc | 3 | 2 | 支持 / 保留 / 反对更完整 |
| Clan | 4 | 3 | 至少有荀氏、袁氏、曹氏样本 |
| Relation | 12 | 10 | 只做关键关系 |
| CharacterSetupPatch | 1 | 1 | 荀彧开局 |
| PoliticalSupportSnapshot 样本 | 2 | 2 | 支持占优 / 阻力占优 |
| AppointmentCandidateEvaluation 样本 | 2 | 2 | 玩家胜出 / 玩家落选 |
| MonthlyEvaluationResult 样本 | 2 | 2 | 成功 / 失败月报 |

---

## 11. 录入完成后的验证顺序

### 验证 1：剧本入口
- 能否正确加载 190 原型剧本
- 默认玩家角色是否为荀彧

### 验证 2：月初任务来源
- 月初是否稳定出现 2–3 个候选任务
- 两类来源是否都能出现
- 任务卡是否显示来源人物与政治意义

### 验证 3：政治支持快照
- 月内或月末后是否能生成 `PoliticalSupportSnapshot`
- 是否能读到主要推荐人与主要阻力来源

### 验证 4：候选竞争
- 是否存在至少 1 个目标职位与 1 名 AI 竞争者
- `AppointmentCandidateEvaluation` 是否能区分成功与落选

### 验证 5：月末成功 / 失败月报
- 至少 1 个月报能显示成功任命
- 至少 1 个月报能显示失败并给出具体原因

### 验证 6：单角色边界
- 不需要打开全势力全官员列表也能完成验证
- 仍以荀彧个人接任务、积累支持、竞争职位为主，而非君主批量任命

---

## 12. 数据录入时的常见错误

| 错误类型 | 表现 | 预防方式 |
|---|---|---|
| 只补世界样本，不补政治规则 | 角色很多，但月报仍没有解释 | 先录 `RecommendationRuleData`、`OppositionRuleData`、`FactionBlocData` |
| 两类任务来源没有真正混合 | 月初总是只有同一种任务 | `TaskPoolRuleData` 必须配置 `required_source_types` 或等价混合策略 |
| 竞争样本不足 | 任命评估总是单人通过，无落选案例 | 至少准备 1 名 AI 竞争者与 1 名关键反对者 |
| 派系块只有名字没有人物 | 势力页可显示标签，但无法解释支持来源 | 每个 `FactionBlocData` 至少挂 1–2 名核心人物 |
| 关系样本太少 | 推荐 / 反对全靠任务结果，政治味道不足 | 至少补齐高信任同僚与竞争对手两类关系 |
| 样本录得过大 | 录入成本上升，验证变慢 | 先按“严格最小可跑条数”推进 |

---

## 13. 建议录入批次

### 批次 A：政治规则骨架
- OfficeData
- TaskTemplateData
- TaskPoolRuleData
- RecommendationRuleData
- OppositionRuleData
- FactionBlocData

### 批次 B：世界样本
- FactionData
- CityData
- ClanData
- CharacterData
- RelationData
- CharacterSetupPatchData
- ScenarioData

### 批次 C：运行时验收样本
- PoliticalSupportSnapshot 支持占优样本
- PoliticalSupportSnapshot 阻力占优样本
- AppointmentCandidateEvaluation 成功样本
- AppointmentCandidateEvaluation 落选样本
- MonthlyEvaluationResult 成功月报
- MonthlyEvaluationResult 失败月报

### 批次 D：后续扩展
- EventData
- FamilyData
- 额外任务模板与更多派系块

---

## 14. 本章结论
《Phase 3 最小数据录入清单 v1》不是让开发 AI 一次性录完整个势力政治表，而是帮助它明确：

1. **哪些对象现在就必须补；**
2. **每类对象最少要补多少；**
3. **按什么顺序补最省返工；**
4. **补完如何验证 explainable-politics 闭环已经成立。**

只要先按本清单完成 P0 数据录入，并跑出 `PoliticalSupportSnapshot`、`AppointmentCandidateEvaluation`、`MonthlyEvaluationResult` 的最小成功 / 失败样本，Phase 3 就已经具备进入 Godot 原型联调的最低条件。
