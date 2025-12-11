class_name Building extends Node3D

@onready var placementYesMaterial = preload("res://assets/materials/placement_yes.tres")
@onready var placementNoMaterial = preload("res://assets/materials/placement_no.tres")

@export var debris_scene: PackedScene = preload("res://scenes/poof.tscn")

@export_group("Meshes, areas and collistions of the building")
@export var meshes : Array[MeshInstance3D]
@export var areas : Array[Area3D]
@export var collisions : Array[StaticBody3D]


var is_placed : bool = false


func _ready() -> void:
	if not is_placed:
		toggle_collisions(false)

func _process(_delta: float) -> void:
	pass

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
		toggle_collisions(true)

func break_part() -> void:
	if debris_scene:
		spawn_debris()
	self.queue_free()

func spawn_debris():
	var debris: GPUParticles3D = debris_scene.instantiate()
	get_tree().current_scene.add_child(debris)
	debris.global_position = global_position

func toggle_collisions(enabled: bool) -> void:
	for body:StaticBody3D in collisions:
		for child in body.get_children():
			if child is CollisionShape3D or child is CollisionPolygon3D:
				child.disabled = not enabled
