class_name Shaft_connections extends RayCast3D


var parent : Node3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parent = get_parent()
	connect_parent()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func create_shaft_connection() -> void:
	
	pass
	
func update_shaft_connection() -> void:
	pass
	
func remove_shaft_connection() -> void:
	pass

func connect_parent() -> void:
	parent.add_user_signal("connected_shaft")
	parent.add_user_signal("update_shaft")
	parent.add_user_signal("disconnected_shaft")
	parent.connect("connected_shaft", Callable(self, "create_shaft_connection"))
	parent.connect("update_shaft", Callable(self, "update_shaft_connection"))
	parent.connect("disconnected_shaft", Callable(self, "remove_shaft_connection"))
