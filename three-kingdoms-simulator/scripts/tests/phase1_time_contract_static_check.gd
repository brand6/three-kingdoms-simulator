extends SceneTree

const HUD_SCRIPT_PATH := "res://scripts/ui/MainHUD.gd"
const REQUIRED_TOKEN := "get_current_label"
const FORBIDDEN_TOKENS := [
	"时间：%d年 %d月 第%d旬",
	"时间：190年 1月 第1旬",
]


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var source := FileAccess.get_file_as_string(HUD_SCRIPT_PATH)
	if source.is_empty():
		_fail("Failed to read %s." % HUD_SCRIPT_PATH)
	if not source.contains(REQUIRED_TOKEN):
		_fail("MainHUD.gd must delegate time rendering through get_current_label().")
	for token in FORBIDDEN_TOKENS:
		if source.contains(token):
			_fail("MainHUD.gd still contains forbidden local time formatter token: %s" % token)
	quit()


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
