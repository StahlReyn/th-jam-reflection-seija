extends Node2D

signal start_game

@export var selection_list : SelectionList

func _ready() -> void:
	modulate.a = 1.0

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("shoot"):
		match selection_list.cur_selection:
			0: # START
				option_start()
			1: # RETRY
				option_options()
			2: # QUIT
				option_quit()

func option_start():
	print("> Option Start")
	start_game.emit()

func option_options():
	print("> Option Options")

func option_quit():
	print("> Option Quit")
	get_tree().quit()

func _on_screen_wipe_closed() -> void:
	SceneHandler.goto_scene(SceneHandler.scene_game)
