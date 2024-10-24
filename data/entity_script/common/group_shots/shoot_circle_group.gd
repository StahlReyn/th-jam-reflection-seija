class_name MSShootCircleGroup
extends EntityScript
# Shoots Multiple bullet in one direction in circle formation

@onready var bullet_scene: PackedScene
@onready var audio_shoot : AudioStream = preload("res://assets/audio/sfx/hit_noise_fade.wav")

@export var shoot_cooldown : float = 3.0
@export var bullet_velocity : Vector2 = Vector2.ZERO
@export var count : float = 16
@export var angle_offset : float = 0
@export var radius : float = 10
@export var layer : int = 1
@export var offset_per_layer : float = 0.0

@export var target_player : bool = false

var time_since_shot : float = 0.0
var bullet_list_function : Callable

func _init(shoot_cooldown: float, bullet_velocity: Vector2, count: float, angle_offset: float, radius : float, layer : int = 1, offset_per_layer : float = 0.0, bullet_scene: PackedScene = null) -> void:
	if bullet_scene != null:
		self.bullet_scene = bullet_scene
	else:
		self.bullet_scene = BulletUtils.scene_dict["circle_medium"]
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
		if target_player:
			var rotation = GameUtils.get_player().position.angle_to_point(parent.position) + PI/2
			bullet_velocity = bullet_velocity.rotated(rotation)
		var bullet_list = BulletUtils.spawn_circle_packed(
			bullet_scene, 
			parent.position, 
			bullet_velocity,
			count,
			radius,
			angle_offset,
			layer,
			offset_per_layer
		)
		if bullet_list_function != null:
			bullet_list_function.call(bullet_list)
		if audio_shoot:
			AudioManager.play_audio(audio_shoot)
		time_since_shot = 0.0

# bullet.global_position.direction_to(player.global_position)
