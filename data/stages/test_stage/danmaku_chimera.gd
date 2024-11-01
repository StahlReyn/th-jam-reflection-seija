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

@onready var enemy_boss : PackedScene = EnemyUtils.scene_dict["lesser_fairy"]

@onready var bullet_line : PackedScene = BulletUtils.scene_dict["partial_laser_small"]
@onready var bullet_circle : PackedScene = BulletUtils.scene_dict["circle_medium"]

@onready var audio_shoot : AudioStream = preload("res://assets/audio/sfx/hit_noise_fade.wav")

@onready var script_expiry : GDScript = preload("res://data/movement/common/expiry_timer.gd")
@onready var blend_add = preload("res://data/canvas_material/blend_additive.tres")

 # Two sets as one goes another direction
var chimera_list_1 : EntityList = EntityList.new()
var chimera_list_2 : EntityList = EntityList.new()

var boss : Enemy
var state : int = State.IDLE
var state_timer : float = 3.0

var boss_target_position : Vector2 = Vector2(385, 385)

var shot_count_1 : int = 0

# Pattern Variables
var bullet_base_speed : float = 320
var line_count : int = 16
var spin_time : float = 2.0
var spawn_time : float = 1.0
var spin_speed : float = 0.19 # This is more of multiplier. Speed is also depend on distance

func _ready() -> void:
	super()
	start_section()
	switch_state(State.IDLE, 3.0)
	boss = spawn_enemy(enemy_boss, Vector2(385,-50))
	boss.do_check_despawn = false
	boss.remove_on_death = false
	boss.mhp = 1000;
	boss.reset_hp()
	boss.drop_power = 40
	boss.drop_point = 20
	boss.drop_life_piece = 1

func _physics_process(delta: float) -> void:
	super(delta)
	state_timer -= delta
	process_state()
	if is_instance_valid(boss):
		#print(boss_target_position)
		boss.position = lerp(boss.position, boss_target_position, delta * 2)
		if boss.hp < 0 and can_switch_end():
			switch_state(State.ENDING, 2.0)
	if time_active >= duration and can_switch_end():
		switch_state(State.ENDING, 2.0)

func end_condition() -> bool:
	return state == State.ENDED

func can_switch_end() -> bool:
	return not (state == State.ENDING or state == State.ENDED)

func end_section() -> void:
	super()
	
func start_section():
	super()
	section_name = "Nue Sign \"Danmaku Chimera\""
	total_bonus = 25000000
	duration = 50.0
	update_displayer()

func spawn_bullet_line():
	var angle_offset = (shot_count_1 % 2) * PI/16
	for circle_i in range(10):
		var bullet_list = BulletUtils.spawn_circle(
			bullet_line,
			boss.position,
			bullet_base_speed,
			line_count,
			angle_offset,
		)
		for i in bullet_list.size():
			var bullet : Bullet = bullet_list[i]
			if circle_i % 2 == 0:
				chimera_list_1.add_entity(bullet)
			else:
				chimera_list_2.add_entity(bullet)
			bullet.set_color(SGBasicBullet.ColorType.BLUE)
			bullet.delay_time = circle_i * 0.1
			set_bullet_style(bullet)
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

func stop_bullets() -> void:
	print("CHIMERA - Stop Bullet")
	
	chimera_list_1.clean_list()
	chimera_list_1.replace_entities(bullet_circle)
	for entity : Entity in chimera_list_1:
		entity.velocity = Vector2(0,0)
		entity.do_check_despawn = false
		set_bullet_style(entity)
	
	chimera_list_2.clean_list()
	chimera_list_2.replace_entities(bullet_circle)
	for entity : Entity in chimera_list_2:
		entity.velocity = Vector2(0,0)
		entity.do_check_despawn = false
		set_bullet_style(entity)

func change_path() -> void:
	chimera_list_1.clean_list()
	for entity : Entity in chimera_list_1:
		var distance = entity.position.distance_to(boss.position)
		var direction = entity.position.direction_to(boss.position).rotated(0.4*PI)
		entity.velocity = direction * spin_speed * distance
	chimera_list_2.clean_list()
	for entity : Entity in chimera_list_2:
		var distance = entity.position.distance_to(boss.position)
		var direction = entity.position.direction_to(boss.position).rotated(-0.4*PI)
		entity.velocity = direction * spin_speed * distance

func continue_bullets() -> void:
	print("CHIMERA - Continue Bullet")
	chimera_list_1.clean_list()
	chimera_list_1.replace_entities(bullet_line)
	for entity : Entity in chimera_list_1:
		var direction = entity.position.direction_to(boss.position)
		entity.velocity = -direction * bullet_base_speed
		entity.do_check_despawn = true
		set_bullet_style(entity)
	
	chimera_list_2.clean_list()
	chimera_list_2.replace_entities(bullet_line)
	for entity : Entity in chimera_list_2:
		var direction = entity.position.direction_to(boss.position)
		entity.velocity = -direction * bullet_base_speed
		entity.do_check_despawn = true
		set_bullet_style(entity)

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
		State.SPINNING:
			stop_bullets()
			change_path()
		State.ENDING:
			if is_instance_valid(boss):
				boss.do_check_despawn = true
			boss_target_position = Vector2(385,-200)
			enabled = false
			clear_bullets()

#func rotate_around_point(point1: Vector2, point2: Vector2, angle: float) -> Vector2:
	#var diff = point1 - point2
	#return diff.rotated(angle) + point2
