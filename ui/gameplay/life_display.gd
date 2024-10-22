extends HBoxContainer

@export_enum("LIFE", "BOMB") var type : int = 0

func _ready() -> void:
	var i : int = 1
	while i <= GameVariables.lives_max:
		var node = IconPieces.create_icon(type, i)
		add_child(node)
		i += 1
