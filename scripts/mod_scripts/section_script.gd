class_name SectionScript
extends ModScript
## For sections in regular stage or boss non-spells
## Can be divided if there need chapter bonuses, like Touhou 15 and onwards

var duration : float = 40.0 ## Duration of section, mostly for boss spellcard + non-spell
var ended_already : bool = false
var is_subsection : bool = false ## If enabled, the ScriptStage will not wait until this ends

var stage_parent : StageScript

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
