extends EntityScript
## For sine wave movement, for both x and y

@export var frequency : Vector2 = Vector2(1,1) ##rad / sec
@export var amplitude : Vector2 = Vector2(100,100) ##(of velocity)
@export var phase_offset : Vector2 = Vector2(0,0) ##rad
@export var base_velocity : Vector2 = Vector2(0,0)

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	var time = parent.active_time
	parent.velocity = base_velocity
	parent.velocity.x += sin(time * frequency.x + phase_offset.x) * amplitude.x
	parent.velocity.y += sin(time * frequency.y + phase_offset.y) * amplitude.y
