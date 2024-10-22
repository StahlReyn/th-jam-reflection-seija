class_name DialogueBalloon
extends Node2D

static var balloon_scene : PackedScene = preload("res://ui/dialogue/dialogue_balloon.tscn")

@onready var label_main : Label = $Balloon/MarginContainer/Label
@onready var dialogue_balloon : Control = $Balloon
@onready var dialogue_tail : Sprite2D = $DialogueTail

var position_type : int

var scale_x_speed : float = 40.0
var press_count : int = 0

func _ready() -> void:
	scale.x = 0

func _process(delta: float) -> void:
	if scale.x < 1:
		scale.x += scale_x_speed * delta
		scale.x = clamp(scale.x, 0, 1)
	if Input.is_action_just_pressed("dialogue"):
		press_count += 1
		# Default Two as when it just spawn its pressed once already
		if press_count >= 2:
			queue_free()
	# Runs constantly but fine as it's just 1-2 objects
	update_balloon_offset()
	set_tail_position()

func set_display_text(text: String) -> void:
	label_main.text = text

func set_position_type(num: int) -> void:
	position_type = num

func set_tail_position() -> void:
	if dialogue_balloon != null:
		dialogue_tail.position.x = 0
		dialogue_tail.position.y = -dialogue_balloon.size.y * 0.5
	match position_type:
		DialogueLine.PortraitPosition.LEFT:
			dialogue_tail.flip_h = true
		DialogueLine.PortraitPosition.RIGHT:
			dialogue_tail.flip_h = false
		
func update_balloon_offset() -> void:
	dialogue_balloon.position.y = -dialogue_balloon.size.y * 0.5
	match position_type:
		DialogueLine.PortraitPosition.LEFT:
			dialogue_balloon.position.x = dialogue_balloon.size.x * -0.1
		DialogueLine.PortraitPosition.RIGHT:
			dialogue_balloon.position.x = dialogue_balloon.size.x * -0.9

static func create_balloon(parent : Node, text: String, position_type: int, pos : Vector2 = Vector2(0,0)) -> DialogueBalloon:
	var balloon : DialogueBalloon = balloon_scene.instantiate()
	parent.add_child(balloon)
	# Set text AFTER due to onready nodes
	balloon.set_display_text(text)
	balloon.set_position_type(position_type)
	balloon.global_position = pos
	return balloon
