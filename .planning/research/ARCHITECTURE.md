# Architecture Patterns

**Domain:** 单角色历史模拟 / Godot 数据驱动原型  
**Researched:** 2026-04-04  
**Overall confidence:** MEDIUM-HIGH

## Recommended Architecture

推荐采用：**单主场景 + 少量 Autoload 引导层 + 运行时状态仓库 + 规则系统层 + 独立 UI 面板层**。

这比“所有东西都做成全局 Manager”更适合 Godot 原型：

- 符合 Godot 官方对 **Autoload 只用于广域、相对自洽职责** 的建议。
- 符合现有设计文档中的 **单主场景 + 数据管理器 + 多 UI 面板 + 事件驱动更新**。
- 能最快做出 15~30 分钟可验证闭环，同时保留后续扩展到更多场景/更复杂表现的空间。

核心判断：

1. **静态剧本数据** 和 **局内运行时状态** 必须分离。  
2. **UI 只能发出玩家意图，不直接改数据。**  
3. **系统只改仓库/状态，不依赖具体 UI 节点。**  
4. **Save/Load 只序列化运行时状态，不保存 Node/Control 树。**

---

## Recommended Scene / Runtime Topology

```text
/root
  AppBootstrap            (Autoload, very thin)
  MainScene               (唯一主场景)
    GameRoot              (组合根 / 原型主控制器)
      SessionRoot         (当前剧本会话容器)
      SystemRoot          (各规则系统节点)
      UIRoot              (全部 UI 场景挂载点)
        HUDLayer
        PanelLayer
        ModalLayer
        SummaryLayer
```

### Why this structure

- **AppBootstrap** 只负责应用级初始化：启动、加载初始剧本、切场景入口、全局配置。
- **GameRoot** 是真正的组合根：创建仓库、注入系统、管理结算顺序。
- **SessionRoot** 持有“当前这一局”的状态对象，不放业务逻辑。
- **SystemRoot** 只放系统脚本/节点，便于统一调试和固定调用顺序。
- **UIRoot** 分层挂载，避免 HUD、详情面板、弹窗、结算页互相污染。

---

## Layered Architecture

## 1. Bootstrap / Composition Layer

### `AppBootstrap`（建议唯一核心 Autoload）

**Responsibility**
- 应用启动
- 读取配置
- 进入主场景
- 触发“新开局 / 读档”的初始流程

**Should not do**
- 不做角色结算
- 不持有全部游戏规则
- 不直接驱动 UI 细节

**Why**
- Godot 官方明确提醒不要把所有共享逻辑都堆进 Autoload；Autoload 适合广域、自含的系统，不适合变成全局神对象。

### `GameRoot`

**Responsibility**
- 组装本局会话
- 创建 repositories / systems / UI facades
- 定义每旬/每月固定执行顺序
- 作为 UI 与规则层之间的应用服务入口

**Boundary**
- 可以调用系统
- 可以读取仓库快照
- 不写具体规则公式

**Recommendation**
- 把 `GameRoot` 视为“原型阶段的 application service + composition root”，而不是另一个无边界 manager。

---

## 2. Data Layer

## 2.1 Static Definition Data（静态定义层）

建议用 **Godot custom Resource** 承载：

- `ScenarioData`
- `CharacterData`
- `FactionData`
- `CityData`
- `ClanData`
- `FamilyData`
- `OfficeData`
- `ActionData`
- `EventData`

### Why Resource over “all JSON”

- Godot 官方文档明确强调 **Resource 是数据容器，天然支持序列化、Inspector 编辑、引用子资源**。
- 原型阶段需要频繁改字段、看 Inspector、手工校验数据，`Resource(.tres)` 比纯 JSON 更顺手。
- 但如果历史样本最终来自表格/外部脚本，可保留“导入 JSON/CSV -> 生成 Resource”的路线。

### Boundary

- 这里只放 **剧本定义**、默认值、静态元数据。
- **绝不**把“当前 AP、当前关系、当前所在城、当前资源”直接写回定义资源。

## 2.2 Runtime State（运行时状态层）

建议单独建立 `SessionState` 聚合根，内部维护：

- `TimeState`
- `CharacterState` 映射
- `FactionState` 映射
- `CityState` 映射
- `RelationState` 映射
- `TaskState` / `EventRuntimeState`
- `PlayerContextState`

### Rule

- **静态定义回答“它本来是什么”**
- **运行时状态回答“这一局现在变成什么了”**

这条边界是整个原型最重要的反返工点。

---

## 3. Repository Layer

Repository 负责“按 ID 取数据、缓存、索引、保存/恢复”，不负责规则。

### Recommended repositories

| Repository | Responsibility | Reads | Writes |
|-----------|---------------|-------|--------|
| `DefinitionRepository` | 加载并索引静态 Resource | Static defs | No |
| `SessionRepository` | 持有本局运行时状态 | Runtime state | Runtime state |
| `QueryRepository` | 组合查询视图数据 | Defs + Runtime | No |
| `SaveRepository` | 存档对象序列化/反序列化 | Runtime snapshots | Save files |

### Boundary rules

- `DefinitionRepository` 不知道 UI。
- `SessionRepository` 不计算行动结果。
- `QueryRepository` 只做查询拼装，不写回状态。
- `SaveRepository` 只认可序列化 DTO，不直存节点引用。

### Why repositories matter here

你的设计文档已经明确采用 **ID 关联**。这意味着运行时必须有一层统一的索引/组装入口，否则系统和 UI 都会自己拼字典，后面一定失控。

---

## 4. Domain Systems Layer

系统层建议作为 `GameRoot` 的子节点或脚本对象统一持有，**不要全部做成 Autoload**。

原因：Godot 官方建议，若一个系统会频繁修改其他系统数据，它更适合由场景内组合根管理，而不是全局裸暴露。

### Core systems

| System | Responsibility | Talks To |
|-------|----------------|----------|
| `TimeSystem` | 旬/月推进；驱动结算阶段 | SessionRepository, other systems |
| `ActionAvailabilitySystem` | 生成当前可执行行动列表 | QueryRepository, DefinitionRepository |
| `ActionResolutionSystem` | 校验条件、消耗 AP/精力、产出结果 | SessionRepository, DefinitionRepository |
| `CharacterSystem` | 属性/状态变化、成长接口 | SessionRepository |
| `RelationSystem` | 好感/信任/戒备等关系变化 | SessionRepository |
| `CareerSystem` | 功绩、官职、任命、权限解锁 | SessionRepository, QueryRepository |
| `FactionSystem` | 势力资源、任命环境、支持/反对 | SessionRepository |
| `ClanFamilySystem` | 士族、家族、联姻资格、出身修正 | SessionRepository, DefinitionRepository |
| `FactionGroupSystem` | 势力内部派系倾向与影响修正 | SessionRepository |
| `TaskEventSystem` | 任务生成、事件检测、事件入队 | SessionRepository, DefinitionRepository |
| `WarStubSystem` | 简化出征与战果结算 | SessionRepository |
| `AISimulationSystem` | 非玩家角色/势力旬末行为 | SessionRepository, QueryRepository |

### Mandatory boundary rule

**系统之间尽量通过 `GameRoot` 明确调度，或通过有限领域事件通信；不要让每个系统互相随便 call。**

原型里最危险的不是“功能少”，而是“结算顺序模糊”。

### Recommended settlement pipeline

每旬结束建议固定顺序：

```text
玩家行动确认
-> ActionResolutionSystem
-> Character/Relation immediate updates
-> TimeSystem.end_xun()
-> Faction / Clan / FactionGroup passive settlement
-> TaskEventSystem trigger scan
-> AISimulationSystem
-> if 月末: CareerSystem + 月末评定 + 月度事件
-> Summary payload to UI
```

这个顺序比“靠信号谁先收到谁先跑”安全得多。

---

## 5. Event / Signal Strategy

Godot 的 signals 很适合解耦，但本项目应采用：**有限事件总线 + 显式结算顺序**。

### Good use of signals

- UI 按钮点击 -> 发出玩家意图
- 系统完成结算 -> 通知 UI 刷新
- 事件队列新增可显示内容 -> Modal 弹出

### Bad use of signals

- 把完整月末结算拆成 8 个系统互相监听链式触发
- 让关系变化自动再触发官职变化，再触发事件变化，再触发 UI 改写

### Recommendation

只保留少量显式领域事件：

- `action_resolved`
- `xun_ended`
- `month_ended`
- `appointment_updated`
- `event_queued`
- `session_loaded`

并由 `GameRoot` 控制主流程，signals 主要承担“通知”，不是“主调度”。

---

## 6. UI Architecture

## 6.1 UI Layers

| Layer | Contents | Responsibility |
|------|----------|----------------|
| `HUDLayer` | 主 HUD、时间条、资源概览、快捷入口 | 常驻信息与主导航 |
| `PanelLayer` | 角色页、关系页、势力页、家族/士族页、行动页 | 查询、规划、选择 |
| `ModalLayer` | 行动结果、事件弹窗、确认框 | 中断式反馈 |
| `SummaryLayer` | 旬末/月末结算页 | 阶段总结与因果解释 |

## 6.2 UI composition rule

- 每个面板单独做成一个 scene。
- `MainHUD.tscn` 只负责导航与常驻信息。
- `CharacterPanel.tscn` / `RelationPanel.tscn` / `FactionPanel.tscn` / `ClanPanel.tscn` / `ActionPanel.tscn` 都独立实例化。
- 弹窗和结算页独立成 modal scene，便于后续替换表现。

### Why

Godot 官方建议“游戏特有概念优先做 scene”，比纯脚本动态拼 UI 更易编辑、复用和调试。

## 6.3 UI boundary

**UI 只能做 3 件事：**

1. 展示 query snapshot  
2. 收集玩家输入  
3. 调用 `GameRoot`/应用服务接口提交 intent  

**UI 不能做：**

- 不直接修改 `CharacterState`
- 不自己算成功率
- 不自己决定任命结果
- 不直接读写存档文件

---

## 7. Managers vs Systems vs Repositories

这是本项目最容易混乱的命名点，建议明确区分：

| Type | What it is | In this project |
|------|------------|-----------------|
| Manager | 协调器/生命周期控制器 | `GameRoot`, `UIFlowController` |
| System | 规则执行者 | `TimeSystem`, `RelationSystem`, `CareerSystem` |
| Repository | 数据访问与索引层 | `DefinitionRepository`, `SessionRepository` |
| Service | 基础设施能力 | `SaveLoadService`, `ScenarioBuilder` |

### Practical rule

- 名字里带 `Manager` 的对象必须“少而薄”。
- 真正复杂逻辑放进 `System`。
- 数据读写入口统一进 `Repository`。

否则很快会变成 `XXXManager` 什么都做。

---

## 8. Save / Load Boundary

## What should be saved

只保存：

- 当前剧本 ID
- 当前时间（年/月/旬）
- 玩家角色 ID
- 各运行时 state 映射
  - 人物当前属性/状态
  - 当前关系数值
  - 当前城市/势力资源
  - 当前官职/派系归属
  - 当前事件队列 / 任务进度
- RNG seed / 历史分支标记（如需要复现）
- Save schema version

## What should NOT be saved

- `Node` 引用
- `Control` 状态树
- 当前打开了哪个 UI 面板（最多作为可选 convenience，不作为核心存档）
- 静态剧本定义 Resource 本体
- 通过场景路径强绑定的临时对象引用

## Save flow

```text
GameRoot requests snapshot
-> SessionRepository exports SaveDTO
-> SaveLoadService serializes to user://
-> file written with schema version
```

## Load flow

```text
Read save file
-> validate schema version
-> DefinitionRepository loads scenario defs
-> ScenarioBuilder rebuilds SessionState from defs + save payload
-> GameRoot rebinds systems
-> UI receives session_loaded and refreshes
```

### Key principle

**Load 是“重建这一局状态”，不是“恢复当时的节点树”。**

这点与 Godot 官方保存文档一致：保存应围绕持久对象和可序列化数据，而不是试图把整个运行树直接冻住。

---

## 9. Component Boundaries

| Component | Responsibility | Communicates With |
|-----------|---------------|-------------------|
| `AppBootstrap` | 启动、进入主场景、开局/读档入口 | `MainScene`, `SaveLoadService` |
| `GameRoot` | 组合根、主流程调度、依赖注入 | All systems, repositories, UI controllers |
| `DefinitionRepository` | 静态剧本资源加载与索引 | `GameRoot`, query/services |
| `SessionRepository` | 当前局状态读写 | Systems, save service |
| `QueryRepository` | 供 UI 使用的读模型拼装 | UI controllers, systems |
| `TimeSystem` | 推进旬/月，触发结算阶段 | `GameRoot`, `SessionRepository` |
| `ActionResolutionSystem` | 玩家行动结算 | `SessionRepository`, `DefinitionRepository` |
| `RelationSystem` | 关系值变化与查询支持 | `SessionRepository`, `QueryRepository` |
| `CareerSystem` | 功绩、官职、任命逻辑 | `SessionRepository`, `FactionSystem` |
| `ClanFamilySystem` | 家族/士族/婚配修正 | `SessionRepository`, `DefinitionRepository` |
| `FactionGroupSystem` | 势力内部派系逻辑 | `SessionRepository`, `FactionSystem` |
| `TaskEventSystem` | 事件检测、任务推进、事件入队 | `SessionRepository`, UI modal controller |
| `SaveLoadService` | DTO 序列化/反序列化 | `GameRoot`, repositories |
| `UIFlowController` | 面板开关、modal 编排 | `GameRoot`, panel scenes |
| `HUD/Panel/Modal scenes` | 展示与输入 | `UIFlowController`, `QueryRepository` |

### Communication rule in one sentence

**UI -> GameRoot/Application API -> Systems -> SessionRepository -> QueryRepository -> UI**

---

## 10. Data Flow

## 10.1 New game flow

```text
Scenario selected
-> DefinitionRepository loads static defs
-> ScenarioBuilder creates SessionState
-> SessionRepository stores current state
-> GameRoot binds systems
-> QueryRepository produces first screen snapshot
-> HUD and panels render
```

## 10.2 Player action flow

```text
Player clicks action
-> ActionPanel submits ActionIntent
-> GameRoot validates routing
-> ActionAvailabilitySystem checks legality
-> ActionResolutionSystem applies costs/results
-> Character/Relation/Career systems update impacted state
-> QueryRepository rebuilds affected views
-> Result modal + HUD refresh
```

## 10.3 End-of-xun flow

```text
Player ends xun
-> GameRoot calls TimeSystem
-> TimeSystem advances clock
-> Settlement pipeline runs in fixed order
-> TaskEventSystem queues events
-> Month-end systems run if needed
-> SummaryLayer displays why things changed
```

## 10.4 Save/load flow

```text
Save request
-> SessionRepository exports DTO
-> SaveLoadService writes file

Load request
-> SaveLoadService reads DTO
-> DefinitionRepository reloads scenario defs
-> ScenarioBuilder rebuilds SessionState
-> GameRoot rehydrates systems and UI
```

---

## 11. Suggested Build Order

这是最适合 roadmap 的实现顺序，因为它严格沿着依赖关系展开。

### Phase A — Data Spine + Session Skeleton

先做：

- `ScenarioData / CharacterData / CityData / FactionData`
- `DefinitionRepository`
- `SessionState` / `SessionRepository`
- `GameRoot` 空骨架

**Why first:** 没有稳定 ID、定义层、运行时状态层，后面所有系统都会返工。

### Phase B — Time Loop + HUD Shell

接着做：

- `TimeSystem`
- `MainHUD`
- 基础查询接口
- 旬推进 / 基础状态展示

**Dependency:** 依赖 Session 骨架。

### Phase C — Action Loop

再做：

- `ActionData`
- `ActionAvailabilitySystem`
- `ActionResolutionSystem`
- `ActionPanel`
- `ResultModal`

**Milestone:** 玩家能在单城内完成“选行动 -> 扣 AP/精力 -> 得反馈”。

### Phase D — Character + Relation Closed Loop

再接：

- `CharacterSystem`
- `RelationSystem`
- `CharacterPanel`
- `RelationPanel`

**Milestone:** 行动结果能被人物成长与关系变化解释。

### Phase E — Career / City / Faction Layer

再接：

- `CareerSystem`
- `FactionSystem`
- `OfficeData`
- `FactionPanel`
- 月末评定页

**Milestone:** 行动 -> 功绩 -> 任命/权限 的闭环成立。

### Phase F — Clan / Family / Marriage Eligibility

再接：

- `ClanFamilySystem`
- `ClanData / FamilyData`
- 家族/士族页
- 联姻资格与举荐修正

**Milestone:** 玩家第一次感知“我不是孤立人物”。

### Phase G — Faction Groups / Internal Politics

再接：

- `FactionGroupSystem`
- 任命支持/反对逻辑
- 派系可视化信息

**Milestone:** 玩家能理解“为什么升官/没升官”。

### Phase H — Event / Task / SaveLoad

再接：

- `TaskEventSystem`
- `SaveLoadService`
- `SummaryLayer`

**Milestone:** 原型可跨多个旬/月稳定运行并可恢复。

### Phase I — War Stub

最后做：

- `WarStubSystem`
- `WarResultPanel`

**Why last:** 战争在原型中是重要补充，但不是验证单角色政治循环的前置依赖。

---

## 12. Prototype-Specific Godot Tradeoffs

### Tradeoff 1: Fewer Autoloads, more explicit composition

**Use because:** 官方文档明确警告 Autoload 容易演化为全局状态泥球。  
**Cost:** 需要 `GameRoot` 做更多装配工作。  
**Worth it:** 是，尤其是你这个项目系统多、互相影响强。

### Tradeoff 2: Resource-driven static data, runtime state in separate containers

**Use because:** Godot 的 `Resource` 非常适合定义数据；但直接把运行时变化写进 Resource 容易污染模板。  
**Cost:** 需要两层数据对象。  
**Worth it:** 非常值得，这是后续扩剧本的基础。

### Tradeoff 3: Signal-assisted UI refresh, not signal-driven core rules

**Use because:** signals 解耦好，但复杂结算若完全靠 signals，顺序难以推理。  
**Cost:** 需要显式 settlement pipeline。  
**Worth it:** 是，本项目大量“旬末/月末因果解释”必须可追踪。

### Tradeoff 4: Single MainScene first, richer world scenes later

**Use because:** 现阶段验证的是决策循环，不是空间沉浸。  
**Cost:** 初期不够“像大地图游戏”。  
**Worth it:** 是，能显著压低原型开发成本。

### Tradeoff 5: Scene-based UI panels, script/resource-based rules and data

**Use because:** Godot 官方建议游戏特有概念优先 scene；数据优先 resource/object。  
**Cost:** 需要同时维护 scene 与 script 两种组织方式。  
**Worth it:** 是，这正是 Godot 的自然工作流。

---

## 13. Anti-Patterns to Avoid

### Anti-Pattern 1: `GameManager` 神对象

**What:** 一个全局单例同时处理时间、行动、关系、存档、UI 刷新。  
**Why bad:** 任意改动都会影响全局；调试路径失控。  
**Instead:** `GameRoot` 只调度，规则拆到 systems，数据拆到 repositories。

### Anti-Pattern 2: UI 里直接写业务逻辑

**What:** 按钮里直接改角色属性、关系、功绩。  
**Why bad:** 换 UI 必返工；逻辑不可复用；测试困难。  
**Instead:** UI 只提交 `ActionIntent` 和刷新视图。

### Anti-Pattern 3: 静态定义与运行时状态混写

**What:** 直接修改 `CharacterData.tres` 里的当前 AP 或所在城。  
**Why bad:** 读档、回档、重开局都容易污染模板。  
**Instead:** 定义层 immutable-ish，状态层独立持有变化值。

### Anti-Pattern 4: 系统通过隐式 signals 链式结算

**What:** 一个 signal 引发多个系统继续发 signal，靠时机碰运气。  
**Why bad:** 月末因果不可解释，极难定位 bug。  
**Instead:** `GameRoot` 固定阶段顺序，signals 主要用来通知 UI。

### Anti-Pattern 5: 存档保存 Node 树快照思维

**What:** 想直接持久化当前 scene/control 结构。  
**Why bad:** 脆弱、难兼容版本变更、与数据驱动方向冲突。  
**Instead:** 保存 DTO + ID + version，加载时重建 SessionState。

---

## 14. Scalability Considerations

| Concern | Prototype | Later expansion |
|---------|-----------|-----------------|
| Data volume | 3~5 城 / 30~50 人可直接全量载入内存 | 全国剧本时仍保留全局索引，但 UI 查询需分页/过滤 |
| Rule complexity | 固定顺序结算即可 | 结算阶段可拆子阶段，但仍保持显式 pipeline |
| UI size | 单主场景 + 面板切换最省事 | 后续可替换为地图/驻地/战役分场景 |
| Save compatibility | DTO + schema version 足够 | 版本迁移脚本必须尽早保留口子 |
| AI load | 旬末统一简单模拟 | 后续可分层模拟：关键人物精算，边缘人物轻算 |

---

## Final Recommendation

对这个 Godot 原型，最稳的架构不是“更多 Manager”，而是：

**一个薄的应用引导层、一个明确的组合根、一个稳定的数据骨架、若干边界清楚的规则系统、以及完全被动的 UI 层。**

如果 roadmap 要按架构依赖排序，应先锁定：

1. **数据模型与仓库边界**  
2. **旬制主循环与行动闭环**  
3. **关系/仕途反馈闭环**  
4. **士族/派系等特色政治层**  
5. **事件、存档、战争补充层**

这是最符合项目目标的 build order：先证明“单角色命运嵌入势力政治”的闭环，再增加特色深度。

---

## Sources

### Internal design docs
- `.planning/PROJECT.md`
- `design/系统设计/核心系统详细设计 v1.md`
- `design/原型与实现/Godot 原型开发拆解 v1.md`
- `design/数据/Godot 数据结构草案 v1.md`
- `design/UIUX/原型 UI 流程图 v1.md`

### Official Godot documentation
- Autoloads versus regular nodes — https://docs.godotengine.org/en/stable/tutorials/best_practices/autoloads_versus_internal_nodes.html
- Scene organization — https://docs.godotengine.org/en/stable/tutorials/best_practices/scene_organization.html
- When to use scenes versus scripts — https://docs.godotengine.org/en/stable/tutorials/best_practices/scenes_versus_scripts.html
- When and how to avoid using nodes for everything — https://docs.godotengine.org/en/stable/tutorials/best_practices/node_alternatives.html
- Resources — https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html
- Singletons (Autoload) — https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html
- Using signals — https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html
- Saving games — https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html
- User interface (UI) — https://docs.godotengine.org/en/stable/tutorials/ui/index.html

### Confidence notes
- **HIGH:** Godot-specific guidance on Autoload, Resource, signals, save patterns, scene/UI composition.
- **HIGH:** Project-specific architecture direction already implied by internal docs.
- **MEDIUM:** Exact repository/service naming and system cut lines are opinionated recommendations for this prototype rather than Godot mandates.
