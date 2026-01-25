class_name PortConnection

@export_storage var  node: PowerNode
@export_storage var port:PowerNodePort

func _init(p_node: PowerNode, p_port: PowerNodePort) ->  void:
	node = p_node
	port = p_port
