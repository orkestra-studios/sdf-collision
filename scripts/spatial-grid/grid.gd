class_name Grid extends RefCounted

var cell_size : int = 4
var data : Dictionary[Vector2i, Cell]

func _init(size : int):
	cell_size = size
	data = {}

func get_cell(position : Vector2) -> Cell:
	var idx = index(position)
	return get_cell_at(idx)
	
func get_cell_at(idx : Vector2i) -> Cell:
	if idx not in data: data[idx] = Cell.new()
	return data[idx]

func index(p: Vector2) -> Vector2i:
	return Vector2i(round(p.x / cell_size), round(p.y / cell_size))
