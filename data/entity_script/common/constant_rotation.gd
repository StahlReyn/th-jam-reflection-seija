class_name MSConstantRotation
extends EntityScript

@export var rotation_speed : float = 10 ## deg/s

func _init(rotation_speed : float) -> void:
	self.rotation_speed = rotation_speed

func _physics_process(delta: float) -> void:
	parent.rotation += delta * rotation_speed
