extends SectionScript

static var material_additive = preload("res://data/canvas_material/blend_additive.tres")
static var enemy_fairy : PackedScene = EnemyUtils.scene_dict["lesser_fairy"]
static var enemy_sunflower : PackedScene = EnemyUtils.scene_dict["sunflower_fairy"]
static var bullet_small : PackedScene = BulletUtils.scene_dict["circle_small"]
static var bullet_crystal : PackedScene = BulletUtils.scene_dict["crystal_small"]
static var bullet_arrow : PackedScene = BulletUtils.scene_dict["arrow"]
static var enemy_ice : PackedScene = preload("res://data/enemies/special/snowflake.tscn")
static var bullet_big_ice : PackedScene = preload("res://data/bullets/example/bullet_big_ice.tscn")

static var drop_fairy_power := EnemyDrops.new(3, 0)
static var drop_fairy_point := EnemyDrops.new(0, 3)
static var drop_fairy_big := EnemyDrops.new(8, 16)

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
	if timer1_count % 7 == 0:
		timer1.start(1.3)
		spawn_weeping_fairy_set()
	elif timer1_count % 7 == 6:
		timer1.start(3.5)
		if time_active > 15.0:
			spawn_side_fairy_set(false, 0)
			spawn_side_fairy_set(true, 0)
		if time_active > 30.0:
			spawn_side_fairy_set(false, 0)
			spawn_side_fairy_set(true, 0)
		if time_active > 40.0:
			timer1.start(100.0)
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

# ================ BIG SHOT FAIRY ================

func spawn_weeping_fairy(position: Vector2, velocity: Vector2, acceleration: Vector2) -> Enemy:
	var enemy = spawn_enemy(enemy_sunflower, position)
	enemy.velocity = velocity
	enemy.drops = drop_fairy_big
	enemy.set_mhp(200)
	enemy.main_sprite.set_type("blue")
	LF.accel(enemy, acceleration)
	enemy.add_behavior_func("shooter", shoot_big_ice)
	return enemy

static func shoot_big_ice(entity:Entity):
	if entity.just_time_passed(3.0):
		AudioManager.play_audio_2d(AudioManager.audio_shoot_default, entity.position)
		var direction = GameUtils.get_direction_to_player(entity)
		var bullet := spawn_bullet(bullet_big_ice, entity.position)
		bullet.velocity = direction * 200
		LF.accel(bullet, Vector2(0, 100))
		
# ================ ACCEL ARROW FAIRY ================

func spawn_side_fairy(position: Vector2, velocity: Vector2, acceleration: Vector2) -> Enemy:
	var enemy = spawn_enemy(enemy_fairy, position)
	enemy.velocity = velocity
	enemy.drops = drop_fairy_power
	enemy.set_mhp(30)
	enemy.main_sprite.set_type("green")
	LF.accel(enemy, acceleration)
	enemy.set_meta("alternate_shot", false)
	enemy.add_behavior_func("shooter", shoot_accel_arrow)
	return enemy

static func shoot_accel_arrow(entity:Entity):
	if entity.just_time_passed_every(1.0):
		AudioManager.play_audio_2d(AudioManager.audio_shoot_default, entity.position)
		var direction = GameUtils.get_direction_to_player(entity)
		var offset = 0
		# Alternate shots so it weaves
		var do_alternate = entity.get_meta("alternate_shot")
		if do_alternate:
			offset = TAU/12
			entity.set_meta("alternate_shot", not do_alternate)
		
		var bullet_list := BulletUtils.spawn_circle(
			bullet_arrow, # Bullet to spawn
			entity.position, # Position
			10, # Speed
			12, # Count
			offset, # Offset rad
		)
		for bullet : Bullet in bullet_list:
			bullet.set_color(SGBasicBullet.ColorType.TEAL)
			LF.accel(bullet, bullet.velocity * 50)

# ================ RAIN ICE FAIRY ================

func spawn_rain_fairy(position: Vector2, velocity: Vector2, acceleration: Vector2) -> Enemy:
	var enemy = spawn_enemy(enemy_fairy, position)
	enemy.velocity = velocity
	enemy.drops = drop_fairy_point
	enemy.set_mhp(3)
	enemy.main_sprite.set_type("yellow")
	LF.accel(enemy, acceleration)
	enemy.add_behavior_func("shooter", shoot_falling)
	return enemy

static func shoot_falling(entity:Entity):
	if entity.just_time_passed_every(0.3):
		var bullet := spawn_bullet(bullet_crystal, entity.position)
		bullet.velocity = Vector2(randf_range(-10, 10), 20)
		LF.accel(bullet, Vector2(0, 250))
		bullet.set_color(SGBasicBullet.ColorType.BLUE)

static func mirror_x(x: float) -> float:
	return -(x - GameUtils.game_area.x)
