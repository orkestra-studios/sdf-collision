class_name Agent extends Node3D

@export_subgroup("Parameters")
@export var radius: float = 1.0
@export var speed: float = 5.0
@export var is_rendered : bool = false

var query : SDF.Query

var current : Cell
var neighbors : Array[Cell] = []
var location : Vector2 : set = _set_location, get = _get_location

var frame_count: int = 0
var frame_thortle = 5 + randi() % 55

func _physics_process(delta: float) -> void:
	
	frame_count = (frame_count + 1) % frame_thortle
	if is_rendered or frame_count == 0:  #thortling
		
		var input = get_input()
		var dx = speed * delta * input
		dx = apply_dynamic_collision(dx, 0.2)
		dx = apply_sdf_collision(dx)
		
		move(dx)
		update_cell()
	
func get_input() -> Vector2:
	var input_vec = Vector2.ZERO
	if Input.is_action_pressed("move_forward"): input_vec.y -= 1
	if Input.is_action_pressed("move_backward"): input_vec.y += 1
	if Input.is_action_pressed("move_left"): input_vec.x -= 1
	if Input.is_action_pressed("move_right"): input_vec.x += 1
	return input_vec.limit_length(1)

func move(direction : Vector2):
	if direction == Vector2.ZERO: return
	location += direction
	
func apply_sdf_collision(dx : Vector2) -> Vector2:
	var loc = location
	query = SDFScene.Main.distance(loc + dx);
	#debug_sdf()
	var diff = query.distance - radius
	if diff < 0:
		var hitNormal = sdf_normal(loc, query.element)
		var correction : Vector2 = -diff * hitNormal
		#print("inside: %.2f * (%.2f, %.2f)"%[diff, hitNormal.x, hitNormal.y])
		dx = dx + correction
	return dx
	
func apply_dynamic_collision(dx : Vector2, inset : float = 0) -> Vector2:
	if current == null: return dx
	var loc = location
	for cell in neighbors:
		for element in cell.elements:
			if element is not Agent: continue
			var agent = element as Agent
			var diff = loc - agent.location
			var dist = diff.length() - (radius + agent.radius - inset)
			#debug_line(global_position, agent.global_position, Color.ORCHID)
			if dist <= 0: dx -= diff.normalized() * dist
	return dx
	
func update_cell():
	var next : Cell = AgentsManager.get_cell(location)
	if next == current: return
	if current != null: current.remove(self)
	next.insert(self)
	current = next
	neighbors = [
		current,
		AgentsManager.get_neighbor_cell(location, Vector2i.RIGHT),
		AgentsManager.get_neighbor_cell(location, Vector2i.RIGHT + Vector2i.DOWN),
		AgentsManager.get_neighbor_cell(location, Vector2i.DOWN),
		AgentsManager.get_neighbor_cell(location, Vector2i.DOWN + Vector2i.LEFT),
		AgentsManager.get_neighbor_cell(location, Vector2i.LEFT),
		AgentsManager.get_neighbor_cell(location, Vector2i.LEFT + Vector2i.UP),
		AgentsManager.get_neighbor_cell(location, Vector2i.UP),
		AgentsManager.get_neighbor_cell(location, Vector2i.UP + Vector2i.RIGHT)
	]
	
func _get_location() -> Vector2: return Vectors.XZ(global_position)
func _set_location(loc : Vector2): global_position = Vectors.X_Z(loc)

func _on_enter_screen(): is_rendered = true
func _on_exit_screen(): is_rendered = false

func sdf_normal(pos: Vector2, element : SDFElement, eps: float = 0.01) -> Vector2:
	var dx = element.distance(pos + Vector2(eps, 0)).distance - element.distance(pos - Vector2(eps, 0)).distance
	var dy = element.distance(pos + Vector2(0, eps)).distance - element.distance(pos - Vector2(0, eps)).distance
	var n = Vector2(dx, dy)
	return n.normalized()
	
func debug_sdf():
	if not is_rendered: return
	if query != null and query.distance != INF:
		query.element._debug_draw(Color.ROYAL_BLUE)
		var closest_point = Vectors.X_Z(location - query.distance * sdf_normal(location, query.element))
		debug_line(global_position, closest_point, Color.ROYAL_BLUE)
		var midpoint = (global_position + query.element.position) / 2
		DebugDraw3D.draw_text(midpoint+1.5*Vector3.UP, "%.2f" % query.distance, 72, Color.ROYAL_BLUE)
		DebugDraw3D.draw_text(global_position+1.5*Vector3.UP, "%d" % query.count, 72, Color.ROYAL_BLUE)
		
func debug_line(from : Vector3, to : Vector3, color : Color):
	if not is_rendered: return
	DebugDraw3D.draw_line(from+Vector3.UP, to+Vector3.UP, color)
