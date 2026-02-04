extends Node

var world: Level
var build_list: BuildList
var player: PlayerCharacter
var ui_context: ContextComponent
var bottom_menu: BottomMenu
var focused_element: Node3D

var folder_save_path: String = "user://saves/"
var file_save_path: String = "slot1.scn"

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("closeProject"):
		get_tree().quit()
	if event.is_action_pressed("Save"):
		save_game()
	if event.is_action_pressed("Load"):
		#print("Hello")
		build_list = load_game(build_list, folder_save_path+file_save_path)
		PowerGridManager.recalculate_all_grids()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and event.keycode == KEY_0 and focused_element and focused_element is Belt:
		print(focused_element.see_inventory_state())
		if focused_element.ft_conn:
			print("FRONT CONN: ", focused_element.ft_conn, " : ", focused_element.ft_conn.pos)
		if focused_element.bk_conn:
			print("BACK  CONN: ", focused_element.bk_conn, " : ", focused_element.bk_conn.pos)
		print("LENGTH: ", focused_element.belt_length)
	if event is InputEventKey and event.is_pressed() and event.keycode == KEY_PAGEUP:
		print_orphan_nodes()

func save_game() -> void:

	#Some infinity recursion loop

	if not DirAccess.dir_exists_absolute(folder_save_path):
		DirAccess.make_dir_absolute(folder_save_path)

	#var build_duped: BuildList = build_list.duplicate()
	#world.add_child(build_duped)
	print(build_list)
	_recursive_set_owner(build_list, build_list)
	#world.remove_child(build_duped)
	var save_node: PackedScene = PackedScene.new()
	var result = save_node.pack(build_list)
	if result == OK:
		var save_path: String = folder_save_path + file_save_path
		var error = ResourceSaver.save(save_node, save_path)
		if error != OK:
			push_error("Error saving file: " + str(error))
		else:
			print("File saved correctly")
	else:
		push_error("Error packing scene: " + str(result))
	pass

func _set_owner(root: Node) -> void:
	for child in root.get_children():
		child.owner = root

func _recursive_set_owner(node: Node, root: Node) -> void:
	if node != root:
		node.owner = root

	if node != root and not node.scene_file_path.is_empty():
		return

	for child in node.get_children():
		_recursive_set_owner(child, root)

func load_game(container: BuildList, save_path: String) -> Node:
	if not FileAccess.file_exists(save_path):
		push_warning("Save file not found.")
		return container
	print(save_path)
	var packed_scene: PackedScene = load(save_path) as PackedScene
	if not packed_scene:
		push_error("Failed to load PackedScene.")
		return container

	var new_container: BuildList = packed_scene.instantiate()
	var parent = container.owner
	var old_name = container.name
	container.name = old_name+"_trash"
	new_container.name = old_name

	#parent.remove_child(container)
	container.queue_free()
	parent.add_child(new_container)
	if parent:
		new_container.owner = parent
	return new_container


#Proces super ineficient, el temps de proces del forn es de 2.87ms i aquesta funcio ocupa 2.84ms
@onready var iron_ore: VisualMaterial 		= load("res://scenes/iron_ore.tscn").instantiate() as VisualMaterial
@onready var iron_ingot: VisualMaterial 	= load("res://scenes/iron_ingot.tscn").instantiate() as VisualMaterial
@onready var coal_ore: VisualMaterial 		= load("res://scenes/coal_ore.tscn").instantiate() as VisualMaterial
func give_visual_material(mat: String) -> VisualMaterial:
	var vis_mat: VisualMaterial = null
	if mat == "Iron ore":
		vis_mat = iron_ore.duplicate()
	elif mat == "Coal ore":
		vis_mat = coal_ore.duplicate()
	elif mat == "Iron ingot":
		vis_mat = iron_ingot.duplicate()
	if vis_mat:
		return vis_mat
	vis_mat.queue_free()
	return null
