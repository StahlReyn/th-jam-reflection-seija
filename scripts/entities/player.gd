class_name Player
extends Character

signal game_over

enum State {
	NORMAL, ## Usual state
	BOMB, ## Invincibility period during bombing
	DEAD_DELAY, ## Slight pause
	SPAWNING, ## When spawning
	GRACE, ## Invincibility period after spawn
}

@export var base_speed : int = 400 ## pixels/sec
@export var focus_speed : int = 100 ## pixels/sec
@export var area_graze : AreaGraze
@export var audio_shoot : AudioStreamPlayer2D ## shoot audio is done on player side to not overlap multiple shooters
@export var audio_item : AudioStreamPlayer2D ## Audio for item collection

var state_timer : float = 0.0
var state : int = State.NORMAL

func _init() -> void:
	super()
	do_check_despawn = false # Always false for player to not despawn

func _ready() -> void:
	super()
	do_spawn_movement()

func _physics_process(delta: float) -> void:
	state_timer -= delta
	super(delta)
	process_movement_input()
	process_shoot_input()
	process_state()
	process_iframe()

func process_movement_input() -> void:
	velocity = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		velocity.x = get_speed()
	if Input.is_action_pressed("move_left"):
		velocity.x = -get_speed()
	if Input.is_action_pressed("move_down"):
		velocity.y = get_speed()
	if Input.is_action_pressed("move_up"):
		velocity.y = -get_speed()

func process_shoot_input() -> void:
	pass
	#if Input.is_action_pressed("shoot") and can_shoot() and not audio_shoot.playing:
	#	audio_shoot.play()

func process_movement(delta) -> void:
	if state == State.NORMAL or state == State.GRACE:
		position += velocity * delta
		position = position.clamp(Vector2.ZERO, GameUtils.get_game_area())
	elif state == State.SPAWNING:
		position += Vector2.UP * 600 * delta

func process_state() -> void:
	if state != State.NORMAL and state_timer < 0:
		match state:
			State.DEAD_DELAY: # When finish switch to spawn
				switch_state(State.SPAWNING, 0.4)
				is_dead = false
			State.SPAWNING:
				switch_state(State.GRACE, 3.0)
			State.GRACE:
				switch_state(State.NORMAL, 0.0)
	
func process_iframe() -> void:
	if is_invincible():
		main_sprite.modulate.a = cos(state_timer * 20) * 0.2 + 0.8
	else:
		main_sprite.modulate.a = 1

func get_speed():
	if Input.is_action_pressed("focus"):
		return focus_speed
	return base_speed

func take_damage(dmg : int):
	if not is_invincible():
		hp -= dmg
		check_death()

func do_death():
	super()
	GameVariables.lose_lives()
	check_game_over()
	do_spawn_movement()

func do_spawn_movement():
	switch_state(State.DEAD_DELAY, 0.5)
	position.x = GameUtils.game_area.x / 2
	position.y = GameUtils.game_area.y + 100

func switch_state(state: int, state_timer: float):
	self.state = state
	self.state_timer = state_timer

func check_game_over():
	if GameVariables.lives <= 0:
		game_over.emit()
		print("GAME OVER")

func is_invincible() -> bool:
	return state != State.NORMAL

func can_shoot() -> bool:
	return not (state == State.DEAD_DELAY or state == State.SPAWNING)
