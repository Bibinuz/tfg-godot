extends Node

var all_power_nodes: Array[PowerNode] = []
var last_built_node : PowerNode = null

var last_power_calculation: float = 0.0


func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass

func _physics_process(_delta: float) -> void:
	pass

func register_node(node: PowerNode) -> void:
	if not all_power_nodes.has(node):
		all_power_nodes.append(node)
		last_built_node = node
		node.network_changed.connect(recalculate_all_grids)

func unregister_node(node: PowerNode) -> void:
	if all_power_nodes.has(node):
		all_power_nodes.erase(node)
		if node.is_connected("network_changed", recalculate_all_grids):
			node.network_changed.disconnect(recalculate_all_grids)

func recalculate_grid(starting_node: PowerNode) -> Array[PowerNode]:
	var grid : Array[PowerNode] =  find_whole_grid_bfs(starting_node)
	var power: float = 0.0
	for node : PowerNode in grid:
		if node is Generator:
			power += node.generate_per_speed*node.speed
		else:
			power -= node.cost_per_speed*node.speed
	if power < 0.0:
		for node : PowerNode in grid:
			node.is_overstressed = true
	if power >= 0.0:
		for node: PowerNode in grid:
			node.is_overstressed = false
	last_power_calculation = power
	return grid

func recalculate_all_grids() -> void:
	var visited: Array[PowerNode] = []
	for node: PowerNode in  all_power_nodes:
		if not visited.has(node) and node:
			visited.append_array(recalculate_grid(node))

func find_whole_grid_bfs(start_node: PowerNode) -> Array[PowerNode]:
	var visited: Array[PowerNode] = []
	var queue: Array[PowerNode] = [start_node]
	visited.append(start_node)
	while not queue.is_empty():
		var current_node = queue.pop_front()
		for connection in current_node.get_connections():
					if connection not in visited:
							visited.append(connection)
							queue.append(connection)
	return visited

			##func find_whole_grid_dfs(start_node: PowerNode) -> Array[PowerNode]:
				##	var visited: Array[PowerNode] = []
				##	var queue: Array[PowerNode] = [start_node]
				##	visited.append(start_node)
				##	while not queue.is_empty():
					##		var current_node = queue.pop_back()
					##		for connection in current_node.get_connections():
						##			if connection not in visited:
							##				visited.append(connection)
							##				queue.append(connection)
							##	return visited

func break_priority(node1 : PowerNode, node2 : PowerNode) -> void:
	# First case:
		# The two nodes are generators: break the last built one, or the node1 by default
	if node1 is Generator and node2 is Generator:
		if node1 == last_built_node:
			node1.break_part()
		elif node2 == last_built_node:
			node2.break_part()
		else:
			node1.break_part()
	# Second case:
		# Node 1 is a generator, then we break the link, node 2
	elif node1 is Generator:
		node2.break_part()
	# Same thing but reversed
	elif node2 is Generator:
		node1.break_part()
	# Last case:
		# Neither of them are generators, we break last built one, or node1 by default
	else:
		if node1 == last_built_node:
			node1.break_part()
		elif node2 == last_built_node:
			node2.break_part()
		else:
			node1.break_part()
	return
