class_name Building extends Node3D

@onready var placementYesMaterial = preload("res://assets/materials/placement_yes.tres")
@onready var placementNoMaterial = preload("res://assets/materials/placement_no.tres")

@onready var debris_scene: PackedScene = preload("res://scenes/poof.tscn")

@export_group("Meshes, areas and collistions of the building")
@export var meshes_path : Array[NodePath]
@export var areas_path : Array[NodePath]
@export var collisions_path : Array[NodePath]

var meshes: Array[MeshInstance3D]
var areas : Array[Area3D]
var collisions: Array [StaticBody3D]

var is_placed : bool = false


func _ready() -> void:
	load_node_exports()
	await get_tree().physics_frame
	if not is_placed:
		toggle_collisions(false)

func _process(_delta: float) -> void:
	pass

func _enter_tree() -> void:
	return
	#await get_tree().physics_frame

func load_node_exports() -> void:
	load_singular_node_path(meshes_path, meshes, MeshInstance3D)
	load_singular_node_path(areas_path, areas, Area3D)
	load_singular_node_path(collisions_path, collisions, StaticBody3D)

func load_singular_node_path(paths: Array[NodePath], nodes: Array, type) -> void:
	for path in paths:
		if not path.is_empty() and has_node(path):
			var node = get_node(path)
			if not is_instance_of(node, type) or nodes.has(node): continue
			nodes.append(node)




func check_placement() -> bool:
	for area in areas:
		if area.get_overlapping_areas() != []:
			placement_red()
			return false
	placement_green()
	return true

func placement_green() -> void:
	for mesh in meshes:
		mesh.material_override = placementYesMaterial
	pass

func placement_red() -> void:
	for mesh in meshes:
		mesh.material_override = placementNoMaterial
	pass

func placed() -> void:
	is_placed = true
	for mesh in meshes:
		mesh.material_override = null
	add_to_group("Persist", true)
	toggle_collisions(true)

func break_part() -> void:
	if debris_scene:
		spawn_debris()
	self.queue_free()

func spawn_debris():
	var spawn_pos: Vector3 = global_position if is_inside_tree() else position
	var debris: GPUParticles3D = debris_scene.instantiate()
	get_tree().current_scene.call_deferred("add_child", debris)
	debris.call_deferred("set", "global_position", spawn_pos)

func toggle_collisions(enabled: bool) -> void:
	for body:StaticBody3D in collisions:
		for child in body.get_children():
			if child is CollisionShape3D or child is CollisionPolygon3D:
				child.disabled = not enabled

func interacted() -> void:
	if get_parent():
		print(self)
		print(get_groups())
		print(get_parent().name)
	else:
		print("No parent")
	pass


func save() -> Dictionary:
	var save_data: Dictionary = {
		"filename": get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x,
		"pos_y" : position.y,
		"pos_z" : position.z,
		"rot_x" : rotation.x,
		"rot_y" : rotation.y,
		"rot_z" : rotation.z,
		"meshes_path" : meshes_path,
		"areas_path" : areas_path,
		"collisions_path" : collisions_path,

	}
	return save_data

func load(data: Dictionary) -> void:
	position.x = data["pos_x"]
	position.y = data["pos_y"]
	position.z = data["pos_z"]
	rotation.x = data["rot_x"]
	rotation.y = data["rot_y"]
	rotation.z = data["rot_z"]
	data.erase("pos_x")
	data.erase("pos_y")
	data.erase("pos_z")
	data.erase("rot_x")
	data.erase("rot_y")
	data.erase("rot_z")
	placed()
