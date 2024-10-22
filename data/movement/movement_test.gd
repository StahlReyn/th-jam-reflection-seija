extends MovementScript

@onready var bullet_circle : PackedScene = BulletUtils.scene_dict["circle_small"]

var player : Player
var cd_shoot : float

func _ready() -> void:
	player = GameUtils.get_player()
	cd_shoot = 1.5

func process_movement(delta: float) -> void:
	cd_shoot -= delta
	
	parent.velocity.x = sin(parent.total_time * 3) * 300
	parent.velocity.y = 100
	
	if cd_shoot <= 0:
		var bullet = spawn_bullet(bullet_circle, parent.position)
		var direction : Vector2 = bullet.global_position.direction_to(player.global_position)
		bullet.velocity = direction * 300
		cd_shoot += 1.5
