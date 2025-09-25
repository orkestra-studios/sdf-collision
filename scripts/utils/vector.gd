class_name Vectors

# filtering
static func X(v:Vector3) -> float: return v.x
static func Y(v:Vector3) -> float: return v.y
static func Z(v:Vector3) -> float: return v.z

static func XY(v:Vector3) -> Vector2 : return Vector2(v.x, v.y)
static func XZ(v:Vector3) -> Vector2 : return Vector2(v.x, v.z)
static func YZ(v:Vector3) -> Vector2 : return Vector2(v.y, v.z)

static func X_(a:float) -> Vector2: return Vector2(a,0)
static func _Y(a:float) -> Vector2: return Vector2(0,a)

static func _YZ(v:Vector2) -> Vector3 : return Vector3(0, v.y, v.y)
static func X_Z(v:Vector2) -> Vector3 : return Vector3(v.x, 0, v.y)
static func XY_(v:Vector2) -> Vector3 : return Vector3(v.x, v.y, 0)

static func X__(a:float) -> Vector3: return Vector3(a,0,0)
static func _Y_(a:float) -> Vector3: return Vector3(0,a,0)
static func __Z(a:float) -> Vector3: return Vector3(0,0,a)

const FLAT : Vector3 = Vector3(1,0,1)

#TODO: swizzling
