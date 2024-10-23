class_name MovementHandler
extends Node

func process_script(delta: float) -> void:
	for node in get_children():
		if node is MovementScript:
			node.process_movement(delta)
