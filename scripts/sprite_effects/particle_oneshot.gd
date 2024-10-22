extends GPUParticles2D

@export var time : float = 0.1

func _ready() -> void:
	emitting = true
	await get_tree().create_timer(time).timeout
	emitting = false
