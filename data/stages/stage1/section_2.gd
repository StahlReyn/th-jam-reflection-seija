extends SectionScript

@onready var enemy_fairy : PackedScene = EnemyUtils.scene_dict["lesser_fairy"]

var timer1 : Timer = Timer.new()
var timer1_1 : Timer = Timer.new()
var timer1_count : int = 0

func _init() -> void:
	timer1 = timer_setup(2.0, timeout_1)
	timer1_1 = timer_setup(1.0, timeout_1_1)
	timer1_1.paused = true

func timer_setup(wait_time: float, function: Callable) -> Timer:
	var timer = Timer.new()
	timer.wait_time = wait_time
	timer.connect("timeout", function)
	add_child(timer)
	return timer

func _ready() -> void:
	super()
	duration = 60.0
	timer1.start()
	timer1_1.start()

func _physics_process(delta: float) -> void:
	super(delta)

func timeout_1():
	if timer1_1.paused:
		timer1_count += 1
	timer1_1.paused = not timer1_1.paused

func timeout_1_1():
	var positions : PackedVector2Array = [
		Vector2(600, -80),
		Vector2(200, -80),
	]
	var count = 0
	var velocity = Vector2(0, 300)
	var acceleration = Vector2(0, -120)
		
	for pos in positions:
		var enemy = spawn_enemy(enemy_fairy, pos)
		enemy.velocity = velocity
		enemy.add_script_node(
			MSAcceleration.new(acceleration)
		)
		enemy.add_script_node(
			MSShootCircleGroup.new(3.0, Vector2(0,300), 16, 0, 50, 5, TAU/32)
		)
		count += 1
	
func entity_flower_pattern(entity : Entity):
	# Circle occasionally
	entity.add_script_node(
		MSShootCircle.new(1.0, 400, 25, 0)
	)
	# Spiral Arm, set of forward and backward
	for i in range(5):
		entity.add_script_node(
			MSShootSpiral.new(0.05, 400, TAU/50, i * TAU/5)
		)
		entity.add_script_node(
			MSShootSpiral.new(0.05, 400, -TAU/50, i * TAU/5)
		)

#enemy.main_sprite.set_type(count % 3)
