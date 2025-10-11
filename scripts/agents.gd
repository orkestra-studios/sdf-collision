class_name AgentsManager extends Node3D

static var instance : AgentsManager

@export var cell_size : int = 4

@export_subgroup("Flow Field")
@export var field : FlowField
@export var flow_target : Agent
const SEPARATION : int = 10

var grid : Grid
var flowfield : Dictionary[Cell, float]
var target : Vector2i

func _ready() -> void:
	#singleton
	if instance != null:
		self.free()
		return
	instance = self
	
	grid = Grid.new(cell_size)
	var count : int = 0
	for child : Node in get_children():
		if child is not Entity: continue
		var entity : Entity = child as Entity
		grid.get_cell(entity.location).insert(child)
		count += 1
	print(count, " entities loaded!")
	
	generate_flow_field()
	
func _process(_delta: float) -> void:
	debug_draw(Color.WHITE)
	#if Engine.get_process_frames() % 2 > 0: return #throttling
	if flow_target == null: return
	update_flow_field(flow_target.location)
		
static func get_cell(location : Vector2) -> Cell: return instance.grid.get_cell(location)

static func get_neighbor_cell(location : Vector2, direction : Vector2i) -> Cell:
	var idx : Vector2i = instance.grid.index(location)
	return instance.grid.get_cell_at(idx + direction)
	
func generate_flow_field() -> void:
	field._init()
	if field == null: return
	await get_tree().process_frame
	for x : int in range(-20, 20):
		for y : int in range(-20, 20):
			var loc : Vector2i = Vector2i(x,y)
			if SDFScene.Main.query(loc).distance <= 0: field.set_cost(x+20, y+20, FlowField.CellType.SOLID)
			else: field.set_cost(x+20, y+20, FlowField.CellType.EMPTY)
			
func update_flow_field(goal : Vector2) -> void:
	if Input.is_action_pressed("debug"):field.debug_draw()
	var _goal : Vector2i = field.world_to_grid(goal)
	#if target == _goal: return
	target = _goal
	field.build_integration(target)
	field.build_flow()
	
static func update_flowfield_cost(location : Vector2, entered : bool) -> void:
	var idx : Vector2i = instance.field.world_to_grid(location)
	var cost : int = instance.field.get_cost(idx.x, idx.y)
	instance.field.set_cost(idx.x, idx.y,
		min(FlowField.CellType.SOLID-1, cost + SEPARATION) if entered else max(FlowField.CellType.EMPTY, cost - SEPARATION)
	)
	
static func get_direction(from : Vector2) -> Vector2:
	return instance.field.get_direction(from)
	
static func get_path_distance(from : Vector2) -> float:
	return instance.field.get_distance(from)
	
static func get_squared_distance(from : Vector2) -> float:
	return instance.flow_target.location.distance_squared_to(from)
	
	
func debug_draw(_c : Color) -> void:
	DebugDraw2D.set_text("FPS", Engine.get_frames_per_second(), 0, _c)
