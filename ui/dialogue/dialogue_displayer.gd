class_name DialogueDisplayer
extends Node2D

var cur_dialogue_script : SectionDialogueScript
var cur_dialogue_action : DialogueAction
var cur_action_index : int = 0

var portrait_dict : Dictionary = {}

func _ready() -> void:
	reset_dialogue_variables()

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("dialogue") or Input.is_action_pressed("skip"):
		if cur_dialogue_script:
			next_dialogue_action_input()

func next_dialogue_action_input():
	if cur_action_index >= cur_dialogue_script.get_dialogue_action_count():
		end_dialogue()
	else:
		while true:
			next_dialogue()
			update_portrait()
			call_deferred("create_balloon") # Deferred so it comes after input and not immediately disappear
			if not cur_dialogue_action.auto:
				break

func next_dialogue() -> void:
	prints("Next Dialogue:", cur_action_index, "/", cur_dialogue_script.get_dialogue_action_count() - 1)
	cur_dialogue_action = cur_dialogue_script.get_dialogue_action(cur_action_index)
	cur_action_index += 1

# Dialogue Balloon
func create_balloon() -> void:
	if cur_dialogue_action is DialogueLine and cur_dialogue_action.text != "":
		var dialogue_balloon : DialogueBalloon = DialogueBalloon.create_balloon(
			self, 
			cur_dialogue_action.text, 
			cur_dialogue_action.position_type,
			get_cur_portrait().get_speech_position()
		)
		dialogue_balloon.press_count = 1

func start_dialogue() -> void:
	reset_anim()
	next_dialogue_action_input()

func end_dialogue() -> void:
	for id in portrait_dict:
		var portrait : PortraitSet = portrait_dict[id]
		portrait.set_initial_position()
		portrait.opacity_free = true
	print_rich("[color=orange]END SECTION - Dialogue End[/color]")
	cur_dialogue_script.end_section()
	reset_dialogue_variables()

func reset_dialogue_variables():
	cur_dialogue_script = null
	cur_dialogue_action = null
	cur_action_index = 0
	portrait_dict = {}

func set_dialogue_script(section : SectionDialogueScript):
	prints("+++ Set Dialogue Script", section)
	cur_dialogue_script = section

func reset_anim():
	pass

func update_portrait():
	if cur_dialogue_action is DialogueLine:
		# Set every other portrait back first. Current portrait later will override
		if cur_dialogue_action.set_others_back:
			for id in portrait_dict:
				var portrait : PortraitSet = portrait_dict[id]
				portrait.set_back_position()
				
		if portrait_dict.has(cur_dialogue_action.id):
			# if no portrait, assume same and just update animation
			if cur_dialogue_action.portrait == null:
				update_portrait_anim()
			else:
				create_portrait()
		else: # If is empty create
			create_portrait()

func update_portrait_anim():
	DialogueLine.update_portrait_anim(get_cur_portrait(), cur_dialogue_action)

func create_portrait():
	if cur_dialogue_action is DialogueLine:
		var new_portrait : PortraitSet = DialogueLine.new_set_from_line(cur_dialogue_action)
		add_child(new_portrait)
		if cur_portrait_exists():
			get_cur_portrait().queue_free()
		set_cur_portrait(new_portrait)

func cur_portrait_exists() -> bool:
	return portrait_dict.has(cur_dialogue_action.id)
	
func get_cur_portrait() -> PortraitSet:
	return portrait_dict[cur_dialogue_action.id]

func set_cur_portrait(portrait : PortraitSet) -> void:
	portrait_dict[cur_dialogue_action.id] = portrait
