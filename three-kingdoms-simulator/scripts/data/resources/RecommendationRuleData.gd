extends Resource
class_name RecommendationRuleData

# 推荐规则静态定义：冻结推荐链来源与排序

@export var id: String = ""
## 来源类型：上级、同僚、派系、门阀等
@export var source_type: String = ""
## 触发阶段：月末评估、月内事件等
@export var trigger_phase: String = ""
## 目标范围：玩家、全体、指定角色等
@export var target_scope: String = ""
## 关系阈值：来源与目标之间 favor 最低要求
@export var relation_threshold: int = 0
## 信任阈值：来源与目标之间 trust 最低要求
@export var trust_threshold: int = 0
## 功绩阈值：目标角色 merit 最低要求
@export var merit_threshold: int = 0
## 派系过滤标签：仅匹配指定派系块
@export var bloc_filter_tags: Array[String] = []
## 支持力度增量
@export var support_delta: int = 0
## 原因文案 key，映射到 UI 展示文本
@export var reason_text_key: String = ""
## 规则优先级（数值越大越优先）
@export var priority: int = 0
## UI 排序序号
@export var sort_order: int = 0
