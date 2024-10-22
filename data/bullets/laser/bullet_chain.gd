class_name BulletChain
extends Bullet

var prev_bullet : BulletChain ## Parent, to follow
var next_bullet : BulletChain ## Child, the following
var bullet_depth : int = 0

@export var max_bullet_depth : int = 15

func _ready() -> void:
	super()
	if bullet_depth == 0:
	# spawn_next_bullet()
		call_deferred("spawn_next_bullet")

func _physics_process(delta: float) -> void:
	super(delta)
	if prev_bullet != null:
		global_position = prev_bullet.global_position + Vector2(10,10)
		rotation = global_position.angle_to_point(prev_bullet.global_position)

func spawn_next_bullet():
	if bullet_depth < max_bullet_depth:
		print("DUPLICATE")
		next_bullet = self.duplicate(15)
		next_bullet.prev_bullet = self
		next_bullet.bullet_depth = self.bullet_depth + 1
		GameUtils.get_bullet_container().add_child(next_bullet)
		next_bullet.spawn_next_bullet()
