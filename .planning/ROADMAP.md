# Roadmap: 三国模拟器

## Overview

本路线图遵循 `.planning/PROJECT.md` 的核心价值与原型边界：先用 190 年局部样本、单角色视角、旬制循环和数据驱动 Godot 架构，验证“个人命运嵌入势力政治”的体验，再逐步接入仕途政治、士族门阀、婚姻历史分歧，以及用于持续验证的存档、调试与战争 stub。

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [ ] **Phase 1: 190样本数据骨架与单角色入口** - 锁定原型数据边界、主界面入口和统一身份底层规则。
- [ ] **Phase 2: 旬内行动—关系闭环** - 让玩家在主 HUD 内完成可解释的行动、反馈与关系变化。
- [ ] **Phase 3: 仕途、势力与可解释政治** - 把行动结果转进任务、任命、派系支持与政治后果。
- [x] **Phase 03.1: Phase 1 基线验证与时间契约修复** - 关闭 Phase 1 孤儿需求，并恢复 HUD 时间标签共享契约的可验证证据链。 (completed 2026-04-09)
- [ ] **Phase 03.2: Phase 3 势力总览复验与需求追踪归一** - 正式清除 FACT-01 阻塞，并收敛 inserted phase 的追踪与验证漂移。
- [ ] **Phase 4: 家族门阀、婚姻与历史分歧** - 接入三国特色的出身网络、联姻政治与事件分歧。
- [ ] **Phase 5: 持久验证与战争接入口** - 补齐 war stub、存档和调试能力，支持持续验证原型。

## Phase Details

### Phase 1: 190样本数据骨架与单角色入口
**Goal**: 玩家能以单个历史人物进入 190 年局部样本，并在统一规则下看到可驱动后续原型的基础状态与数据骨架。
**Depends on**: Nothing (first phase)
**Requirements**: CORE-01, CORE-02, DATA-01, DATA-02, DATA-03, DATA-04, CHAR-01, CHAR-02, CHAR-04
**Success Criteria** (what must be TRUE):
  1. Player can start a 190 scenario sample and enter the main gameplay screen as one historical character rather than a map-first overview.
  2. Main HUD shows current time, city, identity, faction, office, AP, energy, stress, fame, and merit without extra setup steps.
  3. Sample characters, factions, cities, clans, families, actions, and events load from data-driven definitions, while runtime play state stays separate from source definitions.
  4. Different starting identities enter the same single-character time/action framework, with differences expressed through permissions or available actions instead of separate game modes.
**Plans**: 4 plans
Plans:
- [x] 01-190-01-PLAN.md — 建立 Godot 入口壳、HUD 骨架与管理器契约
- [x] 01-190-02-PLAN.md — 建立 Excel→Luban→JSON 烟雾样本数据管线
- [x] 01-190-03-PLAN.md — 实现定义加载、ID 查询与 Definition/Runtime 分离
- [x] 01-190-04-PLAN.md — 接通默认主角开局与主 HUD 实时绑定
**Canonical refs**: `.planning/PROJECT.md`; `design/总纲/GDD 框架 v1.md` §§8-12; `design/原型与实现/Godot 原型开发拆解 v1.md` §§4-7; `design/数据/Godot 数据结构草案 v1.md` §§2-16
**UI hint**: yes

### Phase 2: 旬内行动—关系闭环
**Goal**: 玩家能在一个旬内完成多次行动，获得即时结果、关系变化与旬末反馈，并据此规划下一旬。
**Depends on**: Phase 1
**Requirements**: CORE-03, CORE-04, CORE-05, CHAR-03, ACTN-01, ACTN-02, ACTN-03, ACTN-04, ACTN-05, RELA-01, RELA-02, RELA-03, UI-01, UI-02, UI-04
**Success Criteria** (what must be TRUE):
  1. Player can open an action menu grouped by growth, relationships, governance, military, and family, then execute multiple actions in one xun until AP or availability runs out.
  2. Each action clearly shows cost, target type, and expected effect, and both successful and failed actions produce visible consequences instead of silent rejection.
  3. Visit, train, study, inspect, and rest create readable changes to character stats, status, or relationships, and those changes are surfaced through result dialogs and summaries.
  4. Player can inspect character and relationship context from the main flow, finish at least three stable xun transitions, and receive a xun-end summary that explains what changed.
**Plans**: 7 plans
Plans:
- [x] 02-01-PLAN.md — 建立 Phase 2 行动 / 关系 / 旬总结运行时契约与 session 存储
- [x] 02-02-PLAN.md — 实现五个基础行动目录、结算规则与 GameRoot 接口
- [x] 02-03-PLAN.md — 在 MainHUD 内接通行动浮层、目标弹窗、结果反馈与关系页
- [x] 02-04-PLAN.md — 实现结束本旬、旬末总结与三次稳定推进回归
- [x] 02-05-PLAN.md — 修复配置化行动可见性并补通用角色选择/详情后端契约
- [x] 02-06-PLAN.md — 重建上浮五行动菜单并把拜访/关系接到通用排序选择器
- [x] 02-07-PLAN.md — 修复结束本旬确认框首开尺寸与按钮可见性回归
**Canonical refs**: `design/系统设计/核心系统详细设计 v1.md` §§2-3; `design/原型与实现/Godot 原型开发拆解 v1.md` §§3-6; `design/原型与实现/原型任务拆解清单 v1.md` T06-T08; `design/UIUX/原型 UI 流程图 v1.md` §§4-7, 11-13
**UI hint**: yes

### Phase 02.1: 官职与任务部署 (INSERTED)

**Goal:** 玩家以荀彧身份在新月领受 1 个主任务，在三旬内用现有基础行动推进任务，并在月末收到可解释的任务结算与简化任命结果；首月至少有 1 条更稳定的升官正反馈路径，trust 也能通过可见叙事反馈参与这一轮仕途体验。
**Requirements**: CARE-02, CARE-03, CARE-04, CARE-05, UI-03
**Depends on:** Phase 2
**Plans:** 8 total (6 complete + 2 gap-closure planned)

**Success Criteria** (what must be TRUE):
  1. Player boots as 荀彧, and each new month auto-opens a task picker that requires exactly one main-task selection before any xun actions can proceed, but the gate copy reads as a仕途制度提示 rather than a blunt system lock.
  2. The selected monthly task progresses only through the existing five foundational actions, and the first-month task pool guarantees at least one stable success path that can realistically satisfy the first promotion threshold when the vacancy is open.
  3. The third xun of the month automatically triggers task settlement, merit/fame/trust writeback, and a simplified appointment check using vacancy + data-threshold + notification rules, while trust must also surface in visible narrative feedback instead of remaining a hidden numeric delta.
  4. Month-end feedback first shows a constrained task report with task name, result, progress, merit/fame/trust deltas, and one political-meaning summary line, then a separate promotion popup whose failure copy is standardized as `功绩不足` / `名望不足` / `无空缺` / `任务未达标`, without introducing Phase 3 multi-candidate or faction logic.

Plans:
- [x] 02.1-01-PLAN.md — 建立官职 / 任务 / 升官 / 月结算静态与运行时契约
- [x] 02.1-02-PLAN.md — 录入四级官职链与三条升官规则样本数据
- [x] 02.1-03-PLAN.md — 录入四个任务模板、月初任务池规则与荀彧开局补丁
- [x] 02.1-04-PLAN.md — 扩展仓库与 bootstrap，使荀彧开局与月初任务门控生效
- [x] 02.1-05-PLAN.md — 实现月任务推进、月末结算与简化任命后端闭环
- [x] 02.1-06-PLAN.md — 在 MainHUD 接通月初选任务、月报与升官弹窗并补回归
- [x] 02.1-07-PLAN.md — 修复月初领取按钮即时显现、跨旬任务 HUD 常驻与新月弹窗时序回归
- [x] 02.1-08-PLAN.md — 修复巡察对荀彧的可用性并补 inspect 推进月任务回归

**Canonical refs**: `.planning/PROJECT.md`; `design/总纲/官职与任务原型部署 Phase 2.1 v1.md`; `design/数据/官职与任务原型部署数据字段设计 v1.md`; `design/数据/Phase 2.1 最小数据录入清单 v1.md`; `design/原型与实现/Phase 2.1 Godot 实现映射表 v1.md`; `design/UIUX/原型 UI 流程图 v1.md` §§4-7, 11-13
**UI hint**: yes

### Phase 3: 仕途、势力与可解释政治
**Goal**: 玩家的行动与关系会进入月末仕途结算，形成任务、任命、权限变化和派系博弈的可解释政治循环。
**Depends on**: Phase 2.1
**Requirements**: RELA-04, CARE-01, CARE-02, CARE-03, CARE-04, CARE-05, FACT-01, FACT-02, FACT-03, POLI-01, POLI-02, POLI-03
**Success Criteria** (what must be TRUE):
  1. Player can receive at least two prototype task sources, complete relevant work, and see merit and fame move in response.
  2. Month-end evaluation can result in appointment, promotion, rejection, or missed opportunity, with visible reasons such as merit, trust, support, opposition, or blockers.
  3. Office changes alter what the player is allowed to do or how they are treated politically, while preserving the same single-character rule set.
  4. Player can inspect faction leadership, cities, major officers, resources, and internal political groups, and relationship strength can influence later recommendations or appointment outcomes.
**Plans**: 11 total (10 complete + 1 gap-closure planned)
Plans:
- [x] 03-01-PLAN.md — 冻结推荐 / 反对 / 派系支持 / 任命解释的静态与运行时契约
- [x] 03-02-PLAN.md — 将月任务来源从上级指派扩展到至少两类可解释政治来源
- [x] 03-03-PLAN.md — 建立关系、功绩与任务结果驱动的推荐 / 反对累积链
- [x] 03-04-PLAN.md — 实现派系支持修正、多候选竞争与任命原因分解
- [x] 03-05-PLAN.md — 让官职变化真正影响权限、待遇反馈与政治后果
- [x] 03-06-PLAN.md — 接通势力总览、派系摘要、人物政治支持与月报解释 UI
- [x] 03-07-PLAN.md — 完成 Phase 3 联调、政治失败结果与 explainable-politics 回归验收
- [x] 03-08-PLAN.md — 修复月初任务卡单行来源布局与机遇/风险标签契约
- [x] 03-09-PLAN.md — 修复势力/人物弹窗不透明样式并补视觉回归
- [x] 03-10-PLAN.md — 修复任务卡来源机构/请求方语义并完成第二轮排版收敛
- [ ] 03-11-PLAN.md — 补齐势力总览战略态势字段链路与 popup 展示
**Canonical refs**: `design/总纲/项目总设计方案 v1.md` §§5.5-5.7; `design/总纲/官职与任务原型部署 Phase 2.1 v1.md` §§12-16; `design/总纲/Phase 3 仕途、势力与可解释政治 详细规划 v1.md`; `design/系统设计/核心系统详细设计 v1.md` §§3, 6-7; `design/数据/官职与任务原型部署数据字段设计 v1.md` §§16; `design/原型与实现/Phase 2.1 Godot 实现映射表 v1.md` §§14-16; `design/原型与实现/Godot 原型开发拆解 v1.md` §§5.5-5.7, 8C-8D; `design/原型与实现/原型任务拆解清单 v1.md` T09-T12
**UI hint**: yes

### Phase 03.1: Phase 1 基线验证与时间契约修复 (INSERTED)
**Goal**: 为已交付的 Phase 1 入口、数据骨架与角色基线补齐正式验证证据，并把 TimeManager → MainHUD 的时间标签契约重新收敛成可回归、可审计的共享来源。
**Depends on**: Phase 3
**Requirements**: CORE-01, CORE-02, DATA-01, DATA-02, DATA-03, DATA-04, CHAR-01, CHAR-02, CHAR-04
**Gap Closure**: Closes orphaned Phase 1 requirements, the CORE-02 top-bar time contract integration gap, and the cold-start HUD baseline verification flow gap from `v1.0-v1.0-MILESTONE-AUDIT.md`.
**Success Criteria** (what must be TRUE):
  1. `01-VERIFICATION.md` exists and covers all nine previously orphaned Phase 1 requirements with explicit evidence links instead of summary-only claims.
  2. MainHUD again consumes the shared TimeManager-formatted time label through a stable contract that matches Phase 1 baseline expectations and can be regression-tested.
  3. Cold-start boot → session → HUD baseline verification passes with auditable evidence for the main top bar state, including the time label path.
  4. `REQUIREMENTS.md` no longer marks the nine Phase 1 requirements as complete until this inserted phase is verified and closed.
**Plans**: 2 plans
Plans:
- [x] 03.1-01-PLAN.md — 重建 Phase 1 时间标签共享契约与双层回归 gate
- [x] 03.1-02-PLAN.md — 产出 Phase 1 九项 requirement 的正式 verification 证据表
**Canonical refs**: `.planning/v1.0-v1.0-MILESTONE-AUDIT.md`; `.planning/phases/01-190`; `.planning/REQUIREMENTS.md`; `.planning/ROADMAP.md`
**UI hint**: yes

### Phase 03.2: Phase 3 势力总览复验与需求追踪归一 (INSERTED)
**Goal**: 以最新代码和总结为基准重跑 Phase 3 势力总览验证，正式清除 FACT-01 阻塞，并同步归一 02.1/03 的需求追踪与验证文档漂移。
**Depends on**: Phase 03.1
**Requirements**: FACT-01
**Gap Closure**: Closes the remaining FACT-01 verification blocker and normalizes inserted-phase traceability drift called out by `v1.0-v1.0-MILESTONE-AUDIT.md`.
**Success Criteria** (what must be TRUE):
  1. Phase 3 verification is rerun against the current codebase and no longer reports FACT-01 blocked if the strategic posture chain is truly complete.
  2. If any strategic posture gap remains, the missing data/query/UI evidence is identified and closed within the same inserted phase before verification is marked passed.
  3. `REQUIREMENTS.md` traceability reflects inserted-phase ownership consistently, especially for UI-03 and the Phase 2.1 career-result requirements.
  4. Milestone audit noise caused by stale 02.1 / 03 verification artifacts is reduced so the current milestone can be re-audited cleanly.
**Plans**: TBD
**Canonical refs**: `.planning/v1.0-v1.0-MILESTONE-AUDIT.md`; `.planning/phases/02.1-`; `.planning/phases/03-仕途、势力与可解释政治`; `.planning/REQUIREMENTS.md`
**UI hint**: yes

### Phase 4: 家族门阀、婚姻与历史分歧
**Goal**: 玩家能感受到家族门第、联姻政治和事件分歧对个人仕途与关系网络的高影响修正，这是原型区别于普通养成器的核心层。
**Depends on**: Phase 03.2
**Requirements**: CLAN-01, CLAN-02, CLAN-03, MARR-01, MARR-02, MARR-03, EVNT-01, EVNT-02, EVNT-03, EVNT-04, UI-03
**Success Criteria** (what must be TRUE):
  1. Player can inspect family and clan prestige, wealth or influence, major members, and orientation, and feel visible differences between high-status and low-status starts.
  2. Player can browse viable marriage candidates and see proposal outcomes shaped by relationship, status background, eligibility, and political context.
  3. Marriage, clan status, and family standing create visible consequences for relationships, recommendations, career opportunities, or political paths instead of remaining flavor text.
  4. Triggered events across relationship, appointment, family, and faction contexts visibly change state or opportunities, and at least one event path lets the player diverge from expected historical flow with clear cause explanation.
**Plans**: TBD
**Canonical refs**: `design/总纲/GDD 框架 v1.md` §§4, 6, 8-10, 14; `design/系统设计/核心系统详细设计 v1.md` §§4-5, 9; `design/原型与实现/Godot 原型开发拆解 v1.md` §§2, 5.6-5.9; `design/UIUX/原型 UI 流程图 v1.md` §§8-11
**UI hint**: yes

### Phase 5: 持久验证与战争接入口
**Goal**: 原型能被反复保存、加载、调试和验证，同时用简化战争入口补足政治人生样本中的军事反馈，而不滑向完整战场系统。
**Depends on**: Phase 4
**Requirements**: WAR-01, WAR-02, PERS-01, PERS-02, PERS-03
**Success Criteria** (what must be TRUE):
  1. Player can participate in at least one simplified military expedition or war-related task without entering a full tactical battle layer.
  2. War resolution visibly changes merit, fame, injury or recovery state, and political standing through post-result feedback.
  3. Player can save the current run to `user://` storage and load it back later using a versioned runtime-state format rather than raw scene-tree serialization.
  4. Developer-facing debug visibility exists for important runtime values, triggered events, and settlement results so multi-xun and month-end behavior can be verified repeatedly.
**Plans**: TBD
**Canonical refs**: `.planning/research/SUMMARY.md` §§10-15, 67-87, 120-144; `design/原型与实现/Godot 原型开发拆解 v1.md` §§5.10, 9, 10; `design/原型与实现/原型任务拆解清单 v1.md` T15-T16

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 2.1 → 3 → 3.1 → 3.2 → 4 → 5

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. 190样本数据骨架与单角色入口 | 4/4 | Complete | 01-190-01, 01-190-02, 01-190-03, 01-190-04 |
| 2. 旬内行动—关系闭环 | 4/7 | Gap closure planned | 02-01, 02-02, 02-03, 02-04 |
| 2.1. 官职与任务部署 | 8/8 | Executed - pending verification | 02.1-01, 02.1-02, 02.1-03, 02.1-04, 02.1-05, 02.1-06, 02.1-07, 02.1-08 |
| 3. 仕途、势力与可解释政治 | 10/11 | Gap closure planned | 03-01, 03-02, 03-03, 03-04, 03-05, 03-06, 03-07, 03-08, 03-09, 03-10 |
| 3.1. Phase 1 基线验证与时间契约修复 | 0/2 | Planned | - |
| 3.2. Phase 3 势力总览复验与需求追踪归一 | 0/TBD | Planned | - |
| 4. 家族门阀、婚姻与历史分歧 | 0/TBD | Not started | - |
| 5. 持久验证与战争接入口 | 0/TBD | Not started | - |
