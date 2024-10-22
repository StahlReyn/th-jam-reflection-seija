extends Label

func _physics_process(delta: float) -> void:
	text = GameVariables.get_bomb_piece_display()
