extends SectionScript

static var material_additive = preload("res://data/canvas_material/blend_additive.tres")
@onready var enemy_fairy : PackedScene = EnemyUtils.scene_dict["lesser_fairy"]

@onready var bullet_spike : PackedScene = BulletUtils.scene_dict["spike"]
@onready var bullet_star = BulletUtils.scene_dict["star_small"]
@onready var bullet_circle = BulletUtils.scene_dict["circle_medium"]

@onready var enemy_ice : PackedScene = preload("res://data/enemies/special/snowflake.tscn")
@onready var bullet_big_ice : PackedScene = preload("res://data/bullets/example/bullet_big_ice.tscn")

var timer_fairy : Timer = Timer.new()
var timer_fairy_count : int = 0

var timer_rain : Timer = Timer.new()
var timer_rain_count : int = 0

func _init() -> void:
	timer_fairy = timer_setup(2.0, timeout_fairy)
	timer_rain = timer_setup(0.1, timeout_rain)

func timer_setup(wait_time: float, function: Callable) -> Timer:
	var timer = Timer.new()
	timer.wait_time = wait_time
	timer.connect("timeout", function)
	add_child(timer)
	return timer

func _ready() -> void:
	super()
	duration = 50.0
	timer_fairy.start(5.0)
	timer_rain.start(1.0)

func _physics_process(delta: float) -> void:
	super(delta)
	if time_active > 40.0:
		timer_fairy.paused = true
		timer_rain.paused = true

func end_section():
	clear_bullets()
	clear_enemies()
	super()

func timeout_rain():
	var bullet : Bullet
	var velocity := Vector2(0,0)
	var acceleration := Vector2(0,150)
	var position := Vector2(randf_range(10, 760), -50)
	for i in range(6):
		bullet = spawn_bullet(bullet_spike, position)
		bullet.velocity = velocity
		bullet.delay_time = i * 0.05
		bullet.add_script_node(
			MSAcceleration.new(acceleration)
		)
		bullet.set_color(SpriteGroupBasicBullet.ColorType.BLUE)
		bullet.material = material_additive
	
	if time_active > 10.0:
		if timer_rain_count % 20 == 0:
			var enemy = spawn_enemy(enemy_ice, Vector2(randf_range(60, 700), 5))
			enemy.velocity = velocity
			enemy.add_script_node(
				MSAcceleration.new(acceleration)
			)
	
	if time_active > 20.0:
		if timer_rain_count % 5 == 0:
			bullet = spawn_bullet(bullet_star, Vector2(randf_range(60, 700), -20))
			bullet.velocity = bullet.position.direction_to(GameUtils.get_player().position)
			bullet.add_script_node(
				MSAcceleration.new(bullet.velocity * 200)
			)
			bullet.add_script_node(
				MSConstantRotation.new(4)
			)
			
	timer_rain_count += 1
	timer_rain.start(max(0.2 - (time_active * 0.003), 0.03))
	
func timeout_fairy():
	var velocity := Vector2(0, 80)
	var enemy = spawn_enemy(enemy_fairy, Vector2(randf_range(100, 660), -50))
	enemy.velocity = velocity
	enemy.main_sprite.set_type(SpriteGroupFairy.Type.RED)
	enemy.velocity = velocity
	enemy.drop_power = 0
	enemy.drop_point = 25
	enemy.mhp = 30
	enemy.reset_hp()
	
	var shooter := MSShootCircle.new(4.0, 100, 40, 0, bullet_circle)
	shooter.bullet_list_function = circle_shot_style
	enemy.add_script_node(shooter)
	
	timer_fairy_count += 1
	timer_fairy.start(max(2.0 - (time_active * 0.01), 1.0))

static func circle_shot_style(bullet_list):
	for bullet : Bullet in bullet_list:
		bullet.set_color(SpriteGroupBasicBullet.ColorType.RED)
		bullet.material = material_additive

static func mirror_x(x: float) -> float:
	return -(x - GameUtils.game_area.x)
