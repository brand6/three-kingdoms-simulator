extends RefCounted
class_name ActionResolution

var action_id: String = ""
var title: String = ""
var success: bool = false
var reason_text: String = ""
var target_character_id: String = ""
var stat_deltas: Dictionary = {}
var relation_deltas: Dictionary = {}
var clue_text: String = ""
var summary_line: String = ""


static func create(
	resolved_action_id: String,
	resolved_title: String,
	was_successful: bool,
	reason: String,
	target_id: String = "",
	stats: Dictionary = {},
	relations: Dictionary = {},
	clue: String = "",
	summary: String = ""
) -> Variant:
	var resolution := new()
	resolution.action_id = resolved_action_id
	resolution.title = resolved_title
	resolution.success = was_successful
	resolution.reason_text = reason
	resolution.target_character_id = target_id
	resolution.stat_deltas = stats.duplicate(true)
	resolution.relation_deltas = relations.duplicate(true)
	resolution.clue_text = clue
	resolution.summary_line = summary
	return resolution
