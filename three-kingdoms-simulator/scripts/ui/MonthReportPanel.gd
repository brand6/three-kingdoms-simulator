extends AcceptDialog
class_name MonthReportPanel

signal confirmed_report

@onready var _body_label: Label = get_node("PanelMargin/PanelContent/BodyLabel")


func _ready() -> void:
	confirmed.connect(_on_confirmed)
	get_ok_button().text = "确认"


func show_report(report_text: String) -> void:
	_body_label.text = report_text
	popup(Rect2i(Vector2i.ZERO, Vector2i(620, 420)))


func confirm() -> void:
	hide()
	emit_signal("confirmed_report")


func _on_confirmed() -> void:
	confirm()
