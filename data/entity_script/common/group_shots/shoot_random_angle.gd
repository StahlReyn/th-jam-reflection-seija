class_name MSShootRandomAngle
extends EntityScript
# Shoots Multiple bullet in one direction in circle formation

@onready var bullet_scene: PackedScene
@onready var audio_shoot : AudioStream = preload("res://assets/audio/sfx/hit_noise_fade.wav")

@export var shoot_cooldown : float = 3.0
@export var bullet_speed : float = 10
@export var count : float = 16
@export var min_angle : float = 0
@export var max_angle : float = 0

@export var target_player : bool = false

var time_since_shot : float = 0.0
var bullet_function : Callable
var final_shot_angle : float = 0.0

func _init(shoot_cooldown: float, bullet_speed: float, min_angle: float, max_angle: float = 0.0, bullet_scene: PackedScene = null) -> void:
	if bullet_scene != null:
		self.bullet_scene = bullet_scene
	else:
		self.bullet_scene = BulletUtils.scene_dict["circle_medium"]
	self.shoot_cooldown = shoot_cooldown
	self.bullet_speed = bullet_speed
	self.count = count
	self.min_angle = min_angle
	self.max_angle = max_angle

func physics_process_active(delta: float) -> void:
	time_since_shot += delta
	if time_since_shot >= shoot_cooldown:
		final_shot_angle = randf_range(min_angle,max_angle)
		if target_player:
			final_shot_angle += parent.position.angle_to_point(GameUtils.get_player().position)
		
		var bullet = ModScript.spawn_entity(bullet_scene, parent.position)
		bullet.velocity = Vector2.from_angle(final_shot_angle) * bullet_speed
		if bullet_function != null:
			bullet_function.call(bullet)
		#if audio_shoot:
			#AudioManager.play_audio(audio_shoot)
		time_since_shot = 0.0

# bullet.global_position.direction_to(player.global_position)
