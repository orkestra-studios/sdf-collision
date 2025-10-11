class_name Follower extends Agent

@export var stop_range : float = 1

var dist : float
var _move : Vector2 = Vector2.ZERO
	
func get_input() -> Vector2:
	var loc : Vector2 = location
	dist = AgentsManager.get_squared_distance(loc)
	var dir : Vector2 = AgentsManager.get_direction(loc)
	if dist > pow(stop_range, 2): _move = _move.lerp(dir, 0.2)
	elif dist < pow(stop_range - radius, 2): _move = _move.lerp(-dir, 0.2)
	else: _move = _move.lerp(Vector2.ZERO, 0.25)
	return _move
