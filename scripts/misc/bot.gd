class_name Bot extends Agent

const dirs : Array[Vector2] = [Vector2.ZERO, Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]

var wait : float = 0
var direction
	
func get_input() -> Vector2:
	wait -= get_physics_process_delta_time()
	if wait <= 0:
		wait = 1 + randf()
		direction = dirs.pick_random()
	elif query != null and query.distance < radius: # hit a wall
		wait *= 0.5
		
	return direction
