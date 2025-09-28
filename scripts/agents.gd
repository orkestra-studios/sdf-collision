class_name AgentsManager extends Node3D

static var instance : AgentsManager

@export var cell_size : int = 4

@export_subgroup("Flow Field")
@export var pathfinding_range : int = 10
@export var flow_target : Agent

var grid : Grid
var flowfield : Dictionary[Cell, float]
var target : Vector2i

var frame_count : int

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
	frame_count = 0
	
	grid = Grid.new(cell_size)
	var count : int = 0
	for child in get_children():
		if child is not Entity: continue
		var entity := child as Entity
		grid.get_cell(entity.location).insert(child)
		count += 1
	print(count, " entities loaded!")
	
	fill_cells()
	
func _process(_delta: float) -> void:
	#throttling
	#debug_draw(Color.WHITE)
	frame_count = (frame_count + 1) % 2
	if frame_count > 0: return
	if flow_target == null: return
	
	#debug_draw(Color.BLUE_VIOLET)
	var next_target : Vector2i = grid.index(flow_target.location)
	#if target == next_target: return
	generate_flowfield()
	target = next_target
	
func fill_cells():
	await get_tree().process_frame
	for x in range(-20, 20):
		for y in range(-20, 20):
			var loc = Vector2(x,y)
			if SDFScene.Main.query(loc).distance <= 0: continue
			var cell : Cell = grid.get_cell_at(Vector2i(loc), true)
			cell.debug_draw(Color.STEEL_BLUE)
		
static func get_cell(location : Vector2) -> Cell: return instance.grid.get_cell(location)

static func get_neighbor_cell(location : Vector2, direction : Vector2i) -> Cell:
	var idx := instance.grid.index(location)
	return instance.grid.get_cell_at(idx + direction)

static func set_potential(cell : Cell, potential : float, iteration : int = 0):
	
	# early exit #1: out-of-range case
	if iteration > instance.pathfinding_range: return 
	
	# early exit #2: the cell is already visited by a better path
	if instance.flowfield.has(cell) and instance.flowfield[cell] <= potential: return
		
	# update potential
	instance.flowfield[cell] = potential
	
	#propogate around neighbors
	var i = 0
	for dir in neighbor_dirs:
		var neighbor : Cell = instance.grid.get_cell_at(cell.id + dir)
		if neighbor == null: continue
		var propogate : float = potential + (1.94142 if i==1 else 1.0)
		set_potential(neighbor, propogate, iteration+1)
		i = (i+1) % 2
		
static func get_potential(cell : Cell) -> float:
	if instance.flowfield.has(cell): return instance.flowfield[cell]
	else: return instance.pathfinding_range + 1
	
func generate_flowfield():
	instance.flowfield.clear()
	var cell : Cell = grid.get_cell_at(target, true)
	set_potential(cell, 0)
	
func debug_draw(_c : Color):
	for cell in flowfield:
		var potential : float = flowfield[cell]
		var heatmap = heatmap_color(potential, 0, pathfinding_range)
		#DebugDraw3D.draw_text(Vectors.X_Z(cell.id) + Vector3.UP * 1.25, "%.2f" % potential, 60, heatmap, 0.1)
		#DebugDraw3D.draw_ray(Vectors.X_Z(cell.id), Vector3.UP, 0.8, heatmap, 0.1)
		var pos = Vectors.X_Z(cell.id) + Vector3.UP * 0.25
		DebugDraw3D.draw_sphere(pos, 0.05, heatmap)
		
func heatmap_color(value : float, min_value: float, max_value: float) -> Color:
	# Normalize value to 0..1
	var t = 1 - clamp((value - min_value) / (max_value - min_value), 0.0, 1.0)

	# Thermal vision palette: black → deep blue → purple → red → orange → yellow → white
	const colors = [
		Color(0, 0, 0.5),         # deep blue
		Color(0.5, 0, 1.0),       # purple
		Color(1.0, 0, 0),         # red
		Color(1.0, 0.5, 0),       # orange
		Color(1.0, 1.0, 0),       # yellow
		Color(1.0, 1.0, 1.0)      # white
	]

	var n = colors.size() - 1
	var scaled = t * n
	var i = int(floor(scaled))
	var f = scaled - i

	if i >= n:
		return colors[n]
	return colors[i].lerp(colors[i + 1], f)
