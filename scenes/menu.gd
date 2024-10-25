class_name Menu
extends Node2D

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("shoot"):
		print("Pressed Start")
		SceneHandler.goto_scene(SceneHandler.scene_game)
