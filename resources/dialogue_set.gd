class_name DialogueSet
extends Resource

@export_group("Dialogue Actions")
@export var dialogue_actions : Array[DialogueAction]
@export var start_delay : float = 0.0
@export_group("Boss Spawn")
@export var boss_spawn : PackedScene
@export var spawn_position := Vector2(385, -50)
@export var target_position := Vector2(385, 300)
