extends SectionScript

static var material_additive = preload("res://data/canvas_material/blend_additive.tres")
static var enemy_fairy : PackedScene = EnemyUtils.scene_dict["lesser_fairy"]
static var bullet_circle : PackedScene = BulletUtils.scene_dict["circle_medium"]

static var drop_fairy_power := EnemyDrops.new(3, 0)
static var drop_fairy_point := EnemyDrops.new(0, 3)

static var spawn_positions : PackedVector2Array = [
	Vector2(850, -40),
	Vector2(800, -60),
	Vector2(750, -80)
]

var timer1 : Timer = Timer.new()
var timer1_count : int = 0

func _init() -> void:
	timer1 = timer_setup(3.0, timeout_1)

func _ready() -> void:
	super()
	duration = 30.0
	timer1.start()

func _physics_process(delta: float) -> void:
	super(delta)
	if time_active > 25.0:
		timer1.paused = true

func timeout_1():
	if timer1_count % 3 == 0:
		timer1.start(0.8)
		spawn_side_fairy_set(timer1_count % 2 == 0)
	elif timer1_count <= 1000:
		timer1.start(0.8)
		spawn_weeping_fairy_set(timer1_count % 2 == 1)
		
	timer1_count += 1

static func spawn_side_fairy_set(inverted : bool = false):
	var count = 0
	var velocity = Vector2(-240, 320)
	var acceleration = Vector2(0, -120)
	if inverted:
		velocity.x = -velocity.x
		acceleration.x = -acceleration.x
	for position in spawn_positions:
		if inverted:
			position.x = mirror_x(position.x)
		var enemy = spawn_side_fairy(position, velocity, acceleration)
		enemy.delay_time = count * 0.1
		count += 1

static func spawn_weeping_fairy_set(inverted : bool = false):
	var count = 0
	var velocity = Vector2(-190, 120)
	var acceleration = Vector2(0, -40)
	if inverted:
		velocity.x = -velocity.x
		acceleration.x = -acceleration.x
	for position in spawn_positions:
		if inverted:
			position.x = mirror_x(position.x)
		var enemy = spawn_weeping_fairy(position, velocity, acceleration)
		enemy.delay_time = count * 0.1
		count += 1

# ================ WEEPING RAINING FAIRY ================

static func spawn_weeping_fairy(position: Vector2, velocity: Vector2, acceleration: Vector2) -> Enemy:
	var enemy = spawn_enemy(enemy_fairy, position)
	enemy.velocity = velocity
	enemy.drops = drop_fairy_point
	enemy.main_sprite.set_type("blue")
	LF.accel(enemy, acceleration)
	enemy.add_behavior_func("shooter", weeping_shooter)
	return enemy

static func weeping_shooter(entity: Entity, delta: float):
	if entity.just_time_passed_every(0.2):
		var bullet = ModScript.spawn_entity(bullet_circle, entity.position)
		bullet.velocity = Vector2.from_angle(randf_range(-3 * PI/4, -PI/4)) * 100
		bullet.set_color(SGBasicBullet.ColorType.BLUE)
		LF.accel(bullet, Vector2(0, 200))
		bullet.material = material_additive

# ================ TRIANGLE SHOT FAIRY ================

static func spawn_side_fairy(position: Vector2, velocity: Vector2, acceleration: Vector2) -> Enemy:
	var enemy = spawn_enemy(enemy_fairy, position)
	enemy.velocity = velocity
	enemy.drops = drop_fairy_power
	enemy.main_sprite.set_type("red")
	LF.accel(enemy, acceleration)
	enemy.add_behavior_func("shooter", shoot_implode_circle)
	return enemy

static func shoot_implode_circle(entity: Entity, delta: float):
	if entity.just_time_passed(1.8):
		AudioManager.play_audio_2d(AudioManager.audio_shoot_default, entity.position)
		var bullet_list := BulletUtils.spawn_circle(
			bullet_circle, # Bullet to spawn
			entity.position, # Position
			100, # Speed
			16, # Count
			0, # Offset rad
		)
		for bullet : Bullet in bullet_list:
			bullet.set_color(SGBasicBullet.ColorType.RED)
			bullet.material = material_additive
			LF.accel(bullet, bullet.velocity * -0.8)

static func mirror_x(x: float) -> float:
	return -(x - GameUtils.game_area.x)
