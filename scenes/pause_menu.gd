extends Node2D

@export var selection_list : SelectionList

func _ready() -> void:
	modulate.a = 0.0

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("back"):
		selection_list.reset_display()
		do_pause()
	
	if Input.is_action_just_pressed("shoot"):
		match selection_list.cur_selection:
			0: # RETURN
				do_return()
			1: # RETRY
				do_return()
			2: # QUIT
				do_return()
				
	if Input.is_action_just_pressed("bomb"):
		do_return()
		
	if get_tree().paused:
		modulate.a = lerp(modulate.a, 1.0, delta * 100)
	else:
		modulate.a = lerp(modulate.a, 0.0, delta * 100)

func do_return():
	get_tree().paused = false

func do_pause():
	get_tree().paused = true
