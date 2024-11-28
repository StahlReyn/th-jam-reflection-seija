extends EntityScript
## On collide with wall, spawns a large laser
## Spawns 4 curvy lasers (stream of bullets)
## Many Circle bullets accelerating upwards (opposite) spread side

static var bullet_splinter = BulletUtils.scene_dict["crystal_small"]
static var hit_sound = preload("res://assets/audio/sfx/bullet_big_noisy.wav")

@export var remove_on_hit_wall = true
@export var rotation_speed = 1.0

func _ready() -> void:
	super()
	call_deferred("setup")

func _physics_process(delta: float) -> void:
	super(delta)
	parent.rotation += rotation_speed * delta

func setup() -> void:
	parent.connect("hit_wall", _on_hit_wall)
	parent.connect("death", _on_hit_wall)

func _on_hit_wall() -> void:
	# The direction of bullets, Default up (as if hit bottom)
	var angle_rotated = parent.rotation + TAU/12
	# Major components
	part_splinter(angle_rotated)
	# Remove self
	if remove_on_hit_wall:
		# Add so Chapter enemy count can count properly
		if parent is Enemy:
			GameVariables.shoot_down += 1
			parent.do_remove()

func part_splinter(angle_rotated : float) -> void:
	var count = 3
	var mid = floor(count/2)
	var angle_interval = TAU/6
	if parent is Enemy:
		var multiplier = 1 + 0.2 * (parent.collision_damage / parent.mhp)
		for i in range(6):
			var angle = ((i-mid) * angle_interval) + angle_rotated
			var bullet_list = BulletUtils.spawn_arc_arrow(bullet_splinter, parent.position, 300, 6, TAU/240, angle, 0.2)
			for bullet in bullet_list:
				basic_copy(bullet, parent)
				bullet.set_color(SGBasicBullet.ColorType.BLUE)
				bullet.velocity *= multiplier
				bullet.damage *= multiplier

func basic_copy(to_copy: Entity, base: Entity) -> void:
	to_copy.collision_layer = base.collision_layer
	to_copy.collision_mask = base.collision_mask
	to_copy.modulate = base.modulate
