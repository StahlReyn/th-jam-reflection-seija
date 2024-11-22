class_name PopUps
extends Control
## Does Popups
## Chapter and Spellcard fastest, then timer and effects

@onready var control_bonus : Control = $Center/VBox/SpellBonus
@onready var control_timer : Control = $Center/VBox/FullList/Timer
@onready var control_chapter : Control = $Center/VBox/FullList/Chapter

@onready var timer_chapter : Timer = $TimerChapter

@onready var num_graze : Label = $Center/VBox/FullList/Chapter/Graze/Num
@onready var num_shoot : Label = $Center/VBox/FullList/Chapter/Shoot/Num
@onready var num_retry : Label = $Center/VBox/FullList/Chapter/Retry/Num
@onready var num_bonus : Label = $Center/VBox/FullList/Chapter/Bonus/Num

var displaying_bonus : bool = false
var displaying_timer : bool = false
var displaying_chapter : bool = false

func _ready() -> void:
	control_bonus.modulate.a = 0
	control_timer.modulate.a = 0
	control_chapter.modulate.a = 0

func _physics_process(delta: float) -> void:
	if displaying_bonus:
		control_bonus.modulate.a = MathUtils.expDecay(control_bonus.modulate.a, 1.0, 10.0, delta)
	if displaying_timer:
		control_timer.modulate.a = MathUtils.expDecay(control_timer.modulate.a, 1.0, 10.0, delta)
	if displaying_chapter:
		control_chapter.modulate.a = MathUtils.expDecay(control_chapter.modulate.a, 1.0, 10.0, delta)
	else:
		control_chapter.modulate.a = MathUtils.expDecay(control_chapter.modulate.a, 0.0, 10.0, delta)

func display_chapter() -> void:
	num_graze.text = str(GameVariables.get_chapter_graze())
	num_shoot.text = GameVariables.get_chapter_shoot_display()
	num_retry.text = str(GameVariables.get_chapter_deaths())
	num_bonus.text = str(GameVariables.get_section_bonus_final())
	displaying_chapter = true
	timer_chapter.start()

func _on_timer_chapter_timeout() -> void:
	displaying_chapter = false
