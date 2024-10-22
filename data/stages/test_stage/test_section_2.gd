extends SectionScript

var cd1 : float = 1.0
var cd_script : float = 20.0

@onready var enemy_fairy : PackedScene = preload("res://data/enemies/enemy_lesser_fairy.tscn")

func _ready() -> void:
	super()
	duration = 0.1

func _physics_process(delta: float) -> void:
	super(delta)
	cd1 -= delta
	if cd1 <= 0:
		for i in 3:
			var enemy = spawn_enemy(enemy_fairy, Vector2(400, -100))
			enemy.velocity = Vector2(randi_range(-50,50), randi_range(50,150))
			enemy.main_sprite.set_type(randi_range(0,3))
		cd1 += 0.1
