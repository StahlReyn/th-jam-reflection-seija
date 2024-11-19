extends EntityScript
## On collide with wall, spawns a large laser
## Spawns 4 curvy lasers (stream of bullets)
## Many Circle bullets accelerating upwards (opposite) spread side

@onready var laser = BulletUtils.scene_dict["laser_basic"]
@onready var bullet = BulletUtils.scene_dict["circle_medium"]
@onready var stream = BulletUtils.scene_dict["partial_laser_medium_subtle"]

@onready var blend_add = preload("res://data/canvas_material/blend_additive.tres")
@onready var hit_sound = preload("res://assets/audio/sfx/bullet_big_noisy.wav")

@export var remove_on_hit_wall = true

func _ready() -> void:
	super()
	call_deferred("setup")
	print("READY LILY")

func _physics_process(delta: float) -> void:
	super(delta)

func setup() -> void:
	parent.connect("hit_wall", _on_hit_wall)
	if parent is Bullet: # Main bullet
		parent.damage = 100
		parent.penetration = 100

func _on_hit_wall() -> void:
	print("Lily Hit Wall")
	# The direction of bullets, Default up (as if hit bottom)
	var init_direction = Vector2.UP
	var target_direction = get_target_direction()
	var angle_rotated = init_direction.angle_to(target_direction)
	# Major components
	part_laser(angle_rotated)
	part_stream(angle_rotated)
	part_spray(angle_rotated)
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
	cur_laser.damage = 200
	cur_laser.rotation = angle_rotated - PI/2 #target_direction.angle()
	cur_laser.target_size.y = 100
	cur_laser.delay_time = 0.0
	cur_laser.laser_active_time = 2.0
	cur_laser.switch_state(Laser.State.STATIC, 2.0)
	
	# Audio node to laser
	var audio_node = AudioStreamPlayer2D.new()
	audio_node.set_stream(hit_sound)
	cur_laser.add_child(audio_node)
	audio_node.play()
	
func part_stream(angle_rotated : float) -> void:
	var stream_count : int = 4
	var mid : int = stream_count / 2 # ASSUME Even number, get higher index (4 gives 2)
	for stream_num in range(stream_count):
		var base_amp = 200
		var side_velocity = 180
		var forward_velocity = -600
		var stream_from_center = stream_num - mid
		if stream_num < mid: # inverse halfway
			base_amp *= -1
			stream_from_center += 1 # offset due to double 0 center
		side_velocity *= stream_from_center # Side velocity based on how far from center
		
		# Initial is UP, then rotated
		var frequency = Vector2(3, 0).rotated(angle_rotated) # Only Width side waves
		var amplitude = Vector2(base_amp, 0).rotated(angle_rotated)
		var phase_offset = Vector2(PI/2, 0).rotated(angle_rotated).abs() # Offset should not inverse
		var base_velocity = Vector2(side_velocity, forward_velocity).rotated(angle_rotated)
		
		for i in range(60):
			var cur_bullet = spawn_bullet(stream, parent.position)
			basic_copy(cur_bullet, parent)
			set_bullet_style(cur_bullet)
			cur_bullet.modulate.a = 0.3
			cur_bullet.delay_time = i * 0.02 + 0.1
			
			cur_bullet.add_script_node(
				MSVelocitySine.new(
					frequency, amplitude, phase_offset, base_velocity
				)
			)

func part_spray(angle_rotated : float) -> void:
	# Initial is UP, then rotated. Calculated outside to avoid rotating per every bullet
	var spray_min = Vector2(0, -150).rotated(angle_rotated)
	var spray_max = Vector2(-150, 150).rotated(angle_rotated)
	var spray_accel = Vector2(0, -150).rotated(angle_rotated)
	
	for i in range(40):
		var cur_bullet = spawn_bullet(bullet, parent.position)
		basic_copy(cur_bullet, parent)
		set_bullet_style(cur_bullet)
		cur_bullet.delay_time = i * 0.02
		cur_bullet.velocity.y = randf_range(spray_min.x, spray_max.x)
		cur_bullet.velocity.x = randf_range(spray_min.y, spray_max.y)
		cur_bullet.add_script_node(
			MSAcceleration.new(spray_accel)
		)

func basic_copy(to_copy: Entity, base: Entity) -> void:
	to_copy.collision_layer = base.collision_layer
	to_copy.collision_mask = base.collision_mask
	to_copy.modulate = base.modulate

func set_bullet_style(bullet: Entity) -> void:
	bullet.material = blend_add
	bullet.set_color(SGBasicBullet.ColorType.RED)
