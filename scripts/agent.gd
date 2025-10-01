class_name Agent extends Entity

@export_subgroup("Parameters")
@export var speed: float = 5.0
@export var is_rendered : bool = false

var query : SDF.Query

var current : Cell
var neighbors : Array[Cell] = []

var frame_count: int = 0
var frame_thortle = 5 + randi() % 55

signal on_sdf_collision(other : SDFElement)
signal on_dynamic_collision(other : Entity)

var movement : Vector2 = Vector2.ZERO
var input : Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	
	frame_count = (frame_count + 1) % frame_thortle
	if is_rendered:  #thorttlings
		const t = 0.25
		input = input.lerp(get_input(), t)
		movement = movement.lerp(speed * delta * input, t)
		movement = movement.lerp(apply_dynamic_collision(movement, 0.1), t)
		movement = movement.lerp(apply_sdf_collision(movement), t)
		
		move(movement)
		update_cell()
	
func get_input() -> Vector2:
	var input_vec = Vector2.ZERO
	if Input.is_action_pressed("move_forward"): input_vec.y -= 1
	if Input.is_action_pressed("move_backward"): input_vec.y += 1
	if Input.is_action_pressed("move_left"): input_vec.x -= 1
	if Input.is_action_pressed("move_right"): input_vec.x += 1
	return input_vec.limit_length(1)
	
func apply_sdf_collision(dx : Vector2) -> Vector2:
	var loc = location
	#debug_sdf()
	query = SDFScene.Main.query(loc, dx.limit_length(radius));
	var diff = query.distance - radius
	if diff < 0:
		#print("inside: %.2f * (%.2f, %.2f)"%[diff, hitNormal.x, hitNormal.y])
		if diff <= -radius: dx = Vector2.ZERO
		else:
			var hitNormal = SDF.normal(loc, query.element)
			var correction : Vector2 = -diff * hitNormal
			dx = dx + correction
		on_sdf_collision.emit(query.element)
	return dx
	
func apply_dynamic_collision(dx : Vector2, inset : float = 0) -> Vector2:
	if current == null: return dx
	var loc = location
	for cell in neighbors:
		if cell == null: return dx
		for e in cell.entities:
			if e is not Entity: continue
			var entity = e as Entity
			var diff = loc - entity.location
			var dist = diff.length() - (radius + entity.radius - inset)
			#debug_line(global_position, agent.global_position, Color.ORCHID)
			if dist <= 0:
				dx -= diff.normalized() * dist
				on_dynamic_collision.emit(entity)
	#current.debug_draw(Color.DARK_ORCHID)
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
		AgentsManager.get_neighbor_cell(location, Vector2i(1, -1)),
		AgentsManager.get_neighbor_cell(location, Vector2i.DOWN),
		AgentsManager.get_neighbor_cell(location, Vector2i(-1, -1)),
		AgentsManager.get_neighbor_cell(location, Vector2i.LEFT),
		AgentsManager.get_neighbor_cell(location, Vector2i(-1, 1)),
		AgentsManager.get_neighbor_cell(location, Vector2i.UP),
		AgentsManager.get_neighbor_cell(location, Vector2i(1, 1))
	]

func _on_enter_screen(): is_rendered = true
func _on_exit_screen(): is_rendered = false
	
func debug_sdf():
	if not is_rendered: return
	if query != null and query.distance != INF:
		query.element._debug_draw(Color.ROYAL_BLUE)
		var closest_point = Vectors.X_Z(location - query.distance * SDF.normal(location, query.element))
		debug_line(global_position, closest_point, Color.ROYAL_BLUE)
		var midpoint = (global_position + query.element.position) / 2
		DebugDraw3D.draw_text(midpoint+1.5*Vector3.UP, "%.2f" % query.distance, 72, Color.ROYAL_BLUE)
		DebugDraw3D.draw_text(global_position+1.5*Vector3.UP, "%d" % query.count, 72, Color.ROYAL_BLUE)
		
func debug_line(from : Vector3, to : Vector3, color : Color):
	if not is_rendered: return
	DebugDraw3D.draw_line(from+Vector3.UP, to+Vector3.UP, color)
