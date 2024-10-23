extends EntityScript

@onready var bullet_circle : PackedScene = BulletUtils.scene_dict["knife"]
@onready var audio_shoot : AudioStream = preload("res://assets/audio/sfx/hit_noise_fade.wav")

var player : Player
var audio_node : Node

var cd_shoot : float

var elapsed_time : float = 0.0
var section_time : float = 0.0

var cur_velocity : Vector2 = Vector2(0,0)
var part = 0

var shot_count : int = 0

func _ready() -> void:
	player = GameUtils.get_player()
	call_deferred("setup_enemy")

func set_stat():
	if parent is Enemy:
		parent.mhp = 160
		parent.reset_hp()
		parent.drop_power = 15
		parent.drop_point = 10
		parent.drop_life_piece = 1

func setup_enemy():
	set_stat()
	audio_node = AudioStreamPlayer2D.new()
	audio_node.set_stream(audio_shoot)
	parent.add_child(audio_node)

func physics_process_active(delta: float) -> void:
	elapsed_time += delta
	section_time += delta
	cd_shoot -= delta
	
	match part:
		0:
			cur_velocity.y = 300
			shot_count = 0
			check_part_cd(0.0)
		1:
			cur_velocity.y += -100 * delta
			check_part_cd(3.0)
		2:
			shoot_1()
			check_part_cd(5.0)
		3:
			cur_velocity.y += -300 * delta
			check_part_cd(10.0)
				
	parent.velocity = cur_velocity

func check_part_cd(time: float) -> void: ## How long next section last
	if section_time > time:
		part += 1
		section_time = 0.0
		print(part)

func shoot_1() -> void:
	if cd_shoot <= 0:
		shot_count += 1
		bullet_pattern1(4, 1, 0)
		bullet_pattern1(4, 1, PI)
		audio_node.play()
		cd_shoot = 0.02

func bullet_pattern1(speed, scale, offset) -> void:
	var angle = elapsed_time * speed * scale + offset
	var direction = Vector2(cos(angle),sin(angle))
	var bullet = spawn_bullet(bullet_circle, parent.position)
	var bullet_speed = 150 + (shot_count * 3)
	bullet.velocity = direction * bullet_speed
	bullet.set_color(shot_count, SpriteGroupBasicBullet.ColorVariant.LIGHT)

# bullet.global_position.direction_to(player.global_position)
