extends Node

static var scene_dict : Dictionary = {
	# Bullets
	"circle_small" = preload("res://data/bullets/basic/circle_small.tscn"),
	"circle_medium" = preload("res://data/bullets/basic/circle_medium.tscn"),
	"circle_large" = preload("res://data/bullets/basic/circle_large.tscn"),
	"circle_border" = preload("res://data/bullets/basic/circle_border.tscn"),
	"circle_small_cross" = preload("res://data/bullets/basic/circle_small_cross.tscn"),
	"ellipse_small" = preload("res://data/bullets/basic/ellipse_small.tscn"),
	"crystal_small" = preload("res://data/bullets/basic/crystal_small.tscn"),
	"talisman" = preload("res://data/bullets/basic/talisman.tscn"),
	"arrow" = preload("res://data/bullets/basic/arrow.tscn"),
	"spike" = preload("res://data/bullets/basic/spike.tscn"),
	"knife" = preload("res://data/bullets/basic/knife.tscn"),
	"bullet" = preload("res://data/bullets/basic/bullet.tscn"),
	"star_small" = preload("res://data/bullets/basic/star_small.tscn"),
	# Partial Lasers
	"partial_laser_small" = preload("res://data/bullets/basic/partial_laser_small.tscn"),
	"partial_laser_medium" = preload("res://data/bullets/basic/partial_laser_medium.tscn"),
	"partial_laser_medium_subtle" = preload("res://data/bullets/basic/partial_laser_medium_subtle.tscn"),
	# Lasers
	"laser_basic" = preload("res://data/bullets/laser/laser_basic.tscn"),
}

enum CollisionMask {
	TARGET_PLAYER = 4,
	TARGET_ENEMY = 8,
}
	
static func spawn_circle(bullet_scene: PackedScene, pos: Vector2, speed: float, count: int, angle_offset: float = 0) -> Array[Bullet]:
	var direction : Vector2 = Vector2.ZERO
	var bullet : Bullet
	var bullet_list : Array[Bullet] = []
	var angle_per_shot : float = TAU / count
	for i in range(count):
		direction = Vector2.from_angle(angle_per_shot * i + angle_offset)
		bullet = ModScript.spawn_bullet(bullet_scene, pos)
		bullet.velocity = direction * speed
		bullet_list.append(bullet)
	return bullet_list

static func spawn_circle_packed(bullet_scene: PackedScene, pos: Vector2, velocity: Vector2, count: int, radius : int, angle_offset: float = 0, layer : int = 1, offset_per_layer : float = 0.0):
	var bullet_list : Array[Bullet] = []
	for i in range(layer):
		var bullet_list_ring = BulletUtils.spawn_circle(
			bullet_scene, # Bullet to spawn
			pos, # Position
			1, # Speed - Set to 1 which is just normalized direction
			count, # Count
			angle_offset + (i * offset_per_layer), # Offset rad
		)
		for bullet in bullet_list_ring:
			# Velocity is direction initially due to 1
			var ratio = float(i+1)/float(layer)
			bullet.position += bullet.velocity * radius * ratio
			bullet.velocity = velocity
			bullet_list.append(bullet)
	return bullet_list

static func spawn_arc(bullet_scene: PackedScene, pos: Vector2, speed: float, count: int, angle_per_shot: float, main_angle: float) -> Array[Bullet]:
	var bullet : Bullet
	var bullet_list : Array[Bullet] = []
	var direction : Vector2
	var mid : float = float(count) / 2.0
	for i in range(count):
		direction = Vector2.from_angle(angle_per_shot * (i-mid) + main_angle)
		bullet = ModScript.spawn_bullet(bullet_scene, pos)
		bullet.velocity = direction * speed
		bullet_list.append(bullet)
	return bullet_list

## Initial distance is as if the bullet travelled how many seconds already, tip of triangle
static func spawn_arc_triangle(bullet_scene: PackedScene, pos: Vector2, speed: float, count: int, angle_per_shot: float, main_angle: float, init_distance_mult: float) -> Array[Bullet]:
	var bullet_list : Array[Bullet] = []
	var bullet_list_part : Array[Bullet] = []
	var dist_mult_interval : float = 0.0
	# This case count is the base of triangle width
	# i starts at 0, so the tip
	for i in range(count):
		bullet_list_part = BulletUtils.spawn_arc(bullet_scene, pos, speed, i+1, angle_per_shot, main_angle)
		dist_mult_interval = 1.0 - (float(i) / float(count))
		for bullet in bullet_list_part:
			bullet.position += bullet.velocity * init_distance_mult * dist_mult_interval
			bullet_list.append(bullet)
	return bullet_list

## Initial distance is as if the bullet travelled how many seconds already, tip of arrow
static func spawn_arc_arrow(bullet_scene: PackedScene, pos: Vector2, speed: float, count: int, angle_per_shot: float, main_angle: float, max_mult: float) -> Array[Bullet]:
	var bullet : Bullet
	var bullet_list : Array[Bullet] = []
	var direction : Vector2
	var mid : float = float(count) / 2.0
	var dist_mult_interval : float = 0.0
	for i in range(count):
		direction = Vector2.from_angle(angle_per_shot * (i-mid) + main_angle)
		bullet = ModScript.spawn_bullet(bullet_scene, pos)
		bullet.velocity = direction * speed
		dist_mult_interval = 1.0 - ((abs((float(i) + 0.5 - mid)) / float(count)) * max_mult)
		bullet.velocity *=  dist_mult_interval #* init_distance_mult
		bullet_list.append(bullet)
	return bullet_list

static func clear_bullets() -> void:
	for bullet in GameUtils.get_bullet_list():
		bullet.do_remove()

static func clear_enemies() -> void:
	for enemy in GameUtils.get_enemy_list():
		enemy.do_remove()
