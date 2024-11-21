extends SectionScript

@onready var enemy_fairy : PackedScene = EnemyUtils.scene_dict["lesser_fairy"]

static var material_additive = preload("res://data/canvas_material/blend_additive.tres")

var timer1 : Timer = Timer.new()
var timer1_count : int = 0

func _init() -> void:
	timer1 = timer_setup(timeout_1)

func timer_setup(function: Callable) -> Timer:
	var timer = Timer.new()
	timer.connect("timeout", function)
	add_child(timer)
	return timer

func _ready() -> void:
	super()
	duration = 30.0
	timer1.start(1.0)

func _physics_process(delta: float) -> void:
	super(delta)
	if time_active >= 25.0:
		timer1.paused = true

func timeout_1():
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
	enemy.main_sprite.set_type(SGFairy.Type.GREEN)
	enemy.velocity = velocity
	enemy.drop_power = 0
	enemy.drop_point = 15
	enemy.mhp = 20
	enemy.reset_hp()
	enemy.add_velocity_func(en_accel(acceleration))
	enemy.add_behavior_func(shoot_circle)

func spawn_big_shot_fairy(position):
	var velocity = Vector2(0, 320)
	var acceleration = Vector2(0, -100)
	var enemy = spawn_enemy(enemy_fairy, position)
	enemy.main_sprite.set_type(SGFairy.Type.RED)
	enemy.velocity = velocity
	enemy.drop_power = 15
	enemy.drop_point = 0
	enemy.mhp = 100
	enemy.reset_hp()
	enemy.add_velocity_func(en_accel(acceleration))
	enemy.add_behavior_func(shoot_circle_group)

static func shoot_circle(entity:Entity):
	if entity.just_time_passed_every(1.0):
		AudioManager.play_audio_2d(AudioManager.audio_shoot_default, entity.position)
		var bullet_list = BulletUtils.spawn_circle(
			BulletUtils.scene_dict["spike"], # Bullet to spawn
			entity.position, # Position
			400, # Speed
			25, # Count
			0, # Offset rad
		)
		for bullet : Bullet in bullet_list:
			bullet.set_color(SGBasicBullet.ColorType.GREEN)

static func shoot_circle_group(entity:Entity):
	if entity.just_time_passed(3.0):
		AudioManager.play_audio_2d(AudioManager.audio_shoot_default, entity.position)
		var direction = GameUtils.get_direction_to_player(entity)
		var bullet_list = BulletUtils.spawn_circle_packed(
			BulletUtils.scene_dict["circle_medium"], # Bullet to spawn
			entity.position, # Position
			direction * 200, 16, 40, 0, 4, PI/16
		)
		for bullet : Bullet in bullet_list:
			bullet.set_color(SGBasicBullet.ColorType.RED)
			bullet.material = material_additive
