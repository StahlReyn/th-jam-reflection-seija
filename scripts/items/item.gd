class_name Item
extends AnimatedSprite2D

enum Type {
	POWER,
	POINT,
	POWER_BIG,
	POWER_FULL,
	LIFE,
	BOMB,
	LIFE_PIECE,
	BOMB_PIECE,
}

enum State {
	SPAWNING,
	FALLING,
	COLLECTING
}

static var item_scene : PackedScene = preload("res://scripts/items/item.tscn")
static var audio_collect : AudioStream = preload("res://assets/audio/sfx/click_collect.wav")
static var audio_collect_big : AudioStream = preload("res://assets/audio/sfx/item_get.wav")

static var max_speed : float = 200
static var down_speed : float = -100
static var down_accel : float = 200

static var magnet_range_squared : float = 40000
static var collect_range_squared : float = 360
static var collect_line_y : float = 300
static var magnet_speed : float = 1000

var type : int = Type.POINT
var state : int = State.SPAWNING
var spawn_velocity : Vector2
var spawn_rotation_speed : float = 50.0
var lifetime : float = 0.0

var magnet_target : Node2D
var distance_squared : float

const anim_dict : Dictionary = {
	Type.POWER: "power",
	Type.POINT: "point",
	Type.POWER_BIG: "power_big",
	Type.POWER_FULL: "power_full",
	Type.LIFE: "life",
	Type.LIFE_PIECE: "life_piece",
}

func _ready() -> void:
	magnet_target = GameUtils.get_player()
	state = State.SPAWNING

func _physics_process(delta: float) -> void:
	lifetime += delta
	
	# Update Distance
	if magnet_target:
		distance_squared = global_position.distance_squared_to(magnet_target.global_position)
	else:
		distance_squared = 1000000 # Hacky way of just saying "don't"
	
	# Item are is collected
	if distance_squared < collect_range_squared:
		do_collect()
	
	# Check States, if collecting then ignore
	if state != State.COLLECTING:
		if magnet_target and (distance_squared < magnet_range_squared or is_item_border_range()):
			state = State.COLLECTING
		elif lifetime >= 0.0:
			state = State.FALLING
		
	match state:
		State.SPAWNING:
			position += spawn_velocity * delta
			rotation += spawn_rotation_speed * delta
		State.FALLING:
			down_speed += down_accel * delta
			down_speed = min(down_speed, max_speed)
			position.y += down_speed * delta
			rotation = 0.0
		State.COLLECTING:
			var direction = (magnet_target.global_position - self.global_position).normalized()
			position += direction * magnet_speed * delta

	# Check Despawn
	if position.y > 1000:
		call_deferred("queue_free")
	
func process_target_movement(delta: float) -> void:
	var direction = (magnet_target.global_position - self.global_position).normalized()
	self.position += direction * magnet_speed * delta
	
func set_random_spawn_velocity(speed : float, time : float):
	self.lifetime = randf_range(-time, 0) # Negative Lifetime is spawn time
	self.spawn_velocity = MathUtils.get_random_direction_vector() * speed

func set_type(type : int) -> void:
	self.type = type
	play(anim_dict[type]) # Sets sprite, gets anim name from dictionary
	
func do_collect() -> void:
	var point_value : int = get_point_value()
	GameVariables.add_score(point_value)
	GameVariables.add_power(get_power_value())
	match type:
		Type.LIFE:
			GameVariables.add_lives()
		Type.LIFE_PIECE:
			GameVariables.add_life_pieces()
		Type.BOMB:
			GameVariables.add_bomb()
		Type.BOMB_PIECE:
			GameVariables.add_bomb_pieces()
	
	# Do point display
	if point_value > 0 and magnet_target:
		ItemCollectDisplay.create_display(
			magnet_target.global_position + Vector2(-28, 0),
			point_value,
			is_item_border_range()
		)
	
	call_deferred("queue_free")

func is_item_border_range() -> bool:
	if magnet_target:
		return magnet_target.position.y < collect_line_y
	return false

func get_point_value() -> int:
	match type:
		Type.POWER:
			return 10
		Type.POINT:
			return GameVariables.point_value
		Type.POWER_BIG:
			return 100
		Type.POWER_FULL:
			return 1000
	return 0

func get_power_value() -> int:
	match type:
		Type.POWER:
			return 1
		Type.POWER_BIG:
			return 100
		Type.POWER_FULL:
			return 500
	return 0
