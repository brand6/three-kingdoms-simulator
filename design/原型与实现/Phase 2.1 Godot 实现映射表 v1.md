# Phase 2.1 Godot 实现映射表 v1

#项目设计 #原型实现 #Godot #Phase2_1 #实现映射

> 文档定位：本文件不是新的玩法设计稿，而是把 Phase 2.1 已冻结的设计内容映射到 Godot 原型的模块、数据、场景、状态与验收点的桥接文档。目标是让开发 AI 明确“做什么”之外，还知道“由谁做、放哪里、怎么串起来”。

---

## 1. 文档定位与使用方式

### 1.1 本文档解决的问题
本文件主要回答以下实现问题：

1. Phase 2.1 的设计项分别落到哪些 Godot 模块；
2. 哪些内容属于静态 Resource，哪些属于运行时状态；
3. 月初任务、月内推进、月末结算、升官判定分别由谁负责；
4. UI 面板应该读取哪些数据，而不直接承担业务逻辑；
5. Phase 2.1 的最小闭环应按什么顺序搭建与验收。

### 1.2 本文档不负责的内容
- 不重新定义玩法规则；
- 不替代《官职与任务原型部署 Phase 2.1 v1》；
- 不替代《官职与任务原型部署数据字段设计 v1》；
- 不直接给出代码实现。

### 1.3 使用顺序
开发 AI 在进入 Phase 2.1 实现前，建议按以下顺序阅读：

1. `design/总纲/官职与任务原型部署 Phase 2.1 v1.md`
2. `design/数据/官职与任务原型部署数据字段设计 v1.md`
3. `design/数据/Godot 数据结构草案 v1.md`
4. `design/原型与实现/Godot 系统模块拆分清单 v1.md`
5. **本文档《Phase 2.1 Godot 实现映射表 v1》**

---

## 2. 上游文档依赖

| 上游文档 | 作用 | 本文档如何使用 |
|---|---|---|
| `design/总纲/官职与任务原型部署 Phase 2.1 v1.md` | 定义 Phase 2.1 的目标、范围、成功标准 | 作为实现范围与验收标准来源 |
| `design/数据/官职与任务原型部署数据字段设计 v1.md` | 定义官职、任务、任务池、升官规则与运行时状态字段 | 作为 Resource / State / Save 结构依据 |
| `design/数据/Godot 数据结构草案 v1.md` | 定义通用项目数据骨架 | 用于对齐 Character / Scenario / Faction 等已有数据对象 |
| `design/原型与实现/Godot 系统模块拆分清单 v1.md` | 给出管理层、系统层、UI 层职责边界 | 作为模块归属与系统职责依据 |
| `design/原型与实现/Godot 原型开发拆解 v1.md` | 给出原型开发顺序与 MVP 闭环 | 作为 Phase 2.1 的接入顺序依据 |
| `design/UIUX/原型 UI 流程图 v1.md` | 定义 UI 信息架构与交互 | 用于决定任务选择、月末结算等面板的挂载位置 |

---

## 3. Phase 2.1 实现范围冻结

### 3.1 本文档只覆盖以下内容
- 默认主角切换为荀彧
- 官职链与升官规则接入
- 月初任务池生成与任务选择
- 月内任务进度推进
- 月末任务结算
- 功绩 / 名望 / 信任写入
- 升官判定与官职变化反馈
- 下月任务池刷新

### 3.2 本文档明确不覆盖以下内容
- 推荐人与反对人链路
- 派系支持 / 反对演算
- 多候选人竞争同一官职
- 复杂任命政治解释
- 势力总览、城市政治组、内部派系面板的完整实现

这些内容属于 Phase 3。

---

## 4. 设计章节 → Godot 模块映射表

| 设计项 | Godot 模块 | 主负责人系统 | 辅助模块 | 实现说明 | 验收点 |
|---|---|---|---|---|---|
| 荀彧默认开局 | `ScenarioSystem` + `DataRepository` | `GameRoot` | `CharacterSystem` | 启动剧本时应用 `CharacterSetupPatchData`，将默认玩家角色设为荀彧 | 新开局进入游戏后玩家角色为荀彧 |
| 官职定义 | `OfficeData` Resource | `DataRepository` | `CareerSystem` | 作为静态数据载入，供月末升官与任务池过滤读取 | 官职可按 ID 查询，层级清晰 |
| 任务模板定义 | `TaskTemplateData` Resource | `DataRepository` | `TaskSystem` | 月初候选任务从模板中筛选生成 | 能正确列出 2–3 个候选任务 |
| 月初任务池生成 | `TaskSystem` | `TimeManager` | `DataRepository` | 在月初时点读取任务池规则、玩家官职、角色条件生成任务卡片 | 月初稳定弹出任务选择界面 |
| 月内任务推进 | `TaskSystem` | `ActionSystem` | `CharacterSystem` | 通过行动结果推进任务进度，不在 UI 内部直接改任务状态 | 任务进度可随行动更新 |
| 月末任务结算 | `TaskSystem` | `TimeManager` | `CharacterSystem` | 月末统一判定 success / excellent / failed，并生成结算结果 | 月末能稳定生成任务结果 |
| 功绩 / 名望 / 信任变化 | `CharacterSystem` | `TaskSystem` | `FormulaService` | 根据任务结算写入角色状态 | 月末后数值变化正确显示 |
| 升官判定 | `CareerSystem` | `TimeManager` | `TaskSystem` | 基于当前官职、功绩、任务结果、升官规则进行判定 | 达阈值时可触发升官 |
| 官职变化反馈 | `CareerSystem` + `MonthReportPanel` | `EventManager` | `MainHUD` | 升官后更新当前官职、解锁任务标签，并刷新反馈文案 | 官职变化可感知 |
| 下月任务池刷新 | `TaskSystem` | `TimeManager` | `CareerSystem` | 月末结算后清除旧任务状态，为下月重新生成候选任务做准备 | 新月进入时任务池已刷新 |

---

## 5. 数据定义 → Resource / 运行时状态映射表

| 对象 | 类型 | 存储位置 | 主要读取方 | 主要写入方 | 存档是否保存 |
|---|---|---|---|---|---|
| `OfficeData` | 静态定义 Resource | `res://data/offices/` | `CareerSystem` / `TaskSystem` / UI | 无运行时写入 | 否 |
| `TaskTemplateData` | 静态定义 Resource | `res://data/tasks/` | `TaskSystem` / UI | 无运行时写入 | 否 |
| `TaskPoolRuleData` | 静态定义 Resource | `res://data/tasks/rules/` | `TaskSystem` | 无运行时写入 | 否 |
| `PromotionRuleData` | 静态定义 Resource | `res://data/offices/rules/` | `CareerSystem` | 无运行时写入 | 否 |
| `CharacterSetupPatchData` | 静态定义 Resource | `res://data/scenario_patches/` | `ScenarioSystem` / `GameRoot` | 无运行时写入 | 否 |
| `PlayerCareerState` | 运行时状态 | Save JSON / Runtime State | `CareerSystem` / UI | `CareerSystem` / `CharacterSystem` | 是 |
| `MonthlyTaskState` | 运行时状态 | Save JSON / Runtime State | `TaskSystem` / UI | `TaskSystem` | 是 |
| `TaskProgressSnapshot` | 运行时状态子结构 | `MonthlyTaskState` 内部 | `TaskSystem` | `TaskSystem` / `ActionSystem` | 是 |
| `MonthlyEvaluationResult` | 运行时结果对象 | Runtime State / Save JSON | `MonthReportPanel` / `MainHUD` | `TaskSystem` + `CareerSystem` | 是 |

### 5.1 核心规则
1. 静态定义全部进 Resource，不进存档；
2. 运行时状态全部按最小闭环存入 JSON；
3. UI 只读运行时状态与静态定义，不直接持久化。

---

## 6. Phase 2.1 运行时状态最小集合

建议在 Phase 2.1 仅维护以下最小运行时状态：

| 状态键 | 归属 | 说明 |
|---|---|---|
| `player_character_id` | 全局运行时状态 | 当前玩家角色，应为荀彧 |
| `current_office_id` | `PlayerCareerState` | 当前官职 |
| `total_merit` | `PlayerCareerState` | 当前累计功绩 |
| `current_fame` | `PlayerCareerState` | 当前名望 |
| `current_trust` | `PlayerCareerState` | 当前信任 |
| `months_in_current_office` | `PlayerCareerState` | 当前官职任职月数 |
| `current_month_task_id` | `MonthlyTaskState` | 当月主任务模板 ID |
| `current_month_task_status` | `MonthlyTaskState` | in_progress / success / excellent / failed |
| `current_task_progress` | `TaskProgressSnapshot` | 任务当前进度 |
| `last_month_evaluation` | `MonthlyEvaluationResult` | 最近一次月末结算结果 |

---

## 7. UI 流程 → 场景 / 面板映射表

| UI 流程节点 | 场景 / 面板 | 数据来源 | 交互动作 | 不应承担的职责 |
|---|---|---|---|---|
| 月初任务选择 | `TaskSelectPanel`（建议挂在 `MainHUD` 下） | `TaskSystem` 生成的候选任务列表 | 选择 1 个主任务并回传任务 ID | 不负责生成任务池 |
| 月内任务状态显示 | `MainHUD` 任务摘要区 | `MonthlyTaskState` + `TaskProgressSnapshot` | 展示当前任务、进度、剩余时间 | 不直接改任务进度 |
| 当前官职显示 | `CharacterPanel` / HUD 角色摘要 | `PlayerCareerState` + `OfficeData` | 展示当前官职与下一目标 | 不负责升官判定 |
| 月末结算面板 | `MonthReportPanel` | `MonthlyEvaluationResult` | 阅读结果、确认关闭 | 不负责计算奖励 |
| 升官反馈弹窗 | `PromotionPopup`（可并入 `MonthReportPanel`） | `CareerSystem` 输出 | 提示升官结果与变化 | 不负责修改官职 |

### 7.1 推荐 UI 最小节点
- `MainHUD/TaskSummaryBox`
- `MainHUD/MonthStartDialog/TaskSelectPanel`
- `MainHUD/MonthEndDialog/MonthReportPanel`
- `MainHUD/PopupLayer/PromotionPopup`

---

## 8. 月度流程节点与时序映射

## 8.1 时序总览

```text
进入新月
→ TimeManager 发出 month_start
→ TaskSystem 生成候选任务
→ TaskSelectPanel 打开
→ 玩家选择主任务
→ MonthlyTaskState 建立
→ 月内行动推进任务进度
→ TimeManager 发出 month_end
→ TaskSystem 结算任务结果
→ CharacterSystem 写入功绩/名望/信任
→ CareerSystem 判定升官
→ 生成 MonthlyEvaluationResult
→ MonthReportPanel 展示
→ 清理当月任务状态，准备下月刷新
```

## 8.2 流程节点映射表

| 流程节点 | 触发时机 | 调用系统 | 主要输入 | 主要输出 |
|---|---|---|---|---|
| 应用荀彧开局补丁 | 新游戏初始化 | `GameRoot` / `ScenarioSystem` | `CharacterSetupPatchData` | 默认主角与初始状态 |
| 生成候选任务 | 月初 | `TaskSystem` | `TaskPoolRuleData`、官职层级、角色条件 | 候选任务列表 |
| 锁定主任务 | 月初界面确认时 | `TaskSystem` | 选中任务模板 ID | `MonthlyTaskState` |
| 推进任务进度 | 行动结算后 | `TaskSystem` | `ActionResult`、当前任务状态 | 新进度值 |
| 结算任务结果 | 月末 | `TaskSystem` | 当前任务进度、成功条件 | success / excellent / failed |
| 写入角色收益 | 月末 | `CharacterSystem` | 任务结算结果、奖励结构 | 更新后的 merit / fame / trust |
| 判定升官 | 月末 | `CareerSystem` | 当前官职、累计功绩、升官规则 | 新官职或维持现状 |
| 生成月报 | 月末 | `TaskSystem` + `CareerSystem` | 数值变化、官职变化 | `MonthlyEvaluationResult` |

---

## 9. 系统接口与事件总线建议

## 9.1 关键系统职责切分

| 系统 | 只做什么 | 不做什么 |
|---|---|---|
| `TimeManager` | 管时间与月初/月末时点广播 | 不做任务与升官业务逻辑 |
| `TaskSystem` | 生成任务池、管理任务状态、结算任务结果 | 不直接改官职 |
| `CharacterSystem` | 写入功绩、名望、信任等角色数值 | 不负责挑选升官目标 |
| `CareerSystem` | 管官职状态、升官规则、任务池解锁标签 | 不负责任务进度推进 |
| `DataRepository` | 提供静态数据与状态查询入口 | 不做业务判定 |
| `EventManager` | 广播事件与 UI 刷新通知 | 不承担数据结算 |

## 9.2 建议事件名

| 事件名 | 发送方 | 监听方 | 用途 |
|---|---|---|---|
| `month_started` | `TimeManager` | `TaskSystem` / UI | 新月开始，生成任务池 |
| `task_candidates_ready` | `TaskSystem` | `TaskSelectPanel` | 候选任务可展示 |
| `task_selected` | `TaskSelectPanel` | `TaskSystem` | 锁定当月主任务 |
| `task_progress_updated` | `TaskSystem` | `MainHUD` | 刷新任务进度摘要 |
| `month_ended` | `TimeManager` | `TaskSystem` / `CareerSystem` | 进入统一结算 |
| `monthly_evaluation_ready` | `TaskSystem` / `CareerSystem` | `MonthReportPanel` | 月报可展示 |
| `office_changed` | `CareerSystem` | `MainHUD` / `CharacterPanel` | 刷新官职与待遇文本 |

---

## 10. 任务类型 → 完成条件来源 → 结算器 映射表

| 任务类型 | 推荐进度来源 | 主要结算器 | 奖励写入目标 | 备注 |
|---|---|---|---|---|
| 整理军粮 | 政务 / 后勤类行动次数或累计点数 | `TaskSystem` | 功绩为主，少量名望 | 最稳定保底任务 |
| 安抚士族 | 拜访 / 劝说 / 关系改善结果 | `TaskSystem` + `RelationSystem` | 功绩 + 名望 | 适合验证关系反馈接任务 |
| 举荐人才 | 接触目标人物 + 达成条件标记 | `TaskSystem` | 功绩 + 信任 | 阶段中高阶任务 |
| 整顿文书 | 行政类行动累计完成次数 | `TaskSystem` | 稳定功绩 | 低风险、低波动任务 |

---

## 11. 官职层级 → 任务池 / UI 变化映射表

| 官职 | 解锁任务标签 | 月初任务池变化 | UI / 文案变化 | 升迁目标提示 |
|---|---|---|---|---|
| 白身 | `basic_misc` | 仅基础杂务 | 称呼偏低、无正式任官语义 | 指向从事 |
| 从事 | `logistics`, `admin`, `politics_basic` | 可接正式基础政务任务 | 进入势力考评语境 | 指向主簿级辅官 |
| 主簿级辅官 | `personnel`, `politics_mid`, `dispatch` | 可接中阶政务 / 人事任务 | 文案开始强调政务责任 | 指向中枢幕僚级 |
| 中枢幕僚级 | `central_affairs` | 任务池转向更核心政务 | 文案突出中枢信任 | Phase 2.1 内不再升迁 |

---

## 12. 最小目录与脚本落位建议

## 12.1 数据目录建议

```text
res://data/
  offices/
    office_commoner.tres
    office_congshi.tres
    office_zhubu.tres
    office_central_aide.tres
  office_rules/
    promotion_congshi_to_zhubu.tres
    promotion_zhubu_to_central_aide.tres
  tasks/
    task_grain_audit.tres
    task_clan_pacify.tres
    task_recommend_talent.tres
    task_document_cleanup.tres
  task_rules/
    task_pool_xunyu_early_career.tres
  scenario_patches/
    xunyu_default_start_patch.tres
```

## 12.2 脚本落位建议

```text
res://scripts/autoload/
  game_root.gd
  time_manager.gd
  data_repository.gd
  event_manager.gd

res://scripts/systems/
  task_system.gd
  career_system.gd
  character_system.gd
  scenario_system.gd

res://scripts/ui/
  task_select_panel.gd
  month_report_panel.gd
  promotion_popup.gd
```

## 12.3 状态对象建议

```text
res://scripts/state/
  player_career_state.gd
  monthly_task_state.gd
  monthly_evaluation_result.gd
```

若原型阶段不想过早创建太多状态类，也可先用 Dictionary 实现，但字段名必须与数据字段设计稿保持一致。

---

## 13. 开发顺序建议

### P0：必须先打通
1. `CharacterSetupPatchData` 接入，新开局切换为荀彧
2. `OfficeData` / `PromotionRuleData` 读取与查询
3. `TaskTemplateData` / `TaskPoolRuleData` 读取与查询
4. 月初任务池生成与任务选择 UI
5. `MonthlyTaskState` 建立与月内进度推进
6. 月末结算与 `MonthlyEvaluationResult` 生成
7. 升官判定与官职刷新

### P1：建议补齐
1. 月末报告文案优化
2. 官职变化带来的称呼与任务池差异
3. HUD 中当前任务与升迁目标提示

### P2：为 Phase 3 预留
1. 推荐 / 反对字段挂接位
2. 派系支持修正接口
3. 任命解释明细面板预留

---

## 14. 验收映射表

| 设计成功标准 | Godot 验收点 | 负责模块 |
|---|---|---|
| 默认主角为荀彧 | 新游戏进入后角色卡显示荀彧 | `GameRoot` / `ScenarioSystem` |
| 月初会出现 2–3 个候选任务 | 新月进入后 `TaskSelectPanel` 展示候选卡片 | `TimeManager` / `TaskSystem` |
| 玩家可选择 1 个主任务 | 点击确认后建立 `MonthlyTaskState` | `TaskSelectPanel` / `TaskSystem` |
| 月内任务可推进 | 执行动作后 HUD 中进度数字变化 | `ActionSystem` / `TaskSystem` |
| 月末会输出任务结果 | 月末弹出 `MonthReportPanel` | `TaskSystem` |
| 功绩随任务结果变化 | 月报显示 merit delta，角色状态同步变化 | `CharacterSystem` |
| 功绩达阈值时可升官 | 月报或弹窗显示官职变化 | `CareerSystem` |
| 官职变化带来差异 | 下月任务池或称呼文本发生变化 | `CareerSystem` / UI |

---

## 15. Phase 2.1 范围内做 / 不做清单

| 项目 | 是否在 Phase 2.1 实现 | 说明 |
|---|---|---|
| 荀彧默认开局 | 做 | 作为闭环主角 |
| 基础官职链 | 做 | 4 级足够 |
| 上级指派任务 | 做 | 先保证功绩归属清晰 |
| 月初任务选择界面 | 做 | 稳定节奏入口 |
| 月末任务结算 | 做 | 闭环核心 |
| 功绩驱动升官 | 做 | 仕途反馈核心 |
| 推荐 / 反对链 | 不做 | 留给 Phase 3 |
| 派系博弈演算 | 不做 | 留给 Phase 3 |
| 多候选人竞争官职 | 不做 | 留给 Phase 3 |
| 势力总览政治可视化 | 不做 | 可先仅保留接口 |

---

## 16. 与 Phase 3 的接口预留

### 16.1 TaskSystem 预留
- 任务模板可扩展 `support_faction_tags`
- 任务结果可扩展 `political_risk`
- 月末结算可挂接 `support_sources` / `opposition_sources`

### 16.2 CareerSystem 预留
- 升官判定函数需支持未来加入推荐人、反对者、派系支持度参数
- 官职变化结果对象需支持 future reason breakdown

### 16.3 UI 预留
- `MonthReportPanel` 结构上预留“主要原因 / 阻力因素 / 下月建议”区域
- `CharacterPanel` 预留显示政治支持与派系态度的字段区域

---

## 17. 本章结论
《Phase 2.1 Godot 实现映射表 v1》用于把 Phase 2.1 的设计稿转化为可执行的 Godot 落地方案。

它的核心价值不在于新增玩法，而在于统一以下三件事：

1. **谁负责做**：系统职责清晰；
2. **数据放哪里**：静态 Resource 与运行时状态分层；
3. **闭环怎么跑**：月初、月内、月末的时序与 UI 入口统一。

只要开发阶段严格以本表为桥接层，Phase 2.1 就可以在不引入 Phase 3 复杂政治逻辑的前提下，稳定完成“荀彧开局—领任务—做事务—积功绩—升官职”的最小可玩原型。
