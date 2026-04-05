extends Node
class_name TimeManager

var _current_year: int = 0
var _current_month: int = 0
var _current_xun: int = 0


func initialize(start_year: int, start_month: int, start_xun: int) -> void:
	_current_year = start_year
	_current_month = start_month
	_current_xun = start_xun


func get_current_label() -> String:
	if _current_year <= 0 or _current_month <= 0 or _current_xun <= 0:
		return "—"
	return "%d年 %d月 第%d旬" % [_current_year, _current_month, _current_xun]
