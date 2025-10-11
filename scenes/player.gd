class_name Player extends Agent

var _anchor: Vector2 = Vector2.ZERO
var _drag : Vector2 = Vector2.ZERO

func get_input() -> Vector2:
	var input_vec : Vector2 = _drag
	if Input.is_action_pressed("move_forward"): input_vec.y -= 1
	if Input.is_action_pressed("move_backward"): input_vec.y += 1
	if Input.is_action_pressed("move_left"): input_vec.x -= 1
	if Input.is_action_pressed("move_right"): input_vec.x += 1
	return input_vec.limit_length(1)

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch : InputEventScreenTouch = event as InputEventScreenTouch
		if touch.pressed: _anchor = touch.position
		_drag = Vector2.ZERO
	elif event is InputEventScreenDrag:
		var drag : InputEventScreenDrag = event as InputEventScreenDrag
		_drag = 20 * ((drag.position - _anchor) * 0.001).limit_length(1)
