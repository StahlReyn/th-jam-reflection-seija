class_name MovementHandler
extends Node

func process_script(delta: float) -> void:
	for node in get_children():
		if node is MovementScript:
			node.process_movement(delta)

func add_movement_script(parent : Node, script : GDScript) -> Node:
	var node_script = script.new()
	add_child(node_script)
	node_script.set_parent(parent)
	return node_script
