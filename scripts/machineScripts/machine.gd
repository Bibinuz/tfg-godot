class_name Machine extends PowerNode


enum Strategy {
	FORWARD,
	GENERATE,
	CONVERT
}

var input_ports : Array[Machine]
var output_ports : Array[Machine]
var aviable_formulas : Array[Formula]
var selected_formula : int
var connected_speed : float
var current_cost : float

@export_group("Machine characteristics")
@export var strategy : Strategy
@export var production_speed : float = 1.0

func _ready() -> void:
	cost_per_speed = -1.0
	connected_speed = 0
	current_cost = 0

func set_power_state() -> void:
	if is_overstressed:
		production_speed = 0
	else:
		production_speed = connected_speed
		print("System overstressed")
		
	current_cost = cost_per_speed*connected_speed
	if connected_speed == 0:
		print("Machine is Off")
	else:
		print("Machine is On and connected at: ", connected_speed)
