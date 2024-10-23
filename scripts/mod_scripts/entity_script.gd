class_name EntityScript
extends ModScript

@export var parent : Entity

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	pass

func physics_process_active(delta: float) -> void:
	pass

func set_parent(parent : Node) -> void:
	self.parent = parent
