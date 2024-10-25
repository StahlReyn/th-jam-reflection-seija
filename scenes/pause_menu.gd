extends Node2D

signal retry

@export var selection_list : SelectionList

func _ready() -> void:
	modulate.a = 0.0

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("back") and not get_tree().paused:
		selection_list.reset_display()
		do_pause()
	
	if get_tree().paused:
		if Input.is_action_just_pressed("shoot"):
			match selection_list.cur_selection:
				0: # RETURN
					option_return()
				1: # RETRY
					option_retry()
				2: # QUIT
					option_quit()
					
		if Input.is_action_just_pressed("bomb"):
			option_return()
		
		modulate.a = lerp(modulate.a, 1.0, delta * 100)
	else:
		modulate.a = lerp(modulate.a, 0.0, delta * 100)

func option_return():
	print("> Option Return")
	get_tree().paused = false

func option_retry():
	print("> Option Retry")
	retry.emit()

func option_quit():
	print("> Option Quit")
	get_tree().paused = false
	SceneHandler.goto_scene(SceneHandler.scene_menu)

func do_pause():
	get_tree().paused = true

func _on_screen_wipe_closed() -> void:
	get_tree().paused = false
	GameVariables.reset_variables()
	SceneHandler.reload_current_scene()
