extends RefCounted
class_name MonthlyTaskState

var month_key: String = ""
var task_template_id: String = ""
var issuer_character_id: String = ""
var accepted_at_xun: int = 0
var deadline_month_key: String = ""
var status: String = "pending"
var progress_snapshot: TaskProgressSnapshot = null
var selected_option_index: int = -1
var completion_note: String = ""
var reward_snapshot: Dictionary = {}


static func create(
	month_key_value: String,
	task_template_id_value: String,
	issuer_character_id_value: String,
	accepted_at_xun_value: int,
	deadline_month_key_value: String,
	status_value: String,
	progress_snapshot_value: TaskProgressSnapshot,
	selected_option_index_value: int = -1,
	completion_note_value: String = "",
	reward_snapshot_value: Dictionary = {}
) -> MonthlyTaskState:
	var state := MonthlyTaskState.new()
	state.month_key = month_key_value
	state.task_template_id = task_template_id_value
	state.issuer_character_id = issuer_character_id_value
	state.accepted_at_xun = accepted_at_xun_value
	state.deadline_month_key = deadline_month_key_value
	state.status = status_value
	state.progress_snapshot = progress_snapshot_value
	state.selected_option_index = selected_option_index_value
	state.completion_note = completion_note_value
	state.reward_snapshot = reward_snapshot_value.duplicate(true)
	return state
