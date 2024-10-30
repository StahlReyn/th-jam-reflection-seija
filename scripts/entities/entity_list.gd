class_name EntityList
## This is a data structure for list of entities

var cur_index : int = 0
var entity_list : Array[Entity]

func _init(list : Array[Entity] = []) -> void:
	entity_list = list

# Iterator (use in for-in loop)
func iter_continue():
	return cur_index < entity_list.size()

func _iter_init(arg):
	cur_index = 0
	return iter_continue()

func _iter_next(arg):
	cur_index += 1
	return iter_continue()

func _iter_get(arg): # Returns entity in the list
	return entity_list[cur_index]

# Main data structure
func add_entity(entity: Entity) -> void:
	entity_list.append(entity)

func remove_entity(entity: Entity) -> void:
	entity_list.erase(entity)
	
func entity_count() -> int:
	return entity_list.size()

func clean_list() -> void:
	var old_list = entity_list
	entity_list = []
	for item in old_list:
		if is_instance_valid(item):
			entity_list.append(item)

func replace_entities(entity_scene: PackedScene) -> void:
	var new_list : Array[Entity] = []
	for entity in entity_list:
		var new_entity = ModScript.spawn_entity(entity_scene, entity.position)
		new_entity.velocity = entity.velocity
		new_list.append(new_entity)
		entity.call_deferred("queue_free")
	entity_list = new_list
