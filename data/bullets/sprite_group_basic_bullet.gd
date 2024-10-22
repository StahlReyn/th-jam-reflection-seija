class_name SpriteGroupBasicBullet
extends Sprite2D

enum ColorType { ## Colummn Number x
	BLACK,
	RED,
	MAGENTA,
	BLUE,
	CYAN,
	TEAL,
	GREEN,
	YELLOW,
	ORANGE,
}

enum ColorVariant { ## Row Number y
	LIGHT,
	LIGHT_BOLD,
	DARK,
	DARK_BOLD,
}

func set_color(type: int, variant: int) -> void:
	frame_coords.x = wrap(type, 0, ColorType.size())
	frame_coords.y = wrap(variant, 0, ColorVariant.size())

func set_random_color(variant: int) -> void:
	set_color(randi(), variant)
