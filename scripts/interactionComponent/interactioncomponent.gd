class_name InteractionComponent extends Node

@export var context : String
@export var override_icon : bool
@export var new_icon : Texture2D

@onready var meshes: Array[MeshInstance3D] = get_parent().get_parent().meshes

var focused: bool = false


var parent : Node3D
var main_object : Building
var outline_material : ShaderMaterial = preload("res://assets/materials/outline_material.tres")

func _ready() -> void:
	parent = get_parent()
	main_object = parent.get_parent()
	connect_parent()

func connect_parent() -> void:
	parent.add_user_signal("focused")
	parent.add_user_signal("unfocused")
	parent.add_user_signal("interacted")
	parent.connect("focused", Callable(self, "in_range"))
	parent.connect("unfocused", Callable(self, "not_in_range"))
	parent.connect("interacted", Callable(self, "on_interact"))

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("removeBuilding"):
		if main_object.has_method("break_part") and focused:
			main_object.break_part()
			get_viewport().set_input_as_handled()

func in_range() -> void:
	focused = true
	for mesh: MeshInstance3D in meshes:
		mesh.material_overlay = outline_material
	MessageBus.interaction_focused.emit(context, new_icon, override_icon)
	set_process_input(true)

func not_in_range() -> void:
	focused=false
	for mesh: MeshInstance3D in meshes:
		mesh.material_overlay = null
	MessageBus.interaction_unfocused.emit()
	set_process_input(false)

func on_interact() -> void:
	if main_object.has_method("interacted"):
		main_object.interacted()
