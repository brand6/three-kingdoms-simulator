# Godot 数据结构草案 v1

#项目设计 #数据结构 #Godot #AI开发入口

> 文档定位：本文件用于在原型实现前冻结一版最小可用数据模型，供开发 AI 建立 Resource / JSON / Dictionary / ScriptClass 等数据对象时参考。重点是**字段语义统一、依赖清晰、便于扩展**。

---

## 1. 设计目标

### 1.1 本文档解决的问题
- 原型阶段需要哪些核心数据对象
- 每个对象至少包含哪些字段
- 对象之间如何关联
- 哪些字段必须首版实现，哪些可后置

### 1.2 设计原则
1. **先最小闭环，后复杂扩展**
2. **先稳定 ID 与引用关系，后优化存储形式**
3. **字段名优先表达语义，不急于贴近最终代码名**
4. **所有核心对象必须支持序列化**

---

## 2. 数据建模总览

原型阶段建议优先建立以下对象：

### 核心对象
- `ScenarioData`
- `CharacterData`
- `FactionData`
- `CityData`
- `ClanData`（士族/门阀）
- `FamilyData`
- `RelationData`
- `OfficeData`
- `ActionData`
- `EventData`

### 扩展对象
- `TraitData`
- `SkillData`
- `TaskData`
- `WarStubData`
- `MarriageProposalData`

---

## 3. 对象依赖关系

## 3.1 主要引用方向

- `ScenarioData` 引用：Faction / City / Character / Clan / Family / Event
- `CharacterData` 引用：Faction / City / Family / Clan / Office / Trait / Skill
- `FactionData` 引用：Character / City / Clan / FactionFactionRelation
- `CityData` 引用：Faction / Character
- `FamilyData` 引用：Clan / Character
- `RelationData` 引用：Character -> Character
- `EventData` 引用：Character / Faction / City / Family / Clan / 条件表达式

### 3.2 原则
- 用 **ID 关联**，避免对象互相深拷贝
- 运行时由仓库或缓存系统组装引用
- 设计上允许同一对象被 UI、逻辑系统同时读取

---

## 4. ScenarioData

## 4.1 作用
用于描述一个剧本的总入口与初始状态。

## 4.2 最小字段
| 字段 | 类型 | 说明 |
|------|------|------|
| id | string | 剧本 ID |
| name | string | 剧本名称 |
| start_year | int | 开始年份 |
| start_month | int | 开始月份 |
| start_xun | int | 开始旬 |
| title | string | 展示标题 |
| description | string | 剧本简介 |
| city_ids | Array[string] | 初始城市列表 |
| faction_ids | Array[string] | 初始势力列表 |
| character_ids | Array[string] | 初始人物列表 |
| clan_ids | Array[string] | 初始士族列表 |
| family_ids | Array[string] | 初始家族列表 |
| initial_event_ids | Array[string] | 初始事件池 |

## 4.3 后置字段
- 剧本专属规则修正
- 特殊开场对白
- 区域限制

---

## 5. CharacterData

## 5.1 作用
这是最核心对象，承载单角色体验的主要数据。

## 5.2 最小字段
| 字段 | 类型 | 说明 |
|------|------|------|
| id | string | 人物 ID |
| name | string | 姓名 |
| courtesy_name | string | 字/号，可为空 |
| gender | string | 性别 |
| birth_year | int | 出生年份 |
| age | int | 当前年龄，可运行时生成 |
| identity_type | string | 君主/武将/文臣/在野/隐士 |
| faction_id | string | 所属势力 ID，可为空 |
| city_id | string | 当前所在城市 |
| office_id | string | 当前官职 ID，可为空 |
| family_id | string | 家族 ID，可为空 |
| clan_id | string | 士族/门阀 ID，可为空 |
| faction_group_id | string | 势力内部派系 ID，可为空 |
| father_id | string | 父亲 ID，可为空 |
| mother_id | string | 母亲 ID，可为空 |
| spouse_ids | Array[string] | 配偶列表 |
| child_ids | Array[string] | 子嗣列表 |
| personality_tags | Array[string] | 性格标签 |
| trait_ids | Array[string] | 特性列表 |
| skill_levels | Dictionary | 技能等级映射 |
| stats | Dictionary | 六维属性 |
| status_values | Dictionary | AP/精力/压力/健康等 |
| reputation_values | Dictionary | 名望/功绩/忠诚/恶名等 |
| flags | Array[string] | 特殊标记 |

## 5.3 建议的 stats 结构
```text
stats = {
  leadership,
  martial,
  strategy,
  politics,
  charm,
  prestige_base
}
```

## 5.4 建议的 status_values 结构
```text
status_values = {
  ap,
  energy,
  stress,
  health,
  injury,
  mobility_state
}
```

## 5.5 建议的 reputation_values 结构
```text
reputation_values = {
  fame,
  merit,
  loyalty,
  honor,
  infamy
}
```

## 5.6 后置字段
- 语音/立绘资源路径
- 更复杂的教育经历
- 偏好与厌恶对象表

---

## 6. FactionData

## 6.1 作用
描述一个势力的政治与资源状态。

## 6.2 最小字段
| 字段 | 类型 | 说明 |
|------|------|------|
| id | string | 势力 ID |
| name | string | 势力名称 |
| ruler_id | string | 君主人物 ID |
| capital_city_id | string | 首府城市 ID |
| city_ids | Array[string] | 占领城市 |
| officer_ids | Array[string] | 在编人物 |
| faction_group_ids | Array[string] | 派系列表 |
| allied_faction_ids | Array[string] | 盟友势力 |
| hostile_faction_ids | Array[string] | 敌对势力 |
| clan_support | Dictionary | 士族支持度映射 |
| resources | Dictionary | 金粮兵等资源 |
| policies | Array[string] | 当前政策标签 |
| ai_profile | string | AI 倾向 |

## 6.3 建议 resources 结构
```text
resources = {
  gold,
  food,
  troops,
  morale,
  stability
}
```

---

## 7. CityData

## 7.1 作用
承载玩家行动入口与地区资源。

## 7.2 最小字段
| 字段 | 类型 | 说明 |
|------|------|------|
| id | string | 城市 ID |
| name | string | 城市名称 |
| region | string | 所属区域 |
| owner_faction_id | string | 占领势力 |
| governor_id | string | 太守/负责人 ID |
| character_ids | Array[string] | 在城人物列表 |
| values | Dictionary | 金粮兵治安民心等 |
| tags | Array[string] | 城市标签，如都城/商贸/军事 |
| connected_city_ids | Array[string] | 邻接城市 |
| clan_influence | Dictionary | 该城士族影响度 |

## 7.3 建议 values 结构
```text
values = {
  gold,
  food,
  troops,
  order,
  public_support,
  commerce,
  agriculture,
  defense
}
```

---

## 8. ClanData（士族/门阀）

## 8.1 作用
表现三国时期门第与政治网络。

## 8.2 最小字段
| 字段 | 类型 | 说明 |
|------|------|------|
| id | string | 士族 ID |
| name | string | 士族名称 |
| home_region | string | 根基区域 |
| rank_tier | int | 门第等级 |
| profile_tags | Array[string] | 政治/学术/武勋/豪强倾向 |
| prestige | int | 士族声望 |
| marriage_policy | string | 婚配保守度 |
| favored_faction_ids | Array[string] | 倾向支持势力 |
| hostile_clan_ids | Array[string] | 敌对士族 |
| family_ids | Array[string] | 下属家族 |
| notable_character_ids | Array[string] | 代表人物 |

---

## 9. FamilyData

## 9.1 作用
承载玩家所属支系、婚配网络、亲属关系与家族声望。

## 9.2 最小字段
| 字段 | 类型 | 说明 |
|------|------|------|
| id | string | 家族 ID |
| name | string | 家族名称 |
| clan_id | string | 所属士族 |
| home_city_id | string | 家族根据地 |
| head_character_id | string | 家主 |
| member_ids | Array[string] | 成员列表 |
| prestige | int | 家族声望 |
| wealth | int | 家族财富 |
| education_level | int | 家教水平 |
| style_tags | Array[string] | 家风标签 |
| allied_family_ids | Array[string] | 友好家族 |

---

## 10. RelationData

## 10.1 作用
承载人物之间的核心关系值。

## 10.2 最小字段
| 字段 | 类型 | 说明 |
|------|------|------|
| id | string | 关系记录 ID |
| source_id | string | 发出方人物 |
| target_id | string | 目标人物 |
| relation_tags | Array[string] | 血亲/姻亲/师徒/结义等 |
| favor | int | 好感 |
| trust | int | 信任 |
| respect | int | 敬重 |
| vigilance | int | 戒备 |
| obligation | int | 恩义/人情 |
| last_changed_time | Dictionary | 最后变化时间 |

## 10.3 说明
- 建议按有向关系存储
- 允许 A->B 与 B->A 数值不同

---

## 11. OfficeData

## 11.1 作用
定义官职/军职的权限与收益。

## 11.2 最小字段
| 字段 | 类型 | 说明 |
|------|------|------|
| id | string | 官职 ID |
| name | string | 官职名称 |
| office_type | string | 文官/武职/君主级 |
| rank | int | 品级/层级 |
| unlock_actions | Array[string] | 解锁行动 |
| salary_gold | int | 俸禄 |
| merit_requirement | int | 推荐功绩门槛 |
| notes | string | 备注 |

---

## 12. ActionData

## 12.1 作用
统一定义玩家和 AI 可执行行动，便于菜单生成与结算。

## 12.2 最小字段
| 字段 | 类型 | 说明 |
|------|------|------|
| id | string | 行动 ID |
| name | string | 行动名称 |
| category | string | 成长/关系/政务/军事/家族 |
| ap_cost | int | AP 消耗 |
| energy_cost | int | 精力消耗 |
| valid_identity_types | Array[string] | 可执行身份 |
| valid_conditions | Array[string] | 条件表达 |
| effect_profile | string | 结算模板 |
| target_mode | string | 无目标/单人物/单城市 |
| ui_priority | int | 菜单显示优先级 |

---

## 13. EventData

## 13.1 作用
承载历史事件、人物事件、家族事件、任务事件。

## 13.2 最小字段
| 字段 | 类型 | 说明 |
|------|------|------|
| id | string | 事件 ID |
| name | string | 事件名称 |
| event_type | string | 历史/人物/家族/任务/派系 |
| trigger_conditions | Array[string] | 触发条件 |
| option_ids | Array[string] | 选项列表 |
| priority | int | 触发优先级 |
| repeatable | bool | 是否可重复 |
| related_character_ids | Array[string] | 关联人物 |
| related_faction_ids | Array[string] | 关联势力 |
| related_city_ids | Array[string] | 关联城市 |

## 13.3 选项建议单独拆表
后续可扩展为：
- `EventOptionData`
- `EventEffectData`

---

## 14. TraitData / SkillData（可简化）

## 14.1 TraitData
建议字段：
- id
- name
- category
- effect_summary
- hidden

## 14.2 SkillData
建议字段：
- id
- name
- max_level
- effect_per_level

---

## 15. 运行时状态与静态数据分离建议

### 15.1 静态数据
适合写在资源或配置表中：
- 人物基础属性
- 官职定义
- 行动定义
- 士族基础信息
- 城市基础标签

### 15.2 运行时状态
适合存档或 State 容器：
- 当前 AP
- 当前精力/压力
- 当前所在城
- 当前关系变化
- 当前城市资源
- 当前势力外交状态

### 15.3 原则
不要把“剧本静态定义”和“当前局内状态”混在一起。

---

## 16. ID 与命名建议

### 16.1 ID 规则
建议统一使用英文小写下划线：
- `cao_cao`
- `liu_bei`
- `chenliu`
- `yingchuan_xun`

### 16.2 分类前缀建议
- `char_`
- `fac_`
- `city_`
- `clan_`
- `fam_`
- `event_`
- `act_`

如：
- `char_cao_cao`
- `fac_cao_cao`
- `city_chenliu`

---

## 17. 原型阶段最小样例数据建议

首版至少录入：
- Character：30~50
- Faction：2~3
- City：3~5
- Clan：5~8
- Family：8~12
- Event：10~20
- Action：15~25

---

## 18. 给开发 AI 的实现建议

### 18.1 第一优先
- 先把 `CharacterData`、`CityData`、`FactionData` 跑通
- 再接 `ActionData` 和 `RelationData`

### 18.2 第二优先
- 接入 `ClanData`、`FamilyData`、`OfficeData`

### 18.3 第三优先
- 接入 `EventData` 与任务、婚姻、战争分支

### 18.4 不要一开始做的事
- 不要先做庞大家谱编辑器
- 不要先做全国地图寻路
- 不要先做完整战场单位系统

---

## 19. 本阶段结论

《Godot 数据结构草案 v1》确认了原型阶段的最小数据骨架：

1. 以 `Character / Faction / City` 为主干
2. 以 `Clan / Family / Relation` 形成特色层
3. 以 `Action / Office / Event` 驱动行为层
4. 用 `Scenario` 组织剧本入口

只要这套数据关系稳定，后续系统开发和 UI 搭建就能显著降低返工风险。

---

参见：[[GDD 框架 v1]] [[Godot 原型开发拆解 v1]] [[主循环与数值骨架 v1]] [[task_plan.md]] [[findings.md]] [[progress.md]]
