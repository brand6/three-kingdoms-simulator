extends Resource
class_name PromotionRuleData

@export var id: String = ""
@export var from_office_id: String = ""
@export var to_office_id: String = ""
@export var required_merit: int = 0
@export var required_fame: int = 0
@export var require_task_success_this_month: bool = true
@export var min_months_in_office: int = 0
@export var vacancy_key: String = ""
@export var notification_source_character_id: String = ""
@export_multiline var success_note: String = ""
@export_multiline var failure_note: String = ""
@export var is_phase2_1_available: bool = true
