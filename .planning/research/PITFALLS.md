# Domain Pitfalls

**Domain:** 三国单角色历史模拟 Godot 原型（数据驱动 / UI-heavy / systems-heavy）  
**Researched:** 2026-04-04  
**Overall confidence:** HIGH-MEDIUM

## Phase Mapping Used Below

- **Phase 1 / M1（T01-T08）**：项目骨架、数据仓库、时间推进、角色状态、HUD、行动、关系、旬末总结
- **Phase 2 / M2（T09-T10）**：月末评定、任命、势力与派系基础
- **Phase 3 / M3（T11-T14）**：士族/家族、任务、事件、婚姻接口
- **Phase 4 / M4（T15-T16）**：战争简化、存档/读档、调试与验证工具

---

## Critical Pitfalls

### Pitfall 1: 单角色原型滑成“上帝视角势力管理器”
**What goes wrong:** 君主/高位身份获得全局信息、全局指令和无限处理能力，玩法从“扮演一个人”滑成传统 4X/SLG。  
**Why it happens:** 为了省实现成本，直接把任命、内政、外交、战争都做成全局按钮；没有给君主加时间、关系、执行链条约束。  
**Consequences:** 产品核心卖点被抹平；不同身份共用底层逻辑失败；后续越做越像另一个游戏。  
**Warning signs:**
- 君主界面能直接看全势力完整状态，而武将/文臣看不到同层信息
- 君主可以一旬内无限处理多类事务
- 任命/内政结果不经过臣属、关系或派系链条
**Prevention:**
- 所有身份共享同一时间/AP/状态约束
- 君主只拥有更高权限，不拥有“跳过执行链条”的特权
- 高位行动也必须走“提案/授意/任命/执行/反馈”链
- UI 上区分“可决定”与“可直接完成”
**Detection:** 做一次“君主一月体验审查”：如果体验像全局国家管理而不是个人政治生涯，说明已偏航。  
**Phase to address:** **Phase 1** 定规则，**Phase 2** 在任命与势力系统中强制落地。

### Pitfall 2: 全身份一开始就做深度专属玩法，导致系统爆炸
**What goes wrong:** 君主、武将、文臣、在野、隐士都拥有大量专属规则，底层无法统一。  
**Why it happens:** 过早追求“每个身份都像独立游戏”；没有坚持“差异主要来自权限、事件池、任务来源”。  
**Consequences:** 代码分叉、数值失控、测试面爆炸；原型迟迟做不出闭环。  
**Warning signs:**
- 同一行动在不同身份下使用完全不同结算代码
- UI 流程按身份完全分裂
- 新功能必须写 3~5 套版本
**Prevention:**
- 先做统一行动/结算/关系/任命骨架
- 身份差异只允许改：行动可见性、前置条件、权重、事件池、结果修正
- 原型优先验证在野/武将/文臣三类，君主做受限版
**Detection:** 任意新需求如果需要新开一套系统而不是在既有系统上加权限/修正，说明方向错了。  
**Phase to address:** **Phase 1**。

### Pitfall 3: 数据定义与运行时状态混在一起，后期无法扩展也无法存档
**What goes wrong:** `ActionDefinition`、人物模板、官职定义、事件定义、运行时人物状态全部混在 Dictionary/Node 里，字段语义不稳定。  
**Why it happens:** 为了快，先用临时 JSON/字典硬写；没有区分“静态定义”和“动态实例状态”。  
**Consequences:** 改一个字段牵动全项目；读档困难；事件条件、UI 展示、数值结算引用混乱。  
**Warning signs:**
- 同一个字段在不同地方含义不同（如名望既是门槛又是临时评分）
- UI 直接改配置数据
- 角色模板被运行时直接污染
**Prevention:**
- 明确分层：**Definitions（静态）/ Runtime State（动态）/ ViewModel（展示）**
- 角色、行动、事件、官职、士族等定义对象优先数据化
- 运行时状态单独持有，不回写模板
- 尽早定义存档白名单与序列化边界
**Detection:** 随机切换剧本或重开新局时出现旧局残留，就是定义/状态污染信号。  
**Phase to address:** **Phase 1**，并在 **Phase 4** 用存档验证。

### Pitfall 4: 把 Autoload / Manager 当成“万能总控”，形成全局黑箱耦合
**What goes wrong:** TimeManager、EventManager、DataRepository、UI、角色状态、战果、事件触发全部堆进全局单例。  
**Why it happens:** Godot 原型很容易用 Autoload 快速通路，但全局可访问状态会诱发滥用。  
**Consequences:** 来源难追踪、测试困难、状态互相污染、Bug 排查范围变成整个项目。  
**Warning signs:**
- 任意脚本都能直接改全局状态
- 出现“谁改了这个值根本找不到”的问题
- Manager 逐渐膨胀成几百上千行的全知类
**Prevention:**
- Autoload 只保留广域协调职责：时间推进、场景级服务、事件总线
- 业务状态归系统或运行时状态对象持有，不归 UI、不归万能单例
- 系统间优先用信号/显式接口通信，不靠到处直接读写全局
- 每个 Manager 写清“拥有的数据”和“不拥有的数据”
**Detection:** 如果一个 bug 的排查起点总是“全项目搜这个字段谁都可能改”，说明耦合已过高。  
**Phase to address:** **Phase 1**。

### Pitfall 5: 把大量游戏数据做成 Node 树，导致性能、编辑和复用都变差
**What goes wrong:** 人物、关系、士族、官职、事件条目全做成场景节点或挂在节点树上。  
**Why it happens:** Godot 以场景/节点为中心，原型期容易“万物皆节点”。  
**Consequences:** 节点膨胀、数据不易序列化、调试视图混乱、运行成本无谓上升。  
**Warning signs:**
- 一堆纯数据对象也需要在场景树里存活
- 为了读一个人物数据必须 `get_node()` 层层取
- UI 面板持有并直接修改底层节点对象
**Prevention:**
- 纯数据优先使用 `Resource` / `RefCounted` 风格对象
- Node 只承担生命周期、可视化、输入和协调职责
- 系统层操作数据对象，UI 只消费展示模型
**Detection:** SceneTree 里塞满并不需要显示的“数据节点”，就是典型反模式。  
**Phase to address:** **Phase 1**。

### Pitfall 6: 共用 Resource 被意外共享修改，导致“串档”与脏状态
**What goes wrong:** 多个角色、事件、UI 或场景引用同一份 Resource；修改一处，其他实例一起变。  
**Why it happens:** Godot 文档明确说明资源从磁盘加载后通常只加载一次并共享；若把可变运行时状态也放进共享资源，很容易踩坑。  
**Consequences:** 开局角色互相污染、面板显示错乱、读档后状态异常、测试结果不可复现。  
**Warning signs:**
- 修改 A 角色数据后 B 角色同步变化
- 新开局继承旧局残留值
- 事件定义被运行时写坏后，全局触发都异常
**Prevention:**
- `Resource` 主要承载静态定义；运行时可变状态使用独立实例
- 对运行时需要独占的资源显式复制/实例化，禁止直接修改共享定义
- 建立“模板只读”约束和代码审查点
**Detection:** 做“新局隔离测试”和“多角色并行修改测试”；任何联动异常都优先排查共享资源。  
**Phase to address:** **Phase 1**。

### Pitfall 7: 旬/月/季/年结算顺序不固定，系统结果不可解释且不可复现
**What goes wrong:** 关系、AI 行动、任务、任命、派系、资源和历史事件的结算顺序漂移，导致同样输入出现不同结果。  
**Why it happens:** 先做功能，后补统一结算管线；事件触发散落在各系统内部。  
**Consequences:** 数值平衡无法做；Bug 难复现；玩家感觉系统随机且不讲理。  
**Warning signs:**
- 月末报告里的结果解释不出来源
- 同一回合重放结果不同
- 新增一个系统后旧系统结果变化巨大
**Prevention:**
- 先定义固定流水线：玩家行动结算 → 旬末状态/关系 → AI 推进 → 月末任命/资源 → 季/年级事件
- 事件系统只登记触发，不允许任意系统随手直接结算全局后果
- 为每步输出调试日志与结算摘要
**Detection:** 建“同 seed/同输入重放测试”；结果不稳定就不能继续加系统。  
**Phase to address:** **Phase 1** 设计，**Phase 2-4** 严格遵守。

### Pitfall 8: 结果黑箱化，玩家不知道为何关系变了、任命失败了、婚配被拒了
**What goes wrong:** 系统很多，但反馈只给结果不给因果。玩家看见的是“失败/未任命/关系下降”，看不见原因链。  
**Why it happens:** 设计里有很多修正项，但 UI 没有同步做解释层；原型只显示数值，不显示来源。  
**Consequences:** 明明系统很深，玩家感受到的却是随机和不公平；核心乐趣验证失败。  
**Warning signs:**
- 玩家只能通过猜测理解系统
- 月末报告只有结果，没有阻塞原因
- 士族/派系/名望在前台存在感很弱
**Prevention:**
- 每个关键结果都至少展示 2~4 个主要因子
- 任命、婚姻、事件分支必须给“主要原因标签”
- HUD/旬末/月末报告优先做“解释”而不是美化
- 失败也要产出情报或下轮行动建议
**Detection:** 若测试玩家频繁问“为什么会这样”，不是教程问题，而是系统反馈层缺失。  
**Phase to address:** **Phase 1** 做旬末总结，**Phase 2-3** 做月末/事件解释。

### Pitfall 9: 士族、家族、派系只停留在设定文本，不真正进入主循环
**What goes wrong:** 面板里能看到门第、家族、派系标签，但它们不影响行动、任命、举荐、婚姻、事件。  
**Why it happens:** 先把设定做出来，但没有把它们接进收益公式、条件判定与机会生成。  
**Consequences:** 项目最重要的“三国特色政治系统”变成装饰；与普通三国 RPG/SLG 区分不出来。  
**Warning signs:**
- 高门/寒门开局体感差异极弱
- 派系支持度只显示，不改变升迁/排挤概率
- 婚姻接口不看门第与政治关系
**Prevention:**
- 给士族/家族/派系定义最小但硬性的作用面：入仕门槛、举荐权重、婚配权重、任命修正、事件池偏向
- 控制为“少数高影响修正”，不要做成几十个隐藏系数
- 每次接入新系统都问：它怎样改变玩家下旬决策？
**Detection:** 若删掉士族/派系系统后体验几乎不变，说明它们尚未进入闭环。  
**Phase to address:** **Phase 3**。

### Pitfall 10: 追求“历史百科全书完整度”，导致样本和内容量失控
**What goes wrong:** 试图在原型阶段做全地图、全人物、全门阀、全事件链。  
**Why it happens:** 历史题材天然诱发内容收集冲动；团队容易把“资料完整”误当成“原型有效”。  
**Consequences:** 大部分时间耗在填表与写文本，不在验证闭环；系统质量反而更差。  
**Warning signs:**
- 数据录入工作量远大于系统验证
- 还没证明一城一月好玩，就开始补全国人物
- 历史事件文案增长快于可玩功能增长
**Prevention:**
- 严守局部样本：3~5 城、2~3 势力、30~50 人、5~8 士族
- 所有内容新增都要绑定“本次验证的问题”
- 先做可扩展数据结构和最小样本，不做大全
**Detection:** 如果一个里程碑主要产出是表格和文本，而不是更稳定的闭环体验，范围已经偏了。  
**Phase to address:** **Phase 1-3** 持续控制。

### Pitfall 11: 先做大地图、复杂战争或沉浸表现，核心闭环仍未验证
**What goes wrong:** 资源被地图漫游、战场表现、动画、美术包装吞掉。  
**Why it happens:** 这些内容“看起来更像游戏”，但对当前原型的验证价值最低。  
**Consequences:** 原型华丽但不好玩；真正难的行动—关系—功绩—任命链仍未跑通。  
**Warning signs:**
- 先做场景切换和地图漫游，后做行动结算
- 战争系统工作量明显超过主循环本体
- UI 面板很多，但没有稳定旬/月结算
**Prevention:**
- 保持界面驱动原型路线：主场景 + 面板 + 战果结算页
- 战争只做“出征任务 + 战果反馈”
- 每个表现任务都必须回答“它验证哪条核心假设？”
**Detection:** 若项目演示的亮点是“看起来像大作”，而不是“闭环成立”，则优先级错了。  
**Phase to address:** **Phase 1-4**，尤其 **Phase 4** 防止战争吞范围。

### Pitfall 12: 缺少调试面板、回放日志和存档工具，导致 systems-heavy 原型无法验证
**What goes wrong:** 系统越来越多，但没有观察工具。开发者只能靠猜，无法快速定位数值和事件问题。  
**Why it happens:** 把调试支持当成“以后再说”；但系统型游戏的验证成本远高于动作游戏。  
**Consequences:** 调参极慢；结算错误难复现；后续研究和 roadmap 失真。  
**Warning signs:**
- 无法快速查看某角色当前所有关键状态
- 无法知道本月为何没升迁
- 遇到 bug 只能手点到相同局面重新试
**Prevention:**
- 至少提供：关键变量查看、结算日志、事件触发日志、关系变动来源、强制推进时间、手动改值、基础存档读档
- 将“调试可见性”视为 P0/P1 的一部分，不是收尾工作
**Detection:** 每当定位一个 bug 需要 10 分钟以上重现场景，就说明工具不足。  
**Phase to address:** **Phase 1** 预留接口，**Phase 4** 必须完成。

---

## Moderate Pitfalls

### Pitfall 13: UI 布局先手摆、后补响应式，最终面板不可维护
**What goes wrong:** 大量 `Control` 手工定位，后续一改分辨率、文案长度或面板结构就全乱。  
**Prevention:** 从原型开始就采用 Container-first 布局；把 HUD、详情页、列表页拆成稳定容器层级；不要在容器子节点上依赖手工坐标。  
**Warning signs:** 改一个按钮大小导致整页错位；中英文/长短文案表现不一致。  
**Phase to address:** **Phase 1**。

### Pitfall 14: 行动数值只有成功/失败，没有“失败价值”
**What goes wrong:** 玩家一次失败就纯亏 AP/精力，系统体验变得保守、僵硬。  
**Prevention:** 失败也至少给经验、情报、关系波动、压力变化或事件线索之一。  
**Warning signs:** 玩家很快只选最稳妥动作，不再探索。  
**Phase to address:** **Phase 1-2**。

### Pitfall 15: 把士族/派系修正做成几十个隐藏系数，失去可解释性
**What goes wrong:** 系统看似精细，实则无法展示、无法调试、无法平衡。  
**Prevention:** 先做少量高影响修正项，并保证能被 UI 解释；不要在原型阶段追求“拟真微积分”。  
**Warning signs:** 调一次任命公式要改十几个参数；没人说得清真正起作用的是哪个值。  
**Phase to address:** **Phase 3**。

### Pitfall 16: 历史模拟只做“事实对不对”，不做“模型是否可辩护”
**What goes wrong:** 要么沦为资料堆砌，要么为了玩法完全脱离时代逻辑。  
**Prevention:** 优先验证“某类人物在类似约束下是否会面对类似问题与选择”，而不是追求每条细节逐项百科式准确。  
**Warning signs:** 团队讨论长期停留在“这件事历史上有没有”，却不讨论“它是否服务于问题空间与因果模型”。  
**Phase to address:** **Phase 2-4**。

---

## Minor Pitfalls

### Pitfall 17: 关系值过多前台直出，信息密度压垮玩家
**What goes wrong:** 好感、信任、敬重、戒备、恩义全部常驻显示，玩家被数字淹没。  
**Prevention:** 前台常驻只放最关键值，其余在详情/tooltip/结算说明中展开。  
**Phase to address:** **Phase 1-2**。

### Pitfall 18: 事件文本先于事件结构，导致后续事件难以复用
**What goes wrong:** 先写大量剧情文本，后来才发现没有统一触发条件、结果结构、原因标签。  
**Prevention:** 先定义事件 schema：触发条件、参与者、效果、解释标签、后续钩子；再写文本。  
**Phase to address:** **Phase 3**。

---

## Phase-Specific Warnings

| Phase Topic | Likely Pitfall | Mitigation |
|-------------|---------------|------------|
| T01-T02 项目骨架/数据仓库 | 定义与运行时状态混写 | 先分 Definition / Runtime / ViewModel 三层 |
| T03 时间推进 | 旬/月/季/年结算顺序漂移 | 固化结算流水线与日志输出 |
| T04-T06 角色/行动/HUD | UI 先展示结果，未展示因果 | HUD 与行动结果必须带来源标签 |
| T07-T09 关系/旬末/月末 | 关系与任命变成黑箱 | 做旬末总结、月末阻塞原因面板 |
| T10 势力/派系 | 派系只有展示没有作用 | 任命、信任、排挤至少接一条硬影响链 |
| T11 士族/家族 | 门第只是 flavor 文本 | 接入举荐、婚配、仕途门槛修正 |
| T12-T13 任务/事件 | 先写文本后补结构 | 先做事件 schema 与通用触发/结果系统 |
| T14 婚姻接口 | 婚姻与政治系统脱节 | 议婚必须受门第、关系、派系影响 |
| T15 战争简化 | 战争吞掉原型范围 | 只做出征任务与战果反馈，不做完整战场 |
| T16 存档/调试 | 无法复现和验证复杂系统 | 提供存档、改值、日志、状态查看工具 |

---

## Prevention Priorities for Roadmap Planning

1. **先防架构坑，再防内容坑。** 数据边界、结算顺序、全局耦合必须最早解决。  
2. **先防可解释性坑，再加深系统。** 如果玩家看不懂因果，越深的系统越像噪音。  
3. **先让士族/派系产生少量高影响，再扩复杂度。** 不要先做大而全。  
4. **把调试能力当功能做。** 对 systems-heavy 原型，这是验证基础设施，不是附属品。

---

## Sources

### High confidence
- 项目内部设计文档：
  - `.planning/PROJECT.md`
  - `design/总纲/GDD 框架 v1.md`
  - `design/总纲/项目总设计方案 v1.md`
  - `design/原型与实现/Godot 原型开发拆解 v1.md`
  - `design/原型与实现/原型任务拆解清单 v1.md`
  - `design/数值/主循环与数值骨架 v1.md`
- Godot official docs — Singletons (Autoload): https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html
- Godot official docs — Autoloads versus regular nodes: https://docs.godotengine.org/en/stable/tutorials/best_practices/autoloads_versus_internal_nodes.html
- Godot official docs — When and how to avoid using nodes for everything: https://docs.godotengine.org/en/stable/tutorials/best_practices/node_alternatives.html
- Godot official docs — Resources: https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html
- Godot official docs — Using Containers: https://docs.godotengine.org/en/stable/tutorials/ui/gui_containers.html
- Godot official docs — Using signals: https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html
- Godot official docs — Saving games: https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html

### Medium confidence
- Jeremiah McCall, *Defensible models and Historical Problem Spaces as an approach to assessing the validity of historical games* (2026-03-23): https://gamingthepast.net/2026/03/23/considering-the-evidence-based-validity-of-a-historical-game-defensible-models-and-why-we-should-care/

### Low confidence / investigated but not relied on heavily
- General web search results on Godot UI-heavy strategy prototypes and strategy-game UI complaints were directionally consistent with the pitfalls above, but were mostly forum/community discussions and were **not** used as primary evidence.
