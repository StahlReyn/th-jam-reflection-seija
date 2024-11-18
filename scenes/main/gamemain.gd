class_name GameMain
extends Node2D

signal start_stage

@export var default_stage : StageData
@onready var popup : PopUps = $PopUps

func _ready() -> void:
	print("GAME MAIN READY")
	# Scene Handler need to update if it's reloaded 
	# as previous is considered freed, breaking stuff
	SceneHandler.current_scene = self
	start_stage.emit(default_stage)
	
	# popup.display_chapter()
	
