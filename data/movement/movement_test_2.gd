extends MovementScript

@onready var bullet_scene: PackedScene = BulletUtils.scene_dict["spike"]
@onready var audio_shoot : AudioStream = preload("res://assets/audio/sfx/hit_noise_fade.wav")

var player : Player
var cd_shoot : float

func _ready() -> void:
	player = GameUtils.get_player()
	cd_shoot = 1.0

func process_movement(delta: float) -> void:
	cd_shoot -= delta
	parent.velocity.x = cos(parent.total_time * 3) * 300
	parent.velocity.y = sin(parent.total_time * 3) * 300 + 100
	
	if cd_shoot <= 0:
		var bullet_list = BulletUtils.spawn_circle(
			bullet_scene, # Bullet to spawn
			parent.position, # Position
			300, # Speed
			32, # Count
			0, # Offset rad
		)
		for i in bullet_list.size():
			var bullet = bullet_list[i]
			# bullet.delay_time = i * 0.02 # delay causes spiral
			bullet.set_color((i % 2) * 3 + 2) # Swapping color every 2 index
		AudioManager.play_audio(audio_shoot)
		cd_shoot += 2.0

# bullet.global_position.direction_to(player.global_position)
