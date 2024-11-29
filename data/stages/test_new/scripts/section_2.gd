extends SectionScript

@onready var enemy_fairy : PackedScene = EnemyUtils.scene_dict["lesser_fairy"]
@onready var enemy_sunflower : PackedScene = EnemyUtils.scene_dict["sunflower_fairy"]

static var material_additive = preload("res://data/canvas_material/blend_additive.tres")

var timer1 := Timer.new()
var timer1_count : int = 0

var drop_fairy_power := EnemyDrops.new(10, 0)
var drop_fairy_point := EnemyDrops.new(0, 8)

func _init() -> void:
	timer1 = timer_setup(timeout_1)

func timer_setup(function: Callable) -> Timer:
	var timer = Timer.new()
	timer.connect("timeout", function)
	add_child(timer)
	return timer

func _ready() -> void:
	super()
	duration = 40.0
	timer1.start(0.5)

func _physics_process(delta: float) -> void:
	super(delta)
	if time_active >= 35.0:
		timer1.paused = true

func timeout_1():
	var mid_pos : Vector2 = GameUtils.game_area * 0.5
	var backing_fairy_count : int = 3 + floori(timer1_count / 6)
	if timer1_count % 3 == 2:
		backing_fairy_count -= 1
	var backing_fairy_offset : float = float(backing_fairy_count) * 0.5 - 0.5
	var backing_fairy_space = 700 / backing_fairy_count
	if timer1_count % 3 == 0:
		timer1.start(1.5)
		spawn_big_shot_fairy(Vector2(mid_pos.x, -80))
	elif timer1_count % 3 == 1: # Half is Vector2(384,448)
		timer1.start(1.0)
		for i in range(backing_fairy_count):
			spawn_circle_shot_fairy(Vector2(mid_pos.x - backing_fairy_space * (i - backing_fairy_offset), -80))
	else:
		timer1.start(2.0)
		for i in range(backing_fairy_count):
			spawn_line_shot_fairy(Vector2(mid_pos.x - backing_fairy_space * (i - backing_fairy_offset), -80))
	timer1_count += 1

func spawn_circle_shot_fairy(position: Vector2):
	var enemy = spawn_enemy(enemy_fairy, position)
	enemy.main_sprite.set_type("green")
	enemy.velocity = Vector2(0, 320)
	enemy.drops = drop_fairy_point
	enemy.set_mhp(15)
	LF.accel(enemy, Vector2(0, -100))
	enemy.add_behavior_func("shooter", shoot_circle)

func spawn_line_shot_fairy(position: Vector2):
	var enemy = spawn_enemy(enemy_fairy, position)
	enemy.main_sprite.set_type("blue")
	enemy.velocity = Vector2(0, 270)
	enemy.drops = drop_fairy_point
	enemy.set_mhp(20)
	LF.accel(enemy, Vector2(0, -100))
	enemy.add_behavior_func("shooter", shoot_line)

func spawn_big_shot_fairy(position: Vector2):
	var enemy = spawn_enemy(enemy_sunflower, position)
	enemy.main_sprite.set_type("red")
	enemy.velocity = Vector2(0, 380)
	enemy.drops = drop_fairy_power
	enemy.set_mhp(120)
	LF.accel(enemy, Vector2(0, -120))
	enemy.add_behavior_func("shooter", shoot_circle_group)

static func shoot_line(entity: Entity, delta: float):
	if entity.just_time_passed(1.0):
		AudioManager.play_audio_2d(AudioManager.audio_shoot_default, entity.position)
		var direction = GameUtils.get_direction_to_player(entity)
		var bullet : Bullet
		var main_velocity : Vector2
		var pos_offset : Vector2
		for i in range(16):
			main_velocity = direction * (200 + 10 * i)
			pos_offset = direction.rotated(PI/2) * 15
			
			bullet = spawn_bullet(BulletUtils.scene_dict["spike"], entity.position)
			bullet.velocity = main_velocity
			bullet.position += pos_offset
			bullet.set_color(SGBasicBullet.ColorType.BLUE)
			
			bullet = spawn_bullet(BulletUtils.scene_dict["spike"], entity.position)
			bullet.velocity = main_velocity
			bullet.position -= pos_offset
			bullet.set_color(SGBasicBullet.ColorType.BLUE)

static func shoot_circle(entity: Entity, delta: float):
	if entity.just_time_passed_every(1.3):
		AudioManager.play_audio_2d(AudioManager.audio_shoot_default, entity.position)
		var bullet_list = BulletUtils.spawn_circle(
			BulletUtils.scene_dict["spike"], # Bullet to spawn
			entity.position, # Position
			360, # Speed
			24, # Count
			0, # Offset rad
		)
		for bullet : Bullet in bullet_list:
			bullet.set_color(SGBasicBullet.ColorType.GREEN)

static func shoot_circle_group(entity: Entity, delta: float):
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
