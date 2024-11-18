extends Node2D

@onready var audio_shoot : AudioStream = preload("res://assets/audio/sfx/hit_noise_fade.wav")
@onready var label_volume = $SelectionList/Options/Label

signal start_game

@export var selection_list : SelectionList


func _ready() -> void:
	modulate.a = 1.0
	set_volume(-4.0)

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("shoot"):
		match selection_list.cur_selection:
			0: # START
				option_start()
			1: # RETRY
				#option_options()
				pass
			2: # QUIT
				option_quit()
	
	if selection_list.cur_selection == 1:
		var mult = 1 
		if (Input.is_action_pressed("focus") or Input.is_key_pressed(KEY_SHIFT)):
			mult = 10
		if Input.is_action_just_pressed("move_left"):
			add_volume(-0.1 * mult)
		elif Input.is_action_just_pressed("move_right"):
			add_volume(0.1 * mult)

func set_volume(num : float) -> void:
	var cur_bus = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(cur_bus, num)
	# AudioManager.play_audio(audio_shoot)
	label_volume.text = "VOLUME: " + ("%.2f" % num) + " dB"

func add_volume(num : float) -> void:
	var cur_bus = AudioServer.get_bus_index("Master")
	var cur_volume = AudioServer.get_bus_volume_db(cur_bus)
	var new_volume = clamp(cur_volume + num, -20, 10)
	AudioServer.set_bus_volume_db(cur_bus, new_volume)
	AudioManager.play_audio(audio_shoot)
	label_volume.text = "VOLUME: " + ("%.2f" % new_volume) + " dB"

func option_start():
	print("> Option Start")
	start_game.emit()

func option_options():
	#print("> Option Options")
	print("> Option VOLUME")

func option_quit():
	print("> Option Quit")
	get_tree().quit()

func _on_screen_wipe_closed() -> void:
	SceneHandler.goto_scene(SceneHandler.scene_game)
