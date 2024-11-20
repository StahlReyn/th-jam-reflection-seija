class_name TextPopup
extends Label

static var label_setting_style := preload("res://assets/resources/label_settings/label_text_popup.tres")
static var label_scene := preload("res://scripts/items/text_popup.tscn")

var y_vel : float = 200.0
var y_acc : float = -500.0
var fade_speed : float = 1.0
var rotate_shake_speed : float = 30.0
var rotate_shake_amount : float = 0.10

var total_time = 0.0

func _ready() -> void:
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	total_time += delta
	modulate.a -= fade_speed * delta # Fade out
	position.y -= y_vel * delta
	y_vel += y_acc * delta
	rotation = sin(total_time * rotate_shake_speed) * rotate_shake_amount
	if modulate.a <= 0:
		call_deferred("queue_free")

static func create_popup(display_text: String, pos: Vector2) -> TextPopup:
	var display : TextPopup = label_scene.instantiate()
	var offset = display.get_size() * 0.5
	display.pivot_offset = offset
	display.top_level = true
	display.global_position = pos - offset
	display.set_text(display_text)
	GameUtils.get_effect_container().add_child(display)
	return display
