extends Area2D

@onready var hit_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_hit : AudioStreamPlayer2D = $AudioHit
@onready var audio_swing : AudioStreamPlayer2D = $AudioSwing

var entity_in_area : EntityList = EntityList.new()

var min_time_press : float = 0.1
var time_since_press : float = 0.0
var play_anim : bool = true
var anim_time_per_frame = 0.08
var anim_time = 0.0

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	time_since_press += delta
	anim_time += delta
	if Input.is_action_just_pressed("shoot") and time_since_press >= min_time_press:
		do_hit()

func do_hit() -> void:
	hit_sprite.play("default")
	audio_swing.play()
	time_since_press = 0
	
	entity_in_area.clean_list()
	if entity_in_area.entity_count() > 0:
		audio_hit.play()
		var center_pos = get_parent().position + Vector2(0, 200)
		for entity : Entity in entity_in_area:
			var distance_vector = center_pos - entity.position
			var direction = entity.velocity.bounce(distance_vector.normalized())
			entity.velocity = direction
			entity.collision_layer = BulletUtils.CollisionMask.TARGET_ENEMY
			entity.modulate.a *= 0.5
			entity.z_index -= 10

func _on_area_entered(area: Area2D) -> void:
	if area is Laser:
		return # Dont parry laser
	if area is Entity:
		entity_in_area.add_entity(area)

func _on_area_exited(area: Area2D) -> void:
	if area is Entity:
		entity_in_area.remove_entity(area)
