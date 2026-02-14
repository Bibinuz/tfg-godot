extends Node

var world: Level
var build_list: BuildList
var player: PlayerCharacter
var ui_context: ContextComponent
var bottom_menu: BottomMenu
var focused_element: Node3D

var opened_gui : Control

var pending_load_action = false

var folder_save_path: String = "user://saves/"
var file_save_path: String = "slot1.json"

var MAIN_MENU: String = "res://scenes/main_menu.tscn"

func _process(_delta: float) -> void:
	if pending_load_action:
		if get_tree() and get_tree().current_scene and get_tree().current_scene is Level:
			print(build_list, " ",folder_save_path+file_save_path)
			load_game(folder_save_path+file_save_path)
			pending_load_action = false
			PowerGridManager.recalculate_all_grids()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("closeProject"):
		get_tree().quit()
	if event.is_action_pressed("Save"):
		save_game()
	if event.is_action_pressed("Load"):
		pending_load_action = true

func save_game() -> void:
	if not OS.is_stdout_verbose() and not Thread.is_main_thread():
		push_error("Called save game from a background thread!")
		return


	if not DirAccess.dir_exists_absolute(folder_save_path):
		DirAccess.make_dir_absolute(folder_save_path)

	var save_file: FileAccess = FileAccess.open(folder_save_path+file_save_path, FileAccess.WRITE)
	var to_save: Array[Node] = get_tree().get_nodes_in_group("Persist")
	for node: Node in to_save:
		if node.scene_file_path.is_empty():
			continue
		if !node.has_method("save"):
			continue
		var node_data: Dictionary = node.call("save")
		var json_string: String = JSON.stringify(node_data)
		save_file.store_line(json_string)
	print(folder_save_path+file_save_path)
	save_file.close()
	return

func load_game(save_path: String) -> void:
	if not FileAccess.file_exists(save_path):
		push_warning("Save file not found.")
		return

	var save_nodes: Array[Node] = get_tree().get_nodes_in_group("Persist")
	for node: Node in save_nodes:
		node.queue_free()

	var save_file: FileAccess = FileAccess.open(save_path, FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string: String = save_file.get_line()
		var json: JSON = JSON.new()
		var parse_result: int = json.parse(json_string)
		if not parse_result == OK:
			continue
		var node_data: Dictionary = json.data
		var new_object: Node = load(node_data["filename"]).instantiate()
		get_node(node_data["parent"]).add_child(new_object)

		new_object.load(node_data)
		for i in node_data.keys():
			if i == "filename" or i == "parent":
				continue
			new_object.set(i, node_data[i])
	save_file.close()
	MessageBus.load_finished.emit()



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
