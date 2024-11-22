class_name SpellCardDisplayer
extends Node2D

enum State {
	SPELL, ## Spellcard with name and effects
	NON_SPELL, ## Boss non spells, still show timer and name
	REGULAR, ## Regular stage
}

@onready var animation_node : AnimationPlayer = $AnimationPlayer
@onready var label_name : Label = $FullDisplay/SpellCardName/LabelName
@onready var label_timer : Label = $LabelTimer

static var timer_pos_spell : Vector2 = Vector2(330, 100)
static var timer_pos_non : Vector2 = Vector2(330, 10)
static var timer_lerp_speed : float = 4.0

var cur_spellcard : SpellCard
var cur_state : int

func _ready() -> void:
	set_state(State.REGULAR)
	call_deferred("setup_nodes")

func _physics_process(delta: float) -> void:
	if is_instance_valid(cur_spellcard):
		label_name.text = cur_spellcard.section_name
		label_timer.text = "%.2f" % max(cur_spellcard.get_time_left(), 0.0)
	process_timer_display(delta)

func setup_nodes() -> void:
	label_timer.set_modulate(Color(1,1,1,0))
	reset_anim()

func process_timer_display(delta: float) -> void:
	var cur_color = label_timer.get_modulate()
	var target_color = cur_color
	var cur_pos = label_timer.position
	var target_pos = timer_pos_non
	
	match cur_state:
		State.REGULAR:
			target_color.a = 0
		State.NON_SPELL:
			target_color.a = 1
		State.SPELL:
			target_color.a = 1
			target_pos = timer_pos_spell
	
	label_timer.set_modulate(MathUtils.lerp_smooth(cur_color, target_color, timer_lerp_speed, delta))
	label_timer.position = MathUtils.lerp_smooth(cur_pos, target_pos, timer_lerp_speed, delta)

func reset_anim() -> void:
	animation_node.play(&"RESET")
	animation_node.advance(0)

func start_spellcard() -> void:
	set_state(State.SPELL)
	reset_anim()
	animation_node.play("start")
	AudioManager.play_spell_card()

func end_spellcard() -> void:
	cur_spellcard = null
	set_state(State.REGULAR)
	animation_node.play("end")

func start_non_spell() -> void:
	pass

func end_non_spell() -> void:
	pass

func set_spellcard(spellcard : SpellCard):
	cur_spellcard = spellcard

func set_state(id : int) -> void:
	cur_state = id

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"start":
			animation_node.play("move")
