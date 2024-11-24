class_name ItemCollectDisplay
extends Label

static var item_scene : PackedScene = preload("res://scripts/items/item_collect_display.tscn")
@onready var audio_collect = $ClickCollect

var up_speed : float = 50.0
var fade_speed : float = 3.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_text("")
	audio_collect.play()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	modulate.a -= fade_speed * delta # Fade out
	position.y -= up_speed * delta
	if modulate.a <= 0:
		call_deferred("queue_free")

func set_maximum_style() -> void:
	modulate.b = 0; # Set Yellow

static func create_display(pos: Vector2, point : int, is_maximum : bool = false):
	var display : ItemCollectDisplay = ItemCollectDisplay.item_scene.instantiate()
	var container : EffectContainer = GameUtils.get_effect_container()
	display.top_level = true
	display.global_position = pos
	container.add_child(display)
	display.set_text(str(point))
	if is_maximum:
		display.set_maximum_style()
