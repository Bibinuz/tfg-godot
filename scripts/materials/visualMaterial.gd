class_name VisualMaterial extends PathFollow3D

@export var material: Materials = null
@export var area: Area3D
@export var meshes: Node3D

#func _exit_tree() -> void:
#	queue_free()
