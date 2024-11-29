extends EntityScript
## On collide with wall, spawns a large laser
## Spawns 4 curvy lasers (stream of bullets)
## Many Circle bullets accelerating upwards (opposite) spread side

static var laser = BulletUtils.scene_dict["laser_basic"]
static var bullet = BulletUtils.scene_dict["circle_medium"]
static var stream = BulletUtils.scene_dict["partial_laser_small"]

static var blend_add = preload("res://data/canvas_material/blend_additive.tres")
static var hit_sound = preload("res://assets/audio/sfx/bullet_big_noisy.wav")
static var audio_laser : AudioStream = preload("res://assets/audio/sfx/laser_modified.wav")
static var remove_on_hit_wall = false

func _ready() -> void:
	super()
	call_deferred("setup")

func _physics_process(delta: float) -> void:
	super(delta)
	parent.set_color(bullet_color())

func setup() -> void:
	parent.connect("hit_wall", _on_hit_wall)
	if parent is Bullet: # Main bullet
		parent.damage = 30

func _on_hit_wall() -> void:
	# The direction of bullets, Default up (as if hit bottom)
	var init_direction = Vector2.UP
	var angle_rotated = init_direction.angle_to(get_target_direction())
	# Major components
	part_laser(angle_rotated)
	part_stream(angle_rotated)
	part_spray(angle_rotated)
	
	if parent.position.x < 0 or parent.position.x > GameUtils.game_area.x: # SIDE WALLS
		parent.velocity = parent.velocity.reflect(Vector2.DOWN)
	if parent.position.y < 0 or parent.position.y > GameUtils.game_area.y: # TOP BOTTOM WALLS
		parent.velocity = parent.velocity.reflect(Vector2.RIGHT)
	
	# Remove self
	if remove_on_hit_wall:
		parent.call_deferred("queue_free")

func get_target_direction() -> Vector2:
	if parent.position.y <= 0: # hit top wall, go down
		return Vector2.DOWN
	elif parent.position.x <= 0: # hit left wall, go right
		return Vector2.RIGHT
	elif parent.position.x >= GameUtils.game_area.x: # hit right wall, go left
		return Vector2.LEFT
	return Vector2.UP # Else go up as default

func part_laser(angle_rotated : float) -> void:
	# laser
	var cur_laser = spawn_laser(laser, parent.position)
	basic_copy(cur_laser, parent)
	set_bullet_style(cur_laser)
	cur_laser.damage = parent.damage * 0.75
	cur_laser.rotation = angle_rotated - PI/2
	cur_laser.target_size.y = 30
	cur_laser.delay_time = 0.0
	cur_laser.laser_active_time = 0.8
	
	# Audio node to laser
	AudioManager.play_audio_2d(audio_laser, parent.global_position)
	
func part_stream(angle_rotated : float) -> void:
	var stream_count : int = 4
	var mid : int = stream_count / 2 # ASSUME Even number, get higher index (4 gives 2)
	for stream_num in range(stream_count):
		var base_amp = 5000
		var side_velocity = 80
		var forward_velocity = -600
		var stream_from_center = stream_num - mid
		if stream_num < mid: # inverse halfway
			base_amp *= -1
			stream_from_center += 1 # offset due to double 0 center
		side_velocity *= stream_from_center # Side velocity based on how far from center
		
		# Initial is UP, then rotated
		var frequency = Vector2(12, 0).rotated(angle_rotated) # Only Width side waves
		var amplitude = Vector2(base_amp, 0).rotated(angle_rotated)
		var phase_offset = Vector2(PI/2, 0).rotated(angle_rotated).abs() # Offset should not inverse
		var base_velocity = Vector2(side_velocity, forward_velocity).rotated(angle_rotated)
		
		for i in range(5):
			var cur_bullet = spawn_bullet(stream, parent.position)
			basic_copy(cur_bullet, parent)
			set_bullet_style(cur_bullet)
			#cur_bullet.modulate.a = 0.3
			cur_bullet.damage = parent.damage * 0.02
			cur_bullet.delay_time = i * 0.05 + 0.1
			cur_bullet.velocity = base_velocity
			cur_bullet.add_behavior_func("wave_move",
				func f(e: Entity, delta: float):
					e.velocity.x += sin(e.active_time * frequency.x + phase_offset.x) * amplitude.x * delta
					e.velocity.y += sin(e.active_time * frequency.y + phase_offset.y) * amplitude.y * delta
			)

func part_spray(angle_rotated : float) -> void:
	# Initial is UP, then rotated. Calculated outside to avoid rotating per every bullet
	var spray_min = Vector2(0, -50).rotated(angle_rotated)
	var spray_max = Vector2(-100, 50).rotated(angle_rotated)
	var spray_accel = Vector2(0, -100).rotated(angle_rotated)
	
	for i in range(16):
		var cur_bullet = spawn_bullet(bullet, parent.position)
		basic_copy(cur_bullet, parent)
		set_bullet_style(cur_bullet)
		cur_bullet.damage = parent.damage * 0.02
		cur_bullet.delay_time = i * 0.03
		cur_bullet.velocity.y = randf_range(spray_min.x, spray_max.x)
		cur_bullet.velocity.x = randf_range(spray_min.y, spray_max.y)
		LF.accel(cur_bullet, spray_accel)

func basic_copy(to_copy: Entity, base: Entity) -> void:
	to_copy.collision_layer = base.collision_layer
	to_copy.collision_mask = base.collision_mask
	to_copy.modulate = base.modulate

func set_bullet_style(bullet: Entity) -> void:
	bullet.material = blend_add
	bullet.set_color(bullet_color())

func bullet_color():
	if parent.collision_layer != BulletUtils.CollisionMask.TARGET_PLAYER:
		return SGBasicBullet.ColorType.ORANGE
	else:
		return SGBasicBullet.ColorType.RED
