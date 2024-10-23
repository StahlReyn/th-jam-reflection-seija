extends EntityScript

@onready var bullet_circle : PackedScene = BulletUtils.scene_dict["circle_small_cross"]
@onready var scene_laser : PackedScene = BulletUtils.scene_dict["laser_basic"]
@onready var audio_shoot : AudioStream = preload("res://assets/audio/sfx/hit_noise_fade.wav")
@onready var script_rotation : GDScript = preload("res://data/movement/common/rotation_constant.gd")

@onready var bullet_lily : PackedScene = preload("res://data/bullets/example/bullet_lily.tscn")#BulletUtils.scene_dict["circle_large"]
@onready var script_lily : GDScript = preload("res://data/movement/example/murderous_lilies.gd")

var player : Player
var audio_node : Node

var cd_shoot : float

var elapsed_time : float = 0.0
var section_time : float = 0.0

var cur_velocity : Vector2 = Vector2(0,0)
var part = 0

func _ready() -> void:
	player = GameUtils.get_player()
	call_deferred("setup_enemy")

func set_stat():
	if parent is Enemy:
		parent.mhp = 200
		parent.reset_hp()
		parent.drop_power = 0
		parent.drop_point = 15
		parent.drop_power_big = 1
		parent.drop_bomb_piece = 1

func setup_enemy():
	set_stat()
	audio_node = AudioStreamPlayer2D.new()
	audio_node.set_stream(audio_shoot)
	parent.add_child(audio_node)

func process_movement(delta: float) -> void:
	elapsed_time += delta
	section_time += delta
	cd_shoot -= delta
	
	match part:
		0:
			cur_velocity.y = 400
			check_part_cd(0.0)
		1:
			cur_velocity.y += -200 * delta
			check_part_cd(2.0)
		2:
			#shoot_1()
			check_part_cd(3.0)
		3:
			cur_velocity.y += -300 * delta
			check_part_cd(10.0)
				
	parent.velocity = cur_velocity

func check_part_cd(time: float) -> void: ## How long next section last
	if section_time > time:
		part += 1
		section_time = 0.0
		print(part)
		if part > 1:
			spawn_lily()

func shoot_1() -> void:
	if cd_shoot <= 0:
		bullet_pattern1(16, 1, PI/4)
		bullet_pattern1(16, -1, 3*PI/4)
		audio_node.play()
		cd_shoot = 0.02

func bullet_pattern1(speed, scale, offset) -> void:
	var angle = sin(elapsed_time * speed) * scale + offset
	var direction = Vector2(cos(angle),sin(angle))
	var bullet = spawn_bullet(bullet_circle, parent.position)
	bullet.velocity = direction * 300
	bullet.set_color(SpriteGroupBasicBullet.ColorType.BLUE, SpriteGroupBasicBullet.ColorVariant.LIGHT)

func spawn_lily() -> void:
	print("Spawned Lily")
	var direction = parent.position.direction_to(GameUtils.get_player().position)
	var cur_lily = spawn_bullet(bullet_lily, parent.position)
	cur_lily.velocity = direction * 400
	cur_lily.set_color(
		SpriteGroupBasicBullet.ColorType.RED, 
		SpriteGroupBasicBullet.ColorVariant.LIGHT
	)
	#cur_lily.add_entity_script(script_lily)

# bullet.global_position.direction_to(player.global_position)
