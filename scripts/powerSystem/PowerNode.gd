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
# Dictionary[PowerNodePort, Array[PowerNode, PowerNodePort]]
var connections : Dictionary[PowerNodePort, PortConnection] = {}
var speed : float = 0.0
var is_overstressed : bool = false
var is_running : bool = false
var is_broken : bool = false

func _ready() -> void:
	super()
	for port in $ConnectionPorts.get_children():
		if port is Area3D:
			port.monitorable = false
			port.monitoring = false
			port.area_entered.connect(_on_area_entered.bind(port))
			port.area_exited.connect(_on_area_exited.bind(port))


func _process(delta: float) -> void:
	super(delta)
	pass

func _enter_tree() -> void:
	PowerGridManager.register_node(self)

func _exit_tree() -> void:
	PowerGridManager.unregister_node(self)

func _on_area_entered(other_port: Area3D, local_port: PowerNodePort) -> void:
	if not other_port is PowerNodePort:
		return
	var other_node = other_port.get_power_node()
	if local_port.can_connect_to(other_port):
		connections[local_port] = PortConnection.new(other_node, other_port)
		other_node.connections[other_port] = PortConnection.new(self,  local_port)
		call_deferred("emit_signal", "network_changed", self)

func _on_area_exited(area: Area3D, local_port: PowerNodePort) -> void:
	if connections.has(local_port) and connections[local_port] != null:
		if connections[local_port].port == area:
			connections[local_port] = null
			call_deferred("emit_signal", "network_changed", self)

func get_connections() -> Array[PowerNode]:
	var node_connections: Array[PowerNode] = []
	for port: PowerNodePort in connections:
		if connections[port] and connections[port].node and not connections[port].node.is_broken:
			node_connections.append(connections[port].node)
	return node_connections

func placed() -> void:
	super()
	for port in $ConnectionPorts.get_children():
		if port is Area3D:
			port.monitoring = true
			port.monitorable = true

func get_rotation_axis() -> Vector3:
	return global_transform.basis.y.snappedf(1)

func get_port_rotation_axis(_port: PowerNodePort) -> Vector3:
	return get_rotation_axis()

func break_part() -> void:
	if is_broken:
		return
	is_broken = true
	PowerGridManager.unregister_node(self)
	emit_signal("network_changed", self)
	print(name + " Has exploded due to direction conflicts")
	remove_building()

func check_speeds() -> void:
	var suposed_speed:float = 0.0
	for port: PowerNodePort in connections:
		var temp_speed: float = 0.0
		if  connections[port] and connections[port].node and not connections[port].node.is_queued_for_deletion():
			var connected_port:PortConnection = connections[port]
			var my_axis : Vector3 = self.get_port_rotation_axis(port)
			var connection_axis : Vector3 = connected_port.node.get_port_rotation_axis(connected_port.port)
			var vector_to_connected : Vector3= (connected_port.node.global_position - self.global_position)
			if vector_to_connected.length_squared() >0.001:
				vector_to_connected = vector_to_connected.normalized()
			else:
				vector_to_connected = Vector3.ZERO

			var input_speed: float = connected_port.node.speed * connected_port.port.ratio_multipier * connected_port.port.direction_fliper
			var dot : float = my_axis.dot(connection_axis)

			if abs(dot) > 0.9:
				input_speed *= signf(dot)
			else:
				var my_tangent: Vector3 = my_axis.cross(vector_to_connected)
				var other_tangent: Vector3 = vector_to_connected.cross(connection_axis)
				var alignment: float = my_tangent.dot(other_tangent)
				input_speed *= signf(alignment)

			temp_speed  = (input_speed*port.direction_fliper)/port.ratio_multipier
		if  not is_equal_approx(temp_speed, suposed_speed) and not is_zero_approx(suposed_speed) and (not is_zero_approx(temp_speed)):
			break_part()
			return
		if is_zero_approx(suposed_speed) and not is_zero_approx(temp_speed):
			suposed_speed = temp_speed
	self.speed=suposed_speed


func calculate_speed(local_port: PowerNodePort, connected_node: PowerNode, connected_port: PowerNodePort) -> float:
		var my_axis: Vector3 = self.get_port_rotation_axis(local_port)
		var connection_axis: Vector3 = connected_node.get_port_rotation_axis(connected_port)
		var vector_to_connected: Vector3 = (connected_node.global_position - self.global_position)
		if vector_to_connected.length_squared() > 0.001:
			vector_to_connected = vector_to_connected.normalized()
		else:
			vector_to_connected = Vector3.ZERO

		var input_speed = connected_node.speed / connected_port.ratio_multipier * connected_port.direction_fliper
		if is_zero_approx(input_speed):
			#print(connected_node.name)
			#print(connected_node.speed, " ", connected_port.ratio_multipier, " ",connected_port.direction_fliper)
			pass
		var dot: float = my_axis.dot(connection_axis)

		if abs(dot) > 0.9:
			if local_port.type == PortType.COG_BIG or local_port.type == PortType.COG_SMALL:
				input_speed *= -signf(dot)
			else:
				input_speed *= signf(dot)
		else:
			var my_tangent: Vector3 = my_axis.cross(vector_to_connected)
			var other_tangent: Vector3 = vector_to_connected.cross(connection_axis)
			var alignment: float = my_tangent.dot(other_tangent)
			input_speed *= signf(alignment)

		var resulting_speed = (input_speed * local_port.direction_fliper) * local_port.ratio_multipier
		return resulting_speed



func interacted() -> void:
	print(self.name, ": ", self.speed)
	pass
	#for port in connections:
		#print(port.name, ": ", get_port_rotation_axis(port))

func remove_building() -> void:
	var port_connections = get_connections()
	self.is_broken = true
	for connection in port_connections:
		call_deferred("emit_signal", "network_changed", connection)

	self.queue_free()
