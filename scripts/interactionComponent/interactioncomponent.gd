class_name InteractionComponent extends Node

@export var mesh : MeshInstance3D
@export var context : String
@export var override_icon : bool
@export var new_icon : Texture2D

var parent : Node3D
var outline_material : ShaderMaterial = preload("res://assets/materials/outline_material.tres")

func _ready() -> void:	
	parent = get_parent()
	connect_parent()

func _process(delta: float) -> void:
	pass
	
func in_range() -> void:
	mesh.material_overlay = outline_material
	MessageBus.interaction_focused.emit(context, new_icon, override_icon)
	
func not_in_range() -> void:
	mesh.material_overlay = null
	MessageBus.interaction_unfocused.emit()
	
func on_interact() -> void:
	print(parent.name)

	
func connect_parent() -> void:
	parent.add_user_signal("focused")
	parent.add_user_signal("unfocused")
	parent.add_user_signal("interacted")
	parent.connect("focused", Callable(self, "in_range"))
	parent.connect("unfocused", Callable(self, "not_in_range"))
	parent.connect("interacted", Callable(self, "on_interact"))
	

	
	
