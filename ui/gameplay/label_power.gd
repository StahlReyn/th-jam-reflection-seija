extends Label

func _physics_process(delta: float) -> void:
	text = GameVariables.get_power_display()
