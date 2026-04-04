# Godot 系统模块拆分清单 v1

#项目设计 #模块拆分 #Godot #AI开发

> 文档定位：本文件用于把原型阶段的实现内容拆成可独立开发、可测试、可并行推进的系统模块。面向开发 AI，重点说明模块职责、输入输出、依赖关系与验收标准。

---

## 1. 模块拆分原则

1. 按职责拆分，不按文件数量拆分。
2. UI 不承担核心业务逻辑。
3. 管理层负责调度，系统层负责规则，数据层负责读写。
4. 任何模块都应尽量有明确输入、输出、依赖与测试点。

---

## 2. 分层总览

### 2.1 管理层
- GameRoot
- TimeManager
- EventManager
- DataRepository
- SaveLoadManager

### 2.2 核心系统层
- CharacterSystem
- ActionSystem
- RelationSystem
- CareerSystem
- ClanFamilySystem
- FactionSystem
- TaskSystem
- ScenarioSystem
- EventResolutionSystem
- WarStubSystem

### 2.3 UI 层
- MainHUD
- ActionMenuPanel
- CharacterPanel
- RelationPanel
- FactionPanel
- ClanFamilyPanel
- EventDialog
- TurnSummaryPanel
- MonthReportPanel

### 2.4 支撑层
- FormulaService
- ConditionChecker
- Logger / DebugPanel

---

## 3. 管理层模块

## 3.1 GameRoot

### 职责
- 初始化游戏
- 加载剧本
- 装配管理器与 UI
- 维持主循环入口

### 输入
- ScenarioData
- 初始角色选择

### 输出
- 初始化完成的运行时状态

### 依赖
- DataRepository
- TimeManager
- UI 根节点

### 验收标准
- 可以从剧本与人物选择进入主 HUD

## 3.2 TimeManager

### 职责
- 管理旬/月推进
- 广播旬末、月末事件
- 触发统一结算流程

### 输入
- 当前时间状态
- 玩家结束本旬指令

### 输出
- 新时间状态
- 时间事件广播

### 验收标准
- 能稳定推进多个旬与至少一个月

## 3.3 EventManager

### 职责
- 统一分发系统事件
- 注册和触发 UI/系统监听

### 输入
- 行动结果、时间推进、任务变化等事件

### 输出
- 已分发的事件通知

### 验收标准
- 至少支持：行动完成、旬末结算、月末结算、事件触发四类广播

## 3.4 DataRepository

### 职责
- 统一读取静态数据与运行时状态
- 提供 ID 查询
- 为系统层提供对象访问入口

### 输入
- 数据表 / Resource / 存档

### 输出
- 可被系统层读取和修改的数据引用

### 验收标准
- Character/Faction/City/Clan/Family/Event 可稳定查询

## 3.5 SaveLoadManager

### 职责
- 原型阶段提供基础存档读档接口

### 范围
- 可先只支持单档覆盖存储

---

## 4. 核心系统层模块

## 4.1 CharacterSystem

### 职责
- 管理人物基础属性与状态变更
- 处理 AP/精力/压力、名望/功绩等变化

### 关键输入
- 行动结果
- 时间结算
- 事件效果

### 关键输出
- 新的人物状态

### 依赖
- DataRepository
- FormulaService

### 验收标准
- 任意人物数值变化可被正确记录并反馈到 UI

## 4.2 ActionSystem

### 职责
- 生成可执行行动列表
- 校验行动条件
- 执行动作并生成结果

### 子职责
- ActionQuery
- ActionResolver
- ActionResultBuilder

### 验收标准
- 玩家每旬至少能执行成长/关系/政务三类动作

## 4.3 RelationSystem

### 职责
- 读写人物关系值
- 处理拜访、送礼、请教等行为结果

### 验收标准
- 好感/信任/戒备变化能影响后续行为成功率或事件

## 4.4 CareerSystem

### 职责
- 管理功绩、任命、官职权限
- 处理月末评定与升迁逻辑

### 验收标准
- 玩家能因功绩/关系/派系结果发生任命变化

## 4.5 ClanFamilySystem

### 职责
- 管理士族、家族、门第、联姻修正
- 提供举荐、联姻、名望传播相关接口

### 验收标准
- 高门/寒门开局应有可感知差异

## 4.6 FactionSystem

### 职责
- 维护势力基础数据、派系状态、城市归属
- 提供势力级查询与月度结算接口

### 验收标准
- 势力资源与派系倾向能在 UI 中展示并变化

## 4.7 TaskSystem

### 职责
- 管理任务生成、进行中状态、完成结算
- 支持主公委派、家族请求、事件任务

### 验收标准
- 至少支持 3 类任务的接取与完成

## 4.8 ScenarioSystem

### 职责
- 负责剧本初始化与样本数据装载

### 验收标准
- 190 样本剧本能正确装载全部起始状态

## 4.9 EventResolutionSystem

### 职责
- 检查事件触发条件
- 生成事件弹窗内容与结果

### 验收标准
- 至少支持：关系事件、任命事件、家族事件、势力任务事件

## 4.10 WarStubSystem

### 职责
- 原型阶段仅处理出征任务、战果结算、战功变化

### 验收标准
- 不做完整战场，但可完成“接任务 -> 出征 -> 战果 -> 回朝反馈”闭环

---

## 5. UI 模块清单

## 5.1 MainHUD
- 常驻显示时间、人物状态、快捷入口

## 5.2 ActionMenuPanel
- 显示可执行行动与消耗预览

## 5.3 CharacterPanel
- 展示属性、状态、身份、技能、社会信息

## 5.4 RelationPanel
- 展示关键人物关系与可互动入口

## 5.5 FactionPanel
- 展示势力概况、派系结构、职位环境

## 5.6 ClanFamilyPanel
- 展示家族/士族/门第/婚姻相关信息

## 5.7 EventDialog
- 展示事件与选项

## 5.8 TurnSummaryPanel
- 展示旬末结算

## 5.9 MonthReportPanel
- 展示月末评定、任命与资源变化

---

## 6. 模块依赖顺序

推荐实现顺序：

1. DataRepository
2. ScenarioSystem
3. TimeManager
4. CharacterSystem
5. ActionSystem
6. RelationSystem
7. MainHUD / ActionMenuPanel
8. CareerSystem
9. FactionSystem
10. ClanFamilySystem
11. TaskSystem
12. EventResolutionSystem
13. 其余 UI 面板
14. WarStubSystem
15. SaveLoadManager

---

## 7. 并行开发建议

### 可并行组 A：数据与底层
- DataRepository
- ScenarioSystem
- TimeManager

### 可并行组 B：人物与行动
- CharacterSystem
- ActionSystem
- RelationSystem

### 可并行组 C：表现与反馈
- MainHUD
- ActionMenuPanel
- TurnSummaryPanel

### 第二阶段并行组
- CareerSystem + FactionSystem
- ClanFamilySystem + ClanFamilyPanel
- TaskSystem + EventDialog

---

## 8. 每模块最小验收问题

开发 AI 完成模块后，应回答：

- 这个模块解决了什么问题？
- 依赖了哪些对象？
- 是否能脱离 UI 被测试？
- 结果是否能被日志或调试面板看见？

---

## 9. 原型阶段不要拆过细的模块

以下内容不建议一开始拆太细：
- 战场单位 AI
- 家谱可视化编辑器
- 完整外交系统
- 复杂存档版本兼容

---

## 10. 本阶段结论

《Godot 系统模块拆分清单 v1》把原型实现分成了：

1. 管理层：调度与装配
2. 核心系统层：规则与状态变更
3. UI 层：展示与输入
4. 支撑层：公式、条件、调试

这样开发 AI 可以按模块并行推进，而不会把逻辑全部堆在单一脚本中。

---

参见：[[Godot 原型开发拆解 v1]] [[Godot 数据结构草案 v1]] [[原型 UI 流程图 v1]] [[GDD 框架 v1]] [[task_plan.md]] [[findings.md]] [[progress.md]]
