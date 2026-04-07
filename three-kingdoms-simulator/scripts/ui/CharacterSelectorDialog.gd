extends ConfirmationDialog
class_name CharacterSelectorDialog

signal row_chosen(character_id: String, context_id: String)

const COLUMN_DEFS := [
	{"key": "display_name", "title": "角色", "width": 150},
	{"key": "faction_name", "title": "势力", "width": 110},
	{"key": "city_name", "title": "所在地", "width": 110},
	{"key": "favor", "title": "好感", "width": 56},
	{"key": "trust", "title": "信任", "width": 56},
	{"key": "respect", "title": "敬重", "width": 56},
	{"key": "vigilance", "title": "戒备", "width": 56},
	{"key": "interaction_status", "title": "状态", "width": 120},
]

@onready var _heading_label: Label = get_node("SelectorMargin/SelectorContent/SelectorHeading")
@onready var _hint_label: Label = get_node("SelectorMargin/SelectorContent/SelectorHint")
@onready var _header_row: HBoxContainer = get_node("SelectorMargin/SelectorContent/HeaderRow")
@onready var _rows_container: VBoxContainer = get_node("SelectorMargin/SelectorContent/RowsScroll/RowsContainer")

var _rows: Array = []
var _context_id: String = ""
var _sort_key: String = "display_name"
var _sort_ascending: bool = true
var _selected_character_id: String = ""


func _ready() -> void:
	confirmed.connect(_on_confirmed)
	get_ok_button().text = "确认"
	get_cancel_button().text = "取消"
	get_ok_button().disabled = true


func configure(context_id: String, rows: Array, heading: String, hint: String) -> void:
	_context_id = context_id
	_rows = rows.duplicate()
	_selected_character_id = ""
	_sort_key = "display_name"
	_sort_ascending = true
	_heading_label.text = heading
	_hint_label.text = hint
	get_ok_button().disabled = true
	_render()


func trigger_sort(column_key: String) -> void:
	if _sort_key == column_key:
		_sort_ascending = not _sort_ascending
	else:
		_sort_key = column_key
		_sort_ascending = true
	_render()


func choose_character(character_id: String) -> void:
	_selected_character_id = character_id
	get_ok_button().disabled = _selected_character_id.is_empty()
	_render_rows()


func confirm_selection() -> void:
	_on_confirmed()


func get_sorted_character_ids() -> Array[String]:
	var ids: Array[String] = []
	for row in _sorted_rows():
		ids.append(str(row.character_id))
	return ids


func _render() -> void:
	_render_headers()
	_render_rows()


func _render_headers() -> void:
	for child in _header_row.get_children():
		_header_row.remove_child(child)
		child.queue_free()
	for column in COLUMN_DEFS:
		var button := Button.new()
		_apply_column_width(button, int(column.width))
		button.alignment = HORIZONTAL_ALIGNMENT_CENTER
		button.text = "%s%s" % [column.title, _sort_marker(str(column.key))]
		button.pressed.connect(_on_header_pressed.bind(str(column.key)))
		_header_row.add_child(button)


func _render_rows() -> void:
	for child in _rows_container.get_children():
		_rows_container.remove_child(child)
		child.queue_free()
	for row in _sorted_rows():
		var panel := PanelContainer.new()
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		panel.mouse_filter = Control.MOUSE_FILTER_STOP
		panel.tooltip_text = str(row.disabled_reason) if not str(row.disabled_reason).is_empty() else _row_tooltip_text(row)
		if row.character_id == _selected_character_id:
			panel.self_modulate = Color(0.84, 0.90, 1.0, 1.0)
		elif not row.selectable:
			panel.self_modulate = Color(1.0, 1.0, 1.0, 0.6)
		var row_box := HBoxContainer.new()
		row_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row_box.add_theme_constant_override("separation", 6)
		panel.add_child(row_box)
		for column in COLUMN_DEFS:
			var label := Label.new()
			_apply_column_width(label, int(column.width))
			label.autowrap_mode = TextServer.AUTOWRAP_OFF
			label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.size_flags_horizontal = Control.SIZE_FILL
			label.text = _cell_text(row, str(column.key))
			row_box.add_child(label)
		if not row.selectable and not str(row.disabled_reason).is_empty():
			var reason_label := Label.new()
			reason_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			reason_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			reason_label.text = "原因：%s" % row.disabled_reason
			row_box.add_child(reason_label)
		panel.gui_input.connect(_on_row_gui_input.bind(str(row.character_id), bool(row.selectable)))
		_rows_container.add_child(panel)


func _sorted_rows() -> Array:
	var sorted_rows: Array = _rows.duplicate()
	sorted_rows.sort_custom(func(a: Variant, b: Variant) -> bool:
		var left: Variant = a.get(_sort_key)
		var right: Variant = b.get(_sort_key)
		if typeof(left) == TYPE_STRING:
			var left_text := str(left)
			var right_text := str(right)
			return left_text < right_text if _sort_ascending else left_text > right_text
		var left_value := int(left)
		var right_value := int(right)
		return left_value < right_value if _sort_ascending else left_value > right_value
	)
	return sorted_rows


func _sort_marker(column_key: String) -> String:
	if _sort_key != column_key:
		return ""
	return " ↑" if _sort_ascending else " ↓"


func _cell_text(row: Variant, column_key: String) -> String:
	return str(row.get(column_key))


func _row_tooltip_text(row: Variant) -> String:
	var cells: Array[String] = []
	for column in COLUMN_DEFS:
		cells.append("%s：%s" % [str(column.title), _cell_text(row, str(column.key))])
	return "\n".join(cells)


func _apply_column_width(control: Control, width: int) -> void:
	control.custom_minimum_size = Vector2(width, 0)


func _on_header_pressed(column_key: String) -> void:
	trigger_sort(column_key)


func _on_row_gui_input(event: InputEvent, character_id: String, selectable: bool) -> void:
	if not selectable:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		choose_character(character_id)


func _on_confirmed() -> void:
	if _selected_character_id.is_empty():
		return
	emit_signal("row_chosen", _selected_character_id, _context_id)
