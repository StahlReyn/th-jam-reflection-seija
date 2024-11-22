extends SpellCard
# 

@onready var enemy_boss : PackedScene = preload("res://data/enemies/bosses/boss_junko.tscn")
@onready var bullet_pong : PackedScene = preload("res://data/bullets/example/bullet_lily_pong.tscn")
@onready var bullet_circle = BulletUtils.scene_dict["circle_medium"]

@onready var audio_laser : AudioStream = preload("res://assets/audio/sfx/laser_modified.wav")
@onready var audio_shoot : AudioStream = preload("res://assets/audio/sfx/hit_noise_fade.wav")
@onready var audio_hit : AudioStream = preload("res://assets/audio/sfx/bullet_big_noisy.wav")

@onready var blend_add = preload("res://data/canvas_material/blend_additive.tres")

var pong_bullet_list : EntityList = EntityList.new()

var boss : Enemy
var boss_target_position : Vector2 = Vector2(385, 200)

var charge_particle : GPUParticles2D

var timer_movement : Timer = Timer.new()
var timer_spawn_pong : Timer = Timer.new()
var timer_hit_cooldown : Timer = Timer.new()

var timer_pong_count : Timer = Timer.new()
var timer_star : Timer = Timer.new()

var timer_end : Timer = Timer.new()

var can_hit = true
var doing_end : bool = false
var can_end : bool = false

var total_pong_count : int = 1

func _ready() -> void:
	super()
	start_section()
	boss = spawn_enemy(enemy_boss, Vector2(385,-50))
	boss.do_check_despawn = false
	boss.remove_on_death = false
	boss.remove_on_chapter_change = false
	boss.mhp = 3600
	boss.reset_hp()
	boss.drop_power = 40
	boss.drop_point = 40
	boss.drop_life_piece = 3
	
	# This is a placeholder way to get particle but lol
	for child in boss.get_children():
		if child is GPUParticles2D:
			charge_particle = child
			break
	
	add_child(timer_movement)
	timer_movement.connect("timeout", timeout_movement)
	timer_movement.start(5.0)
	add_child(timer_spawn_pong)
	timer_spawn_pong.connect("timeout", timeout_spawn_pong)
	timer_spawn_pong.start(1.0)
	add_child(timer_hit_cooldown)
	timer_hit_cooldown.connect("timeout", timeout_hit_cooldown)
	timer_hit_cooldown.start(3.0)
	add_child(timer_pong_count)
	timer_pong_count.connect("timeout", timeout_pong_count)
	timer_pong_count.start(40.0)
	add_child(timer_star)
	timer_star.connect("timeout", timeout_star)
	timer_star.start(20.0)
	add_child(timer_end)
	timer_end.connect("timeout", timeout_end)
	timer_end.start(100.0)

func _physics_process(delta: float) -> void:
	super(delta)
	if is_instance_valid(boss):
		boss.position = MathUtils.expDecay(boss.position, boss_target_position, 2, delta)
		if boss.hp <= 0 and not doing_end:
			special_setup_end()
	if time_active >= duration and not doing_end:
		special_setup_end()

func special_setup_end():
	doing_end = true
	if is_instance_valid(boss):
		boss.do_check_despawn = true
	boss_target_position = Vector2(385,-200)
	enabled = false
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
	section_name = "\"Pong of Muderous Intent\""
	total_bonus = 25000000
	duration = 100.0
	update_displayer()

func timeout_movement():
	move_boss_random()

func timeout_spawn_pong():
	pong_bullet_list.clean_list()
	if pong_bullet_list.entity_count() < total_pong_count:
		spawn_pong_bullet()
		timer_spawn_pong.start(1.0)
	else:
		timer_spawn_pong.start(1.0)

func timeout_hit_cooldown():
	var did_hit = false
	pong_bullet_list.clean_list()
	for bullet in pong_bullet_list:
		if bullet is Bullet:
			if bullet.position.distance_to(boss.position) < 150:
				did_hit = do_hit(bullet)
	
	if did_hit:
		AudioManager.play_audio(audio_hit, -1)
		charge_particle.emitting = false
		timer_hit_cooldown.start(2.5)
	else:
		charge_particle.emitting = true
		timer_hit_cooldown.start(0.05)

func timeout_pong_count():
	total_pong_count += 1
	timer_pong_count.start(40.0)

func timeout_star():
	var bullets = BulletUtils.spawn_circle(bullet_circle, boss.position, 300, 32)
	for bullet : Bullet in bullets:
		bullet.material = blend_add
		bullet.set_color(SGBasicBullet.ColorType.BLUE)
	AudioManager.play_audio(audio_shoot)
	if time_active >= 80:
		timer_star.start(1.0)
	elif time_active >= 60:
		timer_star.start(2.5)
	else:
		timer_star.start(4.0)

func move_boss_random():
	boss_target_position = Vector2(
		randf_range(200,600),
		randf_range(160,260)
	)

func spawn_pong_bullet():
	print("Spawned Junko Pong")
	var bullet = spawn_bullet(bullet_pong, boss.position)
	bullet.velocity = 1200 * bullet.position.direction_to(GameUtils.get_player().position)
	bullet.speed_multiplier = 0.3
	pong_bullet_list.add_entity(bullet)

func do_hit(entity : Bullet) -> bool:
	#if entity.collision_layer == BulletUtils.CollisionMask.TARGET_PLAYER:
		#return false
	
	var center_pos = boss.position
	var distance_vector = entity.position - center_pos
	var hit_angle = PI
	# If out of arc length, consider it out of range and skip
	# DOWN, opposite of player
	var angle_to_center = abs(Vector2.DOWN.angle_to(distance_vector))
	if angle_to_center > hit_angle:
		return false

	entity.velocity = distance_vector.normalized() * max(entity.velocity.length(), 300)
	
	# Fancy hit change attributes
	entity.velocity.y = abs(entity.velocity.y) # Go DOWNward
	entity.modulate.a = 1.0
	entity.z_index = 10
	
	entity.collision_layer = BulletUtils.CollisionMask.TARGET_PLAYER
	entity.damage = 100
	entity.penetration = 100
	
	entity.speed_multiplier += 0.01
	return true
