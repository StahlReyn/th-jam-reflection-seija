class_name SpriteGroupFairy
extends SpriteGroup

enum Type { ## essentially rows
	BLUE,
	RED,
	GREEN,
	YELLOW
}

func _ready() -> void:
	cur_anim = State.DEFAULT
	cur_frame = 0
	cur_type = Type.BLUE
	frame_timer = 0.0
	
	delay = 0.1
	frame_default = [0,1,2]
	frame_diagonal = [3,4,5]
	frame_side = [6,7,8]
	frames_per_type = 9
