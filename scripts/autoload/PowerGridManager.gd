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
		node.network_changed.connect(on_network_change)

func unregister_node(node: PowerNode) -> void:
	if all_power_nodes.has(node):
		all_power_nodes.erase(node)
		if node.is_connected("network_changed", on_network_change):
			node.network_changed.disconnect(on_network_change)
			recalculate_all_grids()

func recalculate_grid_stress(grid: Array[PowerNode]) -> void:
	var power: float = 0.0
	for node : PowerNode in grid:
		if node is Generator:
			power += node.generate_per_speed*abs(node.speed)
		else:
			power -= node.cost_per_speed*abs(node.speed)
	if power < 0.0:
		for node : PowerNode in grid:
			node.is_overstressed = true
	if power >= 0.0:
		for node: PowerNode in grid:
			node.is_overstressed = false



func recalculate_all_grids() -> void:
	var visited: Array[PowerNode] = []
	for node: PowerNode in  all_power_nodes:
		if not visited.has(node) and node:
			var grid: Array[PowerNode] = find_whole_grid_bfs(node)
			on_network_change(node, grid)
			visited.append_array(grid)

func on_network_change(start_node: PowerNode, grid:Array[PowerNode] = []) -> void:
	if grid == []:
		grid = find_whole_grid_bfs(start_node)
	var generators: Array[Generator] = []
	for node: PowerNode in grid:
		node.is_overstressed = false
		if node is Generator:
			generators.append(node)
		else:
			node.speed = 0.0
	if generators.is_empty(): return

	solve_speeds(generators)
	if not last_built_node:
		solve_speeds(generators)
	#Si el node eliminat separa la xarxa en dos parts les dos xarxes compartiran potencia encara que no hi hagi connexió fisica, s'hauria de recalcular en base a les connexions del node eliminat
	# En el moment d'eliminar el node retornar un llistat amb les connexions d'aquell node per recalcular cada una de les xarxes individualment
	recalculate_grid_stress(grid)



func solve_speeds(generators: Array[Generator]) -> void:
	var node_speeds: Dictionary = {}
	var queue: Array[PowerNode] = []
	var visited: Array[PowerNode] = []
	for generator: Generator in generators:
		node_speeds[generator] = generator.speed
		queue.append(generator)

	while not queue.is_empty():
		var current_node : PowerNode= queue.pop_front()
		if current_node in visited: continue
		visited.append(current_node)
		current_node.speed = node_speeds[current_node]
		for local_port: PowerNodePort in current_node.connections:

			for connection : PortConnection in current_node.connections[local_port]:
				if not connection or not connection.node or connection.node.is_broken: continue
				var proposed_connection_speed: float = connection.node.calculate_speed(connection.port, current_node, local_port)
				if node_speeds.has(connection.node) and not is_equal_approx(proposed_connection_speed, node_speeds[connection.node]):
					if is_zero_approx(proposed_connection_speed):
						proposed_connection_speed = node_speeds[connection.node]
					elif is_zero_approx(node_speeds[connection.node]):
						node_speeds[connection.node] = proposed_connection_speed
					else:
						#print(last_built_node.name)
						#all_power_nodes.erase(last_built_node)
						if last_built_node:
							last_built_node.break_part()
							last_built_node = null
						#last_built_node = all_power_nodes[-1]
						#break_priority(connection.node, current_node)
						return
				node_speeds[connection.node] = proposed_connection_speed
				queue.append(connection.node)





func find_whole_grid_bfs(start_node: PowerNode) -> Array[PowerNode]:
	var visited: Array[PowerNode] = []
	var queue: Array[PowerNode] = [start_node]
	visited.append(start_node)
	while not queue.is_empty():
		var current_node:PowerNode = queue.pop_front()
		for connection in current_node.get_connections():
					if connection not in visited and not connection.is_broken:
							visited.append(connection)
							queue.append(connection)
	return visited

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
