class_name MSFollowParent
extends EntityScript

@export var node_to_follow : Node2D
@export var offset : Vector2 = Vector2(0,0)

func _init(node_to_follow : Node2D, offset : Vector2 = Vector2(0,0)) -> void:
	self.node_to_follow = node_to_follow
	self.offset = offset

func _ready() -> void:
	set_position()

func physics_process_active(delta: float) -> void:
	set_position()

func set_position() -> void:
	if parent != null:
		parent.global_position = node_to_follow.global_position + offset
