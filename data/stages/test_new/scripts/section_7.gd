extends SectionScript

static var enemy_fairy : PackedScene = EnemyUtils.scene_dict["lesser_fairy"]

static var material_additive = preload("res://data/canvas_material/blend_additive.tres")
static var bullet_star = BulletUtils.scene_dict["star_small"]
static var bullet_circle = BulletUtils.scene_dict["circle_medium"]

static var drop_fairy_power := EnemyDrops.new(10, 0)
static var drop_fairy_point := EnemyDrops.new(0, 15)

var timer1 : Timer = Timer.new()
var timer1_count : int = 0

func _init() -> void:
	timer1 = timer_setup(2.0, timeout_1)

func _ready() -> void:
	super()
	duration = 30.0
	timer1.start(1.0)

func _physics_process(delta: float) -> void:
	super(delta)
	if time_active > 25.0:
		timer1.paused = true

func timeout_1():
	if timer1_count % 3 == 0:
		timer1.start(2.0)
		spawn_star_fairy(Vector2(GameUtils.game_area.x/2, -80))
	elif timer1_count <= 1000:
		timer1.start(3.0)
		spawn_circle_shot_fairy(Vector2(200, -80))
		spawn_circle_shot_fairy(Vector2(600, -80))
	timer1_count += 1

static func spawn_circle_shot_fairy(position):
	var enemy = spawn_enemy(enemy_fairy, position)
	enemy.main_sprite.set_type("red")
	enemy.velocity = Vector2(0, 300)
	enemy.drops = drop_fairy_point
	enemy.set_mhp(50)
	LF.accel(enemy, Vector2(0, -120))
	enemy.add_behavior_func("shooter", shoot_slow_circle)

static func shoot_slow_circle(entity: Entity, delta: float):
	if entity.just_time_passed(3.0):
		AudioManager.play_audio_2d(AudioManager.audio_shoot_default, entity.position)
		var bullet_list := BulletUtils.spawn_circle(
			bullet_circle, # Bullet to spawn
			entity.position, # Position
			70, # Speed
			64, # Count
			0, # Offset rad
		)
		for bullet : Bullet in bullet_list:
			bullet.set_color(SGBasicBullet.ColorType.RED)
			bullet.material = material_additive
	
static func spawn_star_fairy(position):
	var enemy = spawn_enemy(enemy_fairy, position)
	enemy.main_sprite.set_type("yellow")
	enemy.velocity = Vector2(0, 320)
	enemy.drops = drop_fairy_power
	enemy.set_mhp(150)
	LF.accel(enemy, Vector2(0, -100))
	enemy.add_behavior_func("shooter", shoot_star_spiral)
	
static func shoot_star_spiral(entity: Entity, delta: float):
	if entity.just_time_passed_every(0.05):
		var bullet_list := BulletUtils.spawn_circle(
			bullet_star, # Bullet to spawn
			entity.position, # Position
			350, # Speed
			5, # Count
			entity.active_time * 0.5, # Offset rad
		)
		for bullet : Bullet in bullet_list:
			bullet.set_color(SGBasicBullet.ColorType.YELLOW)
			bullet.material = material_additive
			LF.rot_vel(bullet, 2.0)
		
