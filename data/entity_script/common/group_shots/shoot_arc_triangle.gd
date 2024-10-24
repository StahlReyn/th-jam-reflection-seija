class_name MSShootArcTriangle
extends EntityScript
# Shoots Multiple bullet in one direction in circle formation

@onready var bullet_scene: PackedScene
@onready var audio_shoot : AudioStream = preload("res://assets/audio/sfx/hit_noise_fade.wav")

@export var shoot_cooldown : float = 3.0
@export var speed : float = 10
@export var count : float = 16
@export var angle_per_shot : float = 0
@export var main_angle : float = 0
@export var init_distance_mult : float = 0

@export var target_player : bool = false

var time_since_shot : float = 0.0
var bullet_list_function : Callable

func _init(shoot_cooldown: float, speed: float, count: float, angle_per_shot: float, main_angle: float = 0.0, init_distance_mult: float = 0.2, bullet_scene: PackedScene = null) -> void:
	if bullet_scene != null:
		self.bullet_scene = bullet_scene
	else:
		self.bullet_scene = BulletUtils.scene_dict["circle_medium"]
	self.shoot_cooldown = shoot_cooldown
	self.speed = speed
	self.count = count
	self.angle_per_shot = angle_per_shot
	self.main_angle = main_angle
	self.init_distance_mult = init_distance_mult

func physics_process_active(delta: float) -> void:
	time_since_shot += delta
	if time_since_shot >= shoot_cooldown:
		if target_player:
			main_angle = parent.position.angle_to_point(GameUtils.get_player().position)
		var bullet_list = BulletUtils.spawn_arc_triangle(
			bullet_scene,
			parent.position,
			speed,
			count,
			angle_per_shot,
			main_angle,
			init_distance_mult
		)
		if bullet_list_function != null:
			bullet_list_function.call(bullet_list)
		if audio_shoot:
			AudioManager.play_audio(audio_shoot)
		time_since_shot = 0.0

# bullet.global_position.direction_to(player.global_position)
