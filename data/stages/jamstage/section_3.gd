extends SectionScript

static var material_additive = preload("res://data/canvas_material/blend_additive.tres")
@onready var enemy_fairy : PackedScene = EnemyUtils.scene_dict["lesser_fairy"]
@onready var bullet_scene : PackedScene = BulletUtils.scene_dict["bullet"]

var timer1 : Timer = Timer.new()
var timer1_count : int = 0

func _init() -> void:
	timer1 = timer_setup(3.0, timeout_1)

func timer_setup(wait_time: float, function: Callable) -> Timer:
	var timer = Timer.new()
	timer.wait_time = wait_time
	timer.connect("timeout", function)
	add_child(timer)
	return timer

func _ready() -> void:
	super()
	duration = 25.0
	timer1.start()

func _physics_process(delta: float) -> void:
	super(delta)

func timeout_1():
	if time_active > 20.0:
		timer1.start(100.0)
	elif timer1_count % 3 == 0:
		timer1.start(0.8)
		spawn_side_fairy_set(timer1_count % 2 == 0)
	elif timer1_count <= 1000:
		timer1.start(0.8)
		spawn_weeping_fairy_set(timer1_count % 2 == 1)
		
	timer1_count += 1

func spawn_side_fairy_set(inverted : bool = false):
	var positions : PackedVector2Array = [
		Vector2(850, -40),
		Vector2(800, -60),
		Vector2(750, -80)
	]
	var count = 0
	var velocity = Vector2(-240, 220)
	var acceleration = Vector2(0, -80)
	if inverted:
		velocity.x = -velocity.x
		acceleration.x = -acceleration.x
	for position in positions:
		if inverted:
			position.x = mirror_x(position.x)
		var enemy = spawn_side_fairy(position, velocity, acceleration)
		enemy.delay_time = count * 0.1
		count += 1

func spawn_weeping_fairy_set(inverted : bool = false):
	var positions : PackedVector2Array = [
		Vector2(850, -40),
		Vector2(800, -60),
		Vector2(750, -80)
	]
	var count = 0
	var velocity = Vector2(-200, 200)
	var acceleration = Vector2(0, -70)
	if inverted:
		velocity.x = -velocity.x
		acceleration.x = -acceleration.x
	for position in positions:
		if inverted:
			position.x = mirror_x(position.x)
		var enemy = spawn_weeping_fairy(position, velocity, acceleration)
		enemy.delay_time = count * 0.1
		count += 1

# ================ WEEPING RAINING FAIRY ================

func spawn_weeping_fairy(position: Vector2, velocity: Vector2, acceleration: Vector2) -> Enemy:
	var enemy = spawn_enemy(enemy_fairy, position)
	enemy.velocity = velocity
	enemy.drop_power = 0
	enemy.drop_point = 8
	enemy.main_sprite.set_type(SpriteGroupFairy.Type.BLUE)
	enemy.add_script_node(
		MSAcceleration.new(acceleration)
	)
	
	var shoot_script = MSShootRandomAngle.new(0.2, 100, -3 * PI/8, -PI/8)
	shoot_script.bullet_function = bullet_weeping_style
	enemy.add_script_node(shoot_script)
	return enemy

static func bullet_weeping_style(bullet):
	bullet.set_color(SpriteGroupBasicBullet.ColorType.BLUE)
	bullet.add_script_node(
		MSAcceleration.new(Vector2(0, 200))
	)
	bullet.material = material_additive

# ================ TRIANGLE SHOT FAIRY ================

func spawn_side_fairy(position: Vector2, velocity: Vector2, acceleration: Vector2) -> Enemy:
	var enemy = spawn_enemy(enemy_fairy, position)
	enemy.velocity = velocity
	enemy.drop_power = 5
	enemy.drop_point = 0
	enemy.main_sprite.set_type(SpriteGroupFairy.Type.YELLOW)
	enemy.add_script_node(
		MSAcceleration.new(acceleration)
	)
	
	var shoot_script = MSShootArcTriangle.new(1.0, 550, 4, TAU/160, 0, 0.1)
	shoot_script.bullet_scene = bullet_scene
	shoot_script.target_player = true
	shoot_script.bullet_list_function = bullet_shot_style
	enemy.add_script_node(shoot_script)
	return enemy

static func bullet_shot_style(bullet_list):
	for bullet : Bullet in bullet_list:
		bullet.set_color(SpriteGroupBasicBullet.ColorType.ORANGE)

static func mirror_x(x: float) -> float:
	return -(x - GameUtils.game_area.x)
