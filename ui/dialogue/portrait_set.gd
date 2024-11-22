class_name PortraitSet
extends Node2D


@export var id : String ## unique identifier, prevents sprite re-creating if same appear twice
@export_category("Sprite")
@export var sprite_body : AnimatedSprite2D ## Sprite set for body, larger part
@export var sprite_face : AnimatedSprite2D ## Sprite set for face, smaller part
@export var speech_position : Node2D ## Where dialogue would come out from

var pos_left : Vector2 = Vector2(200, 550)
var pos_right : Vector2 = Vector2(800, 550)
var pos_left_back : Vector2 = Vector2(150, 580)
var pos_right_back : Vector2 = Vector2(850, 580)
var pos_left_start : Vector2 = Vector2(100, 610)
var pos_right_start : Vector2 = Vector2(900, 610)
var pos_target : Vector2 = Vector2(0, 0)
var pos_move_speed : float = 10.0

var mod_front : Color = Color(1,1,1,1)
var mod_back : Color = Color(0.5,0.5,0.5,1)
var mod_start : Color = Color(0.5,0.5,0.5,0)
var mod_target : Color = mod_front
var mod_speed : float = 10.0

var position_type : int = 0 # From PortraitLine Enum

var opacity_free : bool = false # queue free when opacity is 0 properly

func _ready() -> void:
	# set_position_type(DialogueLine.PortraitPosition.LEFT_BACK)
	pass

func _physics_process(delta: float) -> void:
	process_position(delta)
	if opacity_free and get_modulate().a <= 0.01:
		print("Freed Portrait")
		queue_free()

func get_speech_position() -> Vector2:
	return speech_position.global_position

func set_position_type(type: int, instant: bool = false) -> void:
	position_type = type
	# Update Position
	match position_type:
		DialogueLine.PortraitPosition.SAME:
			pass # Dont change anything
		DialogueLine.PortraitPosition.LEFT:
			pos_target = pos_left
		DialogueLine.PortraitPosition.RIGHT:
			pos_target = pos_right
		DialogueLine.PortraitPosition.LEFT_BACK:
			pos_target = pos_left_back
		DialogueLine.PortraitPosition.RIGHT_BACK:
			pos_target = pos_right_back
	# Update Modulation
	if DialogueLine.is_back(position_type):
		mod_target = mod_back
	else:
		mod_target = mod_front
	# Move instantly, This is for initializing
	if instant:
		global_position = pos_target
		set_modulate(mod_target)

func set_initial_position(instant: bool = false) -> void:
	# if same assume left
	if DialogueLine.is_left(position_type) or position_type == DialogueLine.PortraitPosition.SAME:
		pos_target = pos_left_start
	else:
		pos_target = pos_right_start
	mod_target = mod_start
	# Move instantly, This is for initializing
	if instant:
		global_position = pos_target
		set_modulate(mod_target)

func set_back_position(instant: bool = false) -> void:
	match position_type:
		DialogueLine.PortraitPosition.LEFT:
			set_position_type(DialogueLine.PortraitPosition.LEFT_BACK, instant)
		DialogueLine.PortraitPosition.RIGHT:
			set_position_type(DialogueLine.PortraitPosition.RIGHT_BACK, instant)

func set_body_anim(anim_name: String) -> void:
	sprite_body.play(anim_name)

func set_face_anim(anim_name: String) -> void:
	sprite_face.play(anim_name)

func process_position(delta: float) -> void:
	global_position = MathUtils.lerp_smooth(global_position, pos_target, pos_move_speed, delta)
	set_modulate(MathUtils.lerp_smooth(get_modulate(), mod_target, mod_speed, delta))
