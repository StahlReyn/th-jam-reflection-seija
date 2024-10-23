class_name MSShootCircleGroup
extends EntityScript
# Shoots Multiple bullet in one direction in circle formation

@onready var bullet_scene: PackedScene = BulletUtils.scene_dict["circle_medium"]
@onready var audio_shoot : AudioStream = preload("res://assets/audio/sfx/hit_noise_fade.wav")

@export var shoot_cooldown : float = 3.0
@export var bullet_velocity : Vector2 = Vector2.ZERO
@export var count : float = 16
@export var angle_offset : float = 0
@export var radius : float = 10
@export var layer : int = 1
@export var offset_per_layer : float = 0.0

var time_since_shot : float = 0.0

func _init(shoot_cooldown: float, bullet_velocity: Vector2, count: float, angle_offset: float, radius : float, layer : int = 1, offset_per_layer : float = 0.0, bullet_scene: PackedScene = null) -> void:
	if bullet_scene != null:
		self.bullet_scene = bullet_scene
	self.shoot_cooldown = shoot_cooldown
	self.bullet_velocity = bullet_velocity
	self.count = count
	self.angle_offset = angle_offset
	self.radius = radius
	self.layer = layer
	self.offset_per_layer = offset_per_layer

func _ready() -> void:
	pass

func physics_process_active(delta: float) -> void:
	time_since_shot += delta
	if time_since_shot >= shoot_cooldown:
		BulletUtils.spawn_circle_packed(
			bullet_scene, 
			parent.position, 
			bullet_velocity,
			count,
			radius,
			angle_offset,
			layer,
			offset_per_layer
		)
			
		if audio_shoot:
			AudioManager.play_audio(audio_shoot)
		time_since_shot = 0.0

# bullet.global_position.direction_to(player.global_position)
