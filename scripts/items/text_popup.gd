class_name TextPopup
extends Label

static var label_setting_style := preload("res://assets/resources/label_settings/label_text_popup.tres")
static var label_setting_style_big := preload("res://assets/resources/label_settings/label_text_popup_big.tres")
static var label_setting_style_super := preload("res://assets/resources/label_settings/label_text_popup_super.tres")
static var label_scene := preload("res://scripts/items/text_popup.tscn")

var y_vel : float = 200.0
var y_acc : float = -500.0

var fade_speed : float = 1.2
var rotate_shake_speed : float = 0.0
var rotate_shake_amount : float = 0.0

enum Type {
	NORMAL,
	BIG_DAMAGE,
	SUPER_DAMAGE
}

var type : int = Type.NORMAL
var do_flash : bool = false
var main_mod : Color

var total_time = 0.0

func _ready() -> void:
	main_mod = self.modulate
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	total_time += delta
	modulate.a -= fade_speed * delta # Fade out
	position.y -= y_vel * delta
	y_vel += y_acc * delta
	
	if rotate_shake_amount != 0.0:
		rotation = sin(total_time * rotate_shake_speed) * rotate_shake_amount
	
	if type == Type.BIG_DAMAGE:
		modulate.g = main_mod.g + sin(total_time * 50.0) * 0.4
	elif type == Type.SUPER_DAMAGE:
		modulate.g = main_mod.g + sin(total_time * 50.0) * 0.4
	
	if modulate.a <= 0:
		call_deferred("queue_free")

static func create_popup(display_text: String, pos: Vector2) -> TextPopup:
	var display : TextPopup = label_scene.instantiate()
	var offset = display.get_size() * 0.5
	display.pivot_offset = offset
	display.top_level = true
	display.z_index = 10
	display.global_position = pos - offset
	display.set_text(display_text)
	GameUtils.get_effect_container().add_child(display)
	return display

static func create_popup_shake(display_text: String, pos: Vector2, speed: float = 30.0, amount: float = 0.1) -> TextPopup:
	var popup : TextPopup = create_popup(display_text, pos)
	popup.rotate_shake_speed = speed
	popup.rotate_shake_amount = amount
	return popup

static func create_popup_damage(value : int, pos: Vector2) -> TextPopup:
	var popup : TextPopup = create_popup(str(value), pos)
	if value >= 100:
		popup.type = Type.SUPER_DAMAGE
		popup.rotate_shake_speed = 30.0
		popup.rotate_shake_amount = 0.20
		popup.modulate = Color.AQUA
		popup.label_settings = label_setting_style_super
		popup.z_index += 2
	elif value >= 10:
		popup.type = Type.BIG_DAMAGE
		popup.rotate_shake_speed = 30.0
		popup.rotate_shake_amount = 0.15
		popup.modulate = Color.CRIMSON
		popup.label_settings = label_setting_style_big
		popup.z_index += 1
	else:
		popup.type = Type.NORMAL
		popup.rotate_shake_speed = 30.0
		popup.rotate_shake_amount = 0.10
		popup.modulate = Color.RED
	return popup
