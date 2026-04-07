extends AcceptDialog
class_name PromotionPopup

@onready var _body_label: Label = get_node("PanelMargin/PanelContent/BodyLabel")


func _ready() -> void:
	get_ok_button().text = "确认"


func show_promotion(message: String) -> void:
	_body_label.text = message
	popup(Rect2i(Vector2i.ZERO, Vector2i(520, 320)))


func confirm() -> void:
	hide()
