class_name EnemyBoss
extends Enemy

@export var health_bar : HealthBarEnemy

func _ready() -> void:
	add_to_group("enemy_boss")
	super()
	stop_all_despawn()

func _physics_process(delta: float) -> void:
	super(delta)

## This is made into a function as it's common enough
func setup_for_section(drops : EnemyDrops, mhp : int) -> void:
	self.stop_all_despawn()
	self.drops = drops
	self.set_mhp(mhp)
	self.set_active()
	
func set_active() -> void:
	monitorable = true
	monitoring = true
	health_bar.start_display()

func set_inactive() -> void:
	monitorable = false
	monitoring = false
	health_bar.end_display()
