extends Node

var world: Level
var build_list: BuildList
var player: PlayerCharacter
var ui_context: ContextComponent
var bottom_menu: BottomMenu
var focused_element: Node3D

var folder_save_path: String = "user://saves/"
var file_save_path: String = "slot1.tscn"

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("closeProject"):
		get_tree().quit()
	if event.is_action_pressed("Save"):
		save_game()
	if event.is_action_pressed("Load"):
		#print("Hello")
		build_list = load_game(build_list, folder_save_path+file_save_path)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and event.keycode == KEY_0 and focused_element and focused_element is Belt:
		print(focused_element.see_inventory_state())
		if focused_element.ft_conn:
			print("FRONT CONN: ", focused_element.ft_conn, " : ", focused_element.ft_conn.pos)
		if focused_element.bk_conn:
			print("BACK  CONN: ", focused_element.bk_conn, " : ", focused_element.bk_conn.pos)
		print("LENGTH: ", focused_element.belt_length)

func give_visual_material(mat: Materials) -> VisualMaterial:
	var vis_mat: VisualMaterial = null
	if mat.name == "Iron ore":
		vis_mat = load("res://scenes/iron_ore.tscn").instantiate()
	return vis_mat

func save_game() -> void:
	if not DirAccess.dir_exists_absolute(folder_save_path):
		DirAccess.make_dir_absolute(folder_save_path)

	var build_duped: BuildList = build_list.duplicate()
	world.add_child(build_duped)
	_recursive_set_owner(build_duped, build_duped)
	world.remove_child(build_duped)
	var save_node: PackedScene = PackedScene.new()
	var result = save_node.pack(build_duped)
	if result == OK:
		var save_path: String = folder_save_path + file_save_path
		var error = ResourceSaver.save(save_node, save_path)
		if error != OK:
			push_error("Error saving file: " + str(error))
	else:
		push_error("Error packing scene: " + str(result))
	pass

func _recursive_set_owner(node: Node, root: Node) -> void:
	if node != root:
		node.owner = root
	for child in node.get_children():
		_recursive_set_owner(child, root)

func load_game(container: BuildList, save_path: String) -> Node:
	print("HELLO")
	if not FileAccess.file_exists(save_path):
		push_warning("Save file not found.")
		return container

	var packed_scene: PackedScene = load(save_path) as PackedScene
	if not packed_scene:
		push_error("Failed to load PackedScene.")
		return container

	var new_container: BuildList = packed_scene.instantiate()
	var parent = container.get_parent()
	var old_name = container.name
	container.name = old_name+"_trash"
	new_container.name = old_name

	#parent.remove_child(container)
	container.queue_free()
	parent.add_child(new_container)
	if parent.owner:
		new_container.owner = parent.owner
	return new_container
