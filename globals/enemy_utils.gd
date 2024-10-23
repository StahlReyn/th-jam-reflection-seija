extends Node

var scene_dict : Dictionary = {
	"lesser_fairy" = preload("res://data/enemies/common/lesser_fairy.tscn"),
	# This is more of testing
	"lesser_fairy_boss" = preload("res://data/enemies/common/lesser_fairy_boss.tscn"),
}

func clear_enemies() -> void:
	for enemy in GameUtils.get_enemy_list():
		enemy.do_remove()
