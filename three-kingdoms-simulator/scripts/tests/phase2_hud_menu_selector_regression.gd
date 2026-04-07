extends SceneTree

const MAIN_SCENE := preload("res://scenes/main/MainScene.tscn")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var main_scene := MAIN_SCENE.instantiate()
	root.add_child(main_scene)
	main_scene.name = "MainScene"
	await process_frame
	await process_frame
	await process_frame

	var hud = root.get_node("/root/MainScene")
	hud._on_action_button_pressed()
	await process_frame
	await _assert_action_menu(hud)

	hud._select_action("visit")
	hud._refresh_action_menu()
	hud._open_character_selector("visit")
	await process_frame
	var selector = hud._character_selector_dialog
	_assert_equal(selector.visible, true, "selector visible for visit")
	var original_ids: Array[String] = selector.get_sorted_character_ids()
	selector.trigger_sort("favor")
	await process_frame
	var sorted_ids: Array[String] = selector.get_sorted_character_ids()
	if original_ids == sorted_ids:
		_fail("Sorting by favor should change selector row order.")
	selector.hide()

	hud._on_relation_button_pressed()
	await process_frame
	_assert_equal(selector.visible, true, "selector visible for relation")
	selector.choose_character("chen_gong")
	selector.confirm_selection()
	await process_frame
	_assert_equal(hud._character_profile_panel.visible, true, "profile panel visible after relation selection")
	_assert_equal(hud._relation_popup.visible, false, "legacy relation popup should stay hidden")

	main_scene.queue_free()
	await process_frame
	quit()


func _assert_action_menu(hud: Node) -> void:
	_assert_equal(hud._action_menu_popup.visible, true, "action popup visible")
	var labels: Array[String] = []
	for child in hud._category_list.get_children():
		if child is Button:
			labels.append(child.text)
	_assert_equal(labels, ["成长", "关系", "政务", "军事", "家族", "移动"], "left rail action categories")
	var detail_text := ""
	for child in hud._action_list.get_children():
		for grandchild in child.get_children():
			for row_child in grandchild.get_children():
				if row_child is Label:
					detail_text += row_child.text + "\n"
	if not detail_text.contains("训练") or not detail_text.contains("效果摘要"):
		_fail("Growth category should expand to second-level action entries.")
	hud._select_action_category("关系")
	hud._refresh_action_menu()
	await process_frame
	var relation_text := ""
	for child in hud._action_list.get_children():
		for grandchild in child.get_children():
			for row_child in grandchild.get_children():
				if row_child is Label:
					relation_text += row_child.text + "\n"
	if not relation_text.contains("拜访"):
		_fail("Relation category should show second-level visit action.")


func _assert_equal(actual: Variant, expected: Variant, label: String) -> void:
	if actual != expected:
		_fail("%s expected '%s' but found '%s'." % [label, expected, actual])


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
