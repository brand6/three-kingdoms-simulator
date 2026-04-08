extends Resource
class_name TaskPoolRuleData

@export var id: String = ""
@export var scenario_ids: Array[String] = []
@export var character_ids: Array[String] = []
@export var office_tier_min: int = 0
@export var office_tier_max: int = 99
@export var include_task_tags: Array[String] = []
@export var exclude_task_tags: Array[String] = []
@export var fallback_task_ids: Array[String] = []
@export var candidate_count: int = 3
@export var allow_repeat_in_consecutive_months: bool = false
@export var max_consecutive_repeats: int = 0
@export var required_flags: Array[String] = []
@export var blocked_flags: Array[String] = []
@export var is_phase2_1_available: bool = true

# Phase 3 来源混合策略
## 必须包含的来源类型列表（如 ["faction_order", "relation_request"]）
@export var required_source_types: Array[String] = []
## 来源混合策略：ensure_diversity / best_fit / random
@export var source_mix_policy: String = "ensure_diversity"
## 关联派系偏好 ID（优先选取与此 bloc 相关的任务）
@export var related_bloc_bias: String = ""
## 备选来源类型：当 required 来源不够时的兜底
@export var fallback_source_types: Array[String] = []
