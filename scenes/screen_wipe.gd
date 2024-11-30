extends ColorRect

signal closed

var cur_percent : float = 1.0
var closing : bool = false
var signal_closed : bool = false
var time_closed : float = 0.0

func _ready() -> void:
	material.set_shader_parameter("percentage", cur_percent)

func _physics_process(delta: float) -> void:
	if closing:
		cur_percent += delta * 10
	else:
		cur_percent -= delta * 10
		signal_closed = false # Reset
	cur_percent = clamp(cur_percent, 0, 1)
	material.set_shader_parameter("percentage", cur_percent)
	if cur_percent >= 1:
		time_closed += delta
		# Slight delay so it doesnt flash
		if not signal_closed and time_closed >= 0.2:
			closed.emit()
			signal_closed = true

func _do_close() -> void:
	closing = true
