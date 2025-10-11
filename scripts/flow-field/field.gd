class_name FlowField extends Node

@export var width : int
@export var height : int

@export var cell_size : float

# predefined cost values
enum CellType {
	SOLID = 1000,
	AVOID = 5,
	EMPTY = 1,
	GOAL = -1
}

const check_range : Vector2i = Vector2i(6,10)

const neighbor_dirs : Array[Vector2i] = [
	Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1),
	Vector2i(1,1), Vector2i(-1,1), Vector2i(1,-1), Vector2i(-1,-1)
]

# normalized directions for building flow
const sqrt2 : float = 1.4142135
const inv_sqrt2 : float = 1/sqrt2
const normalized_dirs : Array[Vector2] = [
	Vector2(1,0), Vector2(-1,0), Vector2(0,1), Vector2(0,-1),
	Vector2(inv_sqrt2, inv_sqrt2), Vector2(-inv_sqrt2, inv_sqrt2), Vector2(inv_sqrt2, -inv_sqrt2), Vector2(-inv_sqrt2, -inv_sqrt2)
]

var costs : PackedInt32Array
var integration : PackedFloat32Array
var flow : PackedVector2Array

var processing : bool

func _init() -> void:
	var size : int = width * height
	@warning_ignore("return_value_discarded")
	costs.resize(size)
	integration.resize(size)
	flow.resize(size)
	
	processing = false

# helpers
func idx(x: int, y: int) -> int:
	return y * width + x

func in_bounds(x: int, y: int) -> bool:
	return x>=0 and y>=0 and x<width and y<height
	
func world_to_grid(world_pos: Vector2) -> Vector2i:
	var gx : int = roundi(world_pos.x / cell_size + float(width) / 2.0)
	var gy : int = roundi(world_pos.y / cell_size + float(height) / 2.0)
	return Vector2i(gx, gy)

func grid_to_world(grid_pos: Vector2i) -> Vector2:
	return Vector2(
		(grid_pos.x - float(width) / 2.0) * cell_size,
		(grid_pos.y - float(height) / 2.0) * cell_size
	)

func set_cost(x:int, y:int, c:int) -> void:
	costs[idx(x,y)] = c
	
func get_cost(x:int, y:int) -> int:
	return costs[idx(x,y)]

func build_integration(goal:Vector2i) -> void:
	
	if processing: return
	processing = true
	
	integration.fill(CellType.SOLID - 1)

	var open : Queue = Queue.new(120)
	integration[idx(goal.x, goal.y)] = -1
	open.push_back(goal)
	
	while not open.is_empty():
		var cur : Vector2i = open.pop_front()
		var cidx : int = idx(cur.x, cur.y)
		
		for dir : Vector2i in neighbor_dirs:
			var nx : int = cur.x + dir.x
			var ny : int = cur.y + dir.y
			
			if not in_bounds(nx, ny): continue
			
			var dist : Vector2i = Vector2i(abs(nx - goal.x), abs(ny - goal.y)) 
			if dist.x > check_range.x or dist.y > check_range.y : continue
			
			# corner-cut check for diagonals
			if dir.x != 0 and dir.y != 0:
				if costs[idx(nx, cur.y)] >= CellType.SOLID: continue
				if costs[idx(cur.x, ny)] >= CellType.SOLID: continue

			var nidx : int = idx(nx, ny)
			var step_cost : float = costs[nidx] * (1.0 if dir.x==0 or dir.y==0 else sqrt2)
			var new_cost : float = integration[cidx] + step_cost
			if new_cost < integration[nidx]:
				integration[nidx] = new_cost
				open.push_back(Vector2i(nx,ny))
	
	processing = false
	
func build_flow() -> void:
	var neighbors : Array = range(8)
	for y : int in range(height):
		for x : int in range(width):
			if not in_bounds(x, y): continue
			var i : int = idx(x, y)
			var lowest : float = integration[i]
			if lowest > 32: continue
			var best : Vector2 = Vector2.ZERO
			for dir_idx : int in neighbors:
				var dir : Vector2i = neighbor_dirs[dir_idx]
				var nx : int = x + dir.x
				var ny : int = y + dir.y
				if not in_bounds(nx, ny): continue
				var ni : int = idx(nx, ny)
				if integration[ni] < lowest:
					lowest = integration[ni]
					best = normalized_dirs[dir_idx]
			flow[i] = best #flow[i].slerp(best, 0.2)

func get_direction(world_pos:Vector2) -> Vector2:
	var grid : Vector2i = world_to_grid(world_pos)
	if not in_bounds(grid.x, grid.y): return Vector2.ZERO
	return flow[idx(grid.x, grid.y)]

func get_distance(world_pos:Vector2) -> float:
	var grid : Vector2i = world_to_grid(world_pos)
	if not in_bounds(grid.x, grid.y): return 0
	return integration[idx(grid.x, grid.y)]

func debug_draw() -> void:
	const arrow_color : Color = Color(Color.BLACK, 0.5)
	for y : int in range(height):
		for x : int in range(width):
			#if not in_bounds(x,y): continue
			var pos : Vector2 = grid_to_world(Vector2i(x, y))
			var dir : Vector2 = get_direction(pos)
			#var cost : float = integration[idx(x,y)]
			#var heatmap : Color = heatmap_color(cost, 0, 20)
			#DebugDraw3D.draw_square(Vectors.X_Z(pos) + Vector3.UP * 0.2, cell_size, heatmap)
			DebugDraw3D.draw_arrow_ray(Vectors.X_Z(pos) + Vector3.UP * 0.5 - Vectors.X_Z(dir) * 0.4, Vectors.X_Z(dir), 0.8, arrow_color, 0.25, true)
			
func heatmap_color(value : float, min_value: float, max_value: float, inverted : bool = false) -> Color:
	# Normalize value to 0..1
	var ft : float = clamp((value - min_value) / (max_value - min_value), 0.0, 1.0)
	var t : float = ft if inverted else 1 - ft

	# Thermal vision palette: black → deep blue → purple → red → orange → yellow → white
	const colors : Array[Color] = [
		Color(0, 0, 0.5),         # deep blue
		Color(0.5, 0, 1.0),       # purple
		Color(1.0, 0, 0),         # red
		Color(1.0, 0.5, 0),       # orange
		Color(1.0, 1.0, 0),       # yellow
		Color(1.0, 1.0, 1.0)      # white
	]

	var n : int = colors.size() - 1
	var scaled : float = t * n
	var i : int = floori(scaled)
	var f : float = scaled - i

	if i >= n:
		return colors[n]
	return colors[i].lerp(colors[i + 1], f)
