extends ConfirmationDialog
class_name CharacterSelectorDialog

signal row_chosen(character_id: String, context_id: String)

const COLUMN_DEFS := [
	{"key": "display_name", "title": "角色"},
	{"key": "faction_name", "title": "势力"},
	{"key": "city_name", "title": "所在地"},
	{"key": "favor", "title": "好感"},
	{"key": "trust", "title": "信任"},
	{"key": "respect", "title": "敬重"},
	{"key": "vigilance", "title": "戒备"},
	{"key": "interaction_status", "title": "状态"},
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
		child.queue_free()
	for column in COLUMN_DEFS:
		var button := Button.new()
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.text = "%s%s" % [column.title, _sort_marker(str(column.key))]
		button.pressed.connect(func() -> void:
			trigger_sort(str(column.key))
		)
		_header_row.add_child(button)


func _render_rows() -> void:
	for child in _rows_container.get_children():
		child.queue_free()
	for row in _sorted_rows():
		var button := Button.new()
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.toggle_mode = true
		button.button_pressed = row.character_id == _selected_character_id
		button.disabled = not row.selectable
		button.autowrap_mode = TextServer.AUTOWRAP_OFF
		button.text = _row_text(row)
		button.tooltip_text = row.disabled_reason if not str(row.disabled_reason).is_empty() else button.text
		button.pressed.connect(func() -> void:
			choose_character(str(row.character_id))
		)
		_rows_container.add_child(button)


func _sorted_rows() -> Array:
	var sorted_rows: Array = _rows.duplicate()
	sorted_rows.sort_custom(func(a: Variant, b: Variant) -> bool:
		var left := a.get(_sort_key)
		var right := b.get(_sort_key)
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


func _row_text(row: Variant) -> String:
	var cells := [
		str(row.display_name),
		str(row.faction_name),
		str(row.city_name),
		str(row.favor),
		str(row.trust),
		str(row.respect),
		str(row.vigilance),
		str(row.interaction_status),
	]
	if not row.selectable and not str(row.disabled_reason).is_empty():
		cells.append("原因：%s" % row.disabled_reason)
	return " | ".join(cells)


func _on_confirmed() -> void:
	if _selected_character_id.is_empty():
		return
	emit_signal("row_chosen", _selected_character_id, _context_id)
