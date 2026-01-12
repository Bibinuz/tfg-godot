class_name Miner extends Machine

@export var extraction_time: float = 16
var extracting_from: ResourceNode
var extracting: Materials
var elapsed_time: float

func _ready() -> void:
	super()

func _process(delta: float) -> void:
	super(delta)
	meshes[1].rotate(Vector3(0,1,0), delta*speed)
	extract_resource(delta)
	if extracting:
		try_output()

func check_placement() -> bool:
	placement_green()
	return true

func interacted() -> void:
	if extracting_from:
		print(extracting_from.resource_type.name, ": ", extracting.amount)

func placed() -> void:
	super()
	elapsed_time = 0.0

func _on_mining_point_area_entered(area: Area3D) -> void:
	if area and area.get_parent() and area.get_parent() is ResourceNode:
		extracting_from = area.get_parent()
		extracting = extracting_from.resource_type.duplicate()
		pass # Replace with function body.

func extract_resource(delta: float) -> void:
	if extracting_from and abs(speed):
		if extracting.amount < extracting.max_stack:
			elapsed_time += delta
			if elapsed_time >=extraction_time/abs(speed):
				extracting.add(1, true, extracting_from.purity)
				elapsed_time = 0.0

func try_output() -> bool:
	if extracting.amount > 0:
		if output_ports[0].try_pass_material(extracting):
			extracting.remove(1)
			return true
	return false
