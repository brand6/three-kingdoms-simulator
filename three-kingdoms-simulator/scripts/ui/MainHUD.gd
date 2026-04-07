extends Control
class_name MainHUD

const ERROR_TEXT := "190 样本加载失败。请检查 Luban JSON 导出文件、默认主角 ID 与数据路径配置，然后重新启动项目。"
const EMPTY_TASK_TITLE := "当前暂无正式任务"
const EMPTY_TASK_BODY := "从行动中选择拜访、巡察或探亲来创造新机会"
const MONTH_EMPTY_TASK_TITLE := "本月暂无可领任务"
const MONTH_EMPTY_TASK_BODY := "当前官职暂无匹配事务。请检查任务池配置，或等待下月任务刷新后再作部署。"
const MONTH_PICKER_TITLE := "领取主任务"
const MONTH_GATE_COPY := "本月尚未领受公事，请先择定一项主任务。"
const EMPTY_EVENT_BODY := "- 暂无新事件\n- 系统会继续根据你的所在地、势力位置与关键人物关系刷新近期动向"
const LOADING_RELATION_SUMMARY := "关键关系摘要：正在整理主公、亲近者与高戒备对象的短句摘要。"
const LOADING_FACTION_SUMMARY := "势力/派系摘要：正在汇总所属势力的支持态势、派系位置与当前风险。"
const LOADING_CLAN_SUMMARY := "家族/士族摘要：正在读取家族声望、门第期待与当前家门诉求。"
const END_TURN_TEXT := "结束本旬：确认后将立即结算本旬变化并推进到下一旬。"
const ACTION_MENU_EMPTY_HEADING := "当前暂无可显示行动"
const ACTION_MENU_EMPTY_BODY := "请确认会话是否已正确载入，再尝试打开行动菜单。"
const CATEGORY_EMPTY_BODY := "当前分类下暂无二级动作。后续可在此扩展更多原型行动。"
const RESULT_LABEL_OUTCOME := "成败结论"
const RESULT_LABEL_REASON := "原因说明"
const RESULT_LABEL_STATS := "数值变化"
const RESULT_LABEL_RELATIONS := "关系变化"
const RESULT_LABEL_CLUE := "新线索"
const XUN_SUMMARY_ACTIONS := "本旬行动摘要"
const XUN_SUMMARY_STATS := "主要数值变化"
const XUN_SUMMARY_RELATIONS := "关系变化摘要"
const XUN_SUMMARY_PROMPTS := "新提示"
const ACTION_POPUP_SIZE := Vector2i(240, 0)
const END_XUN_DIALOG_SIZE := Vector2i(420, 180)

@onready var _time_label: Label = get_node("MarginContainer/VBoxContainer/TopBar/TopBarContent/TimeLabel")
@onready var _city_label: Label = get_node("MarginContainer/VBoxContainer/TopBar/TopBarContent/CityLabel")
@onready var _identity_label: Label = get_node("MarginContainer/VBoxContainer/TopBar/TopBarContent/IdentityLabel")
@onready var _faction_label: Label = get_node("MarginContainer/VBoxContainer/TopBar/TopBarContent/FactionLabel")
@onready var _clan_family_label: Label = get_node("MarginContainer/VBoxContainer/TopBar/TopBarContent/ClanFamilyLabel")
@onready var _name_label: Label = get_node("MarginContainer/VBoxContainer/MainContent/LeftOverview/LeftOverviewContent/NameLabel")
@onready var _ap_label: Label = get_node("MarginContainer/VBoxContainer/MainContent/LeftOverview/LeftOverviewContent/APLabel")
@onready var _energy_label: Label = get_node("MarginContainer/VBoxContainer/MainContent/LeftOverview/LeftOverviewContent/EnergyLabel")
@onready var _stress_label: Label = get_node("MarginContainer/VBoxContainer/MainContent/LeftOverview/LeftOverviewContent/StressLabel")
@onready var _fame_label: Label = get_node("MarginContainer/VBoxContainer/MainContent/LeftOverview/LeftOverviewContent/FameLabel")
@onready var _merit_label: Label = get_node("MarginContainer/VBoxContainer/MainContent/LeftOverview/LeftOverviewContent/MeritLabel")
@onready var _office_info_label: Label = get_node("MarginContainer/VBoxContainer/MainContent/LeftOverview/LeftOverviewContent/OfficeInfoLabel")
@onready var _status_info_label: Label = get_node("MarginContainer/VBoxContainer/MainContent/LeftOverview/LeftOverviewContent/StatusInfoLabel")
@onready var _health_info_label: Label = get_node("MarginContainer/VBoxContainer/MainContent/LeftOverview/LeftOverviewContent/HealthInfoLabel")
@onready var _task_list: Label = get_node("MarginContainer/VBoxContainer/MainContent/RightContext/TaskPanel/TaskPanelContent/TaskListScroll/TaskList")
@onready var _event_list: Label = get_node("MarginContainer/VBoxContainer/MainContent/RightContext/EventPanel/EventPanelContent/EventListScroll/EventList")
@onready var _relation_summary_body: Label = get_node("MarginContainer/VBoxContainer/MainContent/CenterSummary/RelationSummaryCard/RelationSummaryContent/RelationSummaryBody")
@onready var _faction_summary_body: Label = get_node("MarginContainer/VBoxContainer/MainContent/CenterSummary/FactionSummaryCard/FactionSummaryContent/FactionSummaryBody")
@onready var _clan_summary_body: Label = get_node("MarginContainer/VBoxContainer/MainContent/CenterSummary/ClanSummaryCard/ClanSummaryContent/ClanSummaryBody")
@onready var _action_button: Button = get_node("MarginContainer/VBoxContainer/BottomBar/BottomBarContent/ActionButton")
@onready var _relation_button: Button = get_node("MarginContainer/VBoxContainer/BottomBar/BottomBarContent/RelationButton")
@onready var _end_turn_button: Button = get_node("MarginContainer/VBoxContainer/BottomBar/BottomBarContent/EndTurnButton")
@onready var _action_menu_popup: PopupPanel = get_node("ActionMenuPopup")
@onready var _category_list: VBoxContainer = get_node("ActionMenuPopup/ActionMenuMargin/CategoryList")
@onready var _action_sub_menu_popup: PopupPanel = get_node("ActionSubMenuPopup")
@onready var _action_list: VBoxContainer = get_node("ActionSubMenuPopup/SubMenuMargin/ActionList")
@onready var _target_picker_dialog: ConfirmationDialog = get_node("TargetPickerDialog")
@onready var _target_list: VBoxContainer = get_node("TargetPickerDialog/TargetPickerMargin/TargetPickerContent/TargetListScroll/TargetList")
@onready var _relation_list: VBoxContainer = get_node("RelationPopup/RelationMargin/RelationContent/RelationListScroll/RelationList")
@onready var _character_selector_dialog: ConfirmationDialog = get_node("CharacterSelectorDialog")
@onready var _character_profile_panel: PopupPanel = get_node("CharacterProfilePanel")
@onready var _action_result_dialog: AcceptDialog = get_node("ActionResultDialog")
@onready var _action_result_body: Label = get_node("ActionResultDialog/ActionResultMargin/ActionResultBody")
@onready var _end_xun_dialog: ConfirmationDialog = get_node("EndXunDialog")
@onready var _xun_summary_dialog: AcceptDialog = get_node("XunSummaryDialog")
@onready var _xun_summary_body: Label = get_node("XunSummaryDialog/XunSummaryMargin/XunSummaryBody")
@onready var _task_select_panel: PopupPanel = get_node("TaskSelectPanel")
@onready var _month_report_panel = get_node("MonthReportPanel")
@onready var _promotion_popup = get_node("PromotionPopup")

var _selected_action_category: String = "成长"
var _active_month_end_evaluation: MonthlyEvaluationResult = null


func _game_root() -> Node:
	return get_node("/root/GameRoot")


func _data_repository() -> Node:
	return get_node("/root/DataRepository")


func _time_manager() -> Node:
	return get_node("/root/TimeManager")


func _ready() -> void:
	show_loading_state()
	_action_button.pressed.connect(_on_action_button_pressed)
	_relation_button.pressed.connect(_on_relation_button_pressed)
	_end_turn_button.pressed.connect(_on_end_turn_button_pressed)
	_target_picker_dialog.confirmed.connect(_on_target_picker_confirmed)
	_character_selector_dialog.row_chosen.connect(_on_character_selector_row_chosen)
	_end_xun_dialog.confirmed.connect(_on_end_xun_confirmed)
	_task_select_panel.task_confirmed.connect(_on_month_task_confirmed)
	_month_report_panel.confirmed_report.connect(_on_month_report_confirmed)
	_end_xun_dialog.get_ok_button().text = "确认"
	_end_xun_dialog.get_cancel_button().text = "取消"
	if Engine.is_editor_hint():
		return
	call_deferred("_bootstrap_default_entry")


func _bootstrap_default_entry() -> void:
	_game_root().call("register_hud", self)
	_game_root().call("bootstrap_default_entry")


func show_loading_state() -> void:
	_task_list.text = _empty_task_text()
	_event_list.text = EMPTY_EVENT_BODY
	_relation_summary_body.text = LOADING_RELATION_SUMMARY
	_faction_summary_body.text = LOADING_FACTION_SUMMARY
	_clan_summary_body.text = LOADING_CLAN_SUMMARY
	_render_empty_fields()


func show_success_state(session: GameSession) -> void:
	var protagonist := _data_repository().call("get_character", session.protagonist_id) as CharacterDefinition
	var runtime_state := session.get_character_state(session.protagonist_id)
	var city := _data_repository().call("get_city", runtime_state.current_city_id if runtime_state != null else "") as CityDefinition
	var faction := _data_repository().call("get_faction", protagonist.faction_id if protagonist != null else "") as FactionDefinition

	var city_name := _display_value(city.name if city != null else "")
	var faction_name := _display_value(faction.name if faction != null else "")
	var protagonist_name := _display_value(protagonist.name if protagonist != null else "")
	var identity_text := _localized_identity(protagonist.identity_type if protagonist != null else "")
	var office_text := _current_office_text(session, protagonist)
	var clan_text := _localized_clan(protagonist.clan_id if protagonist != null else "")
	var family_text := _localized_family(protagonist.family_id if protagonist != null else "")
	var ap_value := _metric_value(runtime_state, &"ap")
	var merit_value := _metric_value(runtime_state, &"merit")

	_task_list.text = _build_task_summary(session)
	_event_list.text = _build_event_list(city_name, faction_name, protagonist_name)
	_relation_summary_body.text = _build_relation_summary(faction_name, merit_value)
	_faction_summary_body.text = _build_faction_summary(faction_name, city_name)
	_clan_summary_body.text = _build_clan_summary(family_text, clan_text)

	_time_label.text = _time_text(session)
	_city_label.text = "地点：%s" % city_name
	_identity_label.text = "身份：%s" % identity_text
	_faction_label.text = "势力：%s" % faction_name
	_clan_family_label.text = "士族/家族：%s / %s" % [clan_text, family_text]
	_name_label.text = _pair_text("姓名", protagonist_name)
	_ap_label.text = _metric_text("AP", runtime_state, &"ap")
	_energy_label.text = _metric_text("精力", runtime_state, &"energy")
	_stress_label.text = _metric_text("压力", runtime_state, &"stress")
	_fame_label.text = _metric_text("名望", runtime_state, &"fame")
	_merit_label.text = _metric_text("功绩", runtime_state, &"merit")
	_office_info_label.text = "官职：%s" % office_text
	_status_info_label.text = "状态：%s" % _status_text(runtime_state)
	_health_info_label.text = "健康：%s" % _health_text(runtime_state)
	_apply_month_action_gate(session)
	_refresh_overlay_data()
	_open_month_task_picker_if_needed(session)


func show_error_state(message: String) -> void:
	_task_list.text = "- 入口异常\n- 检查数据文件、确认默认主角，并在修复后重新启动项目"
	_event_list.text = "- 启动失败\n- %s\n- %s" % [ERROR_TEXT, _display_value(message)]
	_relation_summary_body.text = "关键关系摘要：数据尚未载入，无法生成可信关系提示。"
	_faction_summary_body.text = "势力/派系摘要：数据尚未载入，无法判断当前政治环境。"
	_clan_summary_body.text = "家族/士族摘要：数据尚未载入，无法提供家门与士族背景提示。"
	_render_empty_fields()


func _render_empty_fields() -> void:
	_time_label.text = "时间：190年 1月 第1旬"
	_city_label.text = "地点：—"
	_identity_label.text = "身份：—"
	_faction_label.text = "势力：—"
	_clan_family_label.text = "士族/家族：—"
	_name_label.text = _pair_text("姓名", "")
	_ap_label.text = _pair_text("AP", null)
	_energy_label.text = _pair_text("精力", null)
	_stress_label.text = _pair_text("压力", null)
	_fame_label.text = _pair_text("名望", null)
	_merit_label.text = _pair_text("功绩", null)
	_office_info_label.text = "官职：—"
	_status_info_label.text = "状态：待命"
	_health_info_label.text = "健康：稳定"


func _empty_task_text() -> String:
	return "- %s\n- %s" % [EMPTY_TASK_TITLE, EMPTY_TASK_BODY]


func _build_task_summary(session: GameSession) -> String:
	if session == null:
		return _empty_task_text()
	var task_state: MonthlyTaskState = session.current_month_task as MonthlyTaskState
	if task_state == null:
		if session.month_action_locked:
			var pending: Array = _game_root().call("get_pending_month_tasks")
			if pending.is_empty():
				return "%s\n%s" % [MONTH_EMPTY_TASK_TITLE, MONTH_EMPTY_TASK_BODY]
			return "%s\n%s" % [MONTH_PICKER_TITLE, MONTH_GATE_COPY]
		return _empty_task_text()
	var template = _data_repository().call("get_task_template", task_state.task_template_id)
	var task_name := str(template.name if template != null else task_state.task_template_id)
	var progress := task_state.progress_snapshot
	var current_value := int(progress.current_value if progress != null else 0)
	var target_value := int(progress.target_value if progress != null else 0)
	var bonus_value := int(progress.bonus_value if progress != null else 0)
	var progress_text := "%d/%d" % [current_value, target_value]
	if bonus_value > target_value:
		progress_text = "%s（优秀 %d）" % [progress_text, bonus_value]
	return "当前主任务：%s\n当前进度：%s\n剩余旬数：%d" % [task_name, progress_text, _remaining_xun_count(session)]


func _build_event_list(city_name: String, faction_name: String, protagonist_name: String) -> String:
	return "- %s城内官员正在观察%s本旬的第一步\n- %s仍处整合期，功绩与关系反馈会被放大\n- 若先巡察，可快速建立秩序；若先拜访，更利于后续政治推进" % [city_name, protagonist_name, faction_name]


func _build_relation_summary(faction_name: String, merit_value: String) -> String:
	var text := "关键关系摘要：优先争取%s阵营中的核心文臣；亲近者提供背书，高戒备者会放大你的失误。" % faction_name
	if merit_value != "—":
		text += " 当前功绩 %s。" % merit_value
	return text


func _build_faction_summary(faction_name: String, city_name: String) -> String:
	return "势力/派系摘要：你正处于%s的核心视线中；当前态度偏支持，但仍需先稳住%s并证明你能持续产出成果。" % [faction_name, city_name]


func _build_clan_summary(family_text: String, clan_text: String) -> String:
	return "家族/士族摘要：家族 %s、士族 %s 正在等待可见成果；若长期忽视家门诉求，后续举荐与联姻机会会减弱。" % [family_text, clan_text]


func _status_text(runtime_state: RuntimeCharacterState) -> String:
	if runtime_state == null:
		return "待命"
	if runtime_state.stress >= 70:
		return "承压"
	if runtime_state.energy <= 30:
		return "疲惫"
	if runtime_state.ap <= 0:
		return "本旬已尽力"
	return "在城待命"


func _health_text(runtime_state: RuntimeCharacterState) -> String:
	if runtime_state == null:
		return "稳定"
	if runtime_state.energy <= 20:
		return "欠佳"
	if runtime_state.stress >= 80:
		return "需要休整"
	return "稳定"


func _time_text(session: GameSession) -> String:
	if session == null:
		return "时间：190年 1月 第1旬"
	return "时间：%d年 %d月 第%d旬" % [session.current_year, session.current_month, session.current_xun]


func _localized_identity(value: String) -> String:
	match value:
		"ruler":
			return "君主"
		"civil_official":
			return "文官"
		"military_officer":
			return "武官"
		"free_agent":
			return "游士"
		_:
			return _display_value(value)


func _localized_office(value: String) -> String:
	match value:
		"lord":
			return "领主"
		"chief_advisor":
			return "首席谋臣"
		"frontline_commander":
			return "前线统兵"
		"hegemon_claimant":
			return "盟主争衡者"
		"":
			return "无官职"
		_:
			return _display_value(value)


func _localized_family(value: String) -> String:
	match value:
		"cao_family":
			return "曹氏"
		"xun_family":
			return "荀氏"
		"le_family":
			return "乐氏"
		"yuan_family":
			return "袁氏"
		"chen_family":
			return "陈氏"
		_:
			return _display_value(value)


func _localized_clan(value: String) -> String:
	match value:
		"qiao_cao_clan":
			return "谯郡曹氏"
		"yingchuan_xun_clan":
			return "颍川荀氏"
		"new_merit_clan":
			return "新兴军功门第"
		"runan_yuan_clan":
			return "汝南袁氏"
		"chenjun_chen_clan":
			return "陈郡陈氏"
		_:
			return _display_value(value)


func _pair_text(label_text: String, value: Variant) -> String:
	return "%s：%s" % [label_text, _display_value(value)]


func _metric_text(label_text: String, runtime_state: RuntimeCharacterState, property_name: StringName) -> String:
	if runtime_state == null:
		return _pair_text(label_text, null)
	return _pair_text(label_text, runtime_state.get(property_name))


func _metric_value(runtime_state: RuntimeCharacterState, property_name: StringName) -> String:
	if runtime_state == null:
		return "—"
	return _display_value(runtime_state.get(property_name))


func _display_value(value: Variant) -> String:
	if value == null:
		return "—"
	var text := str(value).strip_edges()
	if text.is_empty() or text == "null" or text == "N/A":
		return "—"
	return text


func _on_action_button_pressed() -> void:
	if _game_root().current_session != null and _game_root().current_session.month_action_locked:
		_open_month_task_picker_if_needed(_game_root().current_session)
		return
	_refresh_action_menu()
	_popup_action_menu()


func _on_relation_button_pressed() -> void:
	_open_character_selector("relation")


func _refresh_overlay_data() -> void:
	_sync_month_task_ui_state()
	if _game_root().current_session != null:
		_task_list.text = _build_task_summary(_game_root().current_session)
	_refresh_action_menu()


func _refresh_action_menu() -> void:
	_clear_children(_category_list)
	var categories: Array = _game_root().call("get_phase2_action_categories")
	if categories.is_empty():
		categories = ["成长", "关系", "政务", "军事", "家族", "移动"]
	# 获取全部行动（含 disabled），用于判断分类是否有内容
	var all_actions: Array = _game_root().call("get_available_phase2_actions")
	var any_visible := false
	for category in categories:
		var category_actions := _filter_actions_by_category(all_actions, str(category))
		if category_actions.is_empty():
			continue  # 该分类下无任何行动定义，隐藏按钮
		any_visible = true
		var button := Button.new()
		button.text = str(category)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(_on_action_category_pressed.bind(str(category)))
		_category_list.add_child(button)
	if not any_visible:
		var label := Label.new()
		label.text = ACTION_MENU_EMPTY_BODY
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_category_list.add_child(label)
	# 更新选中分类：若当前选中分类已不可见，重置为第一个有内容的分类
	if not categories.has(_selected_action_category) or _filter_actions_by_category(all_actions, _selected_action_category).is_empty():
		for category in categories:
			if not _filter_actions_by_category(all_actions, str(category)).is_empty():
				_selected_action_category = str(category)
				break


func _open_sub_menu(category_id: String) -> void:
	_clear_children(_action_list)
	var actions: Array = _game_root().call("get_available_phase2_actions")
	var category_actions := _filter_actions_by_category(actions, category_id)
	if category_actions.is_empty():
		var label := Label.new()
		label.text = CATEGORY_EMPTY_BODY
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_action_list.add_child(label)
	else:
		for spec in category_actions:
			var button := Button.new()
			button.text = str(spec.display_name)
			button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			button.disabled = not str(spec.disabled_reason).is_empty()
			var tooltip := "AP：%d｜精力：%s\n%s" % [spec.ap_cost, _signed_value(spec.energy_delta), spec.effect_summary]
			if not str(spec.disabled_reason).is_empty():
				tooltip += "\n⚠ %s" % spec.disabled_reason
			button.tooltip_text = tooltip
			button.pressed.connect(_on_action_entry_pressed.bind(spec))
			_action_list.add_child(button)
	# 等下一帧布局完成后再定位，确保 size 已经反映实际内容高度
	call_deferred("_position_sub_menu")


func _position_sub_menu() -> void:
	_action_sub_menu_popup.reset_size()
	var primary_pos := _action_menu_popup.position
	var primary_size := _action_menu_popup.size
	var sub_x := primary_pos.x + primary_size.x
	var sub_y := primary_pos.y
	_action_sub_menu_popup.popup(Rect2i(Vector2i(sub_x, sub_y), Vector2i(0, 0)))


func _on_action_category_pressed(category_id: String) -> void:
	_selected_action_category = category_id
	_open_sub_menu(category_id)


func _on_action_entry_pressed(spec: Variant) -> void:
	_handle_action_selected(spec)


func _filter_actions_by_category(actions: Array, category_id: String) -> Array:
	var filtered: Array = []
	for spec in actions:
		if str(spec.category_id) == category_id:
			filtered.append(spec)
	return filtered


func _popup_action_menu() -> void:
	# 等下一帧布局完成后弹出，确保 reset_size() 反映实际内容高度
	call_deferred("_show_action_menu_popup")


func _show_action_menu_popup() -> void:
	_action_menu_popup.reset_size()
	var button_rect := _action_button.get_global_rect()
	var popup_x := int(button_rect.position.x)
	var popup_y := int(button_rect.position.y) - 12
	_action_menu_popup.popup(Rect2i(Vector2i(popup_x, popup_y), Vector2i(0, 0)))


func _localized_target_type(target_type: String) -> String:
	match target_type:
		"character":
			return "角色"
		"none":
			return "无"
		_:
			return target_type


func _signed_value(value: int) -> String:
	return "+%d" % value if value > 0 else str(value)


func _handle_action_selected(spec: Variant) -> void:
	if not str(spec.disabled_reason).is_empty():
		return
	_action_menu_popup.hide()
	_action_sub_menu_popup.hide()
	if spec.id == "visit":
		_open_character_selector("visit")
		return
	var result = _game_root().call("execute_phase2_action", spec.id, "")
	_show_action_result(result)
	show_success_state(_game_root().current_session)
	_refresh_action_menu()


func _open_character_selector(context_id: String) -> void:
	var rows: Array = _game_root().call("get_character_selector_rows", context_id)
	var heading := "选择拜访目标" if context_id == "visit" else "选择关系对象"
	var hint := "点击表头可排序；确认后才执行后续动作。"
	_character_selector_dialog.configure(context_id, rows, heading, hint)
	_character_selector_dialog.reset_size()
	_character_selector_dialog.popup_centered(Vector2i(880, 420))


func _on_character_selector_row_chosen(character_id: String, context_id: String) -> void:
	if context_id == "visit":
		var result = _game_root().call("execute_phase2_action", "visit", character_id)
		_show_action_result(result)
		show_success_state(_game_root().current_session)
		_refresh_action_menu()
		return
	var view_data = _game_root().call("get_character_profile_view_data", character_id)
	_character_profile_panel.show_profile(view_data)


func _refresh_target_picker() -> void:
	_clear_children(_target_list)
	var relations: Array = _game_root().call("get_relation_overview")
	var protagonist_id: String = _game_root().current_session.protagonist_id if _game_root().current_session != null else ""
	var protagonist_state: RuntimeCharacterState = _game_root().current_session.get_character_state(protagonist_id)
	if protagonist_state == null:
		return
	var targets: Array = _data_repository().call("get_characters_in_city", protagonist_state.current_city_id)
	for target in targets:
		if target.id == protagonist_id:
			continue
		var button := Button.new()
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.toggle_mode = true
		button.text = _format_target_row(target, relations)
		button.set_meta("target_id", target.id)
		_target_list.add_child(button)


func _format_target_row(target: CharacterDefinition, relations: Array) -> String:
	var faction := _data_repository().call("get_faction", target.faction_id) as FactionDefinition
	var city := _data_repository().call("get_city", target.city_id) as CityDefinition
	var relation_summary := "关系摘要：尚无重点标记"
	for relation in relations:
		if relation.target_character_id == target.id:
			relation_summary = "关系摘要：好感 %d / 信任 %d / 敬重 %d / 戒备 %d" % [relation.favor, relation.trust, relation.respect, relation.vigilance]
			break
	return "目标名：%s\n所属势力：%s\n所在城市：%s\n%s\n预估效果：好感 +10，信任 +6，敬重 +2，戒备 -4" % [target.name, _display_value(faction.name if faction != null else ""), _display_value(city.name if city != null else ""), relation_summary]


func _on_target_picker_confirmed() -> void:
	return


func _refresh_relation_popup() -> void:
	_clear_children(_relation_list)
	for relation in _game_root().call("get_relation_overview"):
		var target := _data_repository().call("get_character", relation.target_character_id) as CharacterDefinition
		if target == null:
			continue
		var faction := _data_repository().call("get_faction", target.faction_id) as FactionDefinition
		var label := Label.new()
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.text = "人物名：%s\n关系标签：%s\n好感：%d / 信任：%d / 敬重：%d / 戒备：%d\n所属势力：%s\n可互动状态：%s" % [
			target.name,
			_relation_tag(relation),
			relation.favor,
			relation.trust,
			relation.respect,
			relation.vigilance,
			_display_value(faction.name if faction != null else ""),
			_interaction_status(relation)
		]
		_relation_list.add_child(label)


func _relation_tag(relation: Variant) -> String:
	if relation.vigilance >= 60:
		return "高戒备"
	if relation.trust >= 50:
		return "可信赖"
	if relation.favor >= 45:
		return "亲近"
	return "观望"


func _interaction_status(relation: Variant) -> String:
	return "可拜访" if relation.vigilance < 70 else "需谨慎接触"


func _show_action_result(result: Variant) -> void:
	if result == null:
		return
	var relation_text := _format_relation_delta_text(result.relation_deltas)
	var clue_text := str(result.clue_text).strip_edges()
	_action_result_body.text = "行动名：%s\n%s：%s\n%s：%s\n%s：%s\n%s：%s\n%s：%s" % [
		result.title,
		RESULT_LABEL_OUTCOME,
		"成功" if result.success else "失败",
		RESULT_LABEL_REASON,
		result.reason_text,
		RESULT_LABEL_STATS,
		_format_stat_delta_text(result.stat_deltas),
		RESULT_LABEL_RELATIONS,
		relation_text,
		RESULT_LABEL_CLUE,
		clue_text if not clue_text.is_empty() else "无"
	]
	_action_result_dialog.popup_centered_ratio(0.45)
	_task_list.text = _build_task_summary(_game_root().current_session)
	_event_list.text = "- 结果反馈：%s\n- %s：%s\n- %s：%s" % [result.summary_line, RESULT_LABEL_STATS, _format_stat_delta_text(result.stat_deltas), RESULT_LABEL_RELATIONS, relation_text]
	_relation_summary_body.text = "关键关系摘要：%s" % relation_text


func _on_end_turn_button_pressed() -> void:
	if _xun_summary_dialog.visible:
		_xun_summary_dialog.hide()
	_end_xun_dialog.reset_size()
	_end_xun_dialog.size = END_XUN_DIALOG_SIZE
	_end_xun_dialog.popup_centered(END_XUN_DIALOG_SIZE)
	_end_xun_dialog.size = END_XUN_DIALOG_SIZE


func _on_end_xun_confirmed() -> void:
	_end_xun_dialog.hide()
	var summary = _game_root().call("end_current_xun")
	show_success_state(_game_root().current_session)
	var evaluation = _game_root().call("consume_last_month_evaluation")
	if evaluation != null:
		_active_month_end_evaluation = evaluation as MonthlyEvaluationResult
		_xun_summary_dialog.hide()
		_show_month_end_feedback(_active_month_end_evaluation)
	else:
		_show_xun_summary(summary)


func _show_xun_summary(summary: Variant) -> void:
	if summary == null:
		return
	_xun_summary_body.text = "%s\n%s\n\n%s\n%s\n\n%s\n%s\n\n%s\n%s" % [
		XUN_SUMMARY_ACTIONS,
		"\n".join(summary.action_lines),
		XUN_SUMMARY_STATS,
		_format_summary_dict(summary.stat_delta_totals),
		XUN_SUMMARY_RELATIONS,
		"\n".join(summary.relation_change_lines),
		XUN_SUMMARY_PROMPTS,
		"\n".join(summary.prompt_lines),
	]
	_xun_summary_dialog.popup_centered_ratio(0.5)
	if _game_root().current_session != null:
		_task_list.text = _build_task_summary(_game_root().current_session)
	_event_list.text = "- 旬末总结已生成\n- %s" % (summary.action_lines[0] if not summary.action_lines.is_empty() else END_TURN_TEXT)


func _format_summary_dict(values: Dictionary) -> String:
	if values.is_empty():
		return "无"
	var parts: Array[String] = []
	for key in values.keys():
		parts.append("%s %s" % [key, _signed_value(int(values[key]))])
	return "，".join(parts)


func _format_stat_delta_text(stat_deltas: Dictionary) -> String:
	if stat_deltas.is_empty():
		return "无"
	var parts: Array[String] = []
	for key in stat_deltas.keys():
		parts.append("%s %s" % [key, _signed_value(int(stat_deltas[key]))])
	return "，".join(parts)


func _format_relation_delta_text(relation_deltas: Dictionary) -> String:
	if relation_deltas.is_empty():
		return "无"
	var parts: Array[String] = []
	for key in relation_deltas.keys():
		parts.append("%s %s" % [key, _signed_value(int(relation_deltas[key]))])
	return "，".join(parts)


func _clear_children(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()


func _apply_month_action_gate(session: GameSession) -> void:
	var locked := session != null and session.month_action_locked
	_action_button.disabled = locked
	_relation_button.disabled = locked
	_end_turn_button.disabled = locked


func _open_month_task_picker_if_needed(session: GameSession) -> void:
	if session == null or not session.month_action_locked or _is_month_end_feedback_active():
		return
	var candidates: Array = _game_root().call("get_pending_month_tasks")
	_task_select_panel.show_task_picker(candidates, _data_repository())


func _on_month_task_confirmed(selected_index: int) -> void:
	var task_state = _game_root().call("select_month_task", selected_index)
	if task_state == null:
		return
	_task_select_panel.hide()
	show_success_state(_game_root().current_session)


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	_sync_month_task_ui_state()


func _sync_month_task_ui_state() -> void:
	var session: GameSession = _game_root().current_session
	if session == null:
		return
	_apply_month_action_gate(session)
	if _is_month_end_feedback_active():
		if _task_select_panel.visible:
			_task_select_panel.hide()
		return
	if session.month_action_locked:
		if not _task_select_panel.visible:
			_open_month_task_picker_if_needed(session)
	else:
		if _task_select_panel.visible:
			_task_select_panel.hide()


func _show_month_end_feedback(evaluation: MonthlyEvaluationResult) -> void:
	_month_report_panel.show_report(_build_month_report_text(evaluation))


func _on_month_report_confirmed() -> void:
	var evaluation := _active_month_end_evaluation
	if evaluation == null:
		return
	_promotion_popup.show_promotion(_build_promotion_text(evaluation))
	_active_month_end_evaluation = null


func _is_month_end_feedback_active() -> bool:
	return _active_month_end_evaluation != null or _month_report_panel.visible or _promotion_popup.visible


func _build_month_report_text(evaluation: MonthlyEvaluationResult) -> String:
	var progress_text := "%d/%d" % [evaluation.progress_current_value, evaluation.progress_target_value]
	if evaluation.progress_bonus_value > evaluation.progress_target_value:
		progress_text = "%s（优秀 %d）" % [progress_text, evaluation.progress_bonus_value]
	var political_line := "政治含义：暂无"
	for line in evaluation.summary_lines:
		if str(line).begins_with("政治含义："):
			political_line = str(line)
			break
	return "任务名称：%s\n结果：%s\n进度：%s\n功绩变化：%+d\n名望变化：%+d\n信任变化：%+d\n%s" % [
		evaluation.task_name,
		str(evaluation.task_result),
		progress_text,
		evaluation.merit_delta,
		evaluation.fame_delta,
		evaluation.trust_delta,
		political_line,
	]


func _build_promotion_text(evaluation: MonthlyEvaluationResult) -> String:
	var repository := _data_repository()
	if evaluation.office_changed:
		var office = repository.call("get_office", evaluation.new_office_id)
		var issuer = repository.call("get_character", "cao_cao")
		return "%s\n任命人：%s\n任命缘由：%s" % [
			str(office.name if office != null else evaluation.new_office_id),
			str(issuer.name if issuer != null else "—"),
			_display_value(evaluation.next_goal_hint)
		]
	return "未获任命\n%s\n%s" % [
		evaluation.promotion_failure_label,
		_build_promotion_shortfall_line(evaluation)
	]


func _build_promotion_shortfall_line(evaluation: MonthlyEvaluationResult) -> String:
	var career_state: PlayerCareerState = _game_root().current_session.player_career_state as PlayerCareerState
	var current_office = _data_repository().call("get_office", career_state.current_office_id if career_state != null else "")
	var next_office = _data_repository().call("get_office", current_office.next_office_id if current_office != null else "")
	var office_name := str(next_office.name if next_office != null else "目标官职")
	match evaluation.promotion_failure_label:
		"功绩不足":
			var required_merit := int(evaluation.promotion_missing_values.get("required_merit", 0))
			var current_merit := int(evaluation.promotion_missing_values.get("current_merit", 0))
			return "距离%s仍差 %d 功绩" % [office_name, max(0, required_merit - current_merit)]
		"名望不足":
			var required_fame := int(evaluation.promotion_missing_values.get("required_fame", 0))
			var current_fame := int(evaluation.promotion_missing_values.get("current_fame", 0))
			return "距离%s仍差 %d 名望" % [office_name, max(0, required_fame - current_fame)]
		"无空缺":
			return "当前无空缺"
		_:
			if evaluation.progress_target_value > 0:
				return "当前进度 %d/%d，未达到成功阈值" % [evaluation.progress_current_value, evaluation.progress_target_value]
			return "本月主任务未达成功阈值"


func _current_office_text(session: GameSession, protagonist: CharacterDefinition) -> String:
	if session != null and session.player_career_state != null:
		var office_id := str(session.player_career_state.current_office_id)
		if not office_id.is_empty():
			var office = _data_repository().call("get_office", office_id)
			if office != null:
				return str(office.name)
			return _localized_office(office_id)
	return _localized_office(protagonist.office_id if protagonist != null else "")


func _remaining_xun_count(session: GameSession) -> int:
	if session == null:
		return 0
	var task_system = _game_root().get("_task_system")
	if task_system != null and task_system.has_method("remaining_xun_count"):
		return int(task_system.call("remaining_xun_count", session))
	return max(0, 3 - session.current_xun)
