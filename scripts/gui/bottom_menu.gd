class_name BottomMenu extends Control

@export var hotbar : HBoxContainer
@export var buildingMenu : Control



var isSelected : bool = false
var selected_index: int = 0
var isPlacing : bool = false
var camera : Camera3D
var instance : Building
var placingRange : int = 10
var canPlace : bool = false
var last_rotation: Vector3 = Vector3(PI/2, 0, 0)

func _ready() -> void:
	camera = get_viewport().get_camera_3d()
	GlobalScript.bottom_menu = self
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

	var pressed_index = -1
	if not buildingMenu.is_visible_in_tree():
		if   event.is_action_pressed("select1"): pressed_index = 0
		elif event.is_action_pressed("select2"): pressed_index = 1
		elif event.is_action_pressed("select3"): pressed_index = 2
		elif event.is_action_pressed("select4"): pressed_index = 3
		elif event.is_action_pressed("select5"): pressed_index = 4
		elif event.is_action_pressed("select6"): pressed_index = 5
		elif event.is_action_pressed("select7"): pressed_index = 6
		elif event.is_action_pressed("select8"): pressed_index = 7
		elif event.is_action_pressed("select9"): pressed_index = 8

		if pressed_index != -1:
			select_hotbar_slot(pressed_index)

	if event.is_action_pressed("openBuildingMenu") or event.is_action_pressed("exit"):
		if buildingMenu.is_visible_in_tree():
			buildingMenu.hide()
			buildingMenu.mouse_filter = Control.MOUSE_FILTER_IGNORE
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		elif not event.is_action_pressed("exit"):
			cancel_placement()
			buildingMenu.show()
			buildingMenu.mouse_filter = Control.MOUSE_FILTER_STOP
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		pass


	if isPlacing:
		if event.is_action_pressed("leftClick") and canPlace and instance:
			place()
		if (event.is_action_pressed("rightClick") or event.is_action_pressed("exit")) and isPlacing and instance:
			cancel_placement()
		if event.is_action_pressed("rotateBuildingX"):
			instance.global_rotation.x += PI/2
			last_rotation = instance.global_rotation
		if event.is_action_pressed("rotateBuildingY"):
			instance.global_rotation.y += PI/2
			last_rotation = instance.global_rotation
		if event.is_action_pressed("rotateBuildingZ"):
			instance.global_rotation.z += PI/2
			last_rotation = instance.global_rotation

func place() -> void:
	instance.placed()
	canPlace = false
	var current_data: BuildingData = get_data_from_slot(selected_index)
	instance = null
	if current_data:
		instantiate_building(current_data)
		instance.global_rotation = last_rotation
	else:
		isPlacing = false

func select_hotbar_slot(index: int) -> void:
	selected_index = index
	if isPlacing and instance:
		instance.queue_free()
		instance = null
	var data: BuildingData = get_data_from_slot(index)
	if data:
		instantiate_building(data)
	else:
		isPlacing = false

func get_data_from_slot(index: int) -> BuildingData:
	if index < hotbar.get_child_count():
		var slot: BuildingSlot = hotbar.get_child(index)
		return slot.current_building
	return null

func instantiate_building(data: BuildingData) -> void:
	if data.scene:
		instance = data.scene.instantiate()
		get_parent().add_child(instance)
		isPlacing = true

func cancel_placement():
	if instance:
		instance.queue_free()
	canPlace = false
	isPlacing = false
	instance = null
	last_rotation = Vector3(PI/2, 0, 0)
