extends MovementScript

@export var rotation_speed : float = 10 ## deg/s

func _physics_process(delta: float) -> void:
	parent.rotation += delta * rotation_speed
