class_name Grid extends RefCounted

static var cell_size : int = 4
var data : Dictionary[Vector2i, Cell]

func _init(size : int):
	cell_size = size
	data = {}

func get_cell(location : Vector2) -> Cell:
	var idx = index(location)
	return get_cell_at(idx)
	
func get_cell_at(idx : Vector2i, create : bool = true) -> Cell:
	if idx not in data: 
		if create: data[idx] = Cell.new(idx)
		else: return null
	return data[idx]
	
func get_neighbour(cell : Cell, dir : Vector2i) -> Cell:
	return get_cell_at(cell.id + dir, false)

func index(p: Vector2) -> Vector2i:
	return Vector2i(round(p.x / cell_size), round(p.y / cell_size))
