class_name Cell extends RefCounted

var id : Vector2i
var entities : Dictionary[Entity, bool]
var location : Vector2

func _init(_id : Vector2i): 
	entities = {}
	id = _id
	location = Vector2(id) - Grid.cell_size * 0.5 * Vector2.ONE

func contains(entity : Entity):
	return entity in entities #and entities[entity]
	
func insert(entity : Entity):
	entities[entity] = true

func remove(entity : Entity):
	#entitys[entity] = false
	entities.erase(entity)

func debug_draw(c : Color):
	var pos = Vectors.X_Z(id * Grid.cell_size) + Vector3.UP * 0.25
	DebugDraw3D.draw_box(pos, Quaternion.IDENTITY, Vectors.FLAT * Grid.cell_size + Vector3.UP * 0.5, c, true)
