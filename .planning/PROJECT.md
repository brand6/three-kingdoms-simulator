# 三国模拟器

## What This Is

一款基于 190 年群雄割据剧本、以单角色扮演为核心的三国历史模拟单机游戏。玩家以具体历史人物的身份行动，在旬制时间循环中通过个人成长、人物关系、仕途经营、士族门阀网络、婚姻家族关系与势力派系斗争参与并改写三国历史。当前目标是先完成可验证核心体验的 Godot 原型，而不是一次做成完整大作。

## Core Value

让玩家在 15 到 30 分钟内明确感受到“个人命运嵌入势力政治”的单角色历史模拟体验。

## Requirements

### Validated

(None yet — ship to validate)

### Active

- [ ] 建立以旬为单位的单角色主循环，让玩家能持续进行行动选择、结算反馈与下一轮规划。
- [ ] 做出可玩的原型闭环，覆盖属性/状态、关系变化、功绩/任命反馈，并让不同身份建立在同一底层逻辑上。
- [ ] 接入士族门阀、家族、派系等三国特色政治系统，并让其对仕途、婚姻、举荐和事件产生可感知影响。
- [ ] 采用小规模 190 剧本样本验证体验，包含局部城市、势力、人物、士族与基础事件数据。
- [ ] 用 Godot 的数据驱动架构搭起后续可扩展的原型基础，包括主场景、管理器、UI 面板和可序列化数据对象。

### Out of Scope

- 完整全国地图漫游 — 原型阶段优先验证核心循环，不先做大地图表现。
- 超复杂实时战场与完整战役系统 — 首版只需要简化出征与战果反馈，避免战争系统吞掉开发范围。
- 深度继承法、复杂子嗣教育与极深家谱模拟 — 当前重点是婚配价值、家族延续感与最小接续机制。
- 全量历史人物、全量事件链与超细粒度经济系统 — 先做局部样本和关键链路，避免内容量失控。

## Context

- 项目是 Godot 原型项目，设计文档已经较完整，覆盖总纲、系统设计、数值骨架、数据结构、UI 流程和原型任务拆解。
- 产品方向已明确：不是传统上帝视角三国 SLG，也不是纯 RPG，而是单角色视角下的历史人物命运模拟。
- 现有设计强调统一底层逻辑，身份差异主要来自行动权限、任务来源、事件池和政治处境，而不是切换成不同游戏类型。
- 原型建议采用单主场景 + 数据管理器 + 多 UI 面板 + 事件驱动更新，先以界面驱动验证玩法，再扩沉浸式表现。
- 设计文档已经给出原型推荐样本规模、任务拆解顺序、系统优先级和验收标准，适合直接转成 requirements 与 roadmap。

## Constraints

- **Tech stack**: 使用 Godot 构建单机原型，并以数据驱动方式组织角色、势力、城市、关系、行动与事件数据 — 这是当前设计文档反复强调的落地方向。
- **Scope**: 先做 3 到 5 座城市、2 到 3 个势力、30 到 50 名人物、5 到 8 个士族的局部样本 — 需要在可控规模内验证玩法。
- **Product**: 必须坚持单角色视角，君主玩法也不能退化为传统全局 4X/SLG — 这是项目最核心的设计边界。
- **Architecture**: 统一底层规则优先于身份深度差异化 — 否则全身份设计会导致系统爆炸与实现失控。
- **UX**: 关键状态常驻显示，关键行动不超过 3 次点击，月末与事件反馈必须解释因果 — 原型 UI 的价值在于快速验证而不是美术完成度。
- **Delivery**: 优先做最小可玩闭环，再扩展士族、派系、婚姻、战争与历史事件 — 项目目标是验证核心体验，不是一次性完成全部设计野心。

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| 先以 Godot 原型验证核心体验，而不是直接做完整产品 | 当前最大风险是范围失控，原型更适合验证单角色主循环是否成立 | — Pending |
| 采用旬制时间推进作为主循环骨架 | 旬是最适合承载行动、反馈、月末结算与历史推进的单位 | — Pending |
| 以单主场景 + 数据管理器 + UI 面板切换 + 事件驱动系统起步 | 能最快落地、便于验证和后续替换 | — Pending |
| 先做局部 190 剧本样本而不是全国完整内容 | 样本规模可控，能更快验证系统与数据结构 | — Pending |
| 首版战争只做简化接入，不做复杂战场表现 | 战争是重要分支，但不应吞掉原型阶段的大部分时间 | — Pending |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd-transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd-complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-04-04 after initialization*
