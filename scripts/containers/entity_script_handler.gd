class_name EntityScriptHandler
extends Node

func process_script(delta: float) -> void:
	for node in get_children():
		if node is EntityScript:
			node.process_movement(delta)
