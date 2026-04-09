extends SceneTree

const MAIN_SCENE := preload("res://scenes/main/MainScene.tscn")
const PRIMARY_NODE_PATHS := {
	"关系": "MarginContainer/VBoxContainer/MainContent/CenterSummary/RelationSummaryCard/RelationSummaryContent/RelationSummaryPrimary",
	"势力": "MarginContainer/VBoxContainer/MainContent/CenterSummary/FactionSummaryCard/FactionSummaryContent/FactionSummaryPrimary",
	"家族": "MarginContainer/VBoxContainer/MainContent/CenterSummary/ClanSummaryCard/ClanSummaryContent/ClanSummaryPrimary",
}
const SECONDARY_NODE_PATHS := {
	"关系": "MarginContainer/VBoxContainer/MainContent/CenterSummary/RelationSummaryCard/RelationSummaryContent/RelationSummarySecondary",
	"势力": "MarginContainer/VBoxContainer/MainContent/CenterSummary/FactionSummaryCard/FactionSummaryContent/FactionSummarySecondary",
	"家族": "MarginContainer/VBoxContainer/MainContent/CenterSummary/ClanSummaryCard/ClanSummaryContent/ClanSummarySecondary",
}
const BANNED_PRIMARY_PHRASE_CODES := [
	PackedInt32Array([0x4e3b, 0x8981, 0x63a8, 0x8350, 0x4eba]),
	PackedInt32Array([0x4e3b, 0x8981, 0x963b, 0x529b]),
	PackedInt32Array([0x5f53, 0x524d, 0x673a, 0x4f1a]),
	PackedInt32Array([0x8d44, 0x683c, 0x77ed, 0x677f]),
	PackedInt32Array([0x5efa, 0x8bae, 0x4f60]),
	PackedInt32Array([0x5f53, 0x524d, 0x53d8, 0x5316]),
	PackedInt32Array([0x5efa, 0x8bae, 0x884c, 0x52a8]),
]
const SECONDARY_GUIDANCE_KEYWORDS := [
	"本旬",
	"本月",
	"若",
	"仍可",
	"可",
	"尽快",
	"拖延",
	"影响",
	"减弱",
	"机会",
	"风险",
	"余地",
	"站队",
	"支持",
]


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var main_scene := MAIN_SCENE.instantiate()
	root.add_child(main_scene)
	main_scene.name = "MainScene"
	await process_frame
	await process_frame
	await process_frame

	var hud: Node = root.get_node("/root/MainScene")
	for card_name in PRIMARY_NODE_PATHS.keys():
		_assert_primary_summary(hud, card_name)
		_assert_secondary_summary(hud, card_name)

	main_scene.queue_free()
	await process_frame
	quit()


func _assert_primary_summary(hud: Node, card_name: String) -> void:
	var label := hud.get_node_or_null(str(PRIMARY_NODE_PATHS.get(card_name, ""))) as Label
	if label == null:
		_fail("%s primary summary node should exist." % card_name)
	var text := label.text.strip_edges()
	if text.is_empty():
		_fail("%s primary summary should always exist." % card_name)
	if text.contains("\n"):
		_fail("%s primary summary should stay as a single concise sentence." % card_name)
	for phrase in _banned_primary_phrases():
		if text.contains(phrase):
			_fail("%s primary summary should not fall back to old field/tutorial copy: %s" % [card_name, phrase])


func _assert_secondary_summary(hud: Node, card_name: String) -> void:
	var label := hud.get_node_or_null(str(SECONDARY_NODE_PATHS.get(card_name, ""))) as Label
	if label == null:
		_fail("%s secondary summary node should exist." % card_name)
	var text := label.text.strip_edges()
	if label.visible:
		if text.is_empty():
			_fail("%s secondary summary should contain text when visible." % card_name)
		if not _contains_any_keyword(text, SECONDARY_GUIDANCE_KEYWORDS):
			_fail("%s secondary summary should read like optional timing/risk/opportunity follow-up copy." % card_name)
	else:
		if not text.is_empty():
			_fail("%s secondary summary should stay empty when hidden." % card_name)


func _contains_any_keyword(text: String, keywords: Array) -> bool:
	for keyword in keywords:
		if text.contains(str(keyword)):
			return true
	return false


func _banned_primary_phrases() -> Array[String]:
	var phrases: Array[String] = []
	for codes in BANNED_PRIMARY_PHRASE_CODES:
		phrases.append(_string_from_codes(codes))
	return phrases


func _string_from_codes(codes: PackedInt32Array) -> String:
	var chars: Array[String] = []
	for code in codes:
		chars.append(char(code))
	return "".join(chars)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
