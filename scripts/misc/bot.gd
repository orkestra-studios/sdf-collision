class_name Bot extends Agent

@export var stop_range : float = 3

var _move : Vector2 = Vector2.ZERO
	
func get_input() -> Vector2:
	var dist : float = AgentsManager.get_path_distance(location)
	if dist <= stop_range: _move = _move.lerp(Vector2.ZERO, 0.25)
	else: _move = _move.lerp(AgentsManager.get_direction(location), 0.2)
	return _move

func _on_cell_changed(before : Cell, after : Cell) -> void:
	if is_instance_valid(before): AgentsManager.update_flowfield_cost(before.location, false)
	if is_instance_valid(after): AgentsManager.update_flowfield_cost(after.location, true)	
