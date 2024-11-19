class_name SectionDialogueScript
extends SectionScript
## For section where character talks
## Section ending is called from Dialogue Displayer

var dialogue_set : DialogueSet

func _ready() -> void:
	print_rich("[color=green]==== Section Dialogue Script ====[/color]")
	super()
	# Dialogue should not trigger chapter by default
	do_chapter_end = false
	total_bonus = 0
	start_section()

func _physics_process(delta: float) -> void:
	super(delta)

func start_section() -> void:
	super()
	var displayer : DialogueDisplayer = GameUtils.get_dialogue_displayer()
	displayer.set_dialogue_script(self)
	displayer.start_dialogue()

func end_condition() -> bool: # Dialogue does NOT end automatically by default
	return false

func get_dialogue_actions() -> Array[DialogueAction]:
	return dialogue_set.dialogue_actions

func get_dialogue_action(index : int) -> DialogueAction:
	return get_dialogue_actions()[index]

func get_dialogue_action_count() -> int:
	return get_dialogue_actions().size()
