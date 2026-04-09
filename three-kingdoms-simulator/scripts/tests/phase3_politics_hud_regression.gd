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
	[0x4e3b, 0x8981, 0x63a8, 0x8350, 0x4eba],
	[0x4e3b, 0x8981, 0x963b, 0x529b],
	[0x5f53, 0x524d, 0x673a, 0x4f1a],
	[0x8d44, 0x683c, 0x77ed, 0x677f],
	[0x5efa, 0x8bae, 0x4f60],
	[0x5f53, 0x524d, 0x53d8, 0x5316],
	[0x5efa, 0x8bae, 0x884c, 0x52a8],
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
const FACTION_BUTTON_PATH := "MarginContainer/VBoxContainer/BottomBar/BottomBarContent/FactionButton"
const FACTION_PANEL_PATH := "FactionPanel"
const CHARACTER_PROFILE_PANEL_PATH := "CharacterProfilePanel"


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
	await _assert_opaque_faction_drilldown(hud)

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


func _assert_opaque_faction_drilldown(hud: Node) -> void:
	var faction_button := hud.get_node_or_null(FACTION_BUTTON_PATH) as Button
	if faction_button == null:
		_fail("Faction button should exist for Phase 3 drilldown.")
	if faction_button.disabled:
		_fail("Faction button should stay enabled once the main scene boots.")
	var faction_panel := hud.get_node_or_null(FACTION_PANEL_PATH) as PopupPanel
	if faction_panel == null:
		_fail("FactionPanel should exist in MainScene.")
	var profile_panel := hud.get_node_or_null(CHARACTER_PROFILE_PANEL_PATH) as PopupPanel
	if profile_panel == null:
		_fail("CharacterProfilePanel should exist in MainScene.")

	faction_button.pressed.emit()
	await process_frame
	await process_frame
	_assert_popup_is_opaque(faction_panel, "FactionPanel")
	if not faction_panel.visible:
		_fail("FactionPanel should open from FactionButton without leaving MainScene.")

	var officer_button := _first_officer_button(faction_panel)
	if officer_button == null:
		_fail("FactionPanel should list at least one officer button for drilldown.")
	officer_button.pressed.emit()
	await process_frame
	await process_frame
	_assert_popup_is_opaque(profile_panel, "CharacterProfilePanel")
	if not profile_panel.visible:
		_fail("CharacterProfilePanel should still open from a faction officer row.")
	var profile_name := profile_panel.get_node_or_null("ProfileMargin/ProfileContent/NameLabel") as Label
	if profile_name == null or profile_name.text.strip_edges().is_empty() or profile_name.text == "角色名":
		_fail("CharacterProfilePanel should render the selected officer details after drilldown.")


func _first_officer_button(faction_panel: PopupPanel) -> Button:
	var officer_list := faction_panel.get_node_or_null("PanelMargin/PanelContent/OfficerList") as VBoxContainer
	if officer_list == null:
		return null
	for child in officer_list.get_children():
		if child is Button:
			return child as Button
	return null


func _assert_popup_is_opaque(popup: PopupPanel, popup_name: String) -> void:
	if popup.transparent_bg:
		_fail("%s should disable transparent_bg so HUD content does not bleed through." % popup_name)
	if popup.transparent:
		_fail("%s should disable transparent rendering." % popup_name)
	var has_local_panel_style := popup.has_theme_stylebox_override("panel")
	var has_theme_panel_style := popup.has_theme_stylebox("panel")
	if not has_local_panel_style and not has_theme_panel_style:
		_fail("%s should expose an opaque PopupPanel panel style from the scene or shared theme." % popup_name)


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


func _string_from_codes(codes: Array) -> String:
	var chars: Array[String] = []
	for code in codes:
		chars.append(char(code))
	return "".join(chars)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
