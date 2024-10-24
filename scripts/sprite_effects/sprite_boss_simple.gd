class_name SpriteBossSimple
extends AnimatedSprite2D
## Simple Boss sprite

var total_time = 0.0

func _physics_process(delta: float) -> void:
	total_time += delta
	position.y = sin(total_time) * 15

func update_animation(parent: Node2D) -> void:
	if abs(parent.velocity.x) * 5.0 > abs(parent.velocity.y):
		if parent.velocity.x > 0:
			play("left")
		else:
			play("right")
	else:
		play("default")
