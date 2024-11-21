class_name EnemyBoss
extends Enemy

@export var health_bar : HealthBarEnemy

func _ready() -> void:
	add_to_group("enemy_boss")
	super()
	stop_all_despawn()

func _physics_process(delta: float) -> void:
	super(delta)

func set_active() -> void:
	monitorable = true
	monitoring = true
	health_bar.start_display()

func set_inactive() -> void:
	monitorable = false
	monitoring = false
	health_bar.end_display()
