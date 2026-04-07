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
