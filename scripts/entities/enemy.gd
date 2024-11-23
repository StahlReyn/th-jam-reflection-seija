class_name Enemy
extends Character

@export_group("Important")
@export var remove_on_death : bool = true
@export var self_update_anim : bool = true
@export var remove_on_chapter_change : bool = true
@export_group("Drops")
@export var drops : EnemyDrops = EnemyDrops.new()

func _ready() -> void:
	super()

func _physics_process(delta: float) -> void:
	super(delta)

func stop_all_despawn(): # Used for Bosses more but can be useful for other case
	do_check_despawn = false
	remove_on_death = false
	remove_on_chapter_change = false

func update_animation():
	if not self_update_anim: # If not update just ignore
		return
	super()

func do_death():
	super()
	drops.drop_items(self.global_position)
	death.emit()
	GameVariables.shoot_down += 1
	if remove_on_death:
		do_remove()
