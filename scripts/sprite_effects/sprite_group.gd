class_name SpriteGroup
extends Sprite2D
## Groups of sprite, for enemies with variants like fairies

@export var col_anim_set_dict : Dictionary = {
	"default": 0,
	"diagonal": 1,
	"side": 2,
}

@export var row_variant_dict : Dictionary = {
	"blue": 0,
	"red": 1,
	"green": 2,
	"yellow": 3,
}

@export var frame_delay : float = 0.083
@export var frames_per_anim : int = 3

var cur_anim_set : int = 0
var cur_frame : int = 0
var cur_row : int = 0
var frame_timer : float = 0.0

func _physics_process(delta: float) -> void:
	frame_timer -= delta
	if frame_timer <= 0:
		update_frame()
		frame_timer += frame_delay

func update_frame() -> void:
	cur_frame += 1
	cur_frame = cur_frame % frames_per_anim
	# Cur frame + Column set (frame in an anim) + Row frames (Enemy type)
	var frame_offset = (cur_anim_set * frames_per_anim) + (cur_row * hframes)
	set_frame(cur_frame + frame_offset)

func set_type(key : String = "blue") -> void:
	cur_row = row_variant_dict[key]

func set_row(num : int = 0) -> void:
	cur_row = num

func set_anim(key : String = "default") -> void:
	cur_anim_set = col_anim_set_dict[key]

func update_animation(parent: Entity) -> void:
	if abs(parent.velocity.x) * 0.5 > abs(parent.velocity.y):
		set_anim("side")
	elif abs(parent.velocity.x) * 3.0 > abs(parent.velocity.y):
		set_anim("diagonal")
	else:
		set_anim("default")
	flip_h = parent.velocity.x < 0
