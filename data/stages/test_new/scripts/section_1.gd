extends SectionScript

@onready var enemy_fairy : PackedScene = EnemyUtils.scene_dict["lesser_fairy"]
@onready var bullet_scene : PackedScene = BulletUtils.scene_dict["bullet"]

var timer1 : Timer = Timer.new()
var timer1_count : int = 0
var timer1_set_count : int = 0

var drop_fairy_power := EnemyDrops.new(2, 0)

func _init() -> void:
	timer1 = timer_setup(1.0, timeout_1)

func _ready() -> void:
	super()
	duration = 20.0
	timer1.start(1.0)

func _physics_process(delta: float) -> void:
	super(delta)
	if time_active >= 16.0:
		timer1.paused = true

func timeout_1():
	var positions : PackedVector2Array = [
		Vector2(850, -40),
		Vector2(800, -60),
		Vector2(750, -80)
	]
	var count = 0
	var velocity = Vector2(-150, 200)
	var acceleration = Vector2(0, -80)
	
	if timer1_set_count % 2 == 0:
		velocity.x = -velocity.x
		acceleration.x = -acceleration.x
		
	for position in positions:
		if timer1_set_count % 2 == 0:
			position.x = mirror_x(position.x)
		
		var enemy = spawn_side_fairy(position, velocity, acceleration)
		enemy.main_sprite.set_row(count % 3)
		enemy.delay_time = count * 0.05
		enemy.drops = drop_fairy_power
		count += 1
	
	if timer1_count % 5 == 4:
		timer1_set_count += 1
		timer1.start(3.0)
	else:
		timer1.start(0.2)
	timer1_count += 1

func spawn_side_fairy(position: Vector2, velocity: Vector2, acceleration: Vector2) -> Enemy:
	var enemy = spawn_enemy(enemy_fairy, position)
	enemy.velocity = velocity
	LF.accel(enemy, acceleration)
	enemy.add_behavior_func("shooter", shoot_arc_triangle())
	return enemy

static func shoot_arc_triangle() -> Callable:
	return func f(entity: Entity, delta: float):
		if entity.just_time_passed_every(2.0):
			AudioManager.play_audio_2d(AudioManager.audio_shoot_default, entity.position)
			var angle = entity.position.angle_to_point(GameUtils.get_player().position)
			var bullet_list = BulletUtils.spawn_arc_triangle(
				BulletUtils.scene_dict["bullet"], # Bullet to spawn
				entity.position, # Position
				450, # Speed
				5, # Count
				TAU/160, # angle per shot
				angle, # Main angle
				0.1 # init distance mult
			)
			
			for bullet : Bullet in bullet_list:
				bullet.set_color(SGBasicBullet.ColorType.BLUE)

static func mirror_x(x: float) -> float:
	return -(x - GameUtils.game_area.x)
	
