class_name SDF

enum Shape { Rect, Circle }

static func rect(position : Vector2, center : Vector2, half_extents : Vector2) -> float:
	var edgeDist : Vector2 = (position - center).abs() - half_extents
	var outside : float = edgeDist.maxf(0).length()
	var inside : float = min(max(edgeDist.x, edgeDist.y), 0)
	return outside + inside
	#var bottom_left = center - half_extents
	#var top_right   = center + half_extents
	#return max(
		#bottom_left.x - position.x, position.x - top_right.x,
		#bottom_left.y - position.y, position.y - top_right.y, 0
	#)
	
static func circle(position : Vector2, center : Vector2, radius : float) -> float:
	return (position - center).length() - radius

static func translate(position : Vector2, offset : Vector2) -> Vector2:
	return position - offset

static func rotate(position : Vector2, angle : float) -> Vector2:
	var sin_a = sin(-angle)
	var cos_a = cos(-angle)
	return Vector2(
		position.x * cos_a + position.y * sin_a,
		position.y * cos_a - position.x * sin_a
	)

static func scale(position : Vector2, factor : float) -> Vector2:
	return position / factor
	
static func normal(pos: Vector2, element : SDFElement, eps: float = 0.01) -> Vector2:
	var dx = element.query(pos + Vector2(eps, 0)).distance - element.query(pos - Vector2(eps, 0)).distance
	var dy = element.query(pos + Vector2(0, eps)).distance - element.query(pos - Vector2(0, eps)).distance
	var n = Vector2(dx, dy)
	return n.normalized()

class Query:
	
	var distance: float
	var element: SDFElement
	var count: int
	
	static var NONE : Query = new()
	
	func _init(_distance : float = INF, _element : SDFElement = null, _count = 0):
		element  = _element
		distance = _distance
		count = _count
