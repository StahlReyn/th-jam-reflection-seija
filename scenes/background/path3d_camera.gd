class_name Path3DCamera
extends Path3D

@onready var path_follow : PathFollow3D = $PathFollow3D
@export var speed : float = 1.0 ##m/s

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	path_follow.progress += delta * speed
	pass
