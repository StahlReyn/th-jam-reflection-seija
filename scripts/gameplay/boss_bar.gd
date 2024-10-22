extends TextureProgressBar

var parent : Enemy 

func _ready() -> void:
	call_deferred("setup_parent")

func _physics_process(delta: float) -> void:
	update_value()

func setup_parent():
	if get_parent()	is Enemy:
		parent = get_parent()

func update_value():
	set_min(0)
	set_max(parent.mhp)
	set_value(parent.hp)
