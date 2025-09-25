@abstract
class_name SDFElement extends Node3D

@abstract
func setup() -> void

@abstract
func bounds() -> Rect2

@abstract
func query(to : Vector2) -> SDF.Query

@abstract
func _debug_draw(c : Color) -> void
