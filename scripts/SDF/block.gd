class_name Block extends SDFElement

@export var shape : SDF.Shape = SDF.Shape.Rect
@export var inset : float = 0

var aabb : Rect2

func setup(): 
	var size := Vector2.ONE * Vectors.XZ(scale)
	aabb = Rect2(Vectors.XZ(global_position) - size * 0.5, size)

func distance(to : Vector2) -> SDF.Query:
	#var pos = Vectors.XZ(to_local(Vectors.X_Z(to)))
	var pos = SDF.rotate(SDF.translate(to, Vectors.XZ(global_position)), global_rotation.y)
	var dist : float = INF
	match shape:
		SDF.Shape.Rect:
			var nscale : Vector2 = Vector2(scale.x, scale.z)
			dist = SDF.rect(pos, Vector2.ZERO, nscale * 0.5) + inset
		SDF.Shape.Circle:
			dist = SDF.circle(pos, Vector2.ZERO, 0.5 * scale.x) + inset
			
	return SDF.Query.new(dist, self, 1)
			
func bounds() -> Rect2: return aabb

func _debug_draw(c : Color) -> void:
	match shape:
		SDF.Shape.Rect:
			DebugDraw3D.draw_box( 
				global_position + Vector3.UP * 0.5, quaternion, scale, c, true
			)
		SDF.Shape.Circle:
			DebugDraw3D.draw_cylinder_ab(
				global_position, global_position + Vector3.UP, scale.x * 0.5 - inset, c
			)
