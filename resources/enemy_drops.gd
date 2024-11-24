class_name EnemyDrops
extends Resource

@export_group("Spawning")
@export var spawn_speed : float = 400.0
@export var spawn_time : float = 0.3
@export_group("Drops")
@export var power : int = 0
@export var point : int = 0
@export var power_big : int = 0
@export var power_full : int = 0
@export var bomb : int = 0
@export var life : int = 0
@export var bomb_piece : int = 0
@export var life_piece : int = 0

var item_dict : Dictionary = {}

## Init only contains most common one for simplicity sake
func _init(power: int = 0, point: int = 0) -> void:
	self.power = power
	self.point = point

func update_item_dict():
	item_dict = {
		Item.Type.POWER: power,
		Item.Type.POINT: point,
		Item.Type.POWER_BIG: power_big,
		Item.Type.POWER_FULL: power_full,
		Item.Type.LIFE: life,
		Item.Type.LIFE_PIECE: life_piece,
		Item.Type.BOMB: bomb,
		Item.Type.BOMB_PIECE: bomb_piece,
	}
	
func drop_items(position: Vector2):
	update_item_dict()
	var container : ItemContainer = GameUtils.get_item_container()
	var count : int = 0
	for type in item_dict:
		count = item_dict[type]
		for i in count:
			var item : Item = Item.item_scene.instantiate()
			item.top_level = true
			item.global_position = position
			item.set_random_spawn_velocity(spawn_speed, spawn_time)
			container.call_deferred("add_child", item)
			item.call_deferred("set_type", type)
