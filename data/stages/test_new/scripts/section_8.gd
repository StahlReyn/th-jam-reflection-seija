extends SectionScript

static var material_additive = preload("res://data/canvas_material/blend_additive.tres")
static var enemy_fairy : PackedScene = EnemyUtils.scene_dict["lesser_fairy"]

static var bullet_spike : PackedScene = BulletUtils.scene_dict["spike"]
static var bullet_star = BulletUtils.scene_dict["star_small"]
static var bullet_circle = BulletUtils.scene_dict["circle_medium"]

static var enemy_ice : PackedScene = preload("res://data/enemies/special/snowflake.tscn")
static var bullet_big_ice : PackedScene = preload("res://data/bullets/example/bullet_big_ice.tscn")

static var drop_fairy_point := EnemyDrops.new(0, 15)

var timer_fairy : Timer = Timer.new()
var timer_fairy_count : int = 0

var timer_rain : Timer = Timer.new()
var timer_rain_count : int = 0

func _init() -> void:
	timer_fairy = timer_setup(2.0, timeout_fairy)
	timer_rain = timer_setup(0.1, timeout_rain)

func _ready() -> void:
	super()
	duration = 60.0
	timer_fairy.start(5.0)
	timer_rain.start(1.0)

func _physics_process(delta: float) -> void:
	super(delta)
	if time_active > 50.0:
		timer_fairy.paused = true
		timer_rain.paused = true

func timeout_rain():
	var bullet : Bullet
	var velocity := Vector2(0,0)
	var acceleration := Vector2(0,150)
	var position := Vector2(randf_range(10, 760), -50)
	
	# This is a placeholder bullet to spawn more sets of bullet, it removes itself later
	bullet = spawn_bullet(bullet_spike, position)
	bullet.visible = false
	bullet.monitorable = false
	bullet.monitoring = false
	bullet.add_behavior_func("rain_set", shoot_rain_set)
	
	if time_active > 10.0:
		if timer_rain_count % 25 == 0:
			var enemy = spawn_enemy(enemy_ice, Vector2(randf_range(60, 700), 5))
			enemy.velocity = velocity
			LF.accel(enemy, acceleration)
	
	if time_active > 20.0:
		if timer_rain_count % 10 == 0:
			bullet = spawn_bullet(bullet_star, Vector2(randf_range(60, 700), -20))
			bullet.set_color(SGBasicBullet.ColorType.YELLOW)
			bullet.velocity = bullet.position.direction_to(GameUtils.get_player().position)
			LF.accel(bullet, bullet.velocity * 180)
			LF.rot_vel(bullet, 4.0)
			
	timer_rain_count += 1
	timer_rain.start(max(0.22 - (time_active * 0.003), 0.03))

static func shoot_rain_set(entity: Entity, delta: float):
	if entity.just_time_passed_every(0.05):
		var bullet = spawn_bullet(bullet_spike, entity.position)
		bullet.velocity = Vector2.ZERO
		LF.accel(bullet, Vector2(0,140))
		bullet.set_color(SGBasicBullet.ColorType.BLUE)
		bullet.material = material_additive
	if entity.active_time > 0.32:
		entity.call_deferred("queue_free")
	
func timeout_fairy():
	var velocity := Vector2(0, 80)
	var enemy = spawn_enemy(enemy_fairy, Vector2(randf_range(100, 660), -50))
	enemy.velocity = velocity
	enemy.main_sprite.set_type("red")
	enemy.velocity = velocity
	enemy.drops = drop_fairy_point
	enemy.set_mhp(30)
	enemy.add_behavior_func("shooter", shoot_slow_circle)
	timer_fairy_count += 1
	timer_fairy.start(max(3.5 - (time_active * 0.01), 1.0))

static func shoot_slow_circle(entity: Entity, delta: float):
	if entity.just_time_passed_every(4.0):
		AudioManager.play_audio_2d(AudioManager.audio_shoot_default, entity.position)
		var bullet_list := BulletUtils.spawn_circle(
			bullet_circle, # Bullet to spawn
			entity.position, # Position
			100, # Speed
			40, # Count
			0, # Offset rad
		)
		for bullet : Bullet in bullet_list:
			bullet.set_color(SGBasicBullet.ColorType.RED)
			bullet.material = material_additive

static func mirror_x(x: float) -> float:
	return -(x - GameUtils.game_area.x)
