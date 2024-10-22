class_name MovementScript
extends ModScript

@export var parent : Entity

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	pass

func process_movement(delta: float) -> void:
	pass

func set_parent(parent : Node) -> void:
	self.parent = parent
