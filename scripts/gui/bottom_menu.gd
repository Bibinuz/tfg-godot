class_name BottomMenu extends Control

@onready var furnace = preload("res://scenes/furnace.tscn")
@onready var testMotor = preload("res://scenes/test_motor.tscn")
@onready var shaft = preload("res://scenes/shaft.tscn")
@onready var cogSmall = preload("res://scenes/cog_small.tscn")
@onready var cogBig = preload("res://scenes/cog_big.tscn")
@onready var transmisionBox = preload("res://scenes/transmision_box.tscn")
@onready var multiplier = preload("res://scenes/multiplier.tscn")

@onready var hotbar : ItemList = $PanelContainer/ItemList

var isSelected : bool = false
var selected: int = 0
var isPlacing : bool = false
var camera : Camera3D
var instance : Building
var placingRange : int = 10
var canPlace : bool = false
var lastRotation: Vector3 = Vector3(PI/2, 0, 0)

func _ready() -> void:
	camera = get_viewport().get_camera_3d()
	pass # Replace with function body.

func _process(_delta: float) -> void:
	if isPlacing and instance:
		var screenCenter : Vector2 = get_viewport().size / 2
		var rayOrigin : Vector3 = camera.project_ray_origin(screenCenter)
		var rayEnd : Vector3 = rayOrigin + camera.project_ray_normal(screenCenter) * placingRange
		var query : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(rayOrigin, rayEnd)
		query.collide_with_bodies = true
		var exclusion_list: Array[RID] = []
		if instance.get("collisions"):
			for col in instance.collisions:
				if col is CollisionObject3D:
					exclusion_list.append(col.get_rid())
		query.exclude = exclusion_list
		var collision = camera.get_world_3d().direct_space_state.intersect_ray(query)
		if collision:
			var point = collision.position
			var normal = collision.normal
			var target_pos = point + (normal * 0.5)
			instance.global_position = target_pos.snapped(Vector3(1, 1, 1))
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
		if event.is_action_pressed("leftClick") and canPlace and instance:
			instance.placed()
			canPlace = false
			isPlacing = false
			instance = null
			item_selected(selected)

			instance.global_rotation = lastRotation
		if event.is_action_pressed("rightClick")  and isPlacing and instance:
			instance.queue_free()
			canPlace = false
			isPlacing = false
			hotbar.deselect_all()
			lastRotation = Vector3(PI/2,0,0)
		if event.is_action_pressed("rotateBuildingX"):
			instance.global_rotation.x += PI/2
			lastRotation = instance.global_rotation
		if event.is_action_pressed("rotateBuildingY"):
			instance.global_rotation.y += PI/2
			lastRotation = instance.global_rotation
		if event.is_action_pressed("rotateBuildingZ"):
			instance.global_rotation.z += PI/2
			lastRotation = instance.global_rotation


func item_selected(index: int) -> void:
	if isPlacing and instance:
		instance.queue_free()

	if index == 0:
		instance = furnace.instantiate()
		selected = 0
	elif index == 1:
		instance = shaft.instantiate()
		selected = 1
	elif index == 2:
		instance = testMotor.instantiate()
		selected = 2
	elif index ==  3:
		instance = cogSmall.instantiate()
		selected = 3
	elif index == 4:
		instance = cogBig.instantiate()
		selected = 4
	elif index == 5:
		instance = transmisionBox.instantiate()
		selected = 5
	elif index  == 6:
		instance = multiplier.instantiate()
		selected = 6
	else:
		isPlacing = false
		return
	isPlacing = true
	get_parent().add_child(instance)
