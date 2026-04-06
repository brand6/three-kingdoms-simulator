extends RefCounted
class_name XunSummaryData

var xun_label: String = ""
var action_lines: Array[String] = []
var stat_delta_totals: Dictionary = {}
var relation_change_lines: Array[String] = []
var prompt_lines: Array[String] = []


static func create(
	label: String,
	actions: Array[String] = [],
	stat_totals: Dictionary = {},
	relation_lines: Array[String] = [],
	prompts: Array[String] = []
) -> Variant:
	var summary := new()
	summary.xun_label = label
	summary.action_lines = actions.duplicate()
	summary.stat_delta_totals = stat_totals.duplicate(true)
	summary.relation_change_lines = relation_lines.duplicate()
	summary.prompt_lines = prompts.duplicate()
	return summary
