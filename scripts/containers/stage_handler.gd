class_name StageHandler
extends Node

var cur_stage_script : StageScript

var cd1 = 1.0
var added = false

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	check_finished_sections()

func add_stage_script_from_data(data : StageData) -> Node:
	var inst : StageScript = StageScript.new_stage_script_from_data(data)
	add_child(inst)
	cur_stage_script = inst
	print("Add Script Sequence")
	return inst

func check_finished_sections() -> void:
	for node in get_tree().get_nodes_in_group("stage_script"):
		if node is SpellCard:
			if node.is_ending():
				var displayer : SpellCardDisplayer = GameUtils.get_spell_card_displayer()
				displayer.end_spellcard()
		if node is SectionScript:
			if node.is_ending():
				node.call_deferred("queue_free")

static func current_add_stage_script(script : GDScript) -> void:
	var handler : StageHandler = GameUtils.get_stage_handler()
	handler.add_stage_script(script)

func _on_gameview_start_stage(data : StageData) -> void:
	add_stage_script_from_data(data)
