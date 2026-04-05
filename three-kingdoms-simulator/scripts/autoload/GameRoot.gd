extends Node
class_name GameRoot


func bootstrap_default_entry() -> void:
	push_warning("GameRoot.bootstrap_default_entry() contract is reserved for a later plan.")


func show_boot_error(message: String) -> void:
	push_error(message)
