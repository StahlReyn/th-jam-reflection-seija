class_name Shooter
extends Node2D

@export_category("Unfocus")
@export var unfocus_bullet : PackedScene
@export var unfocus_cd : float = 0.05
@export_category("Focus")
@export var focus_bullet : PackedScene
@export var focus_cd : float = 0.05
@export_category("Layout")
@export var layouts : Array[ShooterLayout]

var position_speed : float = 20.0 ## How fast bullet change position between focus
var cooldown_time : float = 0.0

func _ready() -> void:
	reset_cooldown()
	#position = unfocus_pos

func _physics_process(delta: float) -> void:
	if get_cur_layout() != null:
		visible = true
		cooldown_time -= delta
		process_position(delta)
		if can_shoot():
			do_shoot()
	else:
		visible = false

func can_shoot() -> bool:
	return (
		GameUtils.get_player().can_shoot() 
		and cooldown_time <= 0 
		and Input.is_action_pressed("shoot")
	)

func do_shoot() -> void:
	var bullet_container = GameUtils.get_bullet_container()
	var bullet : Bullet = get_bullet_scene().instantiate()
	bullet.collision_layer = BulletUtils.CollisionMask.TARGET_ENEMY
	bullet.modulate.a = 0.3
	bullet.top_level = true
	bullet.global_position = self.global_position
	bullet_container.add_child(bullet)
	reset_cooldown()

func reset_cooldown() -> void:
	cooldown_time = get_cooldown()

func process_position(delta) -> void:
	position = MathUtils.expDecay(position, get_target_pos(), position_speed, delta)

func get_cur_layout() -> ShooterLayout:
	var cur_highest_layout : ShooterLayout = layouts[0]
	for layout : ShooterLayout in layouts:
		if (layout.min_power <= GameVariables.power 
			and layout.min_power >= cur_highest_layout.min_power):
			cur_highest_layout = layout
	# Double check, if none pass then it pick first one always
	if cur_highest_layout.min_power <= GameVariables.power:
		return cur_highest_layout
	return null
			
func get_target_pos() -> Vector2:
	if Input.is_action_pressed("focus"):
		return get_cur_layout().focus_pos
	return get_cur_layout().unfocus_pos

func get_cooldown() -> float:
	if Input.is_action_pressed("focus") and unfocus_cd != null:
		return focus_cd
	return unfocus_cd

func get_bullet_scene() -> PackedScene:
	if Input.is_action_pressed("focus") and focus_bullet != null:
		return focus_bullet
	return unfocus_bullet
