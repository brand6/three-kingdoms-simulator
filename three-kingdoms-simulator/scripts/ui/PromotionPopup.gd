extends AcceptDialog
class_name PromotionPopup

const PANEL_SIZE := Vector2i(520, 320)

@onready var _body_label: Label = get_node("PanelMargin/PanelContent/BodyLabel")
@onready var _confirm_button: Button = get_node("PanelMargin/PanelContent/ActionRow/ConfirmButton")


func _ready() -> void:
	canceled.connect(_on_canceled)
	min_size = PANEL_SIZE
	max_size = PANEL_SIZE
	get_ok_button().hide()
	_confirm_button.pressed.connect(confirm)


func show_promotion(message: String) -> void:
	_body_label.text = message
	reset_size()
	min_size = PANEL_SIZE
	max_size = PANEL_SIZE
	size = PANEL_SIZE
	call_deferred("_popup_promotion_panel")


func _popup_promotion_panel() -> void:
	popup_centered(PANEL_SIZE)
	size = PANEL_SIZE


func show_evaluation(evaluation: MonthlyEvaluationResult) -> void:
	show_promotion(_format_evaluation(evaluation))


func _format_evaluation(evaluation: MonthlyEvaluationResult) -> String:
	var cause_line := _select_cause_line(evaluation)
	var consequence_line := _select_consequence_line(evaluation)
	if evaluation.office_changed:
		return "%s\n任命缘由：%s\n新权限 / 待遇：%s" % [_display_office_name(evaluation.new_office_id), cause_line, consequence_line]
	return "未获任命\n原因：%s\n下月建议：%s" % [cause_line, consequence_line]


func _select_cause_line(evaluation: MonthlyEvaluationResult) -> String:
	if not evaluation.primary_blocker_lines.is_empty():
		return _normalize_reason_line(evaluation.primary_blocker_lines[0])
	if not evaluation.primary_support_lines.is_empty():
		return _normalize_reason_line(evaluation.primary_support_lines[0])
	return _fallback_text(evaluation.promotion_failure_label, "本月暂无额外任命原因说明。")


func _select_consequence_line(evaluation: MonthlyEvaluationResult) -> String:
	if evaluation.office_changed:
		return _fallback_text(evaluation.next_month_political_hint, _fallback_text(evaluation.next_goal_hint, "下月优先用新职权稳住局势。"))
	if not evaluation.missed_opportunity_note.is_empty():
		return evaluation.missed_opportunity_note
	return _fallback_text(evaluation.next_month_political_hint, _fallback_text(evaluation.next_goal_hint, "下月继续争取资格与政治支持。"))


func _normalize_reason_line(line: Variant) -> String:
	if line is PoliticalReasonLine:
		return _fallback_text(line.summary_text, "—")
	return _fallback_text(str(line), "—")


func _display_office_name(office_id: String) -> String:
	var game_root := get_node_or_null("/root/GameRoot")
	if game_root == null:
		return _fallback_text(office_id, "新官职")
	var repository := game_root.call("_data_repository") as Node
	if repository == null:
		return _fallback_text(office_id, "新官职")
	var office = repository.call("get_office", office_id)
	if office != null and not str(office.name).strip_edges().is_empty():
		return str(office.name)
	return _fallback_text(office_id, "新官职")


func _fallback_text(value: String, fallback: String) -> String:
	var normalized := value.strip_edges()
	return normalized if not normalized.is_empty() else fallback


func confirm() -> void:
	hide()


func _on_canceled() -> void:
	confirm()
