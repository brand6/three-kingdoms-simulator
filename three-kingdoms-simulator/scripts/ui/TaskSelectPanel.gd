extends PopupPanel
class_name TaskSelectPanel

signal task_confirmed(selected_index: int)

const EMPTY_HEADING := "本月暂无可领任务"
const EMPTY_BODY := "当前官职暂无匹配事务。请检查任务池配置，或等待下月任务刷新后再作部署。"

@onready var _title_label: Label = get_node("PanelMargin/PanelContent/TitleLabel")
@onready var _gate_label: Label = get_node("PanelMargin/PanelContent/GateLabel")
@onready var _card_list: VBoxContainer = get_node("PanelMargin/PanelContent/CardScroll/CardList")
@onready var _selected_reward_label: Label = get_node("PanelMargin/PanelContent/SelectedRewardLabel")
@onready var _confirm_button: Button = get_node("PanelMargin/PanelContent/ActionRow/ConfirmButton")

var _candidates: Array = []
var _selected_index: int = -1


func _ready() -> void:
	_confirm_button.pressed.connect(_on_confirm_button_pressed)
	_confirm_button.disabled = true


func show_task_picker(candidates: Array, repository: Node) -> void:
	_title_label.text = "领取主任务"
	_gate_label.text = "本月尚未领受公事，请先择定一项主任务。"
	_candidates = candidates.duplicate(true)
	_selected_index = 0 if not _candidates.is_empty() else -1
	_render_cards(repository)
	_render_selected_reward(repository)
	_confirm_button.disabled = _selected_index < 0
	popup_centered(Vector2i(720, 520))


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
		button.modulate = Color(0.82, 0.92, 0.93, 1.0) if index == _selected_index else Color(1, 1, 1, 1)
		_card_list.add_child(button)


func _render_selected_reward(repository: Node) -> void:
	if _selected_index < 0 or _selected_index >= _candidates.size():
		_selected_reward_label.text = EMPTY_BODY
		return
	var candidate := Dictionary(_candidates[_selected_index])
	var template = repository.call("get_task_template", str(candidate.get("task_template_id", "")))
	var objective_summary := str(template.objective_summary if template != null else "")
	_selected_reward_label.text = "已选任务预期：%s\n预计奖励：%s" % [
		objective_summary if not objective_summary.is_empty() else str(candidate.get("description", "")),
		_reward_text(Dictionary(candidate.get("base_rewards", {})))
	]


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
	_confirm_button.disabled = false


func _on_confirm_button_pressed() -> void:
	if _selected_index < 0:
		return
	emit_signal("task_confirmed", _selected_index)
