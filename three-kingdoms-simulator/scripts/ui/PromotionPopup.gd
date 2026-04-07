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


func confirm() -> void:
	hide()


func _on_canceled() -> void:
	confirm()
