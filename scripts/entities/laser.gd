class_name Laser
extends Bullet

enum State {
	PRE,
	GROW,
	STATIC,
	END,
	REMOVE,
}

@export_group("Important")
@export var laser_collision : CollisionShape2D ## Collision for laser to change
@export var base_size : Vector2 ## Basic size
@export var lerp_speed : float = 6.0 ## how fast laser grows
@export var laser_active_time : float = 5.0 
@export var target_size : Vector2 = Vector2(1500,32)
@export_group("Node Following")
@export var node_follow : Node2D ## Optional, Laser will copies this position
@export var follow_offset : Vector2 = Vector2(0,0)

static var pre_size = 0.1
static var width_remove = 3.0

var state_timer : float = 0.0
var state : int = 0
var had_follow : bool = false

func _ready() -> void:
	super()
	laser_collision.disabled = true
	laser_collision.shape.size.x = target_size.x # Length
	laser_collision.shape.size.y = 1 # Width
	main_sprite.scale.x = 0.1 # Width due to rotate
	main_sprite.scale.y = target_size.x / base_size.y # Length due to rotate
	switch_state(State.PRE, delay_time)

func _physics_process(delta: float) -> void:
	super(delta)
	state_timer -= delta
	process_state()
	
	match state:
		State.STATIC:
			# WIDTH is THICKNESS, due to Positive X axis as forward and sprite rotated 90deg clockwise
			laser_collision.disabled = false
			laser_collision.shape.size.y = MathUtils.expDecay(laser_collision.shape.size.y, target_size.y, lerp_speed, delta)
			var target_scale = target_size.y / base_size.x
			main_sprite.scale.x = MathUtils.expDecay(main_sprite.scale.x, target_scale, lerp_speed, delta)
		State.END:		
			laser_collision.shape.size.y = MathUtils.expDecay(laser_collision.shape.size.y, 0.0, lerp_speed, delta)
			main_sprite.scale.x = MathUtils.expDecay(main_sprite.scale.x, 0.0, lerp_speed, delta)
			if laser_collision.shape.size.y < width_remove:
				switch_state(State.REMOVE, 100.0)
		State.REMOVE:
			laser_collision.disabled = true
			call_deferred("queue_free")
	# Make sprite align to left, where laser starts. Remember sprite is rotated
	var cur_length = base_size.y * main_sprite.scale.y
	main_sprite.position.x = cur_length * 0.5
	laser_collision.shape.size.x = cur_length
	laser_collision.position.x = cur_length * 0.5
	if node_follow != null:
		global_position = node_follow.global_position + follow_offset
	elif had_follow: # Only end early if the node had a follow before. Some laser are on own
		if state == State.STATIC:
			print("Preemptive Laser End")
			switch_state(State.END, 100.0)

func on_hit():
	if bullet_hit_effect_scene:
		AfterEffect.add_effect(bullet_hit_effect_scene, global_position)
	#call_deferred("queue_free")

func process_state() -> void:
	if state_timer < 0:
		match state:
			State.PRE: # When finish switch to spawn
				switch_state(State.GROW, 0.0)
			State.GROW:
				switch_state(State.STATIC, laser_active_time)
			State.STATIC:
				switch_state(State.END, 100.0)
			State.END:
				switch_state(State.REMOVE, 100.0)

func switch_state(state: int, state_timer: float):
	self.state = state
	self.state_timer = state_timer

func set_node_follow(node : Node2D) -> void:
	node_follow = node
	had_follow = true
