class_name Furnace extends Machine

@onready var gui : Control = $FurnaceGUI
#@onready var itemlist: ItemList = $FurnaceGUI/CenterContainer/ItemList

@export_storage var raw_material: Materials
@export_storage var fuel: Materials
@export_storage var processed_material: Materials

@export_storage var remaining_fuel: float
@export_storage var aviable_formulas: Array[Formula]

@export_storage var active_formula: Formula = null

var gui_active: bool = false
var elapsed_time: float = 0.0

func _ready() -> void:
	await get_tree().physics_frame
	super()
	aviable_formulas.append(load("res://Resources/FormulasData/IronOreToIngot.tres") as Formula)
	gui.hide()

func _process(delta: float) -> void:
	if not is_overstressed and abs(speed) > 0 and meshes:
		meshes[0].rotate(Vector3(1, 0, 0), speed * delta)
	if is_placed:
		process_resources(delta)

func get_rotation_axis() -> Vector3:
		return global_transform.basis.x.normalized()

func process_resources(delta: float) -> void:
	if raw_material:
		active_formula = aviable_formulas[0]
		#for formula: Formula in aviable_formulas:
			#print(aviable_formulas)
			#for input in formula.input_materials:
				#print("No raw material")
				#if input == raw_material.name:
					#active_formula = formula



	try_input()
	if abs(speed) > 0 and not is_overstressed:
		process_formula(delta)
	try_output()

func interacted() -> void:
	if fuel:
		print(fuel.name)
		print(fuel.amount)
		print(remaining_fuel)
	else:
		print("No fuel")
	if raw_material:
		print(raw_material.name)
		print(raw_material.amount)
	else:
		print("No raw material")

	if active_formula:
		print(active_formula)
		print(elapsed_time)
		print(active_formula.output_materials.keys())
	else:
		print("No formula")

	if processed_material:
		print(processed_material.name)
		print(processed_material.amount)
	else:
		print("No processed material")
	#print(connections)
	#print(speed)
	#print(raw_material.amount)
	#print(fuel.amount)
		#gui_active = true
	#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	#gui.show()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("exit") and gui_active:
		gui_active = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		gui.hide()

func try_port_input(port: MachinePort, stack: Materials) -> Materials:
	if port.port_belt and port.port_belt.trying_to_pass:
		var belt: Belt = port.port_belt
		var orientation: Vector3 = port.global_position-belt.global_position
		if is_zero_approx(belt.global_rotation.y):
			if (orientation.x<0 and belt.speed > 0) or (orientation.x>0 and belt.speed < 0):
				stack = try_add_to_inventory(belt, stack)
		else:
			if (orientation.z>0 and belt.speed > 0) or (orientation.z<0 and belt.speed < 0):
				stack = try_add_to_inventory(belt, stack)

	return stack

func try_add_to_inventory(belt: Belt, stack: Materials) -> Materials:
	var to_pass: VisualMaterial = belt.trying_to_pass
	if not stack:
		stack = to_pass.material.duplicate()
		stack.amount = 0
	if to_pass.material.name == stack.name and stack.amount < stack.max_stack:
		stack.amount += 1
		belt.path.remove_child(to_pass)
		to_pass.queue_free()
	return stack

func try_input() -> void:
	fuel = try_port_input(input_ports[0], fuel)
	raw_material = try_port_input(input_ports[1], raw_material)

func process_formula(delta: float) -> void:
	if active_formula and remaining_fuel > 50 and raw_material and raw_material.amount >= active_formula.input_materials[raw_material.name]:
		if elapsed_time > active_formula.time:
			elapsed_time = 0
			remaining_fuel -= 50
			raw_material.amount -= active_formula.input_materials[raw_material.name]
			if processed_material and processed_material.amount < processed_material.max_stack and active_formula.output_materials.has(processed_material.name):
				processed_material.amount += active_formula.output_materials[processed_material.name]
			else:
				processed_material = GlobalScript.give_visual_material(active_formula.output_materials.keys()[0]).material
				processed_material.amount = 1

		else:
			elapsed_time += delta*abs(speed)

func try_output() -> void:
	if processed_material:
		if processed_material.amount > 0:
			if output_ports[1].try_pass_material(processed_material):
				processed_material.remove(1)
		else:
			processed_material = null
	if fuel:
		if fuel.amount > 0:
			if remaining_fuel <500:
				remaining_fuel+= fuel.energy
				fuel.remove(1)
			else:
				if output_ports[0].try_pass_material(fuel):
					fuel.remove(1)
		else:
			fuel = null
