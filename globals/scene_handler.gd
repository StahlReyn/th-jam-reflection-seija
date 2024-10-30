extends Node

var current_scene = null

static var scene_game = "res://scenes/main/gamemain.tscn"
static var scene_menu = "res://scenes/main/menu.tscn"

func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)
	prints("Current Scene:", current_scene)

func goto_scene(path):
	# Deferred to ensure scene is not deleted while code is running
	_deferred_goto_scene.call_deferred(path)

func reload_current_scene():
	_deferred_reload_current_scene.call_deferred()

func _deferred_reload_current_scene():
	prints("Reload Scene Before:", current_scene, get_tree().current_scene)
	get_tree().reload_current_scene()
	_deferred_reload_set_scene.call_deferred()
	prints("Reload Scene After:", current_scene, get_tree().current_scene)

func _deferred_reload_set_scene():
	current_scene = get_tree().current_scene
	prints("Reload Scene AFTER After:", current_scene, get_tree().current_scene)

func _deferred_goto_scene(path):
	prints("Goto Scene Before:", current_scene, get_tree().current_scene)
	current_scene.free() 	# It is now safe to remove the current scene.
	var s = ResourceLoader.load(path) # Load the new scene.
	current_scene = s.instantiate() # Instance the new scene.
	get_tree().root.add_child(current_scene) # Add it to the active scene, as child of root.

	# Optionally, to make it compatible with the SceneTree.change_scene_to_file() API.
	get_tree().current_scene = current_scene
	prints("Goto Scene After:", current_scene, get_tree().current_scene)
