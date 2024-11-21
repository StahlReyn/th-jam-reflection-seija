class_name GameMain
extends Control

signal start_stage

@export var default_stage : StageData
@onready var popup : PopUps = $PopUps
@onready var game_hud : Control = $Gamehud

@onready var noise = FastNoiseLite.new()
var cur_shake_strength = 0
var noise_i: float = 0.0

func _ready() -> void:
	print("GAME MAIN READY")
	# Scene Handler need to update if it's reloaded 
	# as previous is considered freed, breaking stuff
	SceneHandler.current_scene = self
	start_stage.emit(default_stage)
	
func _physics_process(delta: float) -> void:
	cur_shake_strength -= delta * 150
	cur_shake_strength = max(0, cur_shake_strength)
	game_hud.position = get_noise_offset(delta, 1000, cur_shake_strength)
	
func get_noise_offset(delta: float, speed: float, strength: float) -> Vector2:
	noise_i += delta * speed
	return Vector2(
		noise.get_noise_2d(1, noise_i) * strength,
		noise.get_noise_2d(100, noise_i) * strength
	)
