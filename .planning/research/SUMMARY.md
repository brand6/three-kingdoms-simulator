# Project Research Summary

**Project:** 三国模拟器
**Domain:** 单角色三国历史模拟 Godot 原型
**Researched:** 2026-04-04
**Confidence:** MEDIUM-HIGH

## Executive Summary

这是一个 **UI-heavy、数据驱动、单角色视角** 的三国历史模拟原型，目标不是先做全国 SLG，也不是先堆内容，而是在 15–30 分钟内证明“个人命运嵌入势力政治”这条核心体验成立。综合研究结论，业内与项目文档都指向同一个方向：先用 **局部 190 剧本样本 + 旬制主循环 + 关系/功绩/任命闭环 + 家族/士族/派系高影响修正**，做出可解释、可重复验证的政治人生模拟。

技术上最稳的路线是 **Godot 4.6.2 stable + Typed GDScript + Control UI + Custom Resource 静态数据 + 独立 Runtime State + Autoload 仅做薄引导 + `user://` JSON 存档**。架构上必须坚持“静态定义与运行时状态分离、UI 只提交意图不改业务数据、系统按固定结算流水线执行、存档只保存 DTO/状态不保存节点树”。这套做法最符合原型速度、可调试性和后续扩量需求。

最大风险不在美术或内容量，而在 **范围漂移与系统黑箱化**：原型很容易滑成上帝视角势力管理器、被战争/地图吞掉范围，或因为结算顺序混乱、士族派系只停留在设定文本而失去核心差异化。应对策略很明确：先锁数据边界和结算顺序，再做行动—关系—仕途闭环，随后把家族/士族/派系/婚姻作为少量但高影响的政治变量接入主循环，并同步建设解释层与调试工具。

## Key Findings

### Recommended Stack

研究对技术方向高度一致：这个原型不该从复杂工具链起步，而应优先使用 Godot 原生能力把玩法闭环跑通。首选栈是 **Godot 4.6.2 stable + Typed GDScript + Control/Container/Theme + Custom Resource + Repositories + JSON saves**，其中 C#、数据库、大型对话插件都不应成为 P0 前提。

**Core technologies:**
- **Godot 4.6.2 stable**：项目运行与编辑基础 — 当前稳定版，最适合原型而非追 dev 版。
- **Typed GDScript**：主逻辑语言 — 与 Resource、Inspector、Autoload、signals 配合最佳，维护成本低于 C# 起步。
- **Control + Container + Theme**：全部主 UI — 项目是面板驱动而非地图驱动，Godot 原生 UI 正好适配。
- **Custom Resource (`.tres`)**：静态定义数据层 — 适合人物、城市、势力、家族、官职、行动、事件等可序列化定义。
- **Autoload（薄层）+ GameRoot**：应用引导与会话装配 — 适合做启动、场景进入、全局配置，不适合承载所有业务。
- **SessionState / Repository 分层**：运行时状态骨架 — 避免定义数据污染，支撑查询、结算、存档与 UI 刷新。
- **FileAccess + JSON (`user://`)**：原型期存档 — 可读、可 diff、可修坏档，且易做 schema_version。
- **表格导入到 Resource**：中期内容管线 — 作者维护表格，游戏运行吃 Resource，兼顾效率与 Godot 原生工作流。

**Critical version requirements:**
- Godot **4.6.2 stable** 为首选。
- 若后续局部使用 C# 工具链，需 Godot **.NET 版 + .NET 8+**。
- 二进制序列化可作为后续优化，但不应替代首版 JSON 存档。

### Expected Features

功能研究的核心结论是：原型要证明的不是“功能多”，而是“每旬选择都会通过关系、家族与派系政治改变人生路径”。因此首版必须优先做闭环，而不是铺地图、堆人物或先做战争表现。

**Must have (table stakes):**
- **旬制单角色主循环** — 玩家每旬有行动选择、资源消耗、结算反馈与下一轮规划。
- **明确的行动菜单与即时反馈** — 至少覆盖成长、交际、政务/任务、休整/家族互动等核心动作。
- **角色成长与状态资源** — 属性、名望、功绩、AP/精力/压力持续可见且能反馈决策代价。
- **关系系统** — 拜访、送礼、请教、结交等行为能实质影响后续仕途。
- **仕途/任务/任命闭环** — 玩家行动必须进入月末评价、任命、升迁或受挫反馈。
- **派系/政治环境可见化** — 玩家必须知道谁支持、谁反对、为什么失败。
- **家族/出身基础影响** — 寒门与世家差异必须影响举荐、婚配、仕途机会。
- **婚姻作为政治入口** — 至少证明一次议婚会改变关系网络或仕途机会。
- **历史事件与分歧入口** — 让玩家感到自己在参与历史，而非纯数值循环。
- **因果可解释反馈 UI** — 旬末/月末说明原因，不让系统变黑箱。

**Should have (competitive differentiators):**
- **士族/门阀三层结构（士族→家族→个人）** — 项目最重要的独特性，应尽早保留。
- **政治因果透明化** — 任命失败、婚配受阻、被排挤都应有可见原因链。
- **婚姻作为政治通道** — 不是收集配偶，而是打开姻亲、举荐与派系关系网络。
- **全身份共底层规则** — 君主、文臣、武将、在野共享同一时间/行动/关系骨架，差异来自权限与事件池。
- **小样本高密度 190 剧本** — 用 3–5 城、2–3 势力、30–50 人的高互动样本证明玩法。

**Defer (v2+):**
- 全国大地图与全势力宏观经营
- 完整战场 / 实时战斗 / 兵种细节系统
- 深继承法、复杂子嗣教育与重家谱模拟
- 海量随机文本事件与全量历史人物/事件链
- 不同身份完全独立的子玩法模式

### Architecture Approach

推荐架构是 **单主场景 + 薄 Autoload Bootstrap + GameRoot 组合根 + Repository 数据层 + Systems 规则层 + 被动 UI 面板层**。这套结构既符合 Godot 官方最佳实践，也与项目文档一致：Autoload 只处理广域初始化，真正的业务调度由 `GameRoot` 负责；静态定义与运行时状态分离；UI 只能展示和提交意图；系统按固定 settlement pipeline 结算；存档只保存运行时 DTO 并在加载时重建会话。

**Major components:**
1. **AppBootstrap / GameRoot** — 启动应用、创建会话、注入依赖、控制旬末/月末固定结算顺序。
2. **DefinitionRepository / SessionRepository / QueryRepository / SaveRepository** — 分别负责静态定义、运行时状态、UI 查询视图与存档序列化。
3. **Domain Systems** — `TimeSystem`、`ActionResolutionSystem`、`RelationSystem`、`CareerSystem`、`ClanFamilySystem`、`FactionGroupSystem`、`TaskEventSystem`、`WarStubSystem` 等分工执行规则。
4. **UI Layers** — HUD、Panel、Modal、Summary 分层展示，只消费 query snapshot，不直接修改 state。

### Critical Pitfalls

1. **原型滑成上帝视角势力管理器** — 所有身份必须共享时间/AP/执行链条；君主只能权限更高，不能跳过个人约束。
2. **定义数据与运行时状态混写** — 必须分离 Definitions / Runtime State / ViewModel，并及早定义存档白名单。
3. **Autoload/Manager 膨胀成全局黑箱** — 让 `GameRoot` 只做调度，复杂逻辑进 Systems，数据进 Repositories。
4. **结算顺序漂移导致不可解释** — 固化“玩家行动 → 旬末状态/关系 → AI → 月末任命/资源 → 事件”的流水线，并输出日志。
5. **士族/家族/派系只停留在文本设定** — 必须接入举荐、婚配、任命、事件池与仕途修正，否则项目失去差异化。
6. **结果黑箱化** — 任命、婚姻、关系、事件结果都要显示 2–4 个主要因子与失败原因。
7. **被战争/地图/内容量吞范围** — 战争只做入口和战果反馈，地图与大规模内容全部后置。
8. **缺少调试与回放工具** — 对 systems-heavy 原型，状态查看、日志、强制推进、改值、基础存档不是附属品，而是验证基础设施。

## Implications for Roadmap

Based on research, suggested phase structure:

### Phase 1: 数据骨架与旬制外壳
**Rationale:** 这是所有后续系统的依赖根。若先不锁数据边界、ID 索引和时间推进，后面每个系统都会返工。  
**Delivers:** `Scenario/Character/Faction/City` 等基础定义、`DefinitionRepository`、`SessionState/SessionRepository`、`GameRoot`、基础 HUD、旬推进与结算外壳。  
**Addresses:** 旬制主循环、角色状态展示、关键状态常驻显示。  
**Avoids:** 定义/状态混写、Autoload 神对象、万物皆节点、布局不可维护、结算顺序漂移。  
**Research need:** **低** — 已有清晰 Godot 标准模式，可直接规划实现。

### Phase 2: 行动—成长—关系闭环
**Rationale:** 这是最早可验证“我作为一个具体人物在生活与交际”的阶段，也是项目最小可玩性来源。  
**Delivers:** `ActionData`、行动合法性与结算系统、结果弹窗、角色成长、关系变化、角色页/关系页、旬末总结。  
**Addresses:** 行动菜单、即时反馈、属性/状态成长、关系系统、因果可解释反馈的第一层。  
**Avoids:** 失败纯亏、UI 直写业务逻辑、结果黑箱化。  
**Research need:** **低** — 模式成熟，重点是按既定边界执行。

### Phase 3: 仕途、势力与可解释政治层
**Rationale:** 只有把行动结果转进功绩、任命、支持/反对与权限变化，项目才真正从“养成面板”升级为“政治人生模拟”。  
**Delivers:** `CareerSystem`、`FactionSystem`、月末评定、任命逻辑、势力页/派系页、任命阻塞原因展示。  
**Addresses:** 仕途/任务/任命闭环、派系/政治环境可见化、政治因果透明化。  
**Avoids:** 原型滑向普通养成器、派系只有展示没有作用、任命黑箱。  
**Research need:** **中** — 规则实现模式已明确，但任命解释层与派系影响权重需要设计阶段再校准。

### Phase 4: 家族、士族、婚姻与历史分歧
**Rationale:** 这是本项目与一般三国 officer-play 拉开差异的关键层，应在主循环稳定后作为高影响政治变量接入。  
**Delivers:** `ClanData/FamilyData`、`ClanFamilySystem`、婚姻接口、举荐/门第修正、若干关键历史事件与任务链。  
**Addresses:** 家族/出身基础影响、婚姻作为政治入口、历史事件与分歧入口、士族/门阀三层结构。  
**Avoids:** 士族/家族只做 flavor 文本、婚姻脱离政治、先写文本后补结构。  
**Research need:** **高** — 这一阶段最需要 `/gsd-research-phase`，尤其是事件 schema、士族/门第作用面、婚姻政治后果与历史模型可辩护性。

### Phase 5: 存档、调试工具与战争接入口
**Rationale:** 当主循环与政治层成立后，再补可持续验证能力和非核心补充系统，避免过早被战争拖偏。  
**Delivers:** `SaveLoadService`、schema-versioned JSON saves、调试面板、日志/回放支持、简化 `WarStubSystem` 与战果反馈页。  
**Addresses:** 存档恢复、多旬/月稳定验证、简化战争入口。  
**Avoids:** 无法复现复杂系统、战争吞范围、脆弱存档设计。  
**Research need:** **低-中** — 存档与调试为标准模式；战争只做 stub，不需要重研究完整战场。

### Phase Ordering Rationale

- **先骨架，后政治深度。** 数据定义、运行时状态、时间与行动闭环是所有后续系统的共同依赖。
- **先闭环，后差异化。** 关系与仕途必须先成立，否则士族、婚姻、派系接入只会变成装饰。
- **先解释层，后扩系统。** 每加一个系统，都必须同步能解释“为什么发生”，否则复杂度只会变成噪音。
- **先局部高密度样本，后扩内容。** Roadmap 应围绕可玩样本推进，不围绕内容量推进。
- **战争与表现后置。** 研究一致认为它们是重要补充，但不是验证核心价值的前置条件。

### Research Flags

Phases likely needing deeper research during planning:
- **Phase 3:** 任命/派系影响的公式解释层需要进一步校准，避免黑箱或过度复杂。
- **Phase 4:** 家族/士族/婚姻/历史事件是项目差异化核心，也是最容易做空或做歪的部分，建议专门补研究。

Phases with standard patterns (skip research-phase):
- **Phase 1:** Godot 数据骨架、Autoload 边界、主场景结构、Resource/Repository 分层已有明确模式。
- **Phase 2:** 行动、关系、HUD、结果弹窗和结算摘要都有稳定实现路径。
- **Phase 5（存档/调试部分）:** JSON + `user://` 存档、schema version、调试日志与状态查看属于成熟模式。

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | 主要基于 Godot 官方文档与当前稳定版信息，结论明确且与项目约束高度匹配。 |
| Features | MEDIUM-HIGH | 项目设计文档与 RTK/CK 类产品预期高度一致，但具体取舍仍带一定产品判断。 |
| Architecture | MEDIUM-HIGH | Godot 官方最佳实践与项目现有文档方向一致；具体 repository/system 切法带一定工程主张。 |
| Pitfalls | HIGH-MEDIUM | 大部分风险与项目文档、Godot 实践高度一致；历史模拟“可辩护模型”部分有少量推断成分。 |

**Overall confidence:** MEDIUM-HIGH

### Gaps to Address

- **任命/派系权重公式仍需产品校准：** 规划阶段应明确哪些因子前台展示、哪些只做后台修正，并限制修正项数量。
- **婚姻与士族政治作用面需收窄：** 要先定义最小硬影响面（举荐、婚配、任命、事件）再扩展，不要追求百科式完整。
- **事件 schema 需要先定结构再写文本：** 包括触发条件、参与者、效果、解释标签、后续钩子与历史分歧标记。
- **调试工具应进入 requirements 而非作为收尾优化：** 否则系统一多，验证效率会迅速下降。
- **全身份共享底层规则需要明确边界：** 建议 requirements 阶段先锁“身份差异只改权限/事件池/修正”，避免 roadmap 被身份分叉拖爆。

## Sources

### Primary (HIGH confidence)
- `.planning/PROJECT.md` — 项目边界、核心价值、约束、范围控制
- `.planning/research/STACK.md` — Godot 技术栈结论与官方来源汇总
- `.planning/research/FEATURES.md` — table stakes、differentiators、anti-features、实现顺序
- `.planning/research/ARCHITECTURE.md` — 主场景、数据分层、系统边界、构建顺序
- `.planning/research/PITFALLS.md` — 分阶段风险、反模式与防错重点
- Godot 官方文档（Resources / UI / Theme / Autoload / Saving games / FileAccess / DirAccess / Scene organization / Signals）— 技术与架构模式验证
- Godot 官方下载页 / .NET 8 公告 — 版本与 C# 工具链要求验证

### Secondary (MEDIUM confidence)
- RTK8 Remake 官方系统页面 — officer-play、关系图谱、婚姻/子嗣、任务/政治循环的品类预期参考
- RTK8 Remake 新特性页面 — 状态差异化与政治命令扩展方向参考
- Crusader Kings III 官方介绍页 — 家族延续、关系、婚姻、头衔与政治模拟预期参考
- 项目内部设计文档（系统设计、数据结构、UI 流程、任务拆解）— 项目适配性验证

### Tertiary (LOW confidence)
- Dialogue Manager 3 Asset Library 页面 — 仅作为后续文本工具弱候选，不构成当前方案依赖
- The Guild 3 政治系统资料 — 仅作角色/政治模拟支撑性参考
- 历史游戏可辩护模型相关文章 — 适合作为事件与历史建模的原则补充，非硬实现依据

---
*Research completed: 2026-04-04*
*Ready for roadmap: yes*
