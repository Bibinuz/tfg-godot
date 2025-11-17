class_name PowerNode extends Building

signal network_changed

var connections : Array[PowerNode] = []
var speed : float
var cost_per_speed : int
var is_overstressed : bool = false

func _ready() -> void:	
	pass 

func _process(_delta: float) -> void:
	pass

func _enter_tree() -> void:
	PowerGridManager.register_node(self)

func _exit_tree() -> void:
	PowerGridManager.unregister_node(self)
	
func _on_area_entered(area: Area3D) -> void:
	var other_node = area.get_owner()
	if other_node is PowerNode and other_node != self:
		if not connections.has(other_node):
			connections.append(other_node)
			emit_signal("network_changed")

func _on_area_exited(area: Area3D) -> void:
	var other_node = area.get_owner()
	if other_node is PowerNode and connections.has(other_node):
		connections.erase(other_node)
		emit_signal("network_changed")
		
func get_connections() ->  Array[PowerNode]:
	return connections
	
func placed() -> void:
	super()
	
	for port in $ConnectionPorts.get_children():
		if port is Area3D:
			port.area_entered.connect(_on_area_entered)
			port.area_exited.connect(_on_area_exited)
	
