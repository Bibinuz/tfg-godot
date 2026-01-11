class_name Belt extends PowerNode


class BeltConnection:
	var belt: Belt
	var pos: float
	func _init(m_belt: Belt, m_pos: float) -> void:
		belt = m_belt
		pos = m_pos



@export var shaderMaterial: ShaderMaterial
var nodes_connected: Array[Node3D] = []
var allowed_connections: Array = [Shaft, MachinePort]
var belt_length: float = 0.0
var inventory: Array[VisualMaterial] = []
var belt_vector: Vector3 = Vector3.ZERO

@onready var path: Path3D = $BeltPath
@onready var front_port: Area3D = $FrontPort
@onready var back_port: Area3D = $BackPort

var ft_conn: BeltConnection = null
var bk_conn: BeltConnection = null

func _ready() -> void:
	super()
	bind_ports()
	path.curve = path.curve.duplicate()


func _process(delta: float) -> void:
	super(delta)
	if is_overstressed:
		meshes[0].set_instance_shader_parameter("speed", 0)
	else:
		meshes[0].set_instance_shader_parameter("speed", speed/2)
	if is_placed:
		manage_belt_items(delta)

func _input(event: InputEvent) -> void:
	if is_placed: return
	else:
		if event.is_action_pressed("leftClick"):
			place_belt()

func bind_ports() -> void:
	front_port.area_entered.connect(_on_port_area_entered.bind("front"))
	front_port.area_exited.connect(_on_port_area_exited.bind("front"))
	back_port.area_entered.connect(_on_port_area_entered.bind("back"))
	back_port.area_exited.connect(_on_port_area_exited.bind("back"))

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
			belt_length = place_position.length() + 0.75
			scale.x = belt_length
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
	path.scale.x = 1/belt_length
	path.curve.set_point_position(0, Vector3(belt_length/2,0,0))
	path.curve.set_point_position(1, Vector3(-belt_length/2,0,0))

func scale_connection_points() -> void:
	front_port.scale.x = 1/belt_length
	back_port.scale.x = 1/belt_length
	front_port.get_child(0).position.x = belt_length/2 + 0.5
	back_port.get_child(0).position.x = -belt_length/2 - 0.5

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
	print(self, ": ", global_position, ": ", belt_length)
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
						if speed > 0 and other_item.progress > item.progress and inventory.has(other_item):
							is_blocked=true
							break
						elif speed < 0 and other_item.progress < item.progress and inventory.has(other_item):
							is_blocked=true
							break
			if speed > 0 and is_equal_approx(item.progress, belt_length):
				to_next_point = item
			elif speed < 0 and is_equal_approx(item.progress, 0):
				to_next_point = item

			if not is_blocked:
				var movement: float = item.progress+speed*delta/2
				if movement < belt_length and abs(movement) >= 0:
					item.progress = movement
				elif movement > belt_length:
					item.progress = belt_length
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
	if is_equal_approx(item.progress_ratio, 1) and bk_conn:
		if bk_conn.belt.try_add_item(item.duplicate(), bk_conn.pos):
			return true
	elif is_zero_approx(item.progress_ratio) and ft_conn:
		if ft_conn.belt.try_add_item(item.duplicate(), ft_conn.pos):
			return true

	return false


func _on_port_area_entered(area: Area3D, port_id: String) -> void:
	if area.get_parent() and area.get_parent() is Belt and area.get_parent().is_placed and self.is_placed:
		var other: Belt = area.get_parent()
		var vector_to_other: Vector3 = self.global_position-other.global_position
		var parallel: bool = self.global_rotation == other.global_rotation
		var connection_point: float = 0.0
		if parallel:
			if vector_to_other.x < 0 or vector_to_other.z < 0:
				connection_point = other.belt_length
			else:
				connection_point = 0.0
		else:
			if is_zero_approx(self.global_rotation.y):
				connection_point = (other.belt_length)/2 + vector_to_other.z
			else:
				connection_point = (other.belt_length)/2 - vector_to_other.x
		if port_id == "front":
			ft_conn = BeltConnection.new(other, connection_point)
		elif port_id == "back":
			bk_conn = BeltConnection.new(other, connection_point)



func _on_port_area_exited(area: Area3D, port_id: String) -> void:
	if area and area.get_path() and area.get_parent() is Belt:
		if port_id == "front" and ft_conn and ft_conn.belt == area.get_parent():
			ft_conn = null
		elif port_id == "back" and bk_conn and bk_conn.belt == area.get_parent():
			bk_conn = null
