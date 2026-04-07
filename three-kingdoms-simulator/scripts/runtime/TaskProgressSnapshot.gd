extends RefCounted
class_name TaskProgressSnapshot

var current_value: int = 0
var target_value: int = 0
var bonus_value: int = 0
var step_records: Array[Dictionary] = []
var last_update_time: String = ""
var derived_status: String = "pending"


static func create(
	current_value_value: int = 0,
	target_value_value: int = 0,
	bonus_value_value: int = 0,
	step_records_value: Array[Dictionary] = [],
	last_update_time_value: String = "",
	derived_status_value: String = "pending"
) -> TaskProgressSnapshot:
	var snapshot := TaskProgressSnapshot.new()
	snapshot.current_value = current_value_value
	snapshot.target_value = target_value_value
	snapshot.bonus_value = bonus_value_value
	snapshot.step_records = step_records_value.duplicate(true)
	snapshot.last_update_time = last_update_time_value
	snapshot.derived_status = derived_status_value
	return snapshot
