class_name MSShootSpiral
extends EntityScript

@onready var bullet_scene: PackedScene
@onready var audio_shoot : AudioStream = preload("res://assets/audio/sfx/hit_noise_fade.wav")

@export var shoot_cooldown : float = 3.0
@export var bullet_speed : float = 300
@export var angle_per_shot : float = 0

var time_since_shot : float = 0.0
var cur_angle : float = 0.0

var bullet_function : Callable

func _init(shoot_cooldown: float, bullet_speed: float, angle_per_shot: float, init_angle: float = 0.0, bullet_scene: PackedScene = null) -> void:
	if bullet_scene != null:
		self.bullet_scene = bullet_scene
	else:
		self.bullet_scene = BulletUtils.scene_dict["spike"]
	self.shoot_cooldown = shoot_cooldown
	self.bullet_speed = bullet_speed
	self.angle_per_shot = angle_per_shot
	self.cur_angle = init_angle

func _ready() -> void:
	pass

func physics_process_active(delta: float) -> void:
	time_since_shot += delta
	if time_since_shot >= shoot_cooldown:
		var bullet = spawn_bullet(bullet_scene, parent.position)
		bullet.velocity = Vector2.from_angle(cur_angle) * bullet_speed
		cur_angle += angle_per_shot
		time_since_shot = 0.0
		bullet_function.call(bullet)
		#if audio_shoot:
		#	AudioManager.play_audio(audio_shoot)
