extends SceneTree

const MAIN_SCENE := preload("res://scenes/main/MainScene.tscn")
const EXPECTED_TIME := "190年 / 1月 / 第1旬"
const EXPECTED_CITY := "地点：许县"
const EXPECTED_IDENTITY := "身份：文官"
const EXPECTED_FACTION := "势力：曹操集团"
const EXPECTED_CLAN_FAMILY := "士族/家族：颍川荀氏 / 荀氏"
const DUPLICATE_TIME_FRAGMENT := "时间："
const HUD_PATH := NodePath("MarginContainer/VBoxContainer/TopBar/TopBarContent")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var main_scene := MAIN_SCENE.instantiate()
	root.add_child(main_scene)

	await process_frame
	await process_frame
	await process_frame

	var hud_root := main_scene.get_node(HUD_PATH)
	_assert_label(hud_root.get_node("TimeLabel") as Label, EXPECTED_TIME, true)
	_assert_label(hud_root.get_node("CityLabel") as Label, EXPECTED_CITY)
	_assert_label(hud_root.get_node("IdentityLabel") as Label, EXPECTED_IDENTITY)
	_assert_label(hud_root.get_node("FactionLabel") as Label, EXPECTED_FACTION)
	_assert_label(hud_root.get_node("ClanFamilyLabel") as Label, EXPECTED_CLAN_FAMILY)

	main_scene.queue_free()
	await process_frame
	quit()


func _assert_label(label: Label, expected: String, reject_duplicate_time: bool = false) -> void:
	if label == null:
		_fail("Missing required label for regression assertion.")
	var actual := label.text
	if reject_duplicate_time and actual != EXPECTED_TIME and actual.contains(DUPLICATE_TIME_FRAGMENT):
		_fail("Time label still contains the duplicated prefix pattern: %s" % actual)
	if actual != expected:
		_fail("Expected '%s' but found '%s'." % [expected, actual])


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
