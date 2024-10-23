class_name EntityScriptHandler
extends Node

func process_script(delta: float) -> void:
	for node in get_children():
		if node is EntityScript:
			node.physics_process_active(delta)
