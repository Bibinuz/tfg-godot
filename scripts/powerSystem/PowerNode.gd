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
	if is_passive:
		check_speeds()
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
		check_speeds()
		call_deferred("emit_signal", "network_changed")
		#emit_signal("network_changed")

func _on_area_exited(area: Area3D, local_port: PowerNodePort) -> void:
	if connections.has(local_port) and connections[local_port] != null:
		if connections[local_port].port == area:
			connections[local_port] = null
			call_deferred("emit_signal", "network_changed")


##	var other_node = area.get_owner()
##	if other_node is PowerNode:
	##		connections[local_port] = null
	##		other_node.connections[area] = null
	##	else:
		##		connections[local_port] = null
		##	check_speeds()
		##	call_deferred("emit_signal", "network_changed")

func get_connections() -> Array[PowerNode]:
	var node_connections: Array[PowerNode] = []
	for port: PowerNodePort in connections:
		if connections[port]:
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
	emit_signal("network_changed")
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
			var vector_to_connected : Vector3= (connected_port.node.global_position - self.global_position).normalized()
			if vector_to_connected.length_squared() >0.001:
				vector_to_connected = vector_to_connected.normalized()
			else:
				vector_to_connected = Vector3.ZERO

			var dot : float = my_axis.dot(connection_axis)

			var input_speed: float = connected_port.node.speed * connected_port.port.ratio_multipier * connected_port.port.direction_fliper

			if abs(dot) > 0.9:
				input_speed *= signf(dot)
			else:
				var interaction_plane : Vector3 = my_axis.cross(connection_axis)
				var  planar_check : float =interaction_plane.dot(vector_to_connected)
				if true or is_zero_approx(planar_check):
					var my_tangent: Vector3 = my_axis.cross(vector_to_connected)
					var other_tangent: Vector3 = vector_to_connected.cross(connection_axis)
					var alignment: float = my_tangent.dot(other_tangent)
					input_speed *= signf(alignment)
				else:
					input_speed *= signf(planar_check)

			temp_speed  = (input_speed*port.direction_fliper)/port.ratio_multipier
		if  not is_equal_approx(temp_speed, suposed_speed) and not is_zero_approx(suposed_speed) and (not is_zero_approx(temp_speed)):
			break_part()
			return
		if is_zero_approx(suposed_speed) and not is_zero_approx(temp_speed):
			suposed_speed = temp_speed
	self.speed=suposed_speed
