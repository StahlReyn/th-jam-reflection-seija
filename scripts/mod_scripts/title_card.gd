class_name TitleCard
extends Sprite2D

@export var fade_in_time : float = 2.0
@export var sustain_time : float = 5.0
@export var fade_out_time : float = 2.0

enum State {
	FADE_IN,
	SUSTAIN,
	FADE_OUT,
	FINISHED,
}

var timer : float = fade_in_time
var state : int = State.FADE_IN

func _ready() -> void:
	timer = fade_in_time
	state = State.FADE_IN
	var color = get_modulate()
	color.a = 0
	set_modulate(color)

func _physics_process(delta: float) -> void:
	timer -= delta
	if timer <= 0:
		update_state()
	update_fade(delta)
	if state == State.FINISHED:
		queue_free()
		
func update_state() -> void:
	match state:
		State.FADE_IN:
			state = State.SUSTAIN
			timer += sustain_time
		State.SUSTAIN:
			state = State.FADE_OUT
			timer += fade_out_time
		State.FADE_OUT:
			state = State.FINISHED

func update_fade(delta: float) -> void:
	var color = get_modulate()
	match state:
		State.FADE_IN:
			color.a += (1 / fade_in_time) * delta
		State.SUSTAIN:
			color.a = 1
		State.FADE_OUT:
			color.a -= (1 / fade_out_time) * delta
	set_modulate(color)
