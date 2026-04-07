extends RefCounted
class_name JsonDefinitionLoader

const GENERATED_ROOT := "res://data/generated/190"


func load_dataset(dataset_id: String) -> Dictionary:
	var index: Dictionary = _read_json("%s/index.json" % GENERATED_ROOT) as Dictionary
	if index.is_empty() or not index.has(dataset_id):
		push_error("Missing dataset index entry: %s" % dataset_id)
		return {}

	var dataset_files: Dictionary = index.get(dataset_id, {}) as Dictionary
	return {
		"scenario": _read_json("%s/%s" % [GENERATED_ROOT, str(dataset_files.get("scenario", ""))]),
		"characters": _read_json("%s/%s" % [GENERATED_ROOT, str(dataset_files.get("characters", ""))]),
		"factions": _read_json("%s/%s" % [GENERATED_ROOT, str(dataset_files.get("factions", ""))]),
		"cities": _read_json("%s/%s" % [GENERATED_ROOT, str(dataset_files.get("cities", ""))])
	}


func _read_json(path: String) -> Variant:
	if path.is_empty() or not FileAccess.file_exists(path):
		push_error("JSON file not found: %s" % path)
		return {}

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Failed to open JSON file: %s" % path)
		return {}

	var parser := JSON.new()
	var error := parser.parse(file.get_as_text())
	if error != OK:
		push_error("Failed to parse JSON file: %s" % path)
		return {}

	return parser.data
