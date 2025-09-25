class_name AgentsManager extends Node3D

static var instance : AgentsManager

@export var cell_size : int = 4

@export_subgroup("Flow Field")
@export var pathfinding_range : int = 10
@export var flow_target : Agent

var grid : Grid
var flowField : Dictionary[Cell, int]
var target : Vector2i

const neighbor_dirs : Array[Vector2i] = [
		Vector2i.RIGHT,
		Vector2i(1, 1),
		Vector2i.DOWN,
		Vector2i(-1, 1),
		Vector2i.LEFT,
		Vector2i(-1, -1),
		Vector2i.UP,
		Vector2i(1, -1)
]

func _ready() -> void:
	#singleton
	if instance != null:
		self.free()
		return	
	instance = self
	
	grid = Grid.new(cell_size)
	var count : int = 0
	for child in get_children():
		if child is not Entity: continue
		var entity := child as Entity
		grid.get_cell(entity.location).insert(child)
		count += 1
	print(count, " entities loaded!")
	
func _process(delta: float) -> void:
	if flow_target == null: return
	debug_draw(Color.BLUE_VIOLET)
	var next_target = grid.index(flow_target.location)
	if target == next_target: return
	instance.flowField.clear()
	var cell : Cell = grid.get_cell_at(target, true)
	set_potential(cell, 0)
	target = next_target

static func get_cell(location : Vector2) -> Cell: return instance.grid.get_cell(location)

static func get_neighbor_cell(location : Vector2, direction : Vector2i) -> Cell:
	var idx := instance.grid.index(location)
	return instance.grid.get_cell_at(idx + direction)

static func set_potential(cell : Cell, potential : int):
	
	# early exit #1: out-of-range case
	if potential > instance.pathfinding_range: return 
	
	# early exit #2: the cell is already visited 
	if instance.flowField.has(cell) and instance.flowField[cell] <= potential: return
	
	# early exit #3: static collider exists at the cell
	if SDFScene.Main.query(cell.id).distance <= 0: 
		instance.flowField[cell] = instance.pathfinding_range + 1
		return
		
	# update potential	
	instance.flowField[cell] = potential
	
	#propogate around neighbors
	var propogate : int = potential + 1
	for dir in neighbor_dirs:
		var neighbor : Cell = instance.grid.get_cell_at(cell.id + dir, false)
		if neighbor == null: continue
		else: set_potential(neighbor, propogate)
		
static func get_potential(cell : Cell) -> int:
	if instance.flowField.has(cell): return instance.flowField[cell]
	else: return instance.pathfinding_range + 1
	
func debug_draw(c : Color):
	for cell in flowField:
		var potential = str(flowField[cell])
		DebugDraw3D.draw_text(Vectors.X_Z(cell.id) + Vector3.UP * 1.25, potential, 60, c)
		DebugDraw3D.draw_ray(Vectors.X_Z(cell.id), Vector3.UP, 0.8, c)
