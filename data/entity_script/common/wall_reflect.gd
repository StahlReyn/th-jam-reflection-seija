class_name MSWallReflect
extends EntityScript

@export var bounce_count : int = 1
var cur_bounce_count : int = 0

func _init(bounce_count : int) -> void:
	self.bounce_count = bounce_count

func _ready() -> void:
	super()
	call_deferred("setup")

func setup() -> void:
	parent.connect("hit_wall", _on_hit_wall)
	cur_bounce_count = 0

func _on_hit_wall() -> void:
	if cur_bounce_count < bounce_count:
		var reflect_line = Vector2.DOWN # Vertical
		if parent.position.y < 0 or parent.position.y > GameUtils.game_area.y:
			reflect_line = Vector2.RIGHT
		parent.velocity = parent.velocity.reflect(reflect_line)
		cur_bounce_count += 1
		prints("Bounce:", cur_bounce_count)
	
