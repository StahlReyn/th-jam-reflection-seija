class_name AreaGraze
extends Area2D

signal graze

@onready var focus_sprite : Sprite2D = $FocusDot
@onready var graze_sprite : Sprite2D = $GrazeCircle
@onready var audio_graze : AudioStreamPlayer2D = $AudioGraze

static var focus_transition_speed : float = 20.0

func _ready() -> void:
	graze_sprite.rotation = 0
	graze_sprite.scale = Vector2(2,2)

func _physics_process(delta: float) -> void:
	graze_sprite.rotation += delta
	if Input.is_action_pressed("focus"):
		graze_sprite.scale = MathUtils.expDecay(graze_sprite.scale, Vector2(2,2), focus_transition_speed, delta)
		graze_sprite.set_modulate(MathUtils.expDecay(graze_sprite.get_modulate(), Color(1,1,1,0.5), focus_transition_speed, delta))
		focus_sprite.set_modulate(MathUtils.expDecay(focus_sprite.get_modulate(), Color(1,1,1,1), focus_transition_speed, delta))
	else:
		graze_sprite.scale = MathUtils.expDecay(graze_sprite.scale, Vector2(2.5,2.5), focus_transition_speed, delta)
		graze_sprite.set_modulate(MathUtils.expDecay(graze_sprite.get_modulate(), Color(1,1,1,0), focus_transition_speed, delta))
		focus_sprite.set_modulate(MathUtils.expDecay(focus_sprite.get_modulate(), Color(1,1,1,0), focus_transition_speed, delta))

func _on_area_entered(area: Area2D) -> void:
	if area is Bullet:
		graze.emit()
		GameVariables.add_graze_count()
		audio_graze.play()
