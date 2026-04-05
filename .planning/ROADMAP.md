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
**Plans**: TBD
**Canonical refs**: `design/系统设计/核心系统详细设计 v1.md` §§2-3; `design/原型与实现/Godot 原型开发拆解 v1.md` §§3-6; `design/原型与实现/原型任务拆解清单 v1.md` T06-T08; `design/UIUX/原型 UI 流程图 v1.md` §§4-7, 11-13
**UI hint**: yes

### Phase 3: 仕途、势力与可解释政治
**Goal**: 玩家的行动与关系会进入月末仕途结算，形成任务、任命、权限变化和派系博弈的可解释政治循环。
**Depends on**: Phase 2
**Requirements**: RELA-04, CARE-01, CARE-02, CARE-03, CARE-04, CARE-05, FACT-01, FACT-02, FACT-03, POLI-01, POLI-02, POLI-03
**Success Criteria** (what must be TRUE):
  1. Player can receive at least two prototype task sources, complete relevant work, and see merit and fame move in response.
  2. Month-end evaluation can result in appointment, promotion, rejection, or missed opportunity, with visible reasons such as merit, trust, support, opposition, or blockers.
  3. Office changes alter what the player is allowed to do or how they are treated politically, while preserving the same single-character rule set.
  4. Player can inspect faction leadership, cities, major officers, resources, and internal political groups, and relationship strength can influence later recommendations or appointment outcomes.
**Plans**: TBD
**Canonical refs**: `design/总纲/项目总设计方案 v1.md` §§5.5-5.7; `design/系统设计/核心系统详细设计 v1.md` §§6-7; `design/原型与实现/Godot 原型开发拆解 v1.md` §§5.5-5.7, 8C-8D; `design/原型与实现/原型任务拆解清单 v1.md` T09-T12
**UI hint**: yes

### Phase 4: 家族门阀、婚姻与历史分歧
**Goal**: 玩家能感受到家族门第、联姻政治和事件分歧对个人仕途与关系网络的高影响修正，这是原型区别于普通养成器的核心层。
**Depends on**: Phase 3
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
Phases execute in numeric order: 1 → 2 → 3 → 4 → 5

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. 190样本数据骨架与单角色入口 | 4/4 | Complete | 01-190-01, 01-190-02, 01-190-03, 01-190-04 |
| 2. 旬内行动—关系闭环 | 0/TBD | Not started | - |
| 3. 仕途、势力与可解释政治 | 0/TBD | Not started | - |
| 4. 家族门阀、婚姻与历史分歧 | 0/TBD | Not started | - |
| 5. 持久验证与战争接入口 | 0/TBD | Not started | - |
