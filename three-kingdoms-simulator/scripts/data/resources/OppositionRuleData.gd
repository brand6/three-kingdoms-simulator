extends Resource
class_name OppositionRuleData

# 反对/阻力规则静态定义：冻结阻力/压制链

@export var id: String = ""
## 来源类型：政敌、派系、门阀竞争者等
@export var source_type: String = ""
## 触发阶段：月末评估、月内事件等
@export var trigger_phase: String = ""
## 关系下限：低于此值触发反对
@export var relation_lower_bound: int = 0
## 信任下限：低于此值触发反对
@export var trust_lower_bound: int = 0
## 竞争标签：与目标争夺相同职位/资源时触发
@export var competition_tags: Array[String] = []
## 反对力度增量
@export var opposition_delta: int = 0
## 阻断标签：命中时直接阻断任命
@export var blocker_tags: Array[String] = []
## 原因文案 key，映射到 UI 展示文本
@export var reason_text_key: String = ""
## 规则优先级（数值越大越优先）
@export var priority: int = 0
