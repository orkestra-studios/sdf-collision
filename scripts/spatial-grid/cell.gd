class_name Cell extends RefCounted

var elements : Dictionary[Node3D, bool]

func _init(): 
	elements = {}

func contains(element : Node3D):
	return element in elements and elements[element]
	
func insert(element : Node3D):
	elements[element] = true

func remove(element : Node3D):
	#elements[element] = false
	elements.erase(element)
	
