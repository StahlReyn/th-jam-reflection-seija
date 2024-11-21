class_name HealthBarEnemy
extends TextureProgressBar

@export var parent : Enemy 
var display_value : float = 0.0
var target_alpha : float = 0.0

func _ready() -> void:
	modulate.a = 0.0

func _physics_process(delta: float) -> void:
	update_value(delta)
	
func start_display():
	display_value = 0.0
	target_alpha = 1.0

func end_display():
	target_alpha = 0.0

func update_value(delta):
	modulate.a = lerp(modulate.a, target_alpha, delta * 5)
	display_value = lerp(display_value, float(parent.hp), delta * 20)
	set_min(0)
	set_max(parent.mhp)
	set_value(display_value)
