extends Node

var game_area : Vector2 = Vector2(768,896)

func get_player() -> Player:
	return get_tree().get_nodes_in_group("player")[0]

func get_enemy_list() -> Array[Node]:
	return get_tree().get_nodes_in_group("enemy")

func get_bullet_list() -> Array[Node]:
	return get_tree().get_nodes_in_group("bullet")
	
func get_bullet_count() -> int:
	return get_tree().get_nodes_in_group("bullet").size()

func get_item_count() -> int:
	return get_tree().get_nodes_in_group("item").size()

func get_enemy_count() -> int:
	return get_tree().get_nodes_in_group("enemy").size()

func get_game_view() -> GameView:
	return get_tree().get_nodes_in_group("game_view")[0]

func get_bullet_container() -> BulletContainer:
	return get_tree().get_nodes_in_group("bullet_container")[0]

func get_effect_container() -> EffectContainer:
	return get_tree().get_nodes_in_group("effect_container")[0]

func get_item_container() -> ItemContainer:
	return get_tree().get_nodes_in_group("item_container")[0]

func get_image_container() -> ImageContainer:
	return get_tree().get_nodes_in_group("image_container")[0]

func get_enemy_container() -> EnemyContainer:
	return get_tree().get_nodes_in_group("enemy_container")[0]

func get_stage_handler() -> StageHandler:
	return get_tree().get_nodes_in_group("stage_handler")[0]

func get_spell_card_displayer() -> SpellCardDisplayer:
	return get_tree().get_nodes_in_group("spell_card_displayer")[0]

func get_dialogue_displayer() -> DialogueDisplayer:
	return get_tree().get_nodes_in_group("dialogue_displayer")[0]

func get_popup_displayer() -> PopUps:
	return get_tree().get_nodes_in_group("popups")[0]

func get_point_items() -> Array[Node]:
	return get_tree().get_nodes_in_group("item")

func get_game_area() -> Vector2:
	return game_area
