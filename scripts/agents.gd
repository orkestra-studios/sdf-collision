class_name AgentsManager extends Node3D

static var instance : AgentsManager

@export var cell_size : int = 4

var grid : Grid

func _ready() -> void:
	#singleton
	if instance != null:
		self.free()
		return	
	instance = self
	
	grid = Grid.new(cell_size)
	var count : int = 0
	for child in get_children():
		if child is not Agent: continue
		var agent := child as Agent
		grid.get_cell(agent.location).insert(child)
		count += 1
	print(count, " agents loaded!")

static func get_cell(location : Vector2) -> Cell: return instance.grid.get_cell(location)
static func get_neighbor_cell(location : Vector2, direction : Vector2i) -> Cell:
	var idx := instance.grid.index(location)
	return instance.grid.get_cell_at(idx + direction)
