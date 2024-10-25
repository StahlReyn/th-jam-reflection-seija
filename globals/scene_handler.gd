extends Node

var current_scene = null

static var scene_game = "res://scenes/gamemain.tscn"
static var scene_menu = "res://scenes/menu.tscn"

func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)

func goto_scene(path):
	# Deferred to ensure scene is not deleted while code is running
	_deferred_goto_scene.call_deferred(path)


func _deferred_goto_scene(path):
	current_scene.free() 	# It is now safe to remove the current scene.
	var s = ResourceLoader.load(path) # Load the new scene.
	current_scene = s.instantiate() # Instance the new scene.
	get_tree().root.add_child(current_scene) # Add it to the active scene, as child of root.

	# Optionally, to make it compatible with the SceneTree.change_scene_to_file() API.
	get_tree().current_scene = current_scene
