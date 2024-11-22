class_name MathUtils
extends Node

static func expDecay(a, b, decay, dt):
	return lerp(a, b, 1 - exp(-decay * dt))

static func expDecayAngle(a, b, decay, dt):
	return lerp_angle(a, b, 1 - exp(-decay * dt))

static func get_random_direction_vector() -> Vector2:
	return Vector2(randf_range(-1,1),randf_range(-1,1)).normalized()
