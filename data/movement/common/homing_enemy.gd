extends MovementScript

@export var bullet_speed : float = 1000.0
@export var rotation_speed : float = 10.0

var cur_target_enemy : Enemy

func _ready() -> void:
	cur_target_enemy = get_enemy_target()
	#if parent != null:
	#	parent.velocity = parent.velocity.normalized() * bullet_speed

func _physics_process(delta: float) -> void:
	if cur_target_enemy == null:
		cur_target_enemy = get_enemy_target()
	if parent is Bullet:
		if parent != null and cur_target_enemy != null:
			var target_angle = parent.global_position.angle_to_point(cur_target_enemy.global_position)
			var prev_angle = parent.velocity.angle()
			var result_angle = lerp_angle(prev_angle, target_angle, delta * rotation_speed)
			parent.velocity = Vector2.from_angle(result_angle) * bullet_speed

func process_movement(delta: float) -> void:
	pass

func get_enemy_target() -> Enemy:
	var enemy_list = GameUtils.get_enemy_list()
	var cur_enemy
	for enemy in enemy_list:
		if enemy is Enemy:
			if cur_enemy == null:
				cur_enemy = enemy
			# Get enemy with largest y, Lowest
			if enemy.position.y > cur_enemy.position.y:
				cur_enemy = enemy
	return cur_enemy
