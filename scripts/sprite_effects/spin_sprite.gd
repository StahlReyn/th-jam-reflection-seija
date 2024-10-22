extends Sprite2D

@export var rotation_speed : float = 10 ## deg/s

func _physics_process(delta: float) -> void:
	rotation += delta * rotation_speed
