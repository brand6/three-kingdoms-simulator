extends PopupPanel
class_name TaskSelectPanel

signal task_confirmed(selected_index: int)

const EMPTY_HEADING := "本月暂无可领任务"
const EMPTY_BODY := "当前官职暂无匹配事务。请检查任务池配置，或等待下月任务刷新后再作部署。"
const PANEL_MIN_WIDTH := 720
const PANEL_MIN_HEIGHT := 520
const CARD_BG_NORMAL := Color(0.973, 0.953, 0.918, 1.0)
const CARD_BG_HOVER := Color(0.949, 0.914, 0.843, 1.0)
const CARD_BG_SELECTED := Color(0.882, 0.788, 0.604, 1.0)
const CARD_BG_SELECTED_HOVER := Color(0.922, 0.831, 0.639, 1.0)
const CARD_BORDER_NORMAL := Color(0.812, 0.765, 0.690, 1.0)
const CARD_BORDER_SELECTED := Color(0.620, 0.451, 0.247, 1.0)
const CARD_TEXT_NORMAL := Color(0.200, 0.180, 0.160, 1.0)
const CARD_TEXT_SELECTED := Color(0.258, 0.149, 0.055, 1.0)

@onready var _title_label: Label = get_node("PanelMargin/PanelContent/TitleLabel")
@onready var _gate_label: Label = get_node("PanelMargin/PanelContent/GateLabel")
@onready var _card_list: VBoxContainer = get_node("PanelMargin/PanelContent/CardScroll/CardList")
@onready var _selected_reward_label: Label = get_node("PanelMargin/PanelContent/SelectedRewardLabel")
@onready var _confirm_button: Button = get_node("PanelMargin/PanelContent/ActionRow/ConfirmButton")

var _candidates: Array = []
var _selected_index: int = -1


func _ready() -> void:
	min_size = Vector2i(PANEL_MIN_WIDTH, PANEL_MIN_HEIGHT)
	max_size = Vector2i(PANEL_MIN_WIDTH, PANEL_MIN_HEIGHT)
	exclusive = true
	_confirm_button.pressed.connect(_on_confirm_button_pressed)
	_gate_label.visible = false
	_selected_reward_label.visible = false
	_confirm_button.visible = true
	_confirm_button.disabled = true


func show_task_picker(candidates: Array, repository: Node) -> void:
	_title_label.text = "领取本月任务"
	_gate_label.visible = false
	_selected_reward_label.visible = false
	_candidates = candidates.duplicate(true)
	_selected_index = -1
	_render_cards(repository)
	_render_selected_reward(repository)
	_confirm_button.visible = true
	_confirm_button.disabled = true
	min_size = Vector2i(PANEL_MIN_WIDTH, PANEL_MIN_HEIGHT)
	max_size = Vector2i(PANEL_MIN_WIDTH, PANEL_MIN_HEIGHT)
	size = Vector2i(PANEL_MIN_WIDTH, PANEL_MIN_HEIGHT)
	popup_centered(size)
	_queue_popup_relayout()


func _render_cards(repository: Node) -> void:
	for child in _card_list.get_children():
		_card_list.remove_child(child)
		child.queue_free()
	if _candidates.is_empty():
		var label := Label.new()
		label.name = "EmptyStateLabel"
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.text = "%s\n%s" % [EMPTY_HEADING, EMPTY_BODY]
		_card_list.add_child(label)
		return
	for index in range(_candidates.size()):
		var button := Button.new()
		button.name = "TaskCard%d" % index
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.custom_minimum_size = Vector2(0, 108)
		button.text = _card_text(Dictionary(_candidates[index]), repository)
		button.pressed.connect(_on_card_pressed.bind(index, repository))
		_apply_card_style(button, index == _selected_index)
		_card_list.add_child(button)


func _render_selected_reward(repository: Node) -> void:
	if _selected_index < 0 or _selected_index >= _candidates.size():
		_selected_reward_label.text = ""
		_selected_reward_label.visible = false
		return
	var candidate := Dictionary(_candidates[_selected_index])
	var template = repository.call("get_task_template", str(candidate.get("task_template_id", "")))
	var objective_summary := str(template.objective_summary if template != null else "")
	_selected_reward_label.text = "已选任务预期：%s\n预计奖励：%s" % [
		objective_summary if not objective_summary.is_empty() else str(candidate.get("description", "")),
		_reward_text(Dictionary(candidate.get("base_rewards", {})))
	]
	_selected_reward_label.visible = false


func _card_text(candidate: Dictionary, repository: Node) -> String:
	var issuer_name := "—"
	var issuer_id := str(candidate.get("issuer_character_id", ""))
	if not issuer_id.is_empty():
		var issuer = repository.call("get_character", issuer_id)
		issuer_name = str(issuer.name if issuer != null else issuer_id)
	return "%s\n发布人：%s\n任务描述：%s\n预计奖励：%s" % [
		str(candidate.get("name", "—")),
		issuer_name,
		str(candidate.get("description", "")),
		_reward_text(Dictionary(candidate.get("base_rewards", {})))
	]


func _reward_text(rewards: Dictionary) -> String:
	if rewards.is_empty():
		return "无"
	return "功绩 %+d / 名望 %+d / 信任 %+d" % [
		int(rewards.get("merit", 0)),
		int(rewards.get("fame", 0)),
		int(rewards.get("trust", 0))
	]


func _on_card_pressed(index: int, repository: Node) -> void:
	_selected_index = index
	_render_cards(repository)
	_render_selected_reward(repository)
	_confirm_button.visible = true
	_confirm_button.disabled = false
	_queue_popup_relayout()


func _queue_popup_relayout() -> void:
	_card_list.queue_sort()
	call_deferred("_refresh_popup_layout")


func _refresh_popup_layout() -> void:
	min_size = Vector2i(PANEL_MIN_WIDTH, PANEL_MIN_HEIGHT)
	max_size = Vector2i(PANEL_MIN_WIDTH, PANEL_MIN_HEIGHT)
	size = Vector2i(PANEL_MIN_WIDTH, PANEL_MIN_HEIGHT)
	popup_centered(size)


func _apply_card_style(button: Button, selected: bool) -> void:
	button.modulate = Color.WHITE
	var font_color := CARD_TEXT_SELECTED if selected else CARD_TEXT_NORMAL
	button.add_theme_color_override("font_color", font_color)
	button.add_theme_color_override("font_hover_color", font_color)
	button.add_theme_color_override("font_pressed_color", font_color)
	button.add_theme_color_override("font_focus_color", font_color)
	button.add_theme_stylebox_override("normal", _build_card_style(CARD_BG_SELECTED if selected else CARD_BG_NORMAL, CARD_BORDER_SELECTED if selected else CARD_BORDER_NORMAL, 2 if selected else 1))
	button.add_theme_stylebox_override("hover", _build_card_style(CARD_BG_SELECTED_HOVER if selected else CARD_BG_HOVER, CARD_BORDER_SELECTED if selected else CARD_BORDER_NORMAL, 2 if selected else 1))
	button.add_theme_stylebox_override("pressed", _build_card_style(CARD_BG_SELECTED_HOVER if selected else CARD_BG_HOVER, CARD_BORDER_SELECTED if selected else CARD_BORDER_NORMAL, 2 if selected else 1))
	button.add_theme_stylebox_override("focus", _build_card_style(CARD_BG_SELECTED_HOVER if selected else CARD_BG_HOVER, CARD_BORDER_SELECTED if selected else CARD_BORDER_NORMAL, 2 if selected else 1))


func _build_card_style(background: Color, border: Color, border_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_right = 8
	style.corner_radius_bottom_left = 8
	style.content_margin_left = 16
	style.content_margin_top = 14
	style.content_margin_right = 16
	style.content_margin_bottom = 14
	return style


func _on_confirm_button_pressed() -> void:
	if _selected_index < 0:
		return
	emit_signal("task_confirmed", _selected_index)
