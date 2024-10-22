extends SpellCard

@onready var enemy_boss : PackedScene = preload("res://data/enemies/enemy_lesser_fairy_boss.tscn")
@onready var bullet_crystal : PackedScene = BulletUtils.scene_dict["crystal_small"]
@onready var audio_shoot : AudioStream = preload("res://assets/audio/sfx/hit_noise_fade.wav")

@onready var script_expiry : GDScript = preload("res://data/movement/common/expiry_timer.gd")

var shot_count_1 : int = 0
var shot_cd_1 : float = 1.0

var shot_count_2 : int = 0
var shot_cd_2 : float = 2.0

var move_count : int = 0
var move_cd : float = 10.0

var end_delay_cd : float = 2.0
var start_ending : bool = false

var pos_spiral : Vector2 = Vector2(380,200)

var boss : Enemy
var boss_target_position = Vector2(380,200)

func _ready() -> void:
	super()
	start_section()
	boss = spawn_enemy(enemy_boss, Vector2(380,0))
	boss.do_check_despawn = false
	boss.remove_on_death = false
	boss.mhp = 1000;
	boss.reset_hp()
	boss.drop_power = 40
	boss.drop_point = 20
	boss.drop_life_piece = 1

func _physics_process(delta: float) -> void:
	super(delta)
	shot_cd_1 -= delta
	shot_cd_2 -= delta
	move_cd -= delta
	pos_spiral = boss.position
	boss_movement()
	
	if boss.hp <= 0 and not start_ending:
		start_ending = true
		var expire_node = boss.add_movement_script(script_expiry)
		expire_node.duration = 3.0
		expire_node.active = true
	if start_ending:
		enabled = false
		end_delay_cd -= delta
		if end_delay_cd <= 1.0:
			boss_target_position = Vector2(380,-200)
	else:
		change_movement()
		shoot_spiral()
		shoot_circle()
		

func end_condition() -> bool:
	return time_active >= duration or end_delay_cd <= 0

func end_section() -> void:
	BulletUtils.clear_bullets()
	boss_target_position = Vector2(380,-200)
	super()
	
func start_section():
	super()
	spell_name = "FLOWER SIGN \"KNOCK OFF MEILING\""
	total_bonus = 5000000
	duration = 30.0
	update_displayer()

func boss_movement():
	var distance_squared = boss_target_position.distance_squared_to(boss.global_position)
	if distance_squared < 10: # If super close just set it there, prevent jittering
		boss.position = boss_target_position
		boss.velocity = Vector2.ZERO
	else:
		boss.velocity = 2.0 * (boss_target_position - boss.position) 

func change_movement():
	if move_cd <= 0:
		move_count += 1
		boss_target_position = Vector2(
			randi_range(200,600),
			randi_range(150,250)
		)
		move_cd += 8.0

func shoot_spiral() -> void:
	if shot_cd_1 <= 0:
		shot_count_1 += 1
		for i in range(5):
			bp_spiral(2, i*TAU/5 + shot_count_1 * 0.01)
			bp_spiral(-2, i*TAU/5 + shot_count_1 * 0.01)
		shot_cd_1 += 0.07

func shoot_circle() -> void:
	if shot_cd_2 <= 0:
		shot_count_2 += 1
		bp_circle(35, shot_count_2 * 0.01)
		AudioManager.play_audio(audio_shoot)
		shot_cd_2 += 1.0

func bp_spiral(speed, offset) -> void:
	var angle = time_elapsed * speed + offset
	var direction = Vector2(cos(angle),sin(angle))
	var bullet = spawn_bullet(bullet_crystal, pos_spiral)
	var bullet_speed = 300
	bullet.velocity = direction * bullet_speed
	bullet.set_color(
		SpriteGroupBasicBullet.ColorType.YELLOW, 
		SpriteGroupBasicBullet.ColorVariant.LIGHT
	)

func bp_circle(count, offset) -> void:
	for i in range(count):
		var angle = TAU * i/count + offset
		var direction = Vector2(cos(angle),sin(angle))
		var bullet = spawn_bullet(bullet_crystal, pos_spiral)
		bullet.velocity = direction * 300
		bullet.set_color(
			SpriteGroupBasicBullet.ColorType.RED, 
			SpriteGroupBasicBullet.ColorVariant.LIGHT
		)
