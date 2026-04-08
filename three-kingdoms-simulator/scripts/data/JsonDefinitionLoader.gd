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
		"scenario": _read_dataset_file(dataset_files, "scenario", {}),
		"characters": _read_dataset_file(dataset_files, "characters", []),
		"factions": _read_dataset_file(dataset_files, "factions", []),
		"cities": _read_dataset_file(dataset_files, "cities", []),
		"actions": _read_dataset_file(dataset_files, "actions", []),
		"task_templates": _read_dataset_file(dataset_files, "task_templates", []),
		"offices": _read_dataset_file(dataset_files, "offices", [])
	}


func _read_dataset_file(dataset_files: Dictionary, key: String, fallback: Variant) -> Variant:
	var relative_path := str(dataset_files.get(key, ""))
	if relative_path.is_empty():
		return fallback
	return _read_json("%s/%s" % [GENERATED_ROOT, relative_path], fallback)


func _read_json(path: String, fallback: Variant = {}) -> Variant:
	if path.is_empty() or not FileAccess.file_exists(path):
		push_error("JSON file not found: %s" % path)
		return fallback

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Failed to open JSON file: %s" % path)
		return fallback

	var parser := JSON.new()
	var error := parser.parse(file.get_as_text())
	if error != OK:
		push_error("Failed to parse JSON file: %s" % path)
		return fallback

	return parser.data
