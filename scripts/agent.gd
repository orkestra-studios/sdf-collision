class_name Agent extends Entity

@export_subgroup("Parameters")
@export var speed: float = 5.0
@export var is_rendered : bool = false

var query : SDF.Query

var current : Cell
var neighbors : Array[Cell] = []
signal cell_changed(before : Cell, after : Cell)

var frame_count: int = 0
var frame_thortle : int = 5 + randi() % 55

signal sdf_collision(other : SDFElement)
signal dynamic_collision(other : Entity)

var movement : Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	if is_rendered:
		var input : Vector2 = get_input()
		#_debug_draw(Color.BLACK)
		movement = movement.lerp(speed * delta * input, 0.5)
		movement = movement.lerp(apply_dynamic_collision(movement, 0.1), 0.25)
		movement = apply_sdf_collision(movement)
		
		move(movement)
		update_cell()
		
func get_input() -> Vector2: return Vector2.ZERO
	
func apply_sdf_collision(dx : Vector2) -> Vector2:
	var loc : Vector2 = location
	#debug_sdf()
	query = SDFScene.Main.query(loc, dx.limit_length(radius));
	var diff : float = query.distance - radius
	if diff < 0:
		var hitNormal : Vector2 = SDF.normal(loc, query.element)
		var correction : Vector2 = -diff * hitNormal * 0.5
		dx = dx + correction
		sdf_collision.emit(query.element)
	return dx
	
func apply_dynamic_collision(dx : Vector2, inset : float = 0) -> Vector2:
	if current == null: return dx
	var loc : Vector2 = location
	for cell : Cell in neighbors:
		if cell == null: return dx
		for entity : Entity in cell.entities:
			var diff : Vector2 = loc - entity.location
			var dist : float = diff.length() - (radius + entity.radius - inset)
			if dist <= 0:
				var reaction : Vector2 = diff.normalized() * dist * 0.1
				var mass_ratio : float = mass / (entity.mass + PI/1000)
				dx -= reaction / mass_ratio
				entity.move(reaction * mass_ratio)
				dynamic_collision.emit(entity)
	#current.debug_draw(Color.DARK_ORCHID)
	return dx
	
func update_cell() -> void:
	var next : Cell = AgentsManager.get_cell(location)
	if next == current: return
	if current != null: current.remove(self)
	next.insert(self)
	cell_changed.emit(current, next)
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

func _on_enter_screen() -> void: is_rendered = true
func _on_exit_screen() -> void: is_rendered = false
	
func debug_sdf() -> void:
	if not is_rendered: return
	if query != null and query.distance != INF:
		query.element._debug_draw(Color.ROYAL_BLUE)
		var closest_point : Vector3 = Vectors.X_Z(location - query.distance * SDF.normal(location, query.element))
		debug_line(global_position, closest_point, Color.ROYAL_BLUE)
		var midpoint : Vector3 = (global_position + query.element.position) / 2
		DebugDraw3D.draw_text(midpoint+1.5*Vector3.UP, "%.2f" % query.distance, 72, Color.ROYAL_BLUE)
		DebugDraw3D.draw_text(global_position+1.5*Vector3.UP, "%d" % query.count, 72, Color.ROYAL_BLUE)
		
func debug_line(from : Vector3, to : Vector3, color : Color) -> void:
	if not is_rendered: return
	DebugDraw3D.draw_line(from+Vector3.UP, to+Vector3.UP, color)
	
func _debug_draw(color : Color) -> void:
	var look_dir : Vector3 = Vectors.X_Z(movement.normalized())
	var pos : Vector3 = Vectors.X_Z(location) + Vector3.UP * radius
	DebugDraw3D.draw_arrow_ray(pos, look_dir, radius + 0.36, color, 0.36, true)
