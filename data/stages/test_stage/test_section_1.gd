extends SectionScript

@onready var enemy_fairy : PackedScene = EnemyUtils.scene_dict["lesser_fairy"]
@onready var enemy_fairy_boss : PackedScene = EnemyUtils.scene_dict["lesser_fairy_boss"]
@onready var bullet_circle_small : PackedScene = BulletUtils.scene_dict["circle_small"]

@onready var entity_script_1 : GDScript = preload("res://data/movement/movement_test.gd")
@onready var entity_script_2 : GDScript = preload("res://data/movement/movement_test_2.gd")
@onready var entity_script_3 : GDScript = preload("res://data/movement/movement_test_3.gd")
@onready var entity_script_4 : GDScript = preload("res://data/movement/movement_test_4.gd")

var cd1 : float = 3.0
var count1 : int = 10
var cd1_loop : float = 0.0
var cd1_count_loop : int = 0

var cd2 : float = 1.0
var cd_big : float = 1.0
var cd_count : int = 0

var cd_fps: float = 1
var cd_fps_count: int = 1

func _ready() -> void:
	super()
	duration = 60.0

func _physics_process(delta: float) -> void:
	super(delta)

	cd1 -= delta
	cd2 -= delta
	cd_big -= delta
	
	if count1 <= 0:
		cd1_loop = 0.0
		count1 = 10
		cd1 += 3.0
		cd1_count_loop += 1
	
	if cd1 <= 0:
		cd1_loop -= delta
		while cd1_loop <= 0 and count1 > 0:
			var enemy = spawn_enemy(enemy_fairy, Vector2(randi_range(150,400), -100))
			if cd1_count_loop % 3 == 2:
				enemy.add_entity_script(entity_script_1)
				enemy.main_sprite.set_type(SpriteGroupFairy.Type.YELLOW)
			elif cd1_count_loop % 3 == 1:
				enemy.add_entity_script(entity_script_2)
				enemy.main_sprite.set_type(SpriteGroupFairy.Type.RED)
			else:
				enemy.add_entity_script(entity_script_1)
				enemy.main_sprite.set_type(SpriteGroupFairy.Type.GREEN)
			count1 -= 1
			cd1_loop += 0.2
	
	
	if cd2 <= 0 and false:
		var bullet1 = spawn_bullet(bullet_circle_small)
		bullet1.position.x = cos(time_active * 2) * 50 + 700
		bullet1.position.y = -50
		bullet1.velocity.y = 200
		var bullet2 = spawn_bullet(bullet_circle_small)
		bullet2.position.x = -cos(time_active * 2) * 50 + 50
		bullet2.position.y = -50
		bullet2.velocity.y = 200
		cd2 += 0.05
	
	
	if cd_big <= 0:
		print("BIG FAIRY ", cd_count)
		if cd_count % 2 == 0:
			var enemy : Enemy = spawn_enemy(enemy_fairy_boss, Vector2(400, -100))
			#enemy.call_deferred("add_entity_script", entity_script_3)
			enemy.add_entity_script(entity_script_3)
			enemy.main_sprite.set_type(SpriteGroupFairy.Type.BLUE)
		else:
			var positions = [
				Vector2(200, -100), 
				Vector2(600, -100)
			]
			for pos in positions:
				var enemy :  = spawn_enemy(enemy_fairy_boss, pos)
				enemy.add_entity_script(entity_script_4)
				enemy.main_sprite.set_type(SpriteGroupFairy.Type.YELLOW)
		cd_big += 15
		cd_count += 1
