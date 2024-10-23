class_name MSVelocityToPlayer
extends EntityScript

@export var offset : Vector2 = Vector2(0,0)
@export var invert : bool = false

func _init(offset : Vector2, invert : bool = false) -> void:
	self.offset = offset
	self.invert = invert

func _ready() -> void:
	set_direction()

func _physics_process(delta: float) -> void:
	pass

func set_direction() -> void:
	if parent != null:
		var target_pos = GameUtils.get_player().global_position + offset
		var target_direction = parent.global_position.direction_to(target_pos)
		var cur_speed = parent.velocity.length()
		if invert:
			cur_speed = -cur_speed
		parent.velocity = target_direction * cur_speed
