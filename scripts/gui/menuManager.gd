extends Control

@export var slot_scene: PackedScene
@export_dir var buildings_data_folder: String

@export var productionGrid: GridContainer
@export var energyGrid: GridContainer
@export var fundationsGrid: GridContainer
@export var decorationGrid: GridContainer


@onready var grids = {
	BuildingData.BuildingCategory.MACHINE : productionGrid,
	BuildingData.BuildingCategory.POWER_NODE : energyGrid,
	BuildingData.BuildingCategory.GENERATOR : energyGrid,
	BuildingData.BuildingCategory.FUNDATIONS : fundationsGrid,
	BuildingData.BuildingCategory.DECORATION : decorationGrid
}

func _ready() -> void:
	load_all_buildings()

func load_all_buildings() -> void:
	for category: BuildingData.BuildingCategory in grids:
		for child in grids[category].get_children():
			child.queue_free()
	var dir: DirAccess = DirAccess.open(buildings_data_folder)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres") or file_name.ends_with(".res"):
				var resource_path = buildings_data_folder + "/" + file_name
				var building_data = load(resource_path)
				if building_data is BuildingData:
					create_slot(building_data)
					file_name = dir.get_next()
	else:
		print("Couldn't acces folder ", buildings_data_folder)

func create_slot(data: BuildingData) -> void:
	var new_slot: BuildingSlot = slot_scene.instantiate()
	new_slot.set_building(data)
	new_slot.is_read_only = true
	var target_grid: GridContainer = grids[data.category]
	target_grid.add_child(new_slot)
