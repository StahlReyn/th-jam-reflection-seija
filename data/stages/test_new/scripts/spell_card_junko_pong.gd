extends SpellCard
# 

static var enemy_boss : PackedScene = preload("res://data/enemies/bosses/boss_junko.tscn")
static var bullet_pong : PackedScene = preload("res://data/bullets/example/bullet_lily_pong.tscn")
static var bullet_circle = BulletUtils.scene_dict["circle_medium"]

static var audio_laser : AudioStream = preload("res://assets/audio/sfx/laser_modified.wav")
static var audio_shoot : AudioStream = preload("res://assets/audio/sfx/hit_noise_fade.wav")
static var audio_hit : AudioStream = preload("res://assets/audio/sfx/bullet_big_noisy.wav")

static var blend_add = preload("res://data/canvas_material/blend_additive.tres")

var pong_bullet_list : EntityList = EntityList.new()
var junko_hit_damage : int = 50
var junko_hit_speed : int = 2000
var junko_hit_radius : int = 150

var boss : Enemy

var charge_particle : GPUParticles2D

var timer_movement : Timer
var timer_spawn_pong : Timer
var timer_hit_cooldown : Timer
var timer_pong_count : Timer
var timer_star : Timer
var timer_end : Timer

var drop_boss := EnemyDrops.new(40, 0)

var can_hit = true
var doing_end : bool = false
var can_end : bool = false

var total_pong_count : int = 1

func _ready() -> void:
	super()
	start_section()
	
	boss = get_existing_boss(enemy_boss, 0)
	boss.setup_for_section(drop_boss, 6000)
	LF.smooth_pos(boss, Vector2(385, 200), 2.0)
	
	# This is a placeholder way to get particle but lol
	for child in boss.get_children():
		if child is GPUParticles2D:
			charge_particle = child
			break
	
	timer_movement = timer_setup(2.5, timeout_movement)
	timer_spawn_pong = timer_setup(1.0, timeout_spawn_pong)
	timer_hit_cooldown = timer_setup(2.5, timeout_hit_cooldown)
	timer_pong_count = timer_setup(50.0, timeout_pong_count)
	timer_star = timer_setup(20.0, timeout_star)
	timer_end = timer_setup(100.0, timeout_end)

func _physics_process(delta: float) -> void:
	super(delta)
	if is_instance_valid(boss):
		if boss.hp <= 0 and not doing_end:
			special_setup_end()
	if time_active >= duration and not doing_end:
		special_setup_end()

func special_setup_end():
	doing_end = true
	if is_instance_valid(boss):
		boss.do_check_despawn = true
	LF.smooth_pos(boss, Vector2(385,-200), 2.0)
	clear_bullets()
		
	timer_end.start(2.0)
	timer_movement.paused = true
	timer_spawn_pong.paused = true
	timer_hit_cooldown.paused = true
	timer_pong_count.paused = true
	timer_star.paused = true

func timeout_end():
	can_end = true

# Modify end condition so boss is finished properly
func end_condition() -> bool:
	return can_end

func end_section() -> void:
	super()
	
func start_section():
	super()
	section_name = "Pong of Murderous Intent"
	total_bonus = 10000000
	duration = 120.0
	update_displayer()

func timeout_movement():
	move_boss_random()

func timeout_spawn_pong():
	pong_bullet_list.clean_list()
	if pong_bullet_list.entity_count() < total_pong_count:
		spawn_pong_bullet()
	timer_spawn_pong.start(1.0)

func timeout_hit_cooldown():
	var did_hit = false
	pong_bullet_list.clean_list()
	for bullet in pong_bullet_list:
		if bullet is Bullet:
			if bullet.position.distance_to(boss.position) <= junko_hit_radius:
				did_hit = do_hit(bullet)
	
	if did_hit:
		AudioManager.play_audio_2d(audio_hit, boss.position, -1.0)
		charge_particle.emitting = false
		timer_hit_cooldown.start(2.5)
	else:
		charge_particle.emitting = true
		timer_hit_cooldown.start(0.1)

func timeout_pong_count():
	total_pong_count += 1
	timer_pong_count.start(50.0)

func timeout_star():
	var bullets = BulletUtils.spawn_circle(bullet_circle, boss.position, 300, 48)
	for bullet : Bullet in bullets:
		bullet.material = blend_add
		bullet.set_color(SGBasicBullet.ColorType.BLUE)
	AudioManager.play_audio(audio_shoot)
	if time_active >= 100:
		timer_star.start(1.0)
	elif time_active >= 70:
		timer_star.start(2.5)
	else:
		timer_star.start(4.0)

func move_boss_random():
	LF.smooth_pos(boss, Vector2(randf_range(200,600), randf_range(160,260)), 2.0)

func spawn_pong_bullet():
	print("Spawned Junko Pong")
	var bullet = spawn_bullet(bullet_pong, boss.position)
	var direction = bullet.position.direction_to(GameUtils.get_player().position)
	bullet.velocity = 300 * direction * (1 + min(time_active * 0.003, 2.0))
	bullet.position += bullet.velocity * 0.1 # Move a little bit from center
	bullet.hit_velocity_mult = 0.2 + min(time_active * 0.0015, 0.8)
	bullet.damage = junko_hit_damage
	pong_bullet_list.add_entity(bullet)

func do_hit(entity : Bullet) -> bool:
	var center_pos = boss.position
	var distance_vector = entity.position - center_pos
	var hit_angle = PI
	# If out of arc length, consider it out of range and skip; DOWN Vector, opposite of player
	var angle_to_center = abs(Vector2.DOWN.angle_to(distance_vector))
	if angle_to_center > hit_angle:
		return false

	entity.velocity = distance_vector.normalized() * junko_hit_speed * entity.hit_velocity_mult
	
	# Fancy hit change attributes
	entity.velocity.y = abs(entity.velocity.y) # Go DOWN-wards
	entity.modulate.a = 1.0
	entity.z_index = 10
	
	entity.collision_layer = BulletUtils.CollisionMask.TARGET_PLAYER
	entity.damage = junko_hit_damage
	
	entity.hit_velocity_mult += 0.01
	return true
