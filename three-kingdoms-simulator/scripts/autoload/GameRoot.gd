extends Node
class_name GameRoot

const DEFAULT_SCENARIO_ID := "scenario_190_smoke"
const DEFAULT_PROTAGONIST_ID := "cao_cao"

var current_session: GameSession
var last_boot_error: String = ""
var _hud: MainHUD


func bootstrap_default_entry() -> void:
	last_boot_error = ""
	if _hud != null:
		_hud.show_loading_state()

	DataRepository.load_phase1_smoke_sample()
	current_session = DataRepository.bootstrap_session(DEFAULT_SCENARIO_ID, DEFAULT_PROTAGONIST_ID)
	if current_session == null:
		show_boot_error("默认数据集或主角 ID 无法载入。")
		return

	TimeManager.initialize(current_session.current_year, current_session.current_month, current_session.current_xun)
	if _hud != null:
		_hud.show_success_state(current_session)


func show_boot_error(message: String) -> void:
	last_boot_error = message
	push_error(message)
	if _hud != null:
		_hud.show_error_state(message)


func register_hud(hud: MainHUD) -> void:
	_hud = hud
