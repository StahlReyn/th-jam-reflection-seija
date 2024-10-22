class_name SpriteGroup
extends Sprite2D
## Groups of sprite, for enemies with variants like fairies

enum State {
	DEFAULT,
	DIAGONAL,
	SIDE,
}

var delay : float
var frame_default : Array[int]
var frame_diagonal : Array[int]
var frame_side : Array[int]
var frames_per_type : int

var cur_anim : int
var cur_frame : int
var cur_type : int
var frame_timer : float

func _ready() -> void:
	cur_anim = 0
	cur_frame = 0
	cur_type = 0
	frame_timer = 0.0

func _physics_process(delta: float) -> void:
	frame_timer -= delta
	if frame_timer <= 0:
		update_frame()
		frame_timer += delay

func update_frame() -> void:
	cur_frame += 1
	cur_frame = cur_frame % 3
	# Adds by cur type, essentially going to other row
	set_frame(get_frames()[cur_frame] + (cur_type * frames_per_type))

func set_type(num : int) -> void:
	cur_type = num

func update_animation(parent: Node2D) -> void:
	if abs(parent.velocity.x) * 0.5 > abs(parent.velocity.y):
		cur_anim = State.SIDE
	elif abs(parent.velocity.x) * 3.0 > abs(parent.velocity.y):
		cur_anim = State.DIAGONAL
	else:
		cur_anim = State.DEFAULT
	flip_h = parent.velocity.x < 0

func get_frames() -> Array[int]:
	match cur_anim:
		State.DIAGONAL:
			return frame_diagonal
		State.SIDE:
			return frame_side
	return frame_default
