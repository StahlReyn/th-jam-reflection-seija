extends SectionScript

static var material_additive = preload("res://data/canvas_material/blend_additive.tres")
@onready var enemy_fairy : PackedScene = EnemyUtils.scene_dict["lesser_fairy"]
@onready var bullet_small : PackedScene = BulletUtils.scene_dict["circle_small"]
@onready var bullet_crystal : PackedScene = BulletUtils.scene_dict["crystal_small"]
@onready var bullet_arrow : PackedScene = BulletUtils.scene_dict["arrow"]
@onready var enemy_ice : PackedScene = preload("res://data/enemies/special/snowflake.tscn")
@onready var bullet_big_ice : PackedScene = preload("res://data/bullets/example/bullet_big_ice.tscn")

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
	duration = 50.0
	timer1.start()

func _physics_process(delta: float) -> void:
	super(delta)

func timeout_1():
	if time_active > 45.0:
		timer1.start(100.0)
	if timer1_count % 7 == 0:
		timer1.start(1.3)
		spawn_weeping_fairy_set()
	elif timer1_count % 7 == 6:
		timer1.start(3.5)
		spawn_side_fairy_set(false, 0)
		spawn_side_fairy_set(true, 0)
	else:
		timer1.start(0.1)
		spawn_side_fairy_set(timer1_count % 2 == 1, 1)
		
	timer1_count += 1

func spawn_side_fairy_set(inverted : bool = false, type: int = 0):
	var positions : PackedVector2Array = [
		Vector2(850, -40),
		Vector2(800, -60),
		Vector2(750, -80)
	]
	var count = 0
	var velocity = Vector2(-320, 300)
	var acceleration = Vector2(100, -100)
	var enemy
	if inverted:
		velocity.x = -velocity.x
		acceleration.x = -acceleration.x
	for position in positions:
		if inverted:
			position.x = mirror_x(position.x)
		if type == 0:
			enemy = spawn_side_fairy(position, velocity, acceleration)
		else: 
			enemy = spawn_rain_fairy(position, velocity * 0.5, acceleration * 0.5)
		enemy.delay_time = count * 0.1
		count += 1

func spawn_weeping_fairy_set(inverted : bool = false):
	var positions : PackedVector2Array = [
		Vector2(200, -50),
		Vector2(400, -50),
		Vector2(600, -50)
	]
	var velocity = Vector2(0, 200)
	var acceleration = Vector2(0, -70)
	for position in positions:
		spawn_weeping_fairy(position, velocity, acceleration)

# ================ WEEPING RAINING FAIRY ================

func spawn_weeping_fairy(position: Vector2, velocity: Vector2, acceleration: Vector2) -> Enemy:
	var enemy = spawn_enemy(enemy_fairy, position)
	enemy.velocity = velocity
	enemy.drop_power = 10
	enemy.drop_point = 20
	enemy.mhp = 70
	enemy.reset_hp()
	enemy.main_sprite.set_type(SpriteGroupFairy.Type.BLUE)
	enemy.add_script_node(
		MSAcceleration.new(acceleration)
	)
	
	var shoot_script = MSShootAtPlayer.new(5.0, 200)
	shoot_script.bullet_scene = bullet_big_ice
	shoot_script.time_since_shot += 2.0
	shoot_script.bullet_function = bullet_weeping_style
	enemy.add_script_node(shoot_script)
	return enemy

static func bullet_weeping_style(bullet):
	bullet.add_script_node(
		MSAcceleration.new(Vector2(0, 100))
	)

# ================ TRIANGLE SHOT FAIRY ================

func spawn_side_fairy(position: Vector2, velocity: Vector2, acceleration: Vector2) -> Enemy:
	var enemy = spawn_enemy(enemy_fairy, position)
	enemy.velocity = velocity
	enemy.drop_power = 5
	enemy.drop_point = 0
	enemy.main_sprite.set_type(SpriteGroupFairy.Type.GREEN)
	enemy.add_script_node(
		MSAcceleration.new(acceleration)
	)
	
	for i in range(2):
		var shoot_script = MSShootCircle.new(2.0, 10, 12, i * PI/12, bullet_arrow)
		shoot_script.bullet_list_function = bullet_shot_style
		shoot_script.time_since_shot -= i * 1.0
		enemy.add_script_node(shoot_script)
	
	return enemy

static func bullet_shot_style(bullet_list):
	for bullet : Bullet in bullet_list:
		bullet.set_color(SpriteGroupBasicBullet.ColorType.TEAL)
		bullet.add_script_node(
			MSAcceleration.new(bullet.velocity * 50)
		)

func spawn_rain_fairy(position: Vector2, velocity: Vector2, acceleration: Vector2) -> Enemy:
	var enemy = spawn_enemy(enemy_fairy, position)
	enemy.velocity = velocity
	enemy.drop_power = 0
	enemy.drop_point = 8
	enemy.main_sprite.set_type(SpriteGroupFairy.Type.YELLOW)
	enemy.add_script_node(
		MSAcceleration.new(acceleration)
	)
	
	var shoot_script = MSShootRandomAngle.new(0.3, 10, 0, PI, bullet_crystal)
	shoot_script.bullet_function = bullet_rain_style
	enemy.add_script_node(shoot_script)
	return enemy

static func bullet_rain_style(bullet):
	bullet.set_color(SpriteGroupBasicBullet.ColorType.BLUE)
	bullet.add_script_node(
		MSAcceleration.new(Vector2(0, 200))
	)

static func mirror_x(x: float) -> float:
	return -(x - GameUtils.game_area.x)
