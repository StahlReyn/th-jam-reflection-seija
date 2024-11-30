extends Node2D

@onready var stat_label = $Control/CenterContainer/VBoxContainer/Stats
@onready var input_delay = $Timer
@onready var screen_wipe = $Control/ScreenWipe
var can_return := false

func _ready() -> void:
	stat_label.text = (
		"Score: " + GameVariables.get_score_display() +
		"\nPoint Value: " + GameVariables.get_point_value_display() +
		"\nPower: " + GameVariables.get_power_display() +
		"\nDeaths: " + str(GameVariables.deaths) + 
		"\nShoot Down: " + str(GameVariables.shoot_down)
	)
	input_delay.start()
	

func _process(delta: float) -> void:
	if can_return:
		if Input.is_action_just_pressed("shoot") or Input.is_action_just_pressed("bomb"):
			screen_wipe._do_close()
			await get_tree().create_timer(0.3).timeout
			get_tree().paused = false
			SceneHandler.goto_scene(SceneHandler.scene_menu)

func _on_timer_timeout() -> void:
	can_return = true
