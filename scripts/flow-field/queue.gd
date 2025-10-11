class_name Queue

var data : Array
var head : int = 0
var tail : int = 0
var count : int = 0

func _init(capacity:int=1024) -> void:
	data = []
	data.resize(capacity)

func is_empty() -> bool:
	return count == 0

func push_back(value : Variant) -> void:
	if count == data.size():
		_grow()
	data[tail] = value
	tail = (tail + 1) % data.size()
	count += 1

func pop_front() -> Variant:
	if count == 0:
		return null
	var value : Variant = data[head]
	head = (head + 1) % data.size()
	count -= 1
	return value

func _grow() -> void:
	var new_data : Array = []
	new_data.resize(data.size() * 2)
	for i : int in count:
		new_data[i] = data[(head + i) % data.size()]
	data = new_data
	head = 0
	tail = count
