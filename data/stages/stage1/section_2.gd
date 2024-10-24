extends SectionScript

@onready var enemy_fairy : PackedScene = EnemyUtils.scene_dict["lesser_fairy"]

static var material_additive = preload("res://data/canvas_material/blend_additive.tres")

var timer1 : Timer = Timer.new()
var timer1_count : int = 0

func _init() -> void:
	timer1 = timer_setup(2.0, timeout_1)

func timer_setup(wait_time: float, function: Callable) -> Timer:
	var timer = Timer.new()
	timer.wait_time = wait_time
	timer.connect("timeout", function)
	add_child(timer)
	return timer

func _ready() -> void:
	super()
	duration = 30.0
	timer1.start(1.0)

func _physics_process(delta: float) -> void:
	super(delta)

func timeout_1():
	if time_active > 25.0:
		timer1.start(100.0)
	if timer1_count % 3 == 0:
		timer1.start(2.0)
		spawn_big_shot_fairy(Vector2(GameUtils.game_area.x/2, -80))
	elif timer1_count <= 1000:
		timer1.start(1.5)
		for i in range(5):
			spawn_circle_shot_fairy(Vector2(140 * i + 100, -80))
	timer1_count += 1

func spawn_circle_shot_fairy(position):
	var velocity = Vector2(0, 300)
	var acceleration = Vector2(0, -120)
	var enemy = spawn_enemy(enemy_fairy, position)
	enemy.main_sprite.set_type(SpriteGroupFairy.Type.GREEN)
	enemy.velocity = velocity
	enemy.drop_power = 0
	enemy.drop_point = 15
	enemy.mhp = 20
	enemy.reset_hp()
	enemy.add_script_node(
		MSAcceleration.new(acceleration)
	)
	var shooter := MSShootCircle.new(1.0, 400, 25, 0)
	shooter.bullet_list_function = circle_shot_style
	enemy.add_script_node(shooter)

static func circle_shot_style(bullet_list):
	for bullet : Bullet in bullet_list:
		bullet.set_color(SpriteGroupBasicBullet.ColorType.GREEN)

func spawn_big_shot_fairy(position):
	var velocity = Vector2(0, 320)
	var acceleration = Vector2(0, -100)
	var enemy = spawn_enemy(enemy_fairy, position)
	enemy.main_sprite.set_type(SpriteGroupFairy.Type.RED)
	enemy.velocity = velocity
	enemy.drop_power = 15
	enemy.drop_point = 0
	enemy.mhp = 100
	enemy.reset_hp()
	enemy.add_script_node(
		MSAcceleration.new(acceleration)
	)
	var shooter = MSShootCircleGroup.new(4.0, Vector2(0,300), 16, 0, 50, 3, TAU/32)
	shooter.target_player = true
	shooter.bullet_list_function = big_shot_style
	enemy.add_script_node(shooter)

static func big_shot_style(bullet_list):
	for bullet : Bullet in bullet_list:
		bullet.set_color(SpriteGroupBasicBullet.ColorType.RED)
		bullet.material = material_additive

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
