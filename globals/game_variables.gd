extends Node

enum Difficulties {
	EASY,
	NORMAL,
	HARD,
	LUNATIC
}

static var power_max : int = 400
static var point_value_max : int = 300000
static var lives_max : int = 8
static var bombs_max : int = 8
static var life_pieces_max : int = 3
static var bomb_pieces_max : int = 5

var game_time : float = 0.0
var score : int = 0
var graze : int = 0
var point_value : int = 10000

var lives : int = 3
var bombs : int = 3
var life_pieces : int = 0
var bomb_pieces : int = 0
##Powers are in integer for simplicity, display divides by 100
var power : int = 0

var deaths : int = 0
var enemy_spawned : int = 0
var shoot_down : int = 0
var section_bonus : int = 0

# For use in counting chapter
var prev_deaths: int = 0
var prev_graze : int = 0
var prev_enemy_spawned : int = 0
var prev_shoot_down : int = 0

func reset_variables() -> void:
	print("==== RESET GAME VARIABLES ====")
	game_time = 0.0
	score = 0
	graze = 0
	lives = 3
	bombs = 3
	power = 0
	point_value = 10000
	
	section_bonus = 0
	deaths = 0
	enemy_spawned = 0
	shoot_down = 0
	reset_chapter_variables()

func reset_chapter_variables() -> void:
	section_bonus = 0
	prev_deaths = deaths
	prev_graze = graze
	prev_enemy_spawned = enemy_spawned
	prev_shoot_down = shoot_down

func get_chapter_graze() -> int:
	return graze - prev_graze

func get_chapter_shoot_ratio() -> float:
	if enemy_spawned - prev_enemy_spawned == 0:
		return 0
	return (
		float(shoot_down - prev_shoot_down) / 
		float(enemy_spawned - prev_enemy_spawned)
	)

func get_chapter_deaths() -> int:
	return deaths - prev_deaths

func get_chapter_shoot_display():
	return percentage_display(get_chapter_shoot_ratio())

func get_section_bonus_final() -> int:
	return int(section_bonus * get_chapter_shoot_ratio())

func add_section_bonus_to_score() -> void:
	add_score(get_section_bonus_final())

func add_score(value: int) -> void:
	score += value

func add_graze_count(value:int = 1) -> void:
	graze += value

func add_lives(value:int = 1) -> void:
	lives += value
	lives = clamp(lives, 0, lives_max)
	AudioManager.play_item_get()

func lose_lives(value:int = 1) -> void: ## Remove counterpart for clarity and debugging purposes
	lives -= value
	lives = clamp(lives, 0, lives_max)

func add_bombs(value:int = 1) -> void:
	bombs += value
	bombs = clamp(bombs, 0, bombs_max)
	AudioManager.play_item_get()

func lose_bombs(value:int = 1) -> void:
	bombs -= value
	bombs = clamp(bombs, 0, bombs_max)

func add_life_pieces(value:int = 1) -> void:
	life_pieces += value
	update_pieces()

func add_bomb_pieces(value:int = 1) -> void:
	bomb_pieces += value
	update_pieces()
	
func update_pieces() -> void:
	if life_pieces >= life_pieces_max:
		add_lives(life_pieces / life_pieces_max) # Integer does floor division
		life_pieces = life_pieces % life_pieces_max # Remainder pieces
	if bomb_pieces >= bomb_pieces_max:
		add_bombs(bomb_pieces / bomb_pieces_max) # Integer does floor division
		bomb_pieces = bomb_pieces % bomb_pieces_max # Remainder pieces

func add_power(value:int = 1) -> void:
	power += value
	power = clamp(power, 0, power_max)

func lose_power(value:int = 1) -> void:
	power += value
	power = clamp(power, 0, power_max)

func get_score_display():
	return thousands_sep(score)

func get_power_display():
	return two_decimal_int(power) + "/" + two_decimal_int(power_max)

func get_point_value_display():
	return thousands_sep(point_value)

func get_graze_display():
	return thousands_sep(graze)

func get_life_piece_display():
	return "(" + str(life_pieces) + "/" + str(life_pieces_max) + ")"

func get_bomb_piece_display():
	return "(" + str(bomb_pieces) + "/" + str(bomb_pieces_max) + ")"

static func two_decimal_int(number : int) -> String:
	return "%.2f" % (float(number) / 100)

static func percentage_display(number : float) -> String:
	return "%.1f" % (float(number) * 100) + "%"

static func thousands_sep(number, prefix='') -> String:
	number = int(number)
	var neg = false
	if number < 0:
		number = -number
		neg = true
	var string = str(number)
	var mod = string.length() % 3
	var res = ""
	for i in range(0, string.length()):
		if i != 0 && i % 3 == mod:
			res += ","
		res += string[i]
	if neg: res = '-'+prefix+res
	else: res = prefix+res
	return res
