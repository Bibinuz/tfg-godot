extends Node


var player: PlayerCharacter
var ui_context: ContextComponent
var bottom_menu: BottomMenu
var focused_element: Node3D

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("closeProject"):
		get_tree().quit()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and event.keycode == KEY_0 and focused_element and focused_element is Belt:
		print(focused_element.see_inventory_state())
		print(focused_element.belts_connected)
		if len(focused_element.inventory) > 0:
			var temp: Array[VisualMaterial] = focused_element.inventory
			print(temp[0].get_parent().get_parent())
