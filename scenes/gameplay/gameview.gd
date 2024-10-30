class_name GameView
extends Node2D

signal game_start

func _ready() -> void:
	game_start.emit()
	pass

func _physics_process(delta: float) -> void:
	GameVariables.game_time += delta
