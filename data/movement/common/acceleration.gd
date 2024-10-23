class_name MSAcceleration
extends MovementScript

@export var acceleration : Vector2 = Vector2.ZERO ## pixel / s^2

func _init(acceleration) -> void:
	self.acceleration = acceleration

func process_movement(delta: float) -> void:
	parent.velocity += acceleration * delta

#func _physics_process(delta: float) -> void:
	#parent.velocity += acceleration * delta
