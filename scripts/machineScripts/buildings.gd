class_name Building extends Node3D

@onready var placementYesMaterial = preload("res://assets/materials/placement_yes.tres")
@onready var placementNoMaterial = preload("res://assets/materials/placement_no.tres")

@onready var raycasts : Array[RayCast3D] = [$Ray1, $Ray2, $Ray3, $Ray4]
@export var meshes : Array[MeshInstance3D]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func check_placement() -> bool:
	for ray in raycasts:
		if !ray.is_colliding():
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
	for mesh in meshes:
		mesh.material_override = null
	for ray in raycasts:
		ray.queue_free()
