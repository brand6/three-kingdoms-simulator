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

# Phase 3 来源快照 — 选中时冻结，月末解释复用
var task_source_type: String = ""
var authority_institution_name: String = ""
var request_character_id: String = ""
var related_bloc_id: String = ""
var source_summary: String = ""
var political_reward_tags: Array[String] = []
var political_risk_tags: Array[String] = []
var recommendation_hint_tags: Array[String] = []
var opposition_hint_tags: Array[String] = []


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


## 冻结候选任务的政治来源快照到已选月任务状态
static func freeze_source_snapshot(state: MonthlyTaskState, candidate: Dictionary) -> void:
	state.task_source_type = str(candidate.get("task_source_type", ""))
	state.authority_institution_name = str(candidate.get("authority_institution_name", ""))
	state.request_character_id = str(candidate.get("request_character_id", ""))
	state.related_bloc_id = str(candidate.get("related_bloc_id", ""))
	state.source_summary = str(candidate.get("source_summary", ""))
	var reward_tags: Array[String] = []
	for tag in Array(candidate.get("political_reward_tags", [])):
		reward_tags.append(str(tag))
	state.political_reward_tags = reward_tags
	var risk_tags: Array[String] = []
	for tag in Array(candidate.get("political_risk_tags", [])):
		risk_tags.append(str(tag))
	state.political_risk_tags = risk_tags
	var recommendation_tags: Array[String] = []
	for tag in Array(candidate.get("recommendation_hint_tags", [])):
		recommendation_tags.append(str(tag))
	state.recommendation_hint_tags = recommendation_tags
	var opposition_tags: Array[String] = []
	for tag in Array(candidate.get("opposition_hint_tags", [])):
		opposition_tags.append(str(tag))
	state.opposition_hint_tags = opposition_tags
