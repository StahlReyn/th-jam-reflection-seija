class_name Bullet
extends Entity

static var bullet_hit_effect : PackedScene = preload("res://data/after_effects/bullet_hit_basic.tscn")
static var bullet_remove_effect : PackedScene = preload("res://data/after_effects/bullet_remove.tscn")
static var bullet_spawn_effect : PackedScene = preload("res://data/after_effects/bullet_remove.tscn")

@export_group("Visuals")
@export var main_sprite : Sprite2D
@export var bullet_hit_effect_scene : PackedScene
@export var rotation_based_on_velocity : bool = true
@export_group("Gameplay")
@export var damage : int = 1
@export var penetration : int = 1

func _init() -> void:
	super()
	
func _ready() -> void:
	super()
	# Placeholder spawn effect
	# AfterEffect.add_effect(bullet_spawn_effect, global_position)

func _physics_process(delta: float) -> void:
	super(delta)

func process_movement(delta) -> void:
	super(delta)
	if rotation_based_on_velocity and velocity != Vector2.ZERO:
		rotation = velocity.angle()

func on_hit():
	super()
	AfterEffect.add_effect(bullet_hit_effect, global_position)
	if hit_count >= penetration:
		do_remove()

func do_remove(remove_effect : bool = false) -> void:
	super(remove_effect)

func set_color(type: int = 0, variant: int = 0) -> void:
	if main_sprite is SpriteGroupBasicBullet:
		main_sprite.set_color(type, variant)
	else:
		printerr("Cannot set color to non-sprite group bullets")

func get_color() -> int:
	if main_sprite is SpriteGroupBasicBullet:
		return main_sprite.frame_coords.x
	else:
		printerr("Cannot set color to non-sprite group bullets")
		return 0
	
func set_random_color(variant: int = 0) -> void:
	if main_sprite is SpriteGroupBasicBullet:
		main_sprite.set_random_color(variant)
	else:
		printerr("Cannot set color to non-sprite group bullets")
