class_name Bot extends Agent

const dirs : Array[Vector2] = [Vector2.ZERO, Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]

var wait : float = 0
var direction

var following : bool = false
	
func get_input() -> Vector2:
	wait -= get_physics_process_delta_time()
	if following || wait <= 0:
		following = true
		wait = 1 + randf()
		direction = pick_closest_route() #dirs.pick_random()
	elif query != null and query.distance < radius: # hit a wall
		wait *= 0.5

	return direction

func pick_closest_route() -> Vector2:
	var route : Vector2i = Vector2.ZERO
	var distance : float = AgentsManager.instance.pathfinding_range + 1
	for dir in AgentsManager.neighbor_dirs:
		var idx : Vector2i = AgentsManager.instance.grid.index(location)
		var cell : Cell = AgentsManager.get_neighbor_cell(idx, dir)
		if cell == null: continue
		var potential : float = AgentsManager.get_potential(cell)
		if potential < distance:
			distance = potential
			route = dir
	
	if distance <= radius * 1.1: return Vector2.ZERO
	return route
