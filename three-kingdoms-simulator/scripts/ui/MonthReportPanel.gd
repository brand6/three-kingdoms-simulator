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


func confirm() -> void:
	hide()
	emit_signal("confirmed_report")


func _on_confirmed() -> void:
	confirm()


func _on_canceled() -> void:
	confirm()
