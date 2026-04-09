extends AcceptDialog
class_name MonthReportPanel

signal confirmed_report

const PANEL_SIZE := Vector2i(620, 420)

@onready var _body_label: Label = get_node("PanelMargin/PanelContent/BodyLabel")
@onready var _confirm_button: Button = get_node("PanelMargin/PanelContent/ActionRow/ConfirmButton")


func _ready() -> void:
	canceled.connect(_on_canceled)
	min_size = PANEL_SIZE
	max_size = PANEL_SIZE
	get_ok_button().hide()
	_confirm_button.pressed.connect(confirm)


func show_report(report_text: String) -> void:
	_body_label.text = report_text
	reset_size()
	min_size = PANEL_SIZE
	max_size = PANEL_SIZE
	size = PANEL_SIZE
	call_deferred("_popup_report_panel")


func _popup_report_panel() -> void:
	popup_centered(PANEL_SIZE)
	size = PANEL_SIZE


func show_evaluation(evaluation: MonthlyEvaluationResult) -> void:
	show_report(_format_evaluation(evaluation))


func _format_evaluation(evaluation: MonthlyEvaluationResult) -> String:
	var reason_lines: Array[String] = []
	for line in evaluation.primary_support_lines:
		reason_lines.append(_normalize_reason_line(line))
	for line in evaluation.primary_blocker_lines:
		if reason_lines.size() >= 3:
			break
		reason_lines.append(_normalize_reason_line(line))
	if reason_lines.is_empty():
		reason_lines.append("本月暂无额外政治解释，默认按任务与资格结算。")
	var verdict := _verdict_label(str(evaluation.appointment_result), evaluation.office_changed)
	var political_forces := _fallback_text(evaluation.political_forces_summary, "政治力量：支持与阻力暂未成形。")
	var next_hint := _fallback_text(evaluation.next_month_political_hint, _fallback_text(evaluation.next_goal_hint, "下月建议：继续稳住主线任务并争取关键人物。"))
	return "结论：%s\n任务：%s\n原因：\n- %s\n政治力量：%s\n下月建议：%s" % [
		verdict,
		_fallback_text(evaluation.task_name, "—"),
		"\n- ".join(reason_lines),
		political_forces.trim_prefix("政治力量："),
		next_hint.trim_prefix("下月建议："),
	]


func _normalize_reason_line(line: Variant) -> String:
	if line is PoliticalReasonLine:
		return _fallback_text(line.summary_text, "—")
	return _fallback_text(str(line), "—")


func _verdict_label(appointment_result: String, office_changed: bool) -> String:
	if office_changed or appointment_result == "appointed":
		return "获得任命"
	match appointment_result:
		"lost_to_rival":
			return "竞争失利"
		"deferred":
			return "暂缓任命"
		"rejected":
			return "未获任命"
		_:
			return _fallback_text(appointment_result, "待定")


func _fallback_text(value: String, fallback: String) -> String:
	var normalized := value.strip_edges()
	return normalized if not normalized.is_empty() else fallback


func confirm() -> void:
	hide()
	emit_signal("confirmed_report")


func _on_confirmed() -> void:
	confirm()


func _on_canceled() -> void:
	confirm()
