extends Node


var player: PlayerCharacter
var ui_context: ContextComponent
var bottom_menu: BottomMenu
var focused_element: Node3D

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("closeProject"):
		get_tree().quit()
