extends Label

func _physics_process(delta: float) -> void:
	text = GameVariables.get_life_piece_display()
