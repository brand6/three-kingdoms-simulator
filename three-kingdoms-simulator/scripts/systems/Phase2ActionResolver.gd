extends RefCounted
class_name Phase2ActionResolver

const ACTION_RESOLUTION_SCRIPT := preload("res://scripts/runtime/ActionResolution.gd")


func execute(
	action_id: String,
	session: GameSession,
	protagonist: CharacterDefinition,
	target_character: CharacterDefinition = null
) -> Variant:
	var runtime_state := session.get_character_state(session.protagonist_id)
	if runtime_state == null or protagonist == null:
		return ACTION_RESOLUTION_SCRIPT.create(action_id, "行动失败", false, "当前会话未初始化。", "", {}, {}, "当前角色状态不可用。", "行动未执行")

	match action_id:
		"train":
			return _resolve_train(runtime_state)
		"study":
			return _resolve_study(runtime_state)
		"rest":
			return _resolve_rest(runtime_state)
		"inspect":
			return _resolve_inspect(runtime_state)
		"visit":
			return _resolve_visit(session, runtime_state, protagonist, target_character)
		_:
			return ACTION_RESOLUTION_SCRIPT.create(action_id, "行动失败", false, "未知行动。", "", {}, {}, "没有找到对应的行动规则。", "行动未执行")


func _resolve_train(runtime_state: RuntimeCharacterState) -> Variant:
	runtime_state.ap -= 1
	runtime_state.energy -= 10
	runtime_state.stress += 3
	runtime_state.merit += 1
	runtime_state.martial_exp += 6
	return ACTION_RESOLUTION_SCRIPT.create(
		"train",
		"训练",
		true,
		"训练完成。",
		"",
		{"ap": -1, "energy": -10, "stress": 3, "merit": 1, "martial_exp": 6},
		{},
		"",
		"训练完成，武艺历练有所提升。"
	)


func _resolve_study(runtime_state: RuntimeCharacterState) -> Variant:
	runtime_state.ap -= 1
	runtime_state.energy -= 8
	runtime_state.stress += 2
	runtime_state.fame += 1
	runtime_state.strategy_exp += 6
	return ACTION_RESOLUTION_SCRIPT.create(
		"study",
		"读书",
		true,
		"读书完成。",
		"",
		{"ap": -1, "energy": -8, "stress": 2, "fame": 1, "strategy_exp": 6},
		{},
		"",
		"读书完成，智略历练有所提升。"
	)


func _resolve_rest(runtime_state: RuntimeCharacterState) -> Variant:
	runtime_state.ap -= 1
	runtime_state.energy += 20
	runtime_state.stress -= 12
	return ACTION_RESOLUTION_SCRIPT.create(
		"rest",
		"休整",
		true,
		"休整完成。",
		"",
		{"ap": -1, "energy": 20, "stress": -12},
		{},
		"",
		"休整完成，精力得到恢复。"
	)


func _resolve_inspect(runtime_state: RuntimeCharacterState) -> Variant:
	runtime_state.ap -= 1
	runtime_state.energy -= 10
	runtime_state.stress += 4
	runtime_state.merit += 5
	runtime_state.governance_exp += 4
	return ACTION_RESOLUTION_SCRIPT.create(
		"inspect",
		"巡察",
		true,
		"巡察完成。",
		"",
		{"ap": -1, "energy": -10, "stress": 4, "merit": 5, "governance_exp": 4},
		{},
		"",
		"巡察完成，政务历练与功绩提升。"
	)


func _resolve_visit(
	session: GameSession,
	runtime_state: RuntimeCharacterState,
	protagonist: CharacterDefinition,
	target_character: CharacterDefinition
) -> Variant:
	if target_character == null or target_character.id == protagonist.id or target_character.city_id != runtime_state.current_city_id:
		runtime_state.stress += 2
		return ACTION_RESOLUTION_SCRIPT.create(
			"visit",
			"行动失败",
			false,
			"目标已不在当前地点，无法完成拜访。",
			target_character.id if target_character != null else "",
			{"stress": 2},
			{},
			"目标暂不可见，请重新确认所在地与动向。",
			"拜访失败，但你得到了一条关于目标动向的线索。"
		)

	runtime_state.ap -= 1
	runtime_state.energy -= 8
	runtime_state.fame += 1
	var relation_key := "%s->%s" % [protagonist.id, target_character.id]
	var relation = session.get_relation_state(relation_key)
	if relation != null:
		relation.favor += 10
		relation.trust += 6
		relation.respect += 2
		relation.vigilance -= 4
		relation.obligation += 1
	return ACTION_RESOLUTION_SCRIPT.create(
		"visit",
		"拜访",
		true,
		"拜访完成。",
		target_character.id,
		{"ap": -1, "energy": -8, "fame": 1},
		{"favor": 10, "trust": 6, "respect": 2, "vigilance": -4, "obligation": 1},
		"",
		"拜访成功，关系有所推进。"
	)
