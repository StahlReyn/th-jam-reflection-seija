class_name MSShootAtPlayer
extends MovementScript

@onready var bullet_circle : PackedScene = BulletUtils.scene_dict["circle_medium"]
@export var shoot_cooldown : float = 3.0
@export var bullet_speed : float = 300

var time_since_shot : float = 0.0

func _init(shoot_cooldown: float, bullet_speed: float) -> void:
	self.shoot_cooldown = shoot_cooldown
	self.bullet_speed = bullet_speed

func _ready() -> void:
	pass

func process_movement(delta: float) -> void:
	time_since_shot += delta
	if time_since_shot >= shoot_cooldown:
		var bullet = spawn_bullet(bullet_circle, parent.position)
		var direction : Vector2 = bullet.global_position.direction_to(GameUtils.get_player().global_position)
		bullet.velocity = direction * bullet_speed
		time_since_shot = 0
