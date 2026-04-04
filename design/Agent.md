# Agent — design 文档检索索引

本文件仅用于帮助开发 AI / 脚本快速定位 `design/` 下的设计文档。

## 1. 目录结构

- `design/Agent.md`：人工 / AI 可读索引入口
- `design/CHANGELOG.md`：文档整理与目录变更记录
- `design/machine_index.json`：机器可读索引
- `design/AI_WORKFLOW.md`：开发 AI 的文档创建 / 修改超短操作清单
- `design/总纲/`
- `design/系统设计/`
- `design/数值/`
- `design/数据/`
- `design/原型与实现/`
- `design/UIUX/`
- `design/剧情与样本/`

## 2. 文件说明

### 总纲
- `design/总纲/GDD 框架 v1.md`
  - 功能：项目总入口、GDD 结构与阅读顺序。
  - 适用：首次接入项目、需要全局理解时优先阅读。

- `design/总纲/项目总设计方案 v1.md`
  - 功能：项目定位、核心玩法、整体设计方案。
  - 适用：确认产品方向、核心体验、首版范围时查阅。

### 系统设计
- `design/系统设计/核心系统详细设计 v1.md`
  - 功能：角色、势力、时间推进、事件等核心系统细化。
  - 适用：实现系统逻辑、拆分模块边界时查阅。

- `design/系统设计/士族门阀系统专项设计 v2.md`
  - 功能：士族 / 门阀特色系统专项规则。
  - 适用：实现出身、举荐、联姻、门阀影响时查阅。

### 数值
- `design/数值/主循环与数值骨架 v1.md`
  - 功能：主循环与核心资源关系。
  - 适用：实现行动收益、回合结算、成长循环时查阅。

- `design/数值/精力-压力-AP 三资源设计方案 v1.md`
  - 功能：三资源职责、消耗、恢复与联动规则。
  - 适用：实现行动消耗、状态变化、触发条件时查阅。

### 数据
- `design/数据/Godot 数据结构草案 v1.md`
  - 功能：Godot 原型期的数据结构与字段草案。
  - 适用：定义 Resource / JSON / 存档结构时查阅。

### 原型与实现
- `design/原型与实现/Godot 原型开发拆解 v1.md`
  - 功能：Godot 原型开发顺序与阶段拆解。
  - 适用：搭建原型、安排技术实现顺序时查阅。

- `design/原型与实现/Godot 系统模块拆分清单 v1.md`
  - 功能：模块职责、接口边界、测试点。
  - 适用：并行开发、模块验收、任务分派时查阅。

- `design/原型与实现/原型任务拆解清单 v1.md`
  - 功能：可直接执行的任务包与验收标准。
  - 适用：给开发 AI 下发具体实现任务时优先查阅。

### UIUX
- `design/UIUX/原型 UI 流程图 v1.md`
  - 功能：UI 信息架构与交互流程。
  - 适用：实现 HUD、菜单、面板、弹窗流程时查阅。

### 剧情与样本
- `design/剧情与样本/190 剧本原型人物-势力样本表 v1.md`
  - 功能：人物、势力、城市等原型样本数据。
  - 适用：录入 ScenarioData、准备测试样本时查阅。

- `design/剧情与样本/190 剧本原型事件样本表 v1.md`
  - 功能：事件样本模板与优先事件列表。
  - 适用：录入事件、验证事件链路时查阅。

## 3. 推荐检索路径

### 场景 A：首次接入项目
1. `design/总纲/GDD 框架 v1.md`
2. `design/总纲/项目总设计方案 v1.md`
3. `design/系统设计/核心系统详细设计 v1.md`

### 场景 B：实现具体系统
1. 先查对应系统设计文档
2. 再查 `design/数据/Godot 数据结构草案 v1.md`
3. 最后查 `design/原型与实现/` 下任务或模块拆解文档

### 场景 C：实现数值或行动逻辑
1. `design/数值/主循环与数值骨架 v1.md`
2. `design/数值/精力-压力-AP 三资源设计方案 v1.md`
3. `design/系统设计/核心系统详细设计 v1.md`

### 场景 D：实现 UI
1. `design/UIUX/原型 UI 流程图 v1.md`
2. `design/原型与实现/Godot 原型开发拆解 v1.md`

### 场景 E：录入样本 / 剧本 / 事件
1. `design/剧情与样本/190 剧本原型人物-势力样本表 v1.md`
2. `design/剧情与样本/190 剧本原型事件样本表 v1.md`
3. `design/数据/Godot 数据结构草案 v1.md`

## 4. 机器检索说明

- 机器优先读取：`design/machine_index.json`
- 人工或通用 AI 优先读取：`design/Agent.md`
- 历史整理记录：`design/CHANGELOG.md`
- 开发 AI 操作清单：`design/AI_WORKFLOW.md`

## 5. 维护规则

- 新增文档时，必须同步更新：
  - `design/Agent.md`
  - `design/machine_index.json`
  - `design/CHANGELOG.md`
- 新增、移动、重命名、归档文档前后，应先检查：
  - `design/AI_WORKFLOW.md`
- 若发生移动、重命名、归档，必须同步记录到：
  - `design/CHANGELOG.md`
