extends EntityScript

@export var node_to_follow : Node2D
@export var offset : Vector2 = Vector2(0,0)

func _ready() -> void:
	set_position()

func _physics_process(delta: float) -> void:
	set_position()

func set_position() -> void:
	if parent != null:
		parent.global_position = node_to_follow.global_position + offset
