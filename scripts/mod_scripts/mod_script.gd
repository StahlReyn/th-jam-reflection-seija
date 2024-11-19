class_name ModScript
extends Node
## This is script that's inserted to change behavior
## Ranging from Stages, Spell Cards, Enemies, and Bullets

var time_elapsed : float = 0.0 ## Timer since script is on_ready
var time_active : float = 0.0 ## Timer that ticks only when active

@export var enabled : bool = true ## Is enabled

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	time_elapsed += delta
	if is_active():
		physics_process_active(delta)
		
func physics_process_active(delta: float) -> void:
	time_active += delta
	
func is_active() -> bool:
	return enabled

static func get_container_for_entity(entity: Entity):
	if entity is Enemy:
		return GameUtils.get_enemy_container()
	elif entity is Bullet or entity is Laser:
		return GameUtils.get_bullet_container()
	printerr("Get container for entity gets non specified container")
	return null

static func spawn_entity(scene : PackedScene, pos : Vector2 = Vector2(0,0)) -> Entity:
	var entity : Entity = scene.instantiate()
	var container = get_container_for_entity(entity)
	entity.global_position = pos
	container.call_deferred("add_child", entity)
	if entity is Enemy:
		GameVariables.enemy_spawned += 1
	return entity

static func spawn_enemy(scene : PackedScene, pos : Vector2 = Vector2(0,0)) -> Enemy:
	var container = GameUtils.get_enemy_container()
	var enemy : Enemy = scene.instantiate()
	enemy.global_position = pos
	container.call_deferred("add_child", enemy)
	GameVariables.enemy_spawned += 1
	return enemy

static func spawn_bullet(scene : PackedScene, pos : Vector2 = Vector2(0,0)) -> Bullet:
	var container = GameUtils.get_bullet_container()
	var bullet : Bullet = scene.instantiate()
	bullet.global_position = pos
	container.call_deferred("add_child", bullet)
	return bullet

static func spawn_laser(scene : PackedScene, pos : Vector2 = Vector2(0,0)) -> Laser:
	var container = GameUtils.get_bullet_container()
	var bullet : Laser = scene.instantiate()
	bullet.global_position = pos
	container.call_deferred("add_child", bullet)
	return bullet

static func spawn_image(image : Texture2D, pos : Vector2 = Vector2(0,0)) -> Sprite2D:
	var sprite = Sprite2D.new()
	var container = GameUtils.get_image_container()
	sprite.texture = image
	sprite.top_level = true
	sprite.global_position = pos
	container.call_deferred("add_child", sprite)
	return sprite

static func spawn_title_card(scene : PackedScene, pos : Vector2 = Vector2(0,0)) -> TitleCard:
	var container = GameUtils.get_image_container()
	var image : TitleCard = scene.instantiate()
	image.top_level = true
	image.global_position = pos
	container.call_deferred("add_child", image)
	return image

# Common Lambda Function
func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

static func en_accel(accel : Vector2):
	return func f(entity : Entity):
		return entity.velocity + (entity.dt * accel)

static func en_circ(freq, amp, shift = 0.0):
	return func f(entity : Entity):
		return entity.velocity + entity.dt * Vector2.from_angle(entity.total_time * freq + shift) * amp
