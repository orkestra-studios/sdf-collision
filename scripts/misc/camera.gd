class_name MainCamera extends Camera3D

@export var target : Node3D 
@export var speed : float = 4
@export var offset : Vector3

func _ready() -> void:
	if !target: return
	var targetPos : Vector3 = target.position + offset
	look_at_from_position(targetPos, target.position)

func _process(delta: float) -> void:
	if !target: return
	var targetPos : Vector3 = target.position + offset
	position = lerp(position, targetPos, speed * delta)
