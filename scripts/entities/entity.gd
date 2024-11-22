class_name Entity
extends Area2D
## This is the largest class for everything gameplay object
## Includes Characters, Bullets, Enemies, Players
## This is the class ModScript targets

signal hit
signal hit_wall
signal exit_wall

@export var delay_time : float = 0.0
@export var velocity : Vector2 = Vector2.ZERO
@export var do_check_despawn : bool = true
@export var script_handler : EntityScriptHandler ## Movement Handler is auto created if empty
@export var rotation_based_on_velocity : bool = false

static var default_remove_effect : PackedScene = preload("res://data/after_effects/bullet_remove.tscn")

var speed_multiplier = 1.0

var total_time : float = 0.0
var active_time : float = 0.0
var in_wall : bool = false
var despawn_padding : float = 100

var dt : float

var func_velocity_list : Array[Callable]
var func_behavior_list : Array[Callable]

var despawn_center = GameUtils.game_area * 0.5
var despawn_radius = 700 ** 2

func _init() -> void:
	# Auto create Movement Handler
	if script_handler == null:
		script_handler = EntityScriptHandler.new()
		script_handler.name = "EntityScriptHandlerAuto"
		add_child(script_handler)

func _ready() -> void:
	if rotation_based_on_velocity and velocity != Vector2.ZERO:
		rotation = velocity.angle()

func _physics_process(delta: float) -> void:
	dt = delta
	total_time += delta
	
	# Performance heavy in main process because GDScript have Really Bad Overhead
	if is_active():
		active_time += delta
		
		for f : Callable in func_velocity_list:
			velocity = f.call(self)
		for f : Callable in func_behavior_list:
			f.call(self)
		position += velocity * delta
		
		if rotation_based_on_velocity and velocity != Vector2.ZERO:
			rotation = velocity.angle()
		
		physics_process_active(delta)
		
		check_hit_wall()
		if do_check_despawn and is_in_despawn_area():
			do_remove()

func physics_process_active(delta: float) -> void:
	pass

func is_active():
	return total_time >= delay_time

func add_velocity_func(f : Callable):
	func_velocity_list.append(f)

func add_behavior_func(f : Callable):
	func_behavior_list.append(f)

func check_hit_wall() -> void:
	if is_in_wall_area():
		if not in_wall: # emit only once
			hit_wall.emit()
			in_wall = true
	else:
		in_wall = false
		exit_wall.emit()

func is_in_wall_area() -> bool:
	return (position.x > GameUtils.game_area.x 
			or position.x < 0 
			or position.y > GameUtils.game_area.y
			or position.y < 0)

func is_in_despawn_area() -> bool:
	# return position.distance_squared_to(despawn_center) > (despawn_radius + despawn_padding)
	return (position.x > GameUtils.game_area.x + despawn_padding
			or position.x < - despawn_padding
			or position.y > GameUtils.game_area.y + despawn_padding
			or position.y < - despawn_padding)

func on_hit(entity : Entity) -> void:
	hit.emit()

# in base entity do_remove isnt called automatically, let the child class or external handle it
func do_remove(remove_effect : bool = false):
	if remove_effect:
		AfterEffect.add_effect(default_remove_effect, global_position)
	call_deferred("queue_free")

func add_entity_script(script : GDScript) -> Node:
	var node_script = script.new()
	add_script_node(node_script)
	return node_script

## No return values as a node is already passed in
func add_script_node(node : EntityScript) -> void:
	node.set_parent(self)
	node.name = "EntityScript"
	script_handler.add_child(node)

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

func just_time_passed(time : float):
	return active_time < time and time < active_time + dt

func just_time_passed_every(time : float):
	return fmod(active_time, time) < dt
