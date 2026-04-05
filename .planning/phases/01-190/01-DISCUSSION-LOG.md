# Phase 1: 190样本数据骨架与单角色入口 - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-04-05
**Phase:** 01-190样本数据骨架与单角色入口
**Areas discussed:** 样本范围, 入口流程, HUD信息, 身份验证, Luban接入, 运行时格式, Schema范围, 主场景结构, HUD未来入口

---

## Area Selection

**User selected:**
- HUD信息
- 样本范围
- 入口流程
- 身份验证
- 参考文档：`design/原型与实现/原型任务拆解清单 v1.md`

---

## 样本范围

| Option | Description | Selected |
|--------|-------------|----------|
| 轻代表样本 | 底层按多实体设计，首批资源做 5-8 人、2 城、2 势力左右，既能验证结构，也不过早膨胀 | |
| 最小烟雾样本 | 只做 1 人、1 城、1 势力先跑通启动和显示，后面再扩数据关系 | ✓ |
| 直接小型190样本 | 一开始就做更接近正式原型的局部样本，数据更完整但 Phase 1 工作量更高 | |

**User's choice:** 最小烟雾样本
**Notes:** 用户希望 Phase 1 尽量收窄，先把启动、装载、查询和显示骨架跑通。

---

## 入口流程

| Option | Description | Selected |
|--------|-------------|----------|
| 直接进默认主角 | 启动后自动加载默认 190 烟雾样本和默认主角，最快验证主场景、数据装载和 HUD | ✓ |
| 先选剧本再进入 | 保留剧本选择入口，但先不做人选选择 | |
| 先选人物再进入 | 启动后就让玩家先选主角，体验更完整但会增加 Phase 1 入口工作量 | |
| 你决定 | 入口形式交给后续规划时决定 | |

**User's choice:** 直接进默认主角
**Notes:** Phase 1 不做剧本/人物选择 UI，但入口代码要保留未来扩展点。

---

## HUD信息

| Option | Description | Selected |
|--------|-------------|----------|
| 原型总览型 | 直接显示时间、人物、身份、势力、官职、AP/精力/压力/名望/功绩，外加少量占位入口，后续沿这套演进 | ✓ |
| 调试骨架型 | 先偏开发调试，只显示关键字段和日志，后面再重做正式 HUD | |
| 极简状态型 | 只显示最核心 4-6 个字段，把其余信息推迟到后续 phase | |

**User's choice:** 原型总览型
**Notes:** 用户希望 Phase 1 的 HUD 就是后续原型真实界面的基础，而不是一次性 debug 面板。

---

## 身份验证

| Option | Description | Selected |
|--------|-------------|----------|
| 内部多身份样本 | 资源里准备多种身份样本，启动默认仍只进一个主角，但开发/调试可切换验证同一套底层规则 | |
| 只做默认身份 | Phase 1 先只做一个身份，统一规则留到 Phase 2/3 再证明 | ✓ |
| 开局可选身份 | 玩家启动时就能切换不同身份进入，同阶段就对外验证多身份入口 | |
| 你决定 | 验证方式交给后续规划阶段决定 | |

**User's choice:** 只做默认身份
**Notes:** 用户接受把多身份共底层规则先作为架构约束保留，而不是 Phase 1 的对外演示目标。

---

## Luban接入

| Option | Description | Selected |
|--------|-------------|----------|
| Phase1直接接入 | 从一开始就用 Excel + Luban 生成原型数据，Phase 1 的 DataRepository 直接建立在这条正式管线上 | ✓ |
| Phase1先临时数据 | 先用手写 JSON/资源把骨架跑通，Luban 放到后续 phase 再接 | |
| 折中接入 | Phase 1 先建 Luban schema 和目录结构，但运行时先吃少量手工导出的文件，避免一开始把工具链做太深 | |

**User's choice:** Phase1直接接入
**Notes:** 用户明确希望 Excel 成为正式数据源，并直接把 Luban 作为正式管线接进 Phase 1。

---

## 运行时格式

| Option | Description | Selected |
|--------|-------------|----------|
| JSON导出 | 最利于 Phase 1 调试、对比和快速查错；先让 DataRepository 吃可读文本 | ✓ |
| Godot代码+JSON | Luban 同时生成 Godot 侧类型代码和 JSON 数据，运行时按生成类型/装载流程消费 | |
| 二进制导出 | 更接近后期效率路线，但 Phase 1 可读性和排错成本更高 | |
| 你决定 | 导出格式交给后续 planner/researcher 判断 | |

**User's choice:** JSON导出
**Notes:** 用户偏向早期调试效率，不希望 Phase 1 被低可读格式拖慢验证。

---

## Schema范围

| Option | Description | Selected |
|--------|-------------|----------|
| 主干优先 | 先覆盖 Scenario / Character / Faction / City 四类主干对象；Clan/Family/Action/Event 先留字段或空表扩展位 | ✓ |
| P1骨架一起铺 | Phase 1 一次把 Character / Faction / City / Clan / Family / Action / Event 的 schema 骨架都立起来，但只填烟雾样本 | |
| 全设计对象一起铺 | 尽量一次把后续会用到的所有主要 schema 都建好，减少未来改表 | |

**User's choice:** 主干优先
**Notes:** 用户希望 Phase 1 先把最关键的主干对象管线跑通，其它对象留扩展位，避免过早膨胀。

---

## 主场景结构

| Option | Description | Selected |
|--------|-------------|----------|
| 单MainScene骨架 | 先用一个 MainScene 承载 UI root、管理器挂点和默认主角入口；后续再逐步拆分子面板/子场景 | ✓ |
| 主场景+子面板预拆 | Phase 1 就把 HUD、角色区、快捷区等拆成独立子场景/组件，方便后续扩展 | |
| 更强系统拆分 | Phase 1 就明显拆出 GameRoot、Bootstrap、UIContainer 等层级，尽早建立完整结构 | |
| 你决定 | 交给后续 planner 根据 Godot 结构自己定 | |

**User's choice:** 单MainScene骨架
**Notes:** 用户希望 Phase 1 先建立稳的入口骨架，不在这个阶段过早拆复杂结构。

---

## HUD未来入口

| Option | Description | Selected |
|--------|-------------|----------|
| 可见但禁用 | 先把未来入口位置摆出来，但标成未开放/禁用，稳定整体布局，也明确后续扩展方向 | ✓ |
| 只显示已实现入口 | Phase 1 只放当前可用入口，后续 phase 再逐步加按钮 | |
| 可见且跳占位页 | 先把入口都做成可点，占位页只说明“后续开放”或展示空骨架 | |
| 你决定 | 交给后续 planner 决定显示策略 | |

**User's choice:** 可见但禁用
**Notes:** 用户希望从 Phase 1 起稳定 HUD 布局，并明确后续扩展方向，但不需要占位页。

---

## the agent's Discretion

- Luban 的具体命令行包装与目录结构。
- JSON 装载层与仓库缓存的技术细节。
- 禁用入口的视觉样式细节。
- MainScene 内部节点命名与 placeholder 层次。

## Deferred Ideas

无。
