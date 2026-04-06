extends PopupPanel
class_name CharacterProfilePanel

@onready var _name_label: Label = get_node("ProfileMargin/ProfileContent/NameLabel")
@onready var _meta_label: Label = get_node("ProfileMargin/ProfileContent/MetaLabel")
@onready var _relation_label: Label = get_node("ProfileMargin/ProfileContent/RelationLabel")
@onready var _notes_label: Label = get_node("ProfileMargin/ProfileContent/NotesLabel")

var current_character_id: String = ""


func show_profile(view_data: Variant) -> void:
	if view_data == null:
		return
	current_character_id = str(view_data.character_id)
	_name_label.text = view_data.display_name
	_meta_label.text = "身份：%s\n势力：%s\n地点：%s\n官职：%s" % [
		view_data.identity_label,
		view_data.faction_label,
		view_data.city_label,
		view_data.office_label,
	]
	_relation_label.text = "好感：%d\n信任：%d\n敬重：%d\n戒备：%d\n义务：%d" % [
		view_data.favor,
		view_data.trust,
		view_data.respect,
		view_data.vigilance,
		view_data.obligation,
	]
	_notes_label.text = "说明：\n%s" % "\n".join(view_data.notes)
	popup_centered(Vector2i(480, 320))
