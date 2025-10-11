@abstract
class_name Entity extends Node3D

const INERTIA : float = 0.08

@export var radius : float = 1.0
@export var mass : float = 1.0

var location : Vector2 : set = _set_location, get = _get_location
	
func _get_location() -> Vector2: return Vectors.XZ(global_position)
func _set_location(loc : Vector2) -> void: global_position = Vectors.X_Z(loc)

func move(direction : Vector2) -> void:
	if direction == Vector2.ZERO: return
	location += direction
