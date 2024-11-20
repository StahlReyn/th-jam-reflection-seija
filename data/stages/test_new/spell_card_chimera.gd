extends SpellCard
# Based on Nue Houjuu's spellcard "Danmaku Chimera"
# Spawn a line of line-bullet all around in circle,
# Bullet changes to circle-bullet, 
# Bullet rotates around the center/boss, swapping between left/right
# Bullet changes back to line-bullet, then continue outward trajectory
# Continue on loop 

enum State {
	IDLE,
	SPAWNING,
	SPINNING,
	ENDING,
	ENDED,
}

@onready var enemy_boss : PackedScene = preload("res://data/enemies/bosses/boss_nue_houjuu.tscn")

@onready var bullet_line : PackedScene = BulletUtils.scene_dict["partial_laser_small"]
@onready var bullet_circle : PackedScene = BulletUtils.scene_dict["circle_medium"]

@onready var audio_laser : AudioStream = preload("res://assets/audio/sfx/laser_modified.wav")

@onready var blend_add = preload("res://data/canvas_material/blend_additive.tres")

var boss : Enemy
var state : int = State.IDLE
var state_timer : float = 3.0

var boss_target_position : Vector2 = Vector2(385, 385)

var shot_count_1 : int = 0
var angle_offset : float = 0

var timer_spawn : Timer
var timer_spawn_count : int = 0

# Pattern Variables
var bullet_base_speed : float = 350
var line_count : int = 16
var spin_time : float = 2.0
var spawn_time : float = 1.0
var spin_speed : float = 0.19 # This is more of multiplier. Speed is also depend on distance

func _ready() -> void:
	super()
	start_section()
	timer_spawn = timer_setup(timer_spawn_timeout)
	switch_state(State.IDLE, 3.0)
	boss = spawn_enemy(enemy_boss, Vector2(385,-50))
	boss.do_check_despawn = false
	boss.remove_on_death = false
	boss.remove_on_chapter_change = false
	boss.mhp = 1000;
	boss.reset_hp()
	boss.drop_power = 40
	boss.drop_point = 40
	boss.drop_life_piece = 3

func _physics_process(delta: float) -> void:
	super(delta)
	state_timer -= delta
	process_state()
	if is_instance_valid(boss):
		#print(boss_target_position)
		boss.position = lerp(boss.position, boss_target_position, delta * 2)
		if boss.hp <= 0 and can_switch_end():
			switch_state(State.ENDING, 2.0)
	if time_active >= duration and can_switch_end():
		switch_state(State.ENDING, 2.0)

func timer_setup(function: Callable) -> Timer:
	var timer = Timer.new()
	timer.connect("timeout", function)
	add_child(timer)
	return timer
	
func end_condition() -> bool:
	return state == State.ENDED

func can_switch_end() -> bool:
	return not (state == State.ENDING or state == State.ENDED)

func end_section() -> void:
	super()
	
func start_section():
	super()
	section_name = "Nue Sign \"Danmaku Chimera\""
	total_bonus = 20000000
	duration = 50.0
	update_displayer()

func move_boss_random():
	boss_target_position = Vector2(
		randf_range(200,600),
		randf_range(160,260)
	)

func timer_spawn_timeout():
	var bullet_list = BulletUtils.spawn_circle(
			bullet_line,
			boss.position,
			bullet_base_speed,
			line_count,
			angle_offset,
		)
	for bullet : Bullet in bullet_list:
		bullet.set_meta("center_pos", boss.position)
		bullet.set_meta("circle_count", timer_spawn_count % 2)
		bullet.set_color(SGBasicBullet.ColorType.BLUE)
		set_bullet_style(bullet)
	timer_spawn_count += 1
	if timer_spawn_count >= 12:
		move_boss_random()
		timer_spawn.paused = true
	else:
		timer_spawn.start(0.07)
	
func spawn_bullet_line():
	angle_offset = (shot_count_1 % 2) * PI/16
	timer_spawn_count = 0
	timer_spawn.paused = false
	timer_spawn.start(0.01)
	shot_count_1 += 1

func set_bullet_style(bullet: Entity) -> void:
	bullet.despawn_padding = 300  # increase padding as rotate move offscreen far
	bullet.material = blend_add
	bullet.set_color(SGBasicBullet.ColorType.BLUE)

func process_state() -> void:
	if state_timer < 0:
		match state:
			State.IDLE: 
				switch_state(State.SPAWNING, spawn_time)
			State.SPAWNING:
				switch_state(State.SPINNING, spin_time)
			State.SPINNING:
				switch_state(State.SPAWNING, spawn_time)
			State.ENDING:
				switch_state(State.ENDED, 5.0)

static func bullet_change_path(position, spin_speed, circ_times):
	return func f(entity:Entity):
		var distance = entity.position.distance_to(position)
		var rotation = 0.4 * PI
		if circ_times % 2 == 1:
			rotation *= -1
		var direction = entity.position.direction_to(position).rotated(rotation)
		return direction * spin_speed * distance

func change_path() -> void:
	print("CHIMERA - Change Path")
	var center_pos
	var circle_count
	var new_bullet
	var distance
	var direction
	for bullet in GameUtils.get_bullet_list():
		center_pos = bullet.get_meta("center_pos")
		circle_count = bullet.get_meta("circle_count")
		bullet.call_deferred("queue_free")
		
		new_bullet = spawn_bullet(BulletUtils.scene_dict["circle_medium"], bullet.position)
		new_bullet.set_meta("center_pos", center_pos)
		new_bullet.set_meta("circle_count", circle_count)
		set_bullet_style(new_bullet)
		
		distance = new_bullet.position.distance_to(center_pos)
		if circle_count % 2 == 0:
			direction = new_bullet.position.direction_to(center_pos).rotated(0.4*PI)
		else:
			direction = new_bullet.position.direction_to(center_pos).rotated(-0.4*PI)
		new_bullet.velocity = direction * spin_speed * distance

func continue_bullets() -> void:
	print("CHIMERA - Continue Bullet")
	var center_pos
	var circle_count
	var new_bullet
	var direction
	for bullet in GameUtils.get_bullet_list():
		center_pos = bullet.get_meta("center_pos")
		circle_count = bullet.get_meta("circle_count")
		bullet.call_deferred("queue_free")
		
		new_bullet = spawn_bullet(BulletUtils.scene_dict["partial_laser_small"], bullet.position)
		new_bullet.set_meta("center_pos", center_pos)
		new_bullet.set_meta("circle_count", circle_count)
		set_bullet_style(new_bullet)
		
		direction = new_bullet.position.direction_to(center_pos)
		new_bullet.velocity = -direction * bullet_base_speed
		new_bullet.do_check_despawn = true

func switch_state(state: int, state_timer: float):
	self.state = state
	self.state_timer = state_timer
	on_state_change(state)

func on_state_change(state: int):
	match state:
		State.SPAWNING:
			boss.position = boss_target_position
			continue_bullets()
			spawn_bullet_line()
			AudioManager.play_audio(audio_laser)
		State.SPINNING:
			change_path()
		State.ENDING:
			timer_spawn.paused = true
			if is_instance_valid(boss):
				boss.do_check_despawn = true
			boss_target_position = Vector2(385,-200)
			enabled = false
			clear_bullets()
