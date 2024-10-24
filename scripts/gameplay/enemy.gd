class_name Enemy
extends Character

@export_group("Important")
@export var remove_on_death : bool = true
@export var self_update_anim : bool = true
@export_group("Drops")
@export var drop_spawn_speed : float = 1000.0
@export var drop_spawn_time : float = 0.1
@export var drop_power : int = 0
@export var drop_point : int = 0
@export var drop_power_big : int = 0
@export var drop_power_full : int = 0
@export var drop_bomb : int = 0
@export var drop_bomb_piece : int = 0
@export var drop_life : int = 0
@export var drop_life_piece : int = 0

func _ready() -> void:
	super()

func _physics_process(delta: float) -> void:
	super(delta)

func update_animation():
	if not self_update_anim: # If not update just ignore
		return
	super()

func do_death():
	super()
	drop_items()
	death.emit()
	if remove_on_death:
		do_remove()

func drop_items():
	var item_container : ItemContainer = GameUtils.get_item_container()
	drop_item_type(item_container, Item.Type.POWER, drop_power)
	drop_item_type(item_container, Item.Type.POINT, drop_point)
	drop_item_type(item_container, Item.Type.POWER_BIG, drop_power_big)
	drop_item_type(item_container, Item.Type.POWER_FULL, drop_power_full)
	drop_item_type(item_container, Item.Type.LIFE, drop_life)
	drop_item_type(item_container, Item.Type.LIFE_PIECE, drop_life_piece)
	drop_item_type(item_container, Item.Type.BOMB, drop_bomb)
	drop_item_type(item_container, Item.Type.BOMB_PIECE, drop_bomb_piece)

func drop_item_type(item_container: ItemContainer, type: int, count: int):
	for i in count:
		var item : Item = Item.item_scene.instantiate()
		item.top_level = true
		item.global_position = self.global_position
		item.set_random_spawn_velocity(drop_spawn_speed, drop_spawn_time)
		item_container.call_deferred("add_child", item)
		item.call_deferred("set_type", type)
