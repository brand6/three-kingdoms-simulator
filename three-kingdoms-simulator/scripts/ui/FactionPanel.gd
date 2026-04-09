extends PopupPanel
class_name FactionPanel

signal officer_selected(character_id: String)

const PANEL_SIZE := Vector2i(760, 520)

@onready var _body_label: Label = get_node("PanelMargin/PanelContent/BodyLabel")
@onready var _officer_list: VBoxContainer = get_node("PanelMargin/PanelContent/OfficerList")
@onready var _confirm_button: Button = get_node("PanelMargin/PanelContent/ActionRow/ConfirmButton")


func _ready() -> void:
	min_size = PANEL_SIZE
	max_size = PANEL_SIZE
	_confirm_button.pressed.connect(hide)


func show_faction(payload: Dictionary, repository: Node) -> void:
	_body_label.text = _build_body(payload)
	_render_officers(payload, repository)
	reset_size()
	size = PANEL_SIZE
	popup_centered(PANEL_SIZE)


func _build_body(payload: Dictionary) -> String:
	var overview := Dictionary(payload.get("overview", {}))
	var player_position := Dictionary(overview.get("player_position", {}))
	var bloc_rows: Array = Array(payload.get("bloc_rows", []))
	var resource_summary := Dictionary(payload.get("resource_summary", {}))
	var city_names: Array = Array(payload.get("city_names", []))
	var lines: Array[String] = []
	lines.append("玩家位置：%s｜%s" % [str(player_position.get("office_name", "—")), str(player_position.get("faction_name", "—"))])
	lines.append("推荐权重：%s｜政治风险：%s" % [str(player_position.get("recommendation_power", 0)), str(player_position.get("political_risk_level", "low"))])
	lines.append("派系块：")
	if bloc_rows.is_empty():
		lines.append("- 暂无可见派系块")
	else:
		for row in bloc_rows:
			lines.append("- %s：%s" % [str(row.get("name", "—")), str(row.get("attitude", "观望"))])
	lines.append("核心人物与城市：")
	lines.append("- 君主：%s" % str(overview.get("ruler_name", "—")))
	lines.append("- 城池：%s" % _join_values(city_names))
	lines.append("资源摘要：")
	lines.append("- 军务压力：%s｜治务负荷：%s" % [str(resource_summary.get("military_pressure", "中")), str(resource_summary.get("governance_load", "中"))])
	lines.append("- 粮秣储备：%s｜编制紧张：%s" % [str(resource_summary.get("grain_reserve_level", "中")), str(resource_summary.get("staffing_tension", "中"))])
	return "\n".join(lines)


func _render_officers(payload: Dictionary, repository: Node) -> void:
	for child in _officer_list.get_children():
		_officer_list.remove_child(child)
		child.queue_free()
	var officer_ids: Array = Array(payload.get("major_officer_ids", []))
	if officer_ids.is_empty():
		var empty_label := Label.new()
		empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		empty_label.text = "暂无可查看的核心官员。"
		_officer_list.add_child(empty_label)
		return
	for character_id in officer_ids:
		var character = repository.call("get_character", str(character_id))
		if character == null:
			continue
		var button := Button.new()
		button.custom_minimum_size = Vector2(0, 48)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.text = "%s｜查看政治角色" % str(character.name)
		button.pressed.connect(func() -> void:
			emit_signal("officer_selected", str(character_id))
		)
		_officer_list.add_child(button)


func _join_values(values: Array) -> String:
	if values.is_empty():
		return "—"
	var text_values: Array[String] = []
	for value in values:
		text_values.append(str(value))
	return ", ".join(text_values)
