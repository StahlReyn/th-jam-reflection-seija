class_name GameMain
extends Node2D

func _ready() -> void:
	print("GAME MAIN READY")
	# Scene Handler need to update if it's reloaded 
	# as previous is considered freed, breaking stuff
	SceneHandler.current_scene = self
