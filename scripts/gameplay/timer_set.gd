class_name TimerSet
## Stand for timer set

signal activate

var time_elapsed : float = 0.0
var time_last_checked : float = 0.0
var loop_last_checked : int = 0

var start_time : float = 0.0
var time_per_loop : float = 0.0
var loop_count : int = 0
var auto_reset = true

func _init(start_time : float, time_per_loop : float, loop_count : int) -> void:
	self.start_time = start_time
	self.time_per_loop = time_per_loop
	self.loop_count = loop_count

func update_time(delta: float):
	add_time(delta)
	var count = get_loop_count_next()
	if count > 0:
		activate.emit()
	if is_finished() and auto_reset:
		print("Auto Reset Time")
		reset_time()

func add_time(delta: float):
	time_elapsed += delta

func reset_time():
	time_elapsed = 0.0

## Gets current loop, return the difference from last checked.
## Also updates last checked to new one, preventing repeating execution if its already done
func get_loop_count_next() -> int:
	var cur_count = get_cur_loop()
	var value = cur_count - loop_last_checked
	loop_last_checked = cur_count # Update
	return value

func is_finished() -> bool:
	return loop_last_checked >= loop_count

func get_cur_loop() -> int:
	var active_time = time_elapsed - start_time
	if active_time < 0:
		return 0
	return ceili(active_time / time_per_loop)
	
