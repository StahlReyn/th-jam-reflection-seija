class_name AreaCollection
extends Sprite2D

var appear_time : float = 0

func _ready() -> void:
	appear_time = 0

func _physics_process(delta: float) -> void:
	if appear_time > 0:
		appear_time -= delta
		visible = true
		var color = self.get_modulate()
		color.a = -cos(appear_time * 2) * 0.5 + 0.5
		set_modulate(color)
	else:
		visible = false

func _on_gameview_game_start() -> void:
	appear_time = 7.0
	
