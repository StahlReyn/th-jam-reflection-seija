extends SectionScript

@onready var enemy_fairy : PackedScene = EnemyUtils.scene_dict["lesser_fairy"]
@onready var bullet_scene : PackedScene = BulletUtils.scene_dict["bullet"]

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
	duration = 60.0
	timer1.start()

func _physics_process(delta: float) -> void:
	super(delta)

func timeout_1():
	var positions : PackedVector2Array = [
		Vector2(850, -40),
		Vector2(800, -60),
		Vector2(750, -80)
	]
	var count = 0
	var velocity = Vector2(-150, 200)
	var acceleration = Vector2(0, -80)
	
	if timer1_count % 2 == 0:
		velocity.x = -velocity.x
		acceleration.x = -acceleration.x
		
	for position in positions:
		if timer1_count % 2 == 0:
			position.x = mirror_x(position.x)
		
		var enemy = spawn_side_fairy(position, velocity, acceleration)
		enemy.main_sprite.set_type(count % 3)
		enemy.delay_time = count * 0.05
		count += 1
	
	if timer1_count % 5 == 4:
		timer1.start(2.0)
	else:
		timer1.start(0.1)
	timer1_count += 1

func spawn_side_fairy(position: Vector2, velocity: Vector2, acceleration: Vector2) -> Enemy:
	var enemy = spawn_enemy(enemy_fairy, position)
	enemy.velocity = velocity
	enemy.add_velocity_func(en_accel(acceleration))
	#enemy.add_script_node(
	#	MSAcceleration.new(acceleration)
	#)
	#var shoot_script = MSShootArc.new(2.0, 350, 5, TAU/256)
	#var shoot_script = MSShootArcTriangle.new(2.0, 450, 5, TAU/160, 0, 0.1)
	#var shoot_script = MSShootCircle.new(2.0, 10, 16, 0)
	#shoot_script.bullet_scene = bullet_scene
	#shoot_script.target_player = true
	#shoot_script.bullet_list_function = bullet_shot_style
	#enemy.add_script_node(shoot_script)
	enemy.add_behavior_func(shoot_circle())
	return enemy

static func bullet_shot_style(bullet_list):
	var i = 0
	var angle_per_shot = TAU/16
	for bullet : Bullet in bullet_list:
		bullet.set_color(SpriteGroupBasicBullet.ColorType.BLUE)
		bullet.add_velocity_func(en_circ(10.0, 1000, i*angle_per_shot))
		bullet.add_velocity_func(en_circ(10.0, 500, i*angle_per_shot))
		#bullet.add_velocity_func(en_accel(Vector2(100,-300)))
		i += 1

static func shoot_circle() -> Callable:
	return func f(entity:Entity):
		if entity.just_time_passed_every(2.0):
			var count = 16
			var bullet_list = BulletUtils.spawn_circle(
				BulletUtils.default_bullet, # Bullet to spawn
				entity.position, # Position
				5, # Speed
				count, # Count
				0, # Offset rad
			)
			var i = 0
			var angle_per_shot = TAU/count
			for bullet : Bullet in bullet_list:
				bullet.set_color(SpriteGroupBasicBullet.ColorType.BLUE)
				bullet.add_velocity_func(en_circ(1.0, 40, i*angle_per_shot))
				#bullet.add_velocity_func(en_circ(10.0, 20, i*angle_per_shot))
				i += 1

static func mirror_x(x: float) -> float:
	return -(x - GameUtils.game_area.x)
	
