extends Resource
class_name OfficeData

@export var id: String = ""
@export var name: String = ""
@export var tier: int = 0
@export_multiline var description: String = ""
@export var unlock_task_tags: Array[String] = []
@export var blocked_task_tags: Array[String] = []
@export var merit_threshold: int = 0
@export var next_office_id: String = ""
@export var prev_office_id: String = ""
@export var address_title: String = ""
@export var stipend_text: String = ""
@export var is_phase2_1_available: bool = true
@export var sort_order: int = 0
