class_name SectionDialogueScript
extends SectionScript
## For section where character talks
## Section ending is called from Dialogue Displayer

var dialogue_set : DialogueSet

var boss : EnemyBoss
var boss_target_position := Vector2(385, 300)
var boss_spawn_position := Vector2(385,-50)

func _init(dialogue_set : DialogueSet = null) -> void:
	self.dialogue_set = dialogue_set

func _ready() -> void:
	print_rich("[color=green]==== Section Dialogue Script ====[/color]")
	super()
	# Dialogue should not trigger chapter by default
	do_chapter_end = false
	total_bonus = 0
	print("+ !!!! Dialogue spawned Boss", dialogue_set.boss_spawn)
	if dialogue_set.boss_spawn != null:
		print("+ Dialogue spawned Boss")
		boss = spawn_enemy_boss(dialogue_set.boss_spawn, dialogue_set.spawn_position)
		LF.smooth_pos(boss, boss_target_position, 2.0)
	start_section()

func start_section() -> void:
	super()
	var displayer : DialogueDisplayer = GameUtils.get_dialogue_displayer()
	displayer.set_dialogue_script(self)
	await get_tree().create_timer(dialogue_set.start_delay).timeout
	displayer.start_dialogue()

func end_condition() -> bool: # Dialogue does NOT end automatically by default
	return false

func get_dialogue_actions() -> Array[DialogueAction]:
	return dialogue_set.dialogue_actions

func get_dialogue_action(index : int) -> DialogueAction:
	return get_dialogue_actions()[index]

func get_dialogue_action_count() -> int:
	return get_dialogue_actions().size()
