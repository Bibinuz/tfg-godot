class_name PowerNode extends Building

@warning_ignore("unused_signal")
signal network_changed

@export var cost_per_speed : int = 0
@export var is_passive:bool=true

@export var center: Vector3 = Vector3.ZERO

# Connections[local_port] = [other_node, other_port]
# Dictionary[PowerNodePort, Array[PortConnection]]
var connections : Dictionary[PowerNodePort, Array]= {}
@export_storage var speed : float = 0.0
@export_storage var is_overstressed : bool = false
@export_storage var is_running : bool = false
@export_storage var is_broken : bool = false

func _ready() -> void:
	super()
	for port in $ConnectionPorts.get_children():
		if port is PowerNodePort:
			connections.set(port, [])
			if is_placed: continue
			port.monitorable = false
			port.monitoring = false

func _process(delta: float) -> void:
	super(delta)

func _enter_tree() -> void:
	super()
	connect_signals()

func connect_signals() -> void:
	for port in $ConnectionPorts.get_children():
		if port is PowerNodePort:
			port.area_entered.connect(_on_area_entered.bind(port))
			port.area_exited.connect(_on_area_exited.bind(port))



func _on_area_entered(other_port: Area3D, local_port: PowerNodePort) -> void:
	if not other_port is PowerNodePort:
		return
	var other_node = other_port.get_power_node()
	if local_port.can_connect_to(other_port):

		connections[local_port].append(PortConnection.new(other_node, other_port))
		#other_node.connections[other_port].append(PortConnection.new(self,  local_port))
		call_deferred("emit_signal", "network_changed", self)

func _on_area_exited(area: Area3D, local_port: PowerNodePort) -> void:
	if connections.has(local_port):
		for connection : PortConnection in connections[local_port]:
			if connection.port == area:
				connections[local_port].erase(connection)
				#print("Errased: ", connection.node)
			call_deferred("emit_signal", "network_changed", self)

func get_connections() -> Array[PowerNode]:
	var node_connections: Array[PowerNode] = []
	for port: PowerNodePort in connections:
		for connection: PortConnection in connections[port]:
			if connection.node and not connection.node.is_broken:
				node_connections.append(connection.node)
	return node_connections

func get_rotation_axis() -> Vector3:
		return global_transform.basis.y.normalized()

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
	PowerGridManager.unregister_node(self)
	super()

func calculate_speed(local_port: PowerNodePort, connected_node: PowerNode, connected_port: PowerNodePort) -> float:
	var my_axis: Vector3 = get_port_rotation_axis(local_port)
	var connection_axis: Vector3 = connected_node.get_port_rotation_axis(connected_port)
	#print("My axis: ", self.name, ":", my_axis)
	#print("Cn axis: ", connected_node.name, ":", connection_axis)
	var input_speed : float= connected_node.speed* connected_port.ratio_multiplier * connected_port.direction_flipper
	var dot: float = my_axis.dot(connection_axis)
	if abs(dot) > 0.9:
		if local_port.type == PowerNodePort.PortType.COG_BIG or local_port.type == PowerNodePort.PortType.COG_SMALL:
			input_speed *= -signf(dot)
			#print(self.name,": Cog connection")
		else:
			input_speed *= signf(dot)
			#print(self.name,": Shaft connection")
	else:
		# Explicar això a l'informe: Desplaçament del centre
		var vector_to_connected: Vector3 = ((connected_node.global_position+connected_node.center) - (self.global_position+self.center))
		if vector_to_connected.length_squared() > 0.001:
			vector_to_connected = vector_to_connected.normalized()
		else:
			vector_to_connected = Vector3.ZERO

		#Incloure el cas de les cintes mecàniques.
		var case1: bool = local_port.type == PowerNodePort.PortType.BELT and connected_port.type == PowerNodePort.PortType.SHAFT_END
		var case2: bool = local_port.type == PowerNodePort.PortType.SHAFT_END and connected_port.type == PowerNodePort.PortType.BELT
		if case1:
			input_speed *= signf(connection_axis.dot(Vector3.ONE))
		elif case2:
			input_speed *= signf(my_axis.dot(Vector3.ONE))


		else:
			var my_tangent: Vector3 = my_axis.cross(vector_to_connected)
			var other_tangent: Vector3 = vector_to_connected.cross(connection_axis)
			var alignment: float = my_tangent.dot(other_tangent)
			input_speed *= signf(alignment)
			#print(self.name,": Perpendicular connection")
	var resulting_speed = (input_speed * local_port.direction_flipper) / local_port.ratio_multiplier
	return resulting_speed

func interacted() -> void:
	print(self, ": ", type_string(typeof(self)))
	print(connections)
	return

	##print(self.name, ": ", self.connections)
	##for port in connections:
		##for connection in connections[port]:
			##if port and connection and connection.node and connection.port:
				##calculate_speed(port, connection.node, connection.port)
