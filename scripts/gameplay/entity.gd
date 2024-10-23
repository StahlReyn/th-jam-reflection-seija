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

var total_time : float = 0.0
var active_time : float = 0.0
var hit_count : int = 0
var in_wall : bool = false
var despawn_padding : float = 100

func _init() -> void:
	# Auto create Movement Handler
	if script_handler == null:
		script_handler = EntityScriptHandler.new()
		script_handler.name = "EntityScriptHandlerAuto"
		add_child(script_handler)

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	total_time += delta
	if is_active():
		physics_process_active(delta)

func physics_process_active(delta: float) -> void:
	active_time += delta
	script_handler.process_script(delta)
	process_movement(delta)
	check_hit_wall()
	if do_check_despawn:
		check_despawn()

func is_active():
	return total_time >= delay_time

func process_movement(delta) -> void:
	position += velocity * delta

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
	
func check_despawn() -> void:
	if is_in_despawn_area():
		do_remove()

func is_in_despawn_area() -> bool:
	return (position.x > GameUtils.game_area.x + despawn_padding
			or position.x < - despawn_padding
			or position.y > GameUtils.game_area.y + despawn_padding
			or position.y < - despawn_padding)

func on_hit():
	hit.emit()
	hit_count += 1

# in base entity do_remove isnt called automatically, let the child class or external handle it
func do_remove():
	call_deferred("queue_free")

func add_entity_script(script : GDScript) -> Node:
	var node_script = script.new()
	add_movement_node(node_script)
	return node_script

## No return values as a node is already passed in
func add_movement_node(node : EntityScript) -> void:
	node.set_parent(self)
	node.name = "EntityScript"
	script_handler.add_child(node)
