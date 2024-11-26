extends EntityScript
## On collide with wall, spawns a large laser
## Spawns 4 curvy lasers (stream of bullets)
## Many Circle bullets accelerating upwards (opposite) spread side

static var laser = BulletUtils.scene_dict["laser_basic"]
static var bullet_circle = BulletUtils.scene_dict["circle_medium"]
static var stream = BulletUtils.scene_dict["partial_laser_small"]

static var blend_add = preload("res://data/canvas_material/blend_additive.tres")
static var hit_sound = preload("res://assets/audio/sfx/bullet_big_noisy.wav")

@export var remove_on_hit_wall = true

func _ready() -> void:
	super()
	call_deferred("setup")

func _physics_process(delta: float) -> void:
	super(delta)

func setup() -> void:
	parent.connect("hit_wall", _on_hit_wall)
	if parent is Bullet: # Main bullet
		parent.damage = 200

func _on_hit_wall() -> void:
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
	cur_laser.damage = 100
	cur_laser.rotation = angle_rotated - PI/2 #target_direction.angle()
	cur_laser.target_size.y = 25
	cur_laser.delay_time = 0.0
	cur_laser.laser_active_time = 0.5
	cur_laser.switch_state(Laser.State.STATIC, 0.5)
	
	# Audio node to laser
	var audio_node = AudioStreamPlayer2D.new()
	audio_node.set_stream(hit_sound)
	cur_laser.add_child(audio_node)
	audio_node.play()
	
func part_stream(angle_rotated : float) -> void:
	var alpha_value = 0.3 * parent.modulate.a
	var main_angle = angle_rotated - PI/2 + PI/24
	for i in range(20):
		var bullet_list = BulletUtils.spawn_arc_arrow(
			stream, parent.position, 200, 7, PI/12, main_angle, 1.0
		)
		for bullet in bullet_list:
			basic_copy(bullet, parent)
			set_bullet_style(bullet)
			bullet.modulate.a = alpha_value
			bullet.delay_time = i * 0.02 + 0.1
			bullet.do_spawn_effect = false
			bullet.add_velocity_func(en_accel(bullet.velocity * 4))

func part_spray(angle_rotated : float) -> void:
	# Initial is UP, then rotated. Calculated outside to avoid rotating per every bullet
	var spray_min = Vector2(0, -100).rotated(angle_rotated)
	var spray_max = Vector2(-100, 100).rotated(angle_rotated)
	var spray_accel = Vector2(0, -100).rotated(angle_rotated)
	
	for i in range(20):
		var cur_bullet = spawn_bullet(bullet_circle, parent.position)
		basic_copy(cur_bullet, parent)
		set_bullet_style(cur_bullet)
		cur_bullet.delay_time = i * 0.02
		cur_bullet.velocity.y = randf_range(spray_min.x, spray_max.x)
		cur_bullet.velocity.x = randf_range(spray_min.y, spray_max.y)
		cur_bullet.add_velocity_func(en_accel(spray_accel))

func basic_copy(to_copy: Entity, base: Entity) -> void:
	to_copy.collision_layer = base.collision_layer
	to_copy.collision_mask = base.collision_mask
	to_copy.modulate = base.modulate

static func set_bullet_style(bullet: Entity) -> void:
	bullet.material = blend_add
	bullet.set_color(SGBasicBullet.ColorType.BLUE)
