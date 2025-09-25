class_name Structure extends SDFElement

var elements : Dictionary[SDFElement, bool] = {}
var aabb : Rect2

var result : SDF.Query = SDF.Query.new(INF, null)

func setup():
	elements.clear()
	aabb = Rect2(Vector2.ZERO, Vector2.ZERO)
	var count : int = 0
	for child in get_children():
		if child is SDFElement: 
			child.setup()
			elements.set(child as SDFElement, true)
			if aabb.size == Vector2.ZERO: aabb = child.bounds()
			else: aabb = aabb.merge(child.bounds())
			count += 1
	print("added ", count, " elements")

func query(to : Vector2) -> SDF.Query:
	result.distance = INF
	result.element = null
	result.count = 0
	for e in elements:
		var check = e.query(to)
		result.count += check.count
		if check.distance < result.distance:
			result.element = e
			result.distance = check.distance
	return result
	
func bounds() -> Rect2: return aabb

func _debug_draw(c : Color) -> void:
	DebugDraw3D.draw_aabb_ab(Vectors.X_Z(bounds().position), Vectors.X_Z(bounds().end) + Vector3.UP, c )
	for e in elements:
		e._debug_draw(c)
		if result.element == e: 
			DebugDraw3D.draw_arrow_ray(e.global_position + 1.5 * Vector3.UP, Vector3.DOWN, 0.5, c, 0.5, true)
