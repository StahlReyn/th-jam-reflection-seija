class_name Bullet
extends Entity

static var bullet_hit_effect : PackedScene = preload("res://data/after_effects/bullet_hit_basic.tscn")
static var bullet_remove_effect : PackedScene = preload("res://data/after_effects/bullet_remove.tscn")
static var bullet_spawn_effect : PackedScene = preload("res://data/after_effects/bullet_remove.tscn")

static var DISPLAY_DAMAGE = true

@export_group("Visuals")
@export var main_sprite : Sprite2D
@export var bullet_hit_effect_scene : PackedScene
@export_group("Gameplay")
@export var damage : int = 1
@export var damage_loss_mult : float = 1.0 ## 1 is usual, 0 is damage is never lost

var do_spawn_effect : bool = true ## This will make bullet do slight fade and scale-in transition
var prev_scale : Vector2
var prev_alpha : float

const INIT_SPAWN_SCALE := 3.0
const SPAWN_SCALE_SPEED := 20.0
const SPAWN_OPACITY_SPEED := 5.0

func _init() -> void:
	super()
	
func _ready() -> void:
	super()
	prev_alpha = main_sprite.modulate.a
	prev_scale = main_sprite.scale
	if do_spawn_effect:
		main_sprite.modulate.a = 0
		main_sprite.scale = prev_scale * INIT_SPAWN_SCALE

func _physics_process(delta: float) -> void:
	super(delta)
	if do_spawn_effect:
		main_sprite.modulate.a = MathUtils.lerp_smooth(main_sprite.modulate.a, prev_alpha, SPAWN_OPACITY_SPEED, delta)
		main_sprite.scale = MathUtils.lerp_smooth(main_sprite.scale, prev_scale, SPAWN_SCALE_SPEED, delta)

func do_damage_loss(value : int) -> void:
	self.damage -= value * damage_loss_mult
	if DISPLAY_DAMAGE and value != 0:
		TextPopup.create_popup_damage(value, global_position)
	
func on_hit(entity : Entity) -> void:
	super(entity)
	AfterEffect.add_effect(bullet_hit_effect, global_position)
	if damage <= 0: # Damage is reduced from Character side
		do_remove()

func do_remove(remove_effect : bool = false) -> void:
	super(remove_effect)

func set_color(type: int = 0, variant: int = 0) -> void:
	if main_sprite is SGBasicBullet:
		main_sprite.set_color(type, variant)
	else:
		printerr("Cannot set color to non-sprite group bullets")

func get_color() -> int:
	if main_sprite is SGBasicBullet:
		return main_sprite.frame_coords.x
	else:
		printerr("Cannot set color to non-sprite group bullets")
		return 0
	
func set_random_color(variant: int = 0) -> void:
	if main_sprite is SGBasicBullet:
		main_sprite.set_random_color(variant)
	else:
		printerr("Cannot set color to non-sprite group bullets")
