class_name PowerNodePort extends Area3D

enum PortType{
	SHAFT_END,
	COG_SMALL,
	COG_BIG
}

@export var ratio_multipier : float = 1.0
@export var direction_fliper : int = 1
@export var type : PortType = PortType.SHAFT_END
@export var allow_ports: Array[PortType]


func  can_connect_to(other_port: PowerNodePort) -> bool:
	if allow_ports.has(other_port.type) and self.get_power_node() != other_port.get_power_node():
		var my_axis: Vector3 = self.get_power_node().get_port_rotation_axis(self)
		var connection_axis: Vector3 = other_port.get_power_node().get_port_rotation_axis(other_port)
		var vector_to_connected: Vector3 = (other_port.get_power_node().global_position - self.get_power_node().global_position)
		if vector_to_connected.length_squared() > 0.001:
			vector_to_connected.normalized()
		else:
			vector_to_connected = Vector3.ZERO
		var interaction_plane : Vector3 = my_axis.cross(connection_axis)
		var planar_check: float = interaction_plane.dot(vector_to_connected)
		if not is_zero_approx(planar_check):
			return false
		return true
	return false

func get_power_node() -> PowerNode:
	return get_owner() as PowerNode
