@abstract
class_name Entity extends Node3D

@export var radius: float = 1.0

var location : Vector2 : set = _set_location, get = _get_location
	
func _get_location() -> Vector2: return Vectors.XZ(global_position)
func _set_location(loc : Vector2): global_position = Vectors.X_Z(loc)
