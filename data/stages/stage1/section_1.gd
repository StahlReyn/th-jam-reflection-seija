extends SectionScript

@onready var enemy_fairy : PackedScene = EnemyUtils.scene_dict["lesser_fairy"]

var timer1 : Timer = Timer.new()
var timer1_1 : Timer = Timer.new()
var timer1_count : int = 0

func _init() -> void:
	timer1 = timer_setup(2.0, timeout_1)
	timer1_1 = timer_setup(0.4, timeout_1_1)
	timer1_1.paused = true

func timer_setup(wait_time: float, function: Callable) -> Timer:
	var timer = Timer.new()
	timer.wait_time = wait_time
	timer.connect("timeout", function)
	add_child(timer)
	return timer

func _ready() -> void:
	super()
	duration = 16.0
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
		Vector2(850, -40),
		Vector2(800, -60),
		Vector2(750, -80)
	]
	var count = 0
	var velocity = Vector2(-150, 200)
	var acceleration = Vector2(0, -80)
	
	if timer1_count % 2 == 0:
		velocity.x = -velocity.x
		acceleration.x = -acceleration.x
		
	for pos in positions:
		if timer1_count % 2 == 0:
			pos.x = mirror_x(pos.x)
		
		var enemy = spawn_enemy(enemy_fairy, pos)
		enemy.delay_time = count * 0.05
		enemy.velocity = velocity
		enemy.add_movement_script_node(
			MSAcceleration.new(acceleration)
		)
		enemy.add_movement_script_node(
			MSShootAtPlayer.new(2.0, 300)
		)
		enemy.main_sprite.set_type(count % 3)
		count += 1

func mirror_x(x: float) -> float:
	return -(x - GameUtils.game_area.x)
	
