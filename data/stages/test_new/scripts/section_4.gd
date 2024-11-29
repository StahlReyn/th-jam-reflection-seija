extends SectionScript

static var material_additive = preload("res://data/canvas_material/blend_additive.tres")
static var enemy_fairy : PackedScene = EnemyUtils.scene_dict["lesser_fairy"]
static var bullet_small : PackedScene = BulletUtils.scene_dict["circle_small"]
static var bullet_crystal : PackedScene = BulletUtils.scene_dict["crystal_small"]
static var enemy_ice : PackedScene = preload("res://data/enemies/special/snowflake.tscn")

static var drop_fairy_power := EnemyDrops.new(3, 0)
static var drop_fairy_point := EnemyDrops.new(0, 5)

static var spawn_positions : PackedVector2Array = [
	Vector2(850, -40),
	Vector2(800, -60),
	Vector2(750, -80)
]

var timer1 : Timer = Timer.new()
var timer1_count : int = 0

func _init() -> void:
	timer1 = timer_setup(2.0, timeout_1)

func _ready() -> void:
	super()
	duration = 25.0
	timer1.start()

func _physics_process(delta: float) -> void:
	super(delta)

func timeout_1():
	if time_active > 23.0:
		timer1.start(100.0)
	if timer1_count % 3 == 0:
		timer1.start(1.0)
		spawn_side_fairy_set(timer1_count % 2 == 0)
	elif timer1_count <= 1000:
		timer1.start(1.0)
		spawn_weeping_fairy_set(timer1_count % 2 == 1)
		
	timer1_count += 1

func spawn_side_fairy_set(inverted : bool = false):
	var count = 0
	var velocity = Vector2(-240, 220)
	var acceleration = Vector2(0, -80)
	if inverted:
		velocity.x = -velocity.x
		acceleration.x = -acceleration.x
	for position in spawn_positions:
		if inverted:
			position.x = mirror_x(position.x)
		var enemy = spawn_side_fairy(position, velocity, acceleration)
		enemy.delay_time = count * 0.1
		count += 1

func spawn_weeping_fairy_set(inverted : bool = false):
	var count = 0
	var velocity = Vector2(-200, 200)
	var acceleration = Vector2(0, -70)
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

func spawn_weeping_fairy(position: Vector2, velocity: Vector2, acceleration: Vector2) -> Enemy:
	var enemy = spawn_enemy(enemy_fairy, position)
	enemy.velocity = velocity
	enemy.drops = drop_fairy_point
	enemy.main_sprite.set_type("blue")
	LF.accel(enemy, acceleration)
	enemy.add_behavior_func("shooter", shoot_falling)
	return enemy

static func shoot_falling(entity: Entity, delta: float):
	if entity.just_time_passed(2.0):
		AudioManager.play_audio_2d(AudioManager.audio_shoot_default, entity.position)
		var direction = GameUtils.get_direction_to_player(entity)
		var bullet := spawn_enemy(enemy_ice, entity.position)
		LF.accel(bullet, Vector2(0, 500))

# ================ TRIANGLE SHOT FAIRY ================

func spawn_side_fairy(position: Vector2, velocity: Vector2, acceleration: Vector2) -> Enemy:
	var enemy := spawn_enemy(enemy_fairy, position)
	enemy.velocity = velocity
	enemy.drops = drop_fairy_power
	enemy.main_sprite.set_type("yellow")
	LF.accel(enemy, acceleration)
	enemy.add_behavior_func("shooter", shoot_circle_group)
	return enemy
	
static func shoot_circle_group(entity: Entity, delta: float):
	if entity.just_time_passed(2.0):
		AudioManager.play_audio_2d(AudioManager.audio_shoot_default, entity.position)
		var direction = GameUtils.get_direction_to_player(entity)
		var bullet_list = BulletUtils.spawn_circle_packed(
			bullet_crystal, # Bullet to spawn
			entity.position, # Position
			direction * 200, 6, 60, 0, 6, PI/6
		)
		for bullet : Bullet in bullet_list:
			bullet.set_color(SGBasicBullet.ColorType.TEAL)
			LF.accel(bullet, Vector2(randi_range(-200,200), randi_range(-200,200)))
	
static func mirror_x(x: float) -> float:
	return -(x - GameUtils.game_area.x)
