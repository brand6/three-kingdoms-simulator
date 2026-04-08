# Phase 3 ID 与样本命名冻结表 v1

#项目设计 #数据录入 #Phase3 #命名冻结 #样本套包 #Godot

> 文档定位：为 Phase 3（荀彧—曹操内部政治圈 + 袁绍最小对照势力）提供一份明确的“ID 与样本命名冻结表”。目的在于：

- 解决命名漂移、ID 不统一、样本条目未冻结的问题；
- 为 Godot 原型数据录入提供可直接使用的稳定 ID 列表；
- 明确补足样本的最小占位 ID（用于保证 14–22 人物规模）并说明用途与填充原则。

适用范围：仅限 Phase 3（荀彧/曹操内部政治圈 + 袁绍最小对照势力），配合：[[Phase 3 最小数据录入清单 v1]]、[[Phase 3 首批政治样本名单 v1]]、[[Phase 3 政治与任命数据字段设计 v1]]、[[Phase 3 Godot 实现映射表 v1]] 使用。

---

## 1. 文档目标与适用范围

1. 固定 Phase 3 首批所有静态 Resource 与样本对象的推荐 ID 命名（Scenario / Faction / City / Clan / Character / Office / TaskTemplate / TaskPoolRule / RecommendationRule / OppositionRule / FactionBloc / Relation / CharacterSetupPatch / Competition Sample / Monthly Report Sample）。
2. 统一命名规则约束，避免 snake/pascal/camel 混用与随意更名导致的録入返工。
3. 提供“支撑角色补足表”，用最小数量占位 ID 补足人物数量到 14（严格最小）以便录入可跑通样本。
4. 给出交叉引用关系表（任务 → 推荐/反对/派系/竞争/月报）以便数据录入时同步关联。

---

## 2. 命名规则总则（适用于 Phase 3）

- 前缀约定：所有 ID 均采用短前缀以表达对象类型，便于快速检索与目录化：
  - Scenario: `scenario_...`
  - Faction: `faction_...`
  - City: `city_...`
  - Clan: `clan_...`
  - Character: `char_...`
  - Office: `office_...`
  - TaskTemplate: `task_...`
  - TaskPoolRule: `taskpool_...`
  - RecommendationRule: `rec_...`
  - OppositionRule: `opp_...`
  - FactionBloc: `bloc_...`
  - Relation: `rel_...`（建议格式见下）
  - CharacterSetupPatch: `patch_character_...`
  - Competition Sample: `comp_...`
  - Monthly Report Sample: `report_...`

- 命名风格：统一使用 snake_case 小写字母，单词间下划线分隔；ID 中避免使用中文、空格或特殊字符。

- ID 稳定性规则：一旦文档中列出并被 Resource/实现映射引用，**不得随意改名**。若必须重命名，须：
  1. 在 `design/CHANGELOG.md` 记录旧 ID → 新 ID 的映射；
  2. 在 `design/Agent.md` 与 `design/machine_index.json` 同步更新检索条目；
  3. 在 Godot 项目中保留兼容层（双 ID 映射）至少一个里程碑周期（直至存档迁移或工具脚本完成）。

- 禁止事项：
  - 不要在 Resource 名称与 ID 中混用驼峰与下划线；
  - 不要使用临时语义（如 `tmp_`、`test_`）作为生产样本 ID；
  - 不要把 UI 文案当作 ID（ID 应为稳定键，文案通过 reason_text_key 或 summary_template 引用）。

---

## 3. 各对象 ID 冻结表（Phase 3 首批样本）

说明：下列 ID 优先沿用并冻结自已有文档（见：[[Phase 3 首批政治样本名单 v1]]）。若未在上位文档明确定义 ID，则在下表中补充建议 ID 并说明用途与注意点。

### 3.1 Scenario

- id: `scenario_190_prototype`
  - name: 190 原型剧本
  - 用途：剧本入口，包含默认玩家 `default_player_character_id = char_xun_yu`。

### 3.2 Faction

- `faction_cao_cao` — 曹操集团（主势力）
- `faction_yuan_shao` — 袁紹集团（最小对照势力）
- `faction_neutral_local` — 地方中立/过渡势力（可选占位）

注意：`faction_cao_cao` 内应至少挂接 `bloc_yingchuan_scholars`、`bloc_campaign_hawks` 两个派系块 ID。

### 3.3 City

- `city_chenliu` — 陈留（推荐荀彧主样本位置）
- `city_puyang` — 濮阳
- `city_xuxian` — 许县
- 可选：`city_yecheng`（邺城，对照势力中心）

### 3.4 Clan

- `clan_yingchuan_xun` — 颍川荀氏（荀氏士族）
- `clan_yuannan_yuan` — 汝南袁氏（袁绍相关门第）
- `clan_qiaojun_cao` — 谯郡曹氏 / 夏侯系（曹操近亲样本）

（注：若后续需要更多 clan，可按 `clan_{placename}_{surname}` 语义扩展）

### 3.5 Character（已冻结的首批 ID）

下列 ID 来自《Phase 3 首批政治样本名单 v1》，已在本表冻结为首批必须存在的人物：

- `char_xun_yu` — 荀彧（玩家主角）
- `char_cao_cao` — 曹操（主君 / 上级）
- `char_xun_you` — 荀攸（同門推薦人）
- `char_guo_jia` — 郭嘉（名士 / 观察位）
- `char_cheng_yu` — 程昱（主战实务代表）
- `char_xiahou_dun` — 夏侯惇（宗族 / 军功代表）
- `char_wang_bi` — 王必（旧吏 / 留任位）
- `char_dong_zhao` — 董昭（竞争候选人）
- `char_xun_chen` — 荀谌（对照势力幕僚）
- `char_yuan_shao` — 袁绍（对照势力主君）

说明：以上 10 人为关键人物组（见样本名单）。为满足 Phase 3 最小人物规模（14–22），见第 6 节“支撑角色补足表”。

### 3.6 Office

- `office_none_white` — 白身（最低层）
- `office_clerk_contributor` — 从事
- `office_registry_chief` — 主簿级辅官（目标竞争位）
- `office_central_advisor` — 中枢幕僚级

（注：office ID 使用 `office_{semantic}` 语义，且应在 Resource 中包含 tier、candidate_office_tags 等字段）

### 3.7 TaskTemplate

- `task_faction_order_archive_cleanup` — 整顿文书（faction_order；发布者：曹操）
- `task_faction_order_supply_audit` — 整理军粮（faction_order；发布者：程昱）
- `task_relation_request_clan_pacify` — 安抚士族（relation_request；请求方：荀攸 / 颍川士人）
- `task_relation_request_talent_recommend` — 举荐人才（relation_request；请求方：郭嘉）

注意：每个 TaskTemplate 必须填写 `task_source_type`、`request_character_id`（若为 relation_request）、`related_bloc_id`（可选）与 `source_summary`。

### 3.8 TaskPoolRule

- `taskpool_xunyu_phase3_mixed` — 荀彧 Phase 3 前期混合任务池（保证 faction_order 与 relation_request 各有样本）
- 可选：`taskpool_xunyu_promoted_registry` — 升至主簿级后的任务池（可选）

### 3.9 RecommendationRule（推荐规则）

- `rec_superior_task_excellent_xunyu` — 上级因政务表现优秀而举荐（来源：曹操）
- `rec_relation_trust_high_xunyou` — 高信任同僚举荐（来源：荀攸）
- `rec_clan_network_yingchuan_match` — 颍川士人网络加成（clan）
- `rec_bloc_administration_alignment` — 行政派系议题契合支持（bloc）

（字段合同参见：[[Phase 3 政治与任命数据字段设计 v1]]）

### 3.10 OppositionRule（反对规则）

- `opp_task_failure_visible_archive` — 政务失误导致上级保留（任务失败触发）
- `opp_incumbent_resistance_registry_clerk` — 旧吏留任阻力（incumbent）
- `opp_rival_candidate_pressure_dongzhao` — 竞争者压制（rival）
- `opp_bloc_military_reserve_to_scholar` — 主战派对文臣候选保留（bloc）

### 3.11 FactionBloc（派系块）

- `bloc_yingchuan_scholars` — 颍川士人块（支持型）
- `bloc_campaign_hawks` — 主战实务块（保留型）
- `bloc_registry_old_guard` — 官署旧吏块（留任 / 竞争型）

### 3.12 Relation（关系 ID 命名约定与建议冻结）

关系 ID 建议采用 `rel_{from}_{to}` 语义并小写 snake_case，例如：

- `rel_char_xun_yu__char_cao_cao` — 荀彧 -> 曹操（from 荀彧 to 曹操）
- `rel_char_cao_cao__char_xun_yu` — 曹操 -> 荀彧（反向关系可单独记录）
- `rel_char_xun_yu__char_xun_you` — 荀彧 ↔ 荀攸

说明：Relation Resource 中应包含 `value`、`trust`、`last_updated` 字段，且关系对应的 ID 必须与 Character ID 一一对应，避免使用数字索引。

### 3.13 CharacterSetupPatch

- `patch_character_xun_yu_start` — 荀彧开局补丁（start_faction_id = faction_cao_cao，start_office_id = office_clerk_contributor，start_city_id = city_chenliu 等）

### 3.14 Competition Sample（竞争样本）

- `comp_registry_chief_xunyu_win` — 目标职位 `office_registry_chief`，参与者：`char_xun_yu` vs `char_wang_bi`（玩家胜出样本）
- `comp_registry_chief_xunyu_lose_dongzhao` — 目标职位 `office_registry_chief`，参与者：`char_xun_yu` vs `char_dong_zhao`（玩家落选样本）

### 3.15 Monthly Report Sample（月报样本）

- `report_month_success_registry_promotion` — 成功任命月报（关联 `task_faction_order_archive_cleanup` + `comp_registry_chief_xunyu_win`）
- `report_month_failure_rival_blocked` — 竞争落选失败月报（关联 `task_relation_request_talent_recommend` / `task_faction_order_supply_audit` + `comp_registry_chief_xunyu_lose_dongzhao`）

---

## 4. 支撑角色补足表（保证 14–22 人物规模）

说明：样本名单已冻结 10 名关键人物（见 3.5）。为满足《Phase 3 最小数据录入清单 v1》中“严格最小 14–22”的要求，建议先补 4 名占位角色（可在后续由史实名代替），先保证闭环验证：

最小补足（推荐立即录入，ID 已冻结为占位）：

1. `char_incumbent_registry_1` — 旧吏备选 A（用于 `opp_incumbent_resistance_registry_clerk` 的多个实例）
   - 用途：作为主簿/辅官职位的现任人，支撑留任逻辑与竞争样本。
2. `char_incumbent_registry_2` — 旧吏备选 B（备用竞争/阻力）
   - 用途：提供落选样本的不同阻力来源，避免单点依赖 `char_wang_bi`。
3. `char_colleague_2` — 同僚 / 次要推荐人（同僚样本）
   - 用途：用于关系型推荐或请求来源，支持 `rec_relation_trust_high_xunyou` 的并列角色样本。
4. `char_clan_representative_2` — 士族代表备选（用于多条 clan 请求）
   - 用途：补足 `clan` 与 `relation_request` 场景，避免单一士族代表成为瓶颈。

说明与替换策略：这些占位 ID 可在后续由具体历史人物替换（例如把 `char_incumbent_registry_1` 替换为王姓历史人名），但替换须遵循“ID 重命名流程”以保证存档与实现兼容。

合计：10（原关键人物）+4（占位）=14（满足严格最小）。如需扩展到 20+，按相同前缀与语义继续追加：`char_competitor_2`、`char_clan_minor_1` 等。

---

## 5. 交叉引用关系表（任务 → 推荐 / 反对 / 派系 / 竞争 / 月报）

说明：数据录入时应按下列映射一次性把引用字段写入对应 Resource，避免后期补 ID 导致大量返工。

- `task_faction_order_archive_cleanup` →
  - 推荐规则：`rec_superior_task_excellent_xunyu`
  - 推荐来源人物：`char_cao_cao`
  - 受益派系：`bloc_yingchuan_scholars`
  - 关联成功月报：`report_month_success_registry_promotion`
  - 可触发阻力：`opp_task_failure_visible_archive`

- `task_faction_order_supply_audit` →
  - 推荐规则：可触发 `rec_bloc_administration_alignment`（若任务按务实成功）
  - 受益 / 观测派系：`bloc_campaign_hawks`
  - 可触发失败阻力：`opp_bloc_military_reserve_to_scholar`

- `task_relation_request_clan_pacify` →
  - 推荐规则：`rec_clan_network_yingchuan_match`
  - 请求方：`char_xun_you` 或 `char_clan_representative_2`
  - 失败可能触发：`opp_incumbent_resistance_registry_clerk`

- `task_relation_request_talent_recommend` →
  - 推荐规则：`rec_relation_trust_high_xunyou`（或 `rec_clan_network_yingchuan_match`）
  - 关联竞争样本：`comp_registry_chief_xunyu_lose_dongzhao`
  - 失败月报：`report_month_failure_rival_blocked`

---

## 6. 录入时的校验规则与常见错误

录入工具 / 人工校验脚本应至少验证以下项目：

1. ID 语法校验：所有 ID 均为小写、snake_case、以对应前缀开头（参见第 2 节）。
2. 引用完整性：Resource 内引用的每个 ID（character_ids、bloc_ids、faction_ids、related_task_id 等）在 DataRepository 中存在并已加载。
3. 最小集覆盖：在 Scenario 中列出的 `character_ids`、`faction_ids`、`city_ids` 等数量应满足《Phase 3 最小数据录入清单 v1》所列的严格最小条数。
4. 双向关系核对：若存在 `rel_A_B`，建议同时录入 `rel_B_A` 或确保系统支持单向关系表示并能正确解释。
5. 任务来源类型一致性：`task_template.task_source_type` 必须为 `faction_order` 或 `relation_request`（当前 Phase 3 冻结两类）。
6. Rule 可用性标记：每条 RecommendationRule / OppositionRule 应包含 `is_phase3_available = true`，便于筛选。

常见错误与防范：

- 把 UI 文案直接作为 ID：导致后来修改文案时必须改 ID → 禁止。
- 任务模板未标注 `task_source_type`：会导致 TaskPoolRule 无法混合来源 → 强制该字段为必填。
- 派系块只写名称不挂人物：会造成月末快照无法说明支持来源 → 每个 bloc 至少挂 1 个核心人物。
- 直接用国别/城市名做 Character ID（含多音/同名风险）：尽量采用 `char_{surname}_{given}` 或 `char_{role}_{index}` 语义。

---

## 7. 本章结论

1. 本文档把 Phase 3 首批样本的 ID 命名与交叉引用一次性冻结，优先沿用现有样本命名并补充了最小占位 ID，以避免命名漂移导致的录入返工；
2. 建议在数据录入开始前，把本表与 [[Phase 3 政治与任命数据字段设计 v1]] 一起作为录入 SOW，并用自动化校验脚本确保“引用完整性”与“最小集覆盖”；
3. 占位 ID（`char_incumbent_registry_1` 等）可在后续替换为具体历史人物，但替换必须走变更记录与兼容层策略；
4. 完成本表冻结后，Phase 3 的数据录入团队（人工或 AI）可直接把对应 `.tres`/Resource 写入 `res://data/...`，映射目录建议参见：[[Phase 3 Godot 实现映射表 v1]]。

---

#标签 #Phase3 #数据录入 #命名规范 #样本冻结 #ID
