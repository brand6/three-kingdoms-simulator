extends Resource
class_name TaskTemplateData

@export var id: String = ""
@export var name: String = ""
@export var issuer_character_id: String = ""
@export var issuer_role_tag: String = ""
@export var task_type: String = ""
@export var task_tags: Array[String] = []
@export var min_office_tier: int = 0
@export var max_office_tier: int = 99
@export_multiline var description: String = ""
@export_multiline var objective_summary: String = ""
@export var duration_months: int = 1
@export var difficulty: int = 1
@export var progress_rule_id: String = ""
@export var success_condition: Dictionary = {}
@export var excellent_condition: Dictionary = {}
@export var base_rewards: Dictionary = {}
@export var bonus_rewards: Dictionary = {}
@export var fail_result: Dictionary = {}
@export var followup_tags: Array[String] = []
@export var ui_priority: int = 0
@export var is_phase2_1_available: bool = true

# Phase 3 政治来源字段
## 任务来源类型：faction_order / relation_request / self_initiated / system_routine
@export var task_source_type: String = "faction_order"
## 请求方角色 ID（来源为 relation_request 时为关系发起者）
@export var request_character_id: String = ""
## 关联派系块 ID
@export var related_bloc_id: String = ""
## 政治收益标签（如 "上级支持+", "主战派认可"）
@export var political_reward_tags: Array[String] = []
## 政治风险标签（如 "旧吏阻力↑", "文官派保留"）
@export var political_risk_tags: Array[String] = []
## 推荐暗示标签：完成此任务可能触发的推荐规则 tag
@export var recommendation_hint_tags: Array[String] = []
## 反对暗示标签：完成此任务可能触发的反对规则 tag
@export var opposition_hint_tags: Array[String] = []
## 来源摘要（一行文字说明"这件事从哪里来"）
@export var source_summary: String = ""
## 来源优先级（数值越高越靠前）
@export var source_priority: int = 0
