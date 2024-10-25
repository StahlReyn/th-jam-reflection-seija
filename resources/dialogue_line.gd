class_name DialogueLine
extends DialogueAction

enum PortraitPosition {
	LEFT,
	RIGHT,
	LEFT_BACK,
	RIGHT_BACK,
}

@export_group("Technical")
@export var id : String ## id, if same id the portrait replace the existing
@export var auto : bool = false 
@export var set_others_back : bool = true 
@export_group("Portrait")
@export var portrait : PackedScene ## Portrait shown. If left empty the ID retains it's portrait
@export var face_anim : String ## Face Animation Name
@export var body_anim : String ## Body Animation Name
@export var position_type : PortraitPosition
@export_group("Dialogue")
@export_multiline var text : String ## Dialogue content, use CSV Keys

static func is_back(type: int) -> bool:
	if (type == PortraitPosition.LEFT_BACK or 
		type == PortraitPosition.RIGHT_BACK):
		return true
	return false

static func is_front(type: int) -> bool:
	return not is_back(type) # simple invert in case there are more position type later

static func is_left(type: int) -> bool:
	if (type == PortraitPosition.LEFT or 
		type == PortraitPosition.LEFT_BACK):
		return true
	return false

static func is_right(type: int) -> bool:
	return not is_left(type)

static func new_set_from_line(line: DialogueLine) -> PortraitSet:
	var new_portrait : PortraitSet = line.portrait.instantiate()
	update_portrait_anim(new_portrait, line)
	new_portrait.set_initial_position(true)
	new_portrait.set_position_type(line.position_type)
	return new_portrait

static func update_portrait_anim(portrait: PortraitSet, line: DialogueLine):
	portrait.set_position_type(line.position_type)
	if line.body_anim != null:
		portrait.set_body_anim(line.body_anim)
	if line.face_anim != null:
		portrait.set_face_anim(line.face_anim)
