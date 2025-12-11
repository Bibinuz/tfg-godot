class_name Belt extends Building


var connected_shafts: Array[Shaft] = []



func _ready() -> void:
	super()

func _process(_delta: float) -> void:
	super(_delta)

func _input(event: InputEvent) -> void:
	if is_placed: return
	else:
		if event.is_action_pressed("leftClick"):
			if GlobalScript.focused_element is Shaft:
				if len(connected_shafts) == 0:
					connected_shafts.append(GlobalScript.focused_element)
				elif len(connected_shafts) == 1 and not connected_shafts.has(GlobalScript.focused_element):
					connected_shafts.append(GlobalScript.focused_element)
					var place_position: Vector3 = connected_shafts[0].position - connected_shafts[1].position
					var center_position = place_position/2
					if place_position.x == 0 and place_position.y == 0 and place_position.z != 0:
						GlobalScript.bottom_menu.place()
						position = connected_shafts[0].position - center_position
						rotation = Vector3(0,0,0)
						scale.x = place_position.length() + 0.5

					elif place_position.x != 0 and place_position.y == 0 and place_position.z == 0:
						GlobalScript.bottom_menu.place()
						position = connected_shafts[0].position - center_position
						rotation = Vector3(0,0,0)
						scale.x = place_position.length() + 0.5




func check_placement() -> bool:
	var n: int = len(connected_shafts)
	if n != 2:
		placement_red()
		return false
	placement_green()
	return true
