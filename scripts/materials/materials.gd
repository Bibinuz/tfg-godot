class_name Materials


@export var name : String
@export var max_stack : int
@export var is_flamable : bool
@export var energy : float

func _init(n : String, s : int, f : bool = false, e : float = 0.0) -> void:
	name = n
	max_stack = s
	is_flamable = f
	energy = e
	pass
