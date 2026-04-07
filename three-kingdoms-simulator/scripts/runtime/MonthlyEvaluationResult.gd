extends RefCounted
class_name MonthlyEvaluationResult

var month_key: String = ""
var character_id: String = ""
var task_result: String = ""
var merit_delta: int = 0
var fame_delta: int = 0
var trust_delta: int = 0
var office_changed: bool = false
var old_office_id: String = ""
var new_office_id: String = ""
var promotion_triggered_by_rule_id: String = ""
var task_name: String = ""
var progress_current_value: int = 0
var progress_target_value: int = 0
var progress_bonus_value: int = 0
var summary_lines: Array[String] = []
var next_goal_hint: String = ""
var promotion_missing_values: Dictionary = {}
var promotion_failure_label: String = ""


static func create(
	month_key_value: String,
	character_id_value: String,
	task_result_value: String,
	merit_delta_value: int,
	fame_delta_value: int,
	trust_delta_value: int,
	office_changed_value: bool,
	old_office_id_value: String,
	new_office_id_value: String,
	promotion_triggered_by_rule_id_value: String,
	task_name_value: String = "",
	progress_current_value_value: int = 0,
	progress_target_value_value: int = 0,
	progress_bonus_value_value: int = 0,
	summary_lines_value: Array[String] = [],
	next_goal_hint_value: String = "",
	promotion_missing_values_value: Dictionary = {},
	promotion_failure_label_value: String = ""
) -> MonthlyEvaluationResult:
	var result := MonthlyEvaluationResult.new()
	result.month_key = month_key_value
	result.character_id = character_id_value
	result.task_result = task_result_value
	result.merit_delta = merit_delta_value
	result.fame_delta = fame_delta_value
	result.trust_delta = trust_delta_value
	result.office_changed = office_changed_value
	result.old_office_id = old_office_id_value
	result.new_office_id = new_office_id_value
	result.promotion_triggered_by_rule_id = promotion_triggered_by_rule_id_value
	result.task_name = task_name_value
	result.progress_current_value = progress_current_value_value
	result.progress_target_value = progress_target_value_value
	result.progress_bonus_value = progress_bonus_value_value
	result.summary_lines = summary_lines_value.duplicate()
	result.next_goal_hint = next_goal_hint_value
	result.promotion_missing_values = promotion_missing_values_value.duplicate(true)
	result.promotion_failure_label = promotion_failure_label_value
	return result
