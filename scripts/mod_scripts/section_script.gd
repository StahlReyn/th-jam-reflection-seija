class_name SectionScript
extends ModScript
## For sections in regular stage or boss non-spells
## Can be divided if there need chapter bonuses, like Touhou 15 and onwards

var duration : float = 40.0 ## Duration of section, mostly for boss spellcard + non-spell
var ended_already : bool = false
var is_subsection : bool = false ## If enabled, the ScriptStage will not wait until this ends

var section_name : String = "[SECTION NAME]"
var total_bonus : int = 1000000

var stage_parent : StageScript
var do_chapter_end : bool = true

func _ready() -> void:
	print_rich("[color=green]==== Section Script ====[/color]")
	super()

func _physics_process(delta: float) -> void:
	super(delta)
	if end_condition() and not ended_already:
		print_rich("[color=orange]END SECTION - Section Condition[/color]")
		end_section()

func start_section() -> void:
	pass

## This ends the section. Can also be called externally, like Boss HP condition
func end_section() -> void:
	prints("END SECTION", end_condition(), ended_already)
	ended_already = true
	enabled = false
	if do_chapter_end:
		end_chapter()
	if stage_parent:
		stage_parent.on_section_end()
	else:
		printerr("Section have no StageScript Parent")

func end_condition() -> bool:
	return time_active >= duration

func is_ending() -> bool:
	return ended_already

## Used for StageScript, Subsection can always continue regardless of ending
func can_move_next_section() -> bool:
	return is_ending() or is_subsection

func get_time_left() -> float:
	return duration - time_active

func set_stage_parent(node : StageScript) -> void:
	stage_parent = node

func end_chapter() -> void:
	clear_bullets()
	clear_enemies(false)
	GameVariables.add_section_bonus_to_score()
	GameUtils.get_popup_displayer().display_chapter()
	GameVariables.reset_chapter_variables()
	
static func clear_bullets() -> void:
	print("- Clear Bullets")
	for bullet in GameUtils.get_bullet_list():
		bullet.do_remove()

static func clear_enemies(forced : bool = false) -> void:
	if forced:
		print("- Clear Enemies - FORCED")
		for enemy : Enemy in GameUtils.get_enemy_list():
			enemy.do_remove()
	else:
		print("- Clear Enemies - Soft")
		for enemy : Enemy in GameUtils.get_enemy_list():
			if enemy.remove_on_chapter_change:
				enemy.do_remove()
