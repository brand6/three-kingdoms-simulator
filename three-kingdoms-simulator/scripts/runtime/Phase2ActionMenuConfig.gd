extends Resource
class_name Phase2ActionMenuConfig

@export var rules: Array[Dictionary] = []


func get_sorted_rules() -> Array[Dictionary]:
	var sorted_rules: Array[Dictionary] = []
	for rule in rules:
		sorted_rules.append(Dictionary(rule).duplicate(true))
	sorted_rules.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get("menu_order", 0)) < int(b.get("menu_order", 0))
	)
	return sorted_rules


func get_rule(action_id: String) -> Dictionary:
	for rule in rules:
		if str(rule.get("action_id", "")) == action_id:
			return Dictionary(rule).duplicate(true)
	return {}
