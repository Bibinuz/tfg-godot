class_name BuildingSlot extends PanelContainer


@export var icon_rect: TextureRect
@export var is_read_only: bool = false
@export var current_building: BuildingData = null
var slot_index: int

func ready():
	update_visuals()

func set_building(data: BuildingData) -> void:
	current_building = data
	update_visuals()

func update_visuals() -> void:
	if current_building and current_building.icon:
		icon_rect.texture = current_building.icon
	else:
		icon_rect.texture = null

func _get_drag_data(_position: Vector2) -> BuildingData:
	if not current_building: return null
	var preview: TextureRect = TextureRect.new()
	preview.texture = current_building.icon
	preview.expand = true
	preview.size = Vector2(50, 50)
	set_drag_preview(preview)
	return current_building

func _can_drop_data(_position: Vector2, data: Variant) -> bool:
	return data is BuildingData and "scene" in data and not is_read_only

func _drop_data(_position: Vector2, data: Variant) -> void:
	if is_read_only:
		return
	set_building(data)
