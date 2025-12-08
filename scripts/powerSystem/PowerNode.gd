class_name PowerNode extends Building

enum PortType{
	SHAFT_END,
	COG_SMALL,
	COG_BIG
}

signal network_changed

@export var cost_per_speed : int = 0
@export var is_passive:bool=true

# Connections[local_port] = [other_node, other_port]
# Dictionary[PowerNodePort, Array[PortConnection]]
var connections : Dictionary[PowerNodePort, Array]= {}
var speed : float = 0.0
var is_overstressed : bool = false
var is_running : bool = false
var is_broken : bool = false

func _ready() -> void:
	super()
	for port in $ConnectionPorts.get_children():
		if port is PowerNodePort:
			port.monitorable = false
			port.monitoring = false
			port.area_entered.connect(_on_area_entered.bind(port))
			port.area_exited.connect(_on_area_exited.bind(port))
			connections.set(port, [])

func _process(delta: float) -> void:
	super(delta)
	pass

func _on_area_entered(other_port: Area3D, local_port: PowerNodePort) -> void:
	if not other_port is PowerNodePort:
		return
	var other_node = other_port.get_power_node()
	if local_port.can_connect_to(other_port):
		connections[local_port].append(PortConnection.new(other_node, other_port))
		other_node.connections[other_port].append(PortConnection.new(self,  local_port))
		call_deferred("emit_signal", "network_changed", self)

func _on_area_exited(area: Area3D, local_port: PowerNodePort) -> void:
	if connections.has(local_port):
		for connection : PortConnection in connections[local_port]:
			if connection.port == area:
				connections[local_port].erase(connection)
				print("Errased: ", connection.node)
			call_deferred("emit_signal", "network_changed", self)

func get_connections() -> Array[PowerNode]:
	var node_connections: Array[PowerNode] = []
	for port: PowerNodePort in connections:
		for connection: PortConnection in connections[port]:
			if connection.node and not connection.node.is_broken:
				node_connections.append(connection.node)
	return node_connections

func get_rotation_axis() -> Vector3:
		return global_transform.basis.y.snappedf(1)

func get_port_rotation_axis(_port: PowerNodePort) -> Vector3:
		return get_rotation_axis()

func placed() -> void:
	super()
	PowerGridManager.register_node(self)

	PowerGridManager.last_built_node = self
	for port in $ConnectionPorts.get_children():
		if port is Area3D:
			port.monitoring = true
			port.monitorable = true

func break_part() -> void:
	if is_broken:
		return
	is_broken = true
	print(name + " Has exploded due to direction conflicts")
	PowerGridManager.unregister_node(self)
	#var port_connections = get_connections()
	#for connection in port_connections:
		#call_deferred("emit_signal", "network_changed", connection)
	super()

func calculate_speed(local_port: PowerNodePort, connected_node: PowerNode, connected_port: PowerNodePort) -> float:
	var my_axis: Vector3 = get_port_rotation_axis(local_port)
	var connection_axis: Vector3 = connected_node.get_port_rotation_axis(connected_port)
	var vector_to_connected: Vector3 = (connected_node.global_position - self.global_position)
	if vector_to_connected.length_squared() > 0.001:
		vector_to_connected = vector_to_connected.normalized()
	else:
		vector_to_connected = Vector3.ZERO
	var input_speed : float= connected_node.speed* connected_port.ratio_multipier * connected_port.direction_fliper
	var dot: float = my_axis.dot(connection_axis)
	if abs(dot) > 0.9:
		if local_port.type == PortType.COG_BIG or local_port.type == PortType.COG_SMALL:
			input_speed *= -signf(dot)
		else:
			input_speed *= signf(dot)
	else:
		var interaction_plane : Vector3 = my_axis.cross(connection_axis)
		var planar_check: float = interaction_plane.dot(vector_to_connected)
		if is_zero_approx(planar_check):
			var my_tangent: Vector3 = my_axis.cross(vector_to_connected)
			var other_tangent: Vector3 = vector_to_connected.cross(connection_axis)
			var alignment: float = my_tangent.dot(other_tangent)
			input_speed *= signf(alignment)
		else:
			print("How do we get here")
			input_speed *= signf(planar_check)
	var resulting_speed = (input_speed * local_port.direction_fliper) / local_port.ratio_multipier
	return resulting_speed

func interacted() -> void:
	print(self.name, ": ", self.connections)
	for port in connections:
		for connection in connections[port]:
			calculate_speed(port, connection.node, connection.port)
