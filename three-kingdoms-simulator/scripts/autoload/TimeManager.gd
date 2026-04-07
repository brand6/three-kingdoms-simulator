extends Node

var _current_year: int = 0
var _current_month: int = 0
var _current_xun: int = 0


func initialize(start_year: int, start_month: int, start_xun: int) -> void:
	_current_year = start_year
	_current_month = start_month
	_current_xun = start_xun


func advance_xun() -> void:
	if _current_year <= 0 or _current_month <= 0 or _current_xun <= 0:
		return
	if _current_xun < 3:
		_current_xun += 1
	else:
		_current_xun = 1
		_current_month += 1
		if _current_month > 12:
			_current_month = 1
			_current_year += 1


func get_xun_label(year: int, month: int, xun: int) -> String:
	if year <= 0 or month <= 0 or xun <= 0:
		return "—"
	return "%d年 / %d月 / 第%d旬" % [year, month, xun]


func get_current_label() -> String:
	return get_xun_label(_current_year, _current_month, _current_xun)


func get_current_year() -> int:
	return _current_year


func get_current_month() -> int:
	return _current_month


func get_current_xun() -> int:
	return _current_xun


func is_month_end() -> bool:
	return _current_xun == 3
