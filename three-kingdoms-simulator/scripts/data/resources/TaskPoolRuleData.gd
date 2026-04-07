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
