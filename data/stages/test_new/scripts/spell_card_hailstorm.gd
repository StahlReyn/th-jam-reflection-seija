extends SpellCard
# 

static var enemy_boss : PackedScene = preload("res://data/enemies/bosses/boss_letty_whiterock.tscn")
static var bullet_line : PackedScene = BulletUtils.scene_dict["partial_laser_small"]
static var bullet_circle : PackedScene = BulletUtils.scene_dict["circle_medium"]
static var bullet_shard = BulletUtils.scene_dict["crystal_small"]
static var enemy_ice : PackedScene = preload("res://data/enemies/special/snowflake.tscn")
static var audio_shoot : AudioStream = preload("res://assets/audio/sfx/hit_noise_fade.wav")

enum State {
	MAIN,
	ENDING,
	ENDED,
}

var state = State.MAIN
var boss : Enemy
var drop_boss := EnemyDrops.new(40, 0)
var timer1 : Timer = Timer.new()
var timer1_count : int = 0

func _ready() -> void:
	super()
	start_section()
	boss = get_existing_boss(enemy_boss, 0)
	boss.setup_for_section(drop_boss, 3000)
	LF.smooth_pos(boss, Vector2(385, 200), 2.0)
	timer1 = timer_setup(0.5, timeout_1)
	
func _physics_process(delta: float) -> void:
	super(delta)
	if state == State.MAIN:
		if boss.hp <= 0 or time_active >= duration:
			state = State.ENDING
			boss.do_check_despawn = true
			LF.smooth_pos(boss, Vector2(385, -200), 2.0)
			clear_bullets()
			timer1.start(2.0)

# Modify end condition so boss is finished properly
func end_condition() -> bool:
	return state == State.ENDED

func start_section():
	super()
	section_name = "Winter Sign \"Cold Front\""
	total_bonus = 5000000
	duration = 50.0
	update_displayer()

func timeout_1():
	if state == State.ENDING:
		state = State.ENDED
		timer1.paused = true
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
	
