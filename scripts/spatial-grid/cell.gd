class_name Cell

var id : Vector2i
var entities : Dictionary[Entity, bool]
var location : Vector2

func _init(_id : Vector2i) -> void: 
	entities = {}
	id = _id
	location = Vector2(id) - Grid.cell_size * 0.5 * Vector2.ONE

func contains(entity : Entity) -> bool:
	return entity in entities #and entities[entity]
	
func insert(entity : Entity) -> void:
	entities[entity] = true

func remove(entity : Entity) -> void:
	#entitys[entity] = false
	entities.erase(entity)

func debug_draw(c : Color) -> void:
	var pos : Vector3 = Vectors.X_Z(id * Grid.cell_size) + Vector3.UP * 0.25
	DebugDraw3D.draw_box(pos, Quaternion.IDENTITY, Vectors.FLAT * Grid.cell_size + Vector3.UP * 0.5, c, true)
