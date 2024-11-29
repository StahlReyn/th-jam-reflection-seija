extends SpellCard
# 

@onready var enemy_boss : PackedScene = preload("res://data/enemies/bosses/boss_letty_whiterock.tscn")

@onready var bullet_line : PackedScene = BulletUtils.scene_dict["partial_laser_small"]
@onready var bullet_circle : PackedScene = BulletUtils.scene_dict["circle_medium"]

@onready var bullet_shard = BulletUtils.scene_dict["crystal_small"]
@onready var enemy_ice : PackedScene = preload("res://data/enemies/special/snowflake.tscn")

@onready var audio_laser : AudioStream = preload("res://assets/audio/sfx/laser_modified.wav")
@onready var audio_shoot : AudioStream = preload("res://assets/audio/sfx/hit_noise_fade.wav")

@onready var blend_add = preload("res://data/canvas_material/blend_additive.tres")

 # Two sets as one goes another direction
var chimera_list_1 : EntityList = EntityList.new()
var chimera_list_2 : EntityList = EntityList.new()

var boss : Enemy
var drop_boss := EnemyDrops.new(40, 0)

var timer1 : Timer = Timer.new()
var timer1_count : int = 0
var doing_end : bool = false
var can_end : bool = false

# Pattern Variables
var bullet_base_speed : float = 320
var line_count : int = 16
var spin_time : float = 2.0
var spawn_time : float = 1.0
var spin_speed : float = 0.19 # This is more of multiplier. Speed is also depend on distance

func _ready() -> void:
	super()
	start_section()
	boss = get_existing_boss(enemy_boss, 0)
	boss.setup_for_section(drop_boss, 1200)
	LF.smooth_pos(boss, Vector2(385, 200), 2.0)
	
	add_child(timer1)
	timer1.connect("timeout", timeout_1)
	timer1.start(0.5)

func _physics_process(delta: float) -> void:
	super(delta)
	if is_instance_valid(boss):
		if boss.hp < 0 and not doing_end:
			timer1.start(0.1)
			doing_end = true
	if time_active >= duration and not doing_end:
		timer1.start(0.1)
		doing_end = true

# Modify end condition so boss is finished properly
func end_condition() -> bool:
	return can_end

func end_section() -> void:
	super()
	
func start_section():
	super()
	section_name = "Winter Sign \"Cold Front\""
	total_bonus = 5000000
	duration = 50.0
	update_displayer()
			
func set_bullet_style(bullet: Entity) -> void:
	bullet.despawn_padding = 300  # increase padding as rotate move offscreen far
	bullet.material = blend_add
	bullet.set_color(SGBasicBullet.ColorType.BLUE)

func timeout_1():
	if not enabled:
		can_end = true
		return
	if doing_end:
		timer1.start(2.0)
		if is_instance_valid(boss):
			boss.do_check_despawn = true
		LF.smooth_pos(boss, Vector2(385, -200), 2.0)
		enabled = false
		clear_bullets()
		return
		
	if timer1_count % 10 == 9:
		move_boss_random()
		
	if timer1_count % 5 == 4:
		timer1.wait_time = 5.0
		timer1.start(2.5)
		spawn_ice_shards(timer1_count % 2 * 10)
	elif timer1_count % 5 == 0:
		timer1.start(0.2)
		spawn_ice_wall()
	else:
		timer1.start(0.1)
		spawn_ice_shards(timer1_count % 2 * 10)
		
	timer1_count += 1

func move_boss_random():
	LF.smooth_pos(boss, Vector2(randf_range(200,600), randf_range(160,260)), 2.0)

func spawn_ice_wall():
	# Remember ice is enemy
	var enemy : Enemy
	for i in range(10):
		enemy = ModScript.spawn_enemy(enemy_ice, Vector2(i * 75 + 40, 5))
		enemy.velocity = Vector2.DOWN
		enemy.rotation += i * 0.1
		LF.accel(enemy, Vector2(0, 300))
	AudioManager.play_audio(audio_shoot)

func spawn_ice_shards(x_offset : float):
	var bullet : Bullet
	for i in range(50):
		bullet = ModScript.spawn_bullet(bullet_shard, Vector2(i * 20 + x_offset, 5))
		bullet.velocity = Vector2.DOWN
		bullet.set_color(SGBasicBullet.ColorType.TEAL)
		LF.accel(bullet, Vector2(0, 200))
	AudioManager.play_audio(audio_shoot)
	
