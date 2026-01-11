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
		if focused_element.ft_conn:
			print("FRONT CONN: ", focused_element.ft_conn, " : ", focused_element.ft_conn.pos)
		if focused_element.bk_conn:
			print("BACK  CONN: ", focused_element.bk_conn, " : ", focused_element.bk_conn.pos)
		print("LENGTH: ", focused_element.belt_length)
