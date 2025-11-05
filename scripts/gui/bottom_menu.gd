class_name BottomMenu extends Control

@onready var furnace = preload("res://scenes/furnace.tscn")
@onready var testMotor = preload("res://scenes/test_motor.tscn")
@onready var shaft = preload("res://scenes/shaft.tscn")

@onready var hotbar : ItemList = $PanelContainer/ItemList

var isSelected : bool = false
var isPlacing : bool = false
var camera : Camera3D
var instance : Building
var placingRange : int = 1000
var canPlace : bool = false

func _ready() -> void:
	camera = get_viewport().get_camera_3d()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if isPlacing:
		var screenCenter : Vector2 = get_viewport().size / 2
		var rayOrigin : Vector3 = camera.project_ray_origin(screenCenter) 
		var rayEnd : Vector3 = rayOrigin+camera.project_ray_normal(screenCenter)*placingRange
		var query : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(rayOrigin,rayEnd)
		query.collide_with_bodies = true
		var collision = camera.get_world_3d().direct_space_state.intersect_ray(query)
		if collision:
			#instance.transform.origin = Vector3(snappedf(collision.position.x, 1),collision.position.y,snappedf(collision.position.z, 1))
			instance.transform.origin = ceil(collision.position)
			
			canPlace = instance.check_placement()
			

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("select1"):
		hotbar.select(0)
		item_selected(0)
	elif event.is_action_pressed("select2"):
		hotbar.select(1)
		item_selected(1)
	elif event.is_action_pressed("select3"):
		hotbar.select(2)
		item_selected(2)
	elif event.is_action_pressed("select4"):
		hotbar.select(3)
		item_selected(3)
	elif event.is_action_pressed("select5"):
		hotbar.select(4)
		item_selected(4)
	elif event.is_action_pressed("select6"):
		hotbar.select(5)
		item_selected(5)
	elif event.is_action_pressed("select7"):
		hotbar.select(6)
		item_selected(6)
	elif event.is_action_pressed("select8"):
		hotbar.select(7)
		item_selected(7)
	elif event.is_action_pressed("select9"):
		hotbar.select(8)
		item_selected(8)
	
	if isPlacing:
		if event.is_action_pressed("leftClick") and canPlace:
			instance.placed()
			hotbar.deselect_all()
			canPlace = false
			isPlacing = false



func item_selected(index: int) -> void:
	if isPlacing:
		instance.queue_free()
	
	if index == 0:
		instance = furnace.instantiate()
	elif index == 1:
		instance = shaft.instantiate()
	elif index == 2:
		instance = testMotor.instantiate()
	isPlacing = true
	get_parent().add_child(instance)
