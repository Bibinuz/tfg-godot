class_name Belt extends PowerNode

@export var shaderMaterial: ShaderMaterial
var nodes_connected: Array[Node3D] = []
var allowed_connections: Array = [Shaft, MachinePort]
var belt_lenght: float = 0.0
var inventory: Array[VisualMaterial] = []
var belt_vector: Vector3 = Vector3.ZERO


# Dictionary with connected belt and position of the other belt where this belt want to input items
var belts_connected: Dictionary[Belt, float] = {}


@onready var path: Path3D = $BeltPath
@onready var belt_connection_area: Area3D = $BeltConnections

func _ready() -> void:
	super()
	path.curve = path.curve.duplicate()

func _process(delta: float) -> void:
	super(delta)
	meshes[0].set_instance_shader_parameter("speed", speed/2)
	if is_placed:
		manage_belt_items(delta)

func _input(event: InputEvent) -> void:
	if is_placed: return
	else:
		if event.is_action_pressed("leftClick"):
			place_belt()

func place_belt() -> void:
	if GlobalScript.focused_element is Shaft or GlobalScript.focused_element is MachinePort:
		if len(nodes_connected) == 0:
			nodes_connected.append(GlobalScript.focused_element)
		elif len(nodes_connected) == 1 and not nodes_connected.has(GlobalScript.focused_element):
			nodes_connected.append(GlobalScript.focused_element)
			var place_position: Vector3 = nodes_connected[0].global_position - nodes_connected[1].global_position
			var center_position = place_position/2
			position = nodes_connected[0].position - center_position
			GlobalScript.bottom_menu.place()
			belt_lenght = place_position.length() + 0.75
			scale.x = belt_lenght
			scale_path()
			scale_connection_points()
			if is_zero_approx(place_position.x) and is_zero_approx(place_position.y) and not is_zero_approx(place_position.z):
				rotation = Vector3(0,PI/2,0)
			elif not is_zero_approx(place_position.x) and is_zero_approx(place_position.y) and is_zero_approx(place_position.z):
				rotation = Vector3(0,0,0)
			else:
				self.break_part()
				return

			for connection in nodes_connected:
				if connection is MachinePort:
					connection.port_has_belt = self
			meshes[0].material_override = shaderMaterial

func scale_path() -> void:
	path.scale.x = 1/belt_lenght

	path.curve.set_point_position(0, Vector3(belt_lenght/2,0,0))
	path.curve.set_point_position(1, Vector3(-belt_lenght/2,0,0))

func scale_connection_points() -> void:
	belt_connection_area.scale.x = 1/belt_lenght
	belt_connection_area.get_child(0).position.x = belt_lenght/2 + 0.5
	belt_connection_area.get_child(1).position.x = -belt_lenght/2 - 0.5

func check_placement() -> bool:
	if GlobalScript.focused_element and (GlobalScript.focused_element is Belt or GlobalScript.focused_element is MachinePort):
		placement_green()
		if len(nodes_connected) == 2:
			return true
		else:
			return false
	placement_red()
	return false

func get_port_rotation_axis(_port: PowerNodePort) -> Vector3:
	return global_transform.basis.x.normalized()

func interacted() -> void:
	print(self, ": ", global_position, ": ", belt_lenght)
	var visual_mat: VisualMaterial = load("res://scenes/iron_ore.tscn").instantiate()
	try_add_item(visual_mat, 0)
	see_inventory_state()

func break_part() -> void:
	for connection in nodes_connected:
		if connection is MachinePort:
			connection.port_has_belt = null
	super()

func is_shaft_in_ends(shaft: Shaft) -> void:
	if shaft == nodes_connected[0] or shaft == nodes_connected[1]:
		break_part()

func manage_belt_items(delta: float) -> void:
	var to_next_point: VisualMaterial = null
	for item: VisualMaterial in inventory:

		if item:
			var overlapping_areas: Array[Area3D] = item.area.get_overlapping_areas()
			var overlap_count: int = len(overlapping_areas)
			var is_blocked: bool = false
			if overlap_count > 0:
				for area: Area3D in overlapping_areas:
					var other_item = area.get_parent()
					if other_item is VisualMaterial:
						if speed > 0 and other_item.progress > item.progress:
							is_blocked=true
							break
						elif speed < 0 and other_item.progress < item.progress:
							is_blocked=true
							break
			if speed > 0 and is_equal_approx(item.progress, belt_lenght):
				to_next_point = item
			elif speed < 0 and is_equal_approx(item.progress, 0):
				to_next_point = item

			if not is_blocked:
				var movement: float = item.progress+speed*delta/2
				if movement < belt_lenght and abs(movement) >= 0:
					item.progress = movement
				elif movement > belt_lenght:
					item.progress = belt_lenght
				elif movement < 0:
					item.progress = 0

				#item.visual_material.progress = item.progress
	if to_next_point:
		if try_pass_item(to_next_point):
			inventory.erase(to_next_point)
			path.remove_child(to_next_point)
			to_next_point.queue_free()
		#inventory.erase(to_erase)
		#to_erase.visual_material.queue_free()
		#to_erase.queue_free()

func see_inventory_state() -> void:
	print("Inventory state")
	for item: VisualMaterial in inventory:
		print(item, " : ", item.progress_ratio)

func try_add_item(visual_mat: VisualMaterial, position_in_belt: float) -> bool:
	var is_there_an_item: bool = false
	for item in inventory:
		var n: float = 1
		if item.progress + n > position_in_belt and item.progress - n < position_in_belt:
			is_there_an_item = true
			break
	if not is_there_an_item:
		inventory.append(visual_mat)
		inventory[-1].progress = position_in_belt
		path.add_child(visual_mat)
		return true
	return false

func try_pass_item(item:VisualMaterial) -> bool:
	var pass_to_position: float = 0.0
	if is_equal_approx(item.progress_ratio, 1):
		pass_to_position = 0.0
	elif is_equal_approx(item.progress_ratio, 0):
		pass_to_position = 1.0

	for connection: Belt in belts_connected:
		if connection.try_add_item(item.duplicate(), pass_to_position*connection.belt_lenght):
			return true
	return false

func _on_belt_connections_area_entered(area: Area3D) -> void:
	if area.get_parent() and area.get_parent() is Belt and area.get_parent().is_placed and self.is_placed:
		var other: Belt = area.get_parent()
		var vector_to_other: Vector3 = self.global_position-other.global_position
		var parallel: bool = self.global_rotation == other.global_rotation

		if parallel:
			if vector_to_other.x < 0 or vector_to_other.z < 0:
				self.belts_connected[other] = other.belt_lenght
			else:
				self.belts_connected[other] = 0.0
		else:
			if is_zero_approx(self.global_rotation.y):
				self.belts_connected[other] = (other.belt_lenght)/2 - vector_to_other.z
			else:
				self.belts_connected[other] = (other.belt_lenght)/2 - vector_to_other.x

func _on_belt_connections_area_exited(area: Area3D) -> void:
	if area and area.get_parent() and area.get_parent() is Belt and area.get_parent().is_placed and self.is_placed:
		if belts_connected.has(area.get_parent()):
			belts_connected.erase(area.get_parent())
