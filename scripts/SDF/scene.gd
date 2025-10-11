class_name SDFScene extends Node3D

static var Main : SDFScene

@export var cell_size : int = 4
var grid : Dictionary[Vector2i, SDFCell]

var proximity : SDFCell = SDFCell.new()

func _ready() -> void:
	# singleton instance
	if Main != null:
		self.free()
		return
	Main = self
	
	grid = {}
	load_elements()
	
func query(to : Vector2, dx : Vector2 = Vector2.ZERO) -> SDF.Query: 
	var idx : Vector2i = _cell_index(to)
	
	# create a temporary cell around the query position
	proximity.location = idx * cell_size
	proximity.setup()
	proximity.merge(grid.get(idx))
	
	# add more cells onwards of movement direction
	var dir : Vector2 = dx.normalized()
	var fwd : Vector2i = _cell_index(to + dir * cell_size * 0.5)
	var lft : Vector2i = _cell_index(to + dir.rotated(PI/4) * cell_size * 0.5)
	var rgt : Vector2i = _cell_index(to + dir.rotated(-PI/4) * cell_size * 0.5)
	proximity.merge(grid.get(fwd))
	proximity.merge(grid.get(lft))
	proximity.merge(grid.get(rgt))
	
	var result : SDF.Query = proximity.query(to)
	#proximity._debug_draw(Color.STEEL_BLUE)
		
	return result

func load_elements() -> void:
	for child : Node in get_children():
		if child is not SDFElement: continue
		var element : SDFElement = child as SDFElement
		
		element.setup()
		var bounds : Rect2    = element.bounds()
		var start  : Vector2i = _cell_index(bounds.position)
		var end    : Vector2i = _cell_index(bounds.position + bounds.size)
		
		for x : int in range(start.x, end.x+1):
			for y : int in range(start.y, end.y+1):
				var idx : Vector2i = Vector2i(x, y)
				if idx not in grid:
					grid[idx] = SDFCell.new()
					grid[idx].location = Vector2(idx * cell_size)
					grid[idx].setup()
				grid[idx].insert(element)
				
func _cell_index(p: Vector2) -> Vector2i:
	return Vector2i(round(p.x / cell_size), round(p.y / cell_size))

class SDFCell extends Structure:
	
	var location : Vector2
	
	func setup() -> void:
		elements = {}
		var cell_size : float = 1.0 * SDFScene.Main.cell_size
		var size : Vector2 = Vector2(cell_size, cell_size)
		aabb = Rect2(location - size * 0.5, size)
		
	func insert(element : SDFElement) -> void: elements.set(element, true)
	
	func merge(other : SDFCell) -> void:
		if other == null: return
		elements.merge(other.elements)
		aabb = aabb.merge(other.aabb)
		
	func debug_draw(c : Color) -> void:
		super._debug_draw(c)
