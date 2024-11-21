extends SectionDialogueScript

@onready var dialogue_set_data : DialogueSet = preload("res://data/stages/test_new/dialogues/dialogue_nue.tres")
@onready var enemy_boss : PackedScene = preload("res://data/enemies/bosses/boss_nue_houjuu.tscn")

var boss : EnemyBoss
var boss_target_position : Vector2 = Vector2(385, 385)

func _ready() -> void:
	dialogue_set = dialogue_set_data
	dialogue_delay = 2.0
	super()
	boss = spawn_enemy(enemy_boss, Vector2(385,-50))
	boss.stop_all_despawn()
	boss.set_inactive()

func _physics_process(delta: float) -> void:
	super(delta)
	boss.position = lerp(boss.position, boss_target_position, delta * 2)
