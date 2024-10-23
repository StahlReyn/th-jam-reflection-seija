extends Area2D

@onready var main_collision : CollisionShape2D = $CollisionShape2D
@onready var hit_sprite : AnimatedSprite2D = $SpriteHitSmall
@onready var hit_sprite_large : AnimatedSprite2D = $SpriteHitLarge
@onready var audio_hit : AudioStreamPlayer2D = $AudioHit
@onready var audio_swing : AudioStreamPlayer2D = $AudioSwing
@onready var progress_bar : TextureProgressBar = $TextureProgressBar
@onready var charge_particles : GPUParticles2D = $ChargeParticles

var entity_in_area : EntityList = EntityList.new()

var min_time_press : float = 0.1
var time_since_press : float = 0.0
var charge_time : float = 0.0
var play_anim : bool = true
var anim_time_per_frame = 0.08
var anim_time = 0.0

var max_charge = 2.0

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	time_since_press += delta
	anim_time += delta
	if Input.is_action_pressed("shoot"):
		charge_time += delta
		charge_time = minf(charge_time, max_charge)
	if Input.is_action_just_released("shoot"):
		#prints("released, charge time:", charge_time)
		do_hit()
		charge_time = 0
	
	progress_bar.set_value(charge_time)
	if is_max_charge():
		progress_bar.modulate.a = 1
		main_collision.shape.size = Vector2(240, 200)
		charge_particles.emitting = true
	else:
		progress_bar.modulate.a = 0.5
		main_collision.shape.size = Vector2(130, 100)
		charge_particles.emitting = false

func do_hit() -> void:
	if is_max_charge():
		hit_sprite_large.play("default")
	else:
		hit_sprite.play("default")
	audio_swing.play()
	time_since_press = 0
	
	entity_in_area.clean_list()
	if entity_in_area.entity_count() > 0:
		audio_hit.play()
		var center_pos = get_parent().position #+ Vector2(0, 300)
		for entity : Entity in entity_in_area:
			if entity is Bullet:
				var distance_vector = center_pos - entity.position
				#var direction = entity.velocity.bounce(distance_vector.normalized())
				#entity.velocity = direction * (charge_time + 1)
				entity.velocity = -distance_vector.normalized() * 500 * (charge_time + 1)
				# Fancy hit change attributes
				entity.velocity.y = -abs(entity.velocity.y) # Go upward
				entity.collision_layer = BulletUtils.CollisionMask.TARGET_ENEMY
				entity.modulate.a = 0.5
				entity.z_index = -10
				entity.damage += floori(charge_time * 10)
				entity.penetration += floori(charge_time * 5)
				if is_max_charge():
					entity.damage *= 2
					entity.penetration *= 2

func is_max_charge() -> bool:
	return charge_time >= max_charge
	
func _on_area_entered(area: Area2D) -> void:
	if area is Laser:
		return # Dont parry laser
	if area is Bullet:
		#print("Bullet Entered")
		entity_in_area.add_entity(area)

func _on_area_exited(area: Area2D) -> void:
	if area is Bullet:
		#print("Bullet Exited")
		entity_in_area.remove_entity(area)
