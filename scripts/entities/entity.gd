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

var hit_velocity_mult = 1.0 # This is unique to Seija reflection mechanic

var total_time : float = 0.0
var active_time : float = 0.0
var in_wall : bool = false
var despawn_padding : float = 100

var prev_active_time : float
var prev_position : Vector2

var lambda_dict : Dictionary = {}

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
	total_time += delta
	
	# Performance heavy in main process because GDScript have Really Bad Overhead
	if is_active():
		prev_active_time = active_time
		prev_position = position
		active_time += delta
		for key : String in lambda_dict:
			lambda_dict[key].call(self, delta)
		position += velocity * delta
		if rotation_based_on_velocity and velocity != Vector2.ZERO:
			rotation = velocity.angle()
		
		physics_process_active(delta)
		check_hit_wall()
		if do_check_despawn and is_in_despawn_area():
			do_remove()

func step_time(delta: float) -> void:
	_physics_process(delta)

func physics_process_active(delta: float) -> void:
	pass

func is_active():
	return total_time >= delay_time

func add_behavior_func(key: String, f: Callable):
	lambda_dict[key] = f

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

func just_time_passed(time : float):
	return prev_active_time < time and time < active_time

func just_time_passed_every(time : float):
	return fmod(active_time, time) < active_time - prev_active_time
