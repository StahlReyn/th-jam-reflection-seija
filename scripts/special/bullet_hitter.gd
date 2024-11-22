extends Area2D

@onready var main_collision : CollisionShape2D = $CollisionShape2D
@onready var hit_sprite : AnimatedSprite2D = $SpriteHitSmall
@onready var hit_sprite_large : AnimatedSprite2D = $SpriteHitLarge
@onready var audio_hit : AudioStreamPlayer2D = $AudioHit
@onready var audio_hit_big : AudioStreamPlayer2D = $AudioHitBig
@onready var audio_swing : AudioStreamPlayer2D = $AudioSwing
@onready var progress_bar : TextureProgressBar = $TextureProgressBar
@onready var bar_hit_range : TextureProgressBar = $HitRange
@onready var charge_particles : GPUParticles2D = $ChargeParticles

static var hit_effect : PackedScene = preload("res://data/after_effects/bullet_reflect.tscn")
static var hit_effect_big : PackedScene = preload("res://data/after_effects/bullet_reflect_big.tscn")

var sprite_hit_range_base_width = 256

var entity_in_area : EntityList = EntityList.new()
var entity_hittable_list := []

var min_time_press : float = 0.1
var charge_time : float = 0.0
var play_anim : bool = true

var disable_time : float = 0.0
var whiff_disable_time : float = 0.3
var combo_threshold : int = 30

var hit_radius : float
var hit_angle : float ## Angle from center, UP Vector
var hit_velocity := 500.0
var max_charge := 1.0

var hit_radius_min := 80.0
var hit_radius_max := 120.0
var hit_angle_min := TAU/6
var hit_angle_max := TAU/4
var max_charge_mult := 1.15

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	disable_time -= delta
	if disable_time <= 0.0:
		progress_bar.modulate = Color(Color.WHITE, 0.2)
		bar_hit_range.modulate = Color(Color.WHITE, 0.2)
		process_hitter(delta)
	else:
		progress_bar.modulate = Color(Color.CRIMSON, 0.2)
		bar_hit_range.modulate = Color(Color.CRIMSON, 0.2)
	update_display()

func update_display():
	progress_bar.set_value(charge_time)
	hit_radius = lerp(hit_radius_min, hit_radius_max, charge_time)
	hit_angle = lerp(hit_angle_min, hit_angle_max, charge_time)
		
	if is_max_charge():
		hit_radius *= max_charge_mult
		hit_angle *= max_charge_mult
		progress_bar.modulate.a = 1
		bar_hit_range.modulate.a = 0.15
		charge_particles.emitting = true
	else:
		progress_bar.modulate.a = 0.5
		bar_hit_range.modulate.a = 0.1
		charge_particles.emitting = false
	
	main_collision.shape.radius = hit_radius
	var scale_sprite = 2 * hit_radius / sprite_hit_range_base_width
	bar_hit_range.scale = Vector2(scale_sprite, scale_sprite)
	bar_hit_range.value = hit_angle

func process_hitter(delta):
	if Input.is_action_pressed("shoot"):
		charge_time += delta
		charge_time = minf(charge_time, max_charge)
	if Input.is_action_just_released("shoot"):
		#prints("released, charge time:", charge_time)
		do_hit()
		charge_time = 0

func do_hit() -> void:
	if is_max_charge():
		hit_sprite_large.play("default")
	else:
		hit_sprite.play("default")
	entity_in_area.clean_list()
	entity_hittable_list = []
	
	for entity : Entity in entity_in_area:
		var angle_to_center = abs(Vector2.UP.angle_to(entity.position - get_parent().position))
		if angle_to_center <= hit_angle:
			entity_hittable_list.append(entity)
	
	var hit_count = entity_hittable_list.size()
	if hit_count > 0: # HIT BULLET
		if is_max_charge() and hit_count >= combo_threshold: # Combo Effect
			audio_hit_big.play()
			var popup := TextPopup.create_popup("COMBO: " + str(hit_count), get_parent().global_position)
			popup.modulate = Color.YELLOW
			GameUtils.freeze_frame(0.2, 0.3)
			GameUtils.get_game_view().get_parent().cur_shake_strength = 20.0
		else:
			audio_hit.play()
		for entity : Entity in entity_hittable_list: # Bullet Changes
			var direction = (entity.position - get_parent().position).normalized()
			entity.velocity = direction * hit_velocity * (charge_time + 1)
			# Hitted Entity change attributes
			entity.modulate.a = 0.3
			entity.z_index = -10
			hit_entity_property(entity)
			if is_max_charge():
				entity.velocity *= 2
				AfterEffect.add_effect(hit_effect_big, entity.global_position)
			else:
				AfterEffect.add_effect(hit_effect, entity.global_position)
	else: # WHIFFED - NO BULLET
		audio_swing.play()
		var popup := TextPopup.create_popup("WHIFFED", get_parent().global_position)
		popup.modulate = Color.LIGHT_CORAL
		disable_time = whiff_disable_time

func hit_entity_property(entity):
	var power_mult = (GameVariables.power / 100) + 1
	var charge_mult = charge_time + 1
	var total_mult = charge_mult * power_mult
	
	if entity is Bullet:
		entity.collision_layer = BulletUtils.CollisionMask.TARGET_ENEMY
		entity.damage = floori(entity.damage * total_mult)
		if is_max_charge():
			entity.damage *= 2
		GameVariables.point_value += entity.damage
	elif entity is Character:
		entity.collision_layer = BulletUtils.CollisionMask.TARGET_ENEMY
		entity.collision_mask = BulletUtils.CollisionMask.TARGET_PLAYER
		entity.collision_damage = floori(charge_time * total_mult * 2)
		if is_max_charge():
			entity.collision_damage *= 2
		GameVariables.point_value += entity.collision_damage
	
func is_max_charge() -> bool:
	return charge_time >= max_charge

func area_can_parry(area: Area2D) -> bool:
	return (
		(area is Bullet and not area is Laser) 
		or (area is Enemy and area.can_be_parried)
	)

func _on_area_entered(area: Area2D) -> void:
	if area_can_parry(area):
		entity_in_area.add_entity(area)

func _on_area_exited(area: Area2D) -> void:
	entity_in_area.remove_entity(area)
