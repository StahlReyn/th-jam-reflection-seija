extends SectionScript

static var material_additive = preload("res://data/canvas_material/blend_additive.tres")
@onready var enemy_fairy : PackedScene = EnemyUtils.scene_dict["lesser_fairy"]
@onready var bullet_scene : PackedScene = BulletUtils.scene_dict["bullet"]

var timer1 : Timer = Timer.new()
var timer1_count : int = 0

var drop_fairy_power := EnemyDrops.new(3, 0)
var drop_fairy_point := EnemyDrops.new(0, 5)

func _init() -> void:
	timer1 = timer_setup(timeout_1)

func timer_setup(function: Callable) -> Timer:
	var timer = Timer.new()
	timer.connect("timeout", function)
	add_child(timer)
	return timer

func _ready() -> void:
	super()
	duration = 25.0
	timer1.start(1.0)

func _physics_process(delta: float) -> void:
	super(delta)
	if time_active > 20.0:
		timer1.paused = true

func timeout_1():
	if timer1_count % 3 == 0:
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
	enemy.drops = drop_fairy_point
	enemy.main_sprite.set_type("blue")
	enemy.add_velocity_func(en_accel(acceleration))
	enemy.add_behavior_func(weeping_shooter)
	return enemy

static func weeping_shooter(entity:Entity):
	if entity.just_time_passed_every(0.2):
		var bullet = ModScript.spawn_entity(
			BulletUtils.scene_dict["circle_medium"], entity.position
		)
		bullet.velocity = Vector2.from_angle(randf_range(-3 * PI/4, -PI/4)) * 100
		bullet.set_color(SGBasicBullet.ColorType.BLUE)
		bullet.add_velocity_func(en_accel(Vector2(0, 200)))
		bullet.material = material_additive

# ================ TRIANGLE SHOT FAIRY ================

func spawn_side_fairy(position: Vector2, velocity: Vector2, acceleration: Vector2) -> Enemy:
	var enemy = spawn_enemy(enemy_fairy, position)
	enemy.velocity = velocity
	enemy.drops = drop_fairy_power
	enemy.main_sprite.set_type("yellow")
	enemy.add_velocity_func(en_accel(acceleration))
	enemy.add_behavior_func(shoot_arc_triangle)
	return enemy

static func shoot_arc_triangle(entity:Entity):
	if entity.just_time_passed_every(1.0):
		AudioManager.play_audio_2d(AudioManager.audio_shoot_default, entity.position)
		var angle = entity.position.angle_to_point(GameUtils.get_player().position)
		var bullet_list = BulletUtils.spawn_arc_triangle(
			BulletUtils.scene_dict["bullet"], # Bullet to spawn
			entity.position, # Position
			550, # Speed
			4, # Count
			TAU/160, # angle per shot
			angle, # Main angle
			0.1 # init distance mult
		)
		
		for bullet : Bullet in bullet_list:
			bullet.set_color(SGBasicBullet.ColorType.ORANGE)

static func mirror_x(x: float) -> float:
	return -(x - GameUtils.game_area.x)
