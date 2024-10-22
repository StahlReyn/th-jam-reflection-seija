class_name AfterEffect
extends Node2D
## Things after enemy or bullet is removed, like death effects

@export var audio_start : AudioStreamPlayer2D
@export var lifetime : float = 1.0

func _ready() -> void:
	if audio_start:
		audio_start.play()
	await get_tree().create_timer(lifetime).timeout
	queue_free()

static func add_effect(scene : PackedScene, pos : Vector2):
	var effect : AfterEffect = scene.instantiate()
	effect.top_level = true
	effect.global_position = pos
	GameUtils.get_effect_container().add_child(effect)
