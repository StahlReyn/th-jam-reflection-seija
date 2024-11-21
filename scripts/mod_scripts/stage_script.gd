class_name StageScript
extends ModScript
## StageScripts manages a list of Sections and Spellcards

var stage_data : StageData
var stage_action_index : int = 0
var section_index : int = 0
var cur_stage_action : StageAction
var added_section_list : Array[SectionScript] = []

var section_delay_timer : Timer

func _init(stage_data : StageData) -> void:
	self.stage_data = stage_data
	section_delay_timer = Timer.new()
	section_delay_timer.one_shot = true
	add_child(section_delay_timer)
	section_delay_timer.connect("timeout", _on_section_delay_timer_timeout)

func _ready() -> void:
	super()
	add_to_group("stage_script")
	print_rich("[color=green][b]==== Stage Script ====[/b][/color]")
	do_next_stage_action()
	do_next_action()
	print("THIS STUFF")
	print(stage_data)
	print(stage_data.stage_actions)

func add_section_script(section : SectionScript) -> void:
	add_child(section)
	added_section_list.push_front(section)
	section.set_stage_parent(self)
	GameVariables.section_bonus += section.total_bonus;
	print_rich("[color=yellow]+ Add Section Script[/color]")

func is_section_available() -> bool:
	for section in added_section_list:
		if not section.can_move_next_section():
			return false # If ANY script saying to wait, wait
	return true

func on_section_end(section_script : SectionScript) -> void:
	print("On Section End - Delaying ", section_script.section_end_delay)
	section_delay_timer.start(section_script.section_end_delay)

func _on_section_delay_timer_timeout() -> void:
	do_next_action()
	
func do_next_stage_action() -> void:
	print_rich("[color=yellow]> Next Stage Action: [/color]", stage_action_index)
	section_index = 0
	if stage_action_index < stage_data.stage_actions.size():
		cur_stage_action = stage_data.stage_actions[stage_action_index]
		stage_action_index += 1
	
func do_next_action() -> void:
	print(cur_stage_action)
	if cur_stage_action is StageActionDialogue:
		if section_index < cur_stage_action.dialogue_data.size():
			print_rich("[color=yellow]> Next Script (Dialogue): [/color]", section_index)
			var dialogue_set : DialogueSet = cur_stage_action.dialogue_data[section_index]
			add_section_script(SectionDialogueScript.new(dialogue_set))
			section_index += 1
	elif cur_stage_action is StageActionScript:
		if section_index < cur_stage_action.script_data.size():
			print_rich("[color=yellow]> Next Script (Script): [/color]", section_index)
			var stage_script : GDScript = cur_stage_action.script_data[section_index]
			add_section_script(stage_script.new())
			section_index += 1
