extends Node

func get_random_direction_vector() -> Vector2:
	return Vector2(randf_range(-1,1),randf_range(-1,1)).normalized()
