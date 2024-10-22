extends AnimatedSprite2D

func update_animation(parent: Node2D) -> void:
	if parent.velocity.x > 0:
		play("right")
	elif parent.velocity.x < 0:
		play("left")
	elif sprite_frames.has_animation("idle"):
		play("idle")
