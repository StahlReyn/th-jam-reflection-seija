class_name MSShootAtPlayer
extends EntityScript

@onready var bullet_scene : PackedScene
@onready var default_bullet_scene : PackedScene = BulletUtils.scene_dict["circle_medium"]
@export var shoot_cooldown : float = 3.0
@export var bullet_speed : float = 300.0
@export var angle_offset : float = 0.0


var time_since_shot : float = 0.0
var bullet_function : Callable

func _init(shoot_cooldown: float, bullet_speed: float, angle_offset: float = 0.0) -> void:
	self.shoot_cooldown = shoot_cooldown
	self.bullet_speed = bullet_speed
	self.angle_offset = angle_offset

func _ready() -> void:
	pass

func physics_process_active(delta: float) -> void:
	time_since_shot += delta
	if time_since_shot >= shoot_cooldown:
		if bullet_scene == null:
			bullet_scene = default_bullet_scene
		var bullet = spawn_bullet(bullet_scene, parent.position)
		var direction : Vector2 = bullet.global_position.direction_to(GameUtils.get_player().global_position)
		bullet.velocity = direction.rotated(angle_offset) * bullet_speed
		time_since_shot = 0
		if bullet_function != null:
			bullet_function.call(bullet)
