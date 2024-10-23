class_name MSShootCircle
extends EntityScript

@onready var bullet_scene: PackedScene = BulletUtils.scene_dict["spike"]
@onready var audio_shoot : AudioStream = preload("res://assets/audio/sfx/hit_noise_fade.wav")

@export var shoot_cooldown : float = 3.0
@export var speed : float = 300
@export var count : float = 16
@export var offset : float = 0

var time_since_shot : float = 0.0

func _init(shoot_cooldown: float, speed: float, count: float, offset: float, bullet_scene: PackedScene = null) -> void:
	if bullet_scene != null:
		self.bullet_scene = bullet_scene
	self.shoot_cooldown = shoot_cooldown
	self.speed = speed
	self.count = count
	self.offset = offset

func _ready() -> void:
	pass

func physics_process_active(delta: float) -> void:
	time_since_shot += delta
	if time_since_shot >= shoot_cooldown:
		var bullet_list = BulletUtils.spawn_circle(
			bullet_scene, # Bullet to spawn
			parent.position, # Position
			speed, # Speed
			count, # Count
			offset, # Offset rad
		)
		for i in bullet_list.size():
			var bullet = bullet_list[i]
			bullet.set_color((i % 2) * 3 + 2) # Swapping color every 2 index
		if audio_shoot:
			AudioManager.play_audio(audio_shoot)
		time_since_shot = 0.0

# bullet.global_position.direction_to(player.global_position)
