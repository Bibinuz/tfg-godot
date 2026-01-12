class_name Machine extends PowerNode

enum Strategy {
	FORWARD,
	GENERATE,
	CONVERT
}

@export_group("Machine data")
@export var input_ports : Array[MachinePort]
@export var output_ports : Array[MachinePort]
@export var aviable_formulas : Array[Formula]

var selected_formula : int

@export_group("Machine characteristics")
@export var strategy : Strategy
@export var production_speed : float = 1.0

func _ready() -> void:
	super()
	cost_per_speed = -1

func _process(_delta: float) -> void:

	pass

func set_power_state() -> void:
	if is_overstressed:
		production_speed = 0
	else:
		print("System overstressed")

	if speed == 0:
		print("Machine is Off")
	else:
		print("Machine is On and connected at: ", speed)

func break_part() -> void:
	for port: MachinePort in input_ports:
		if port and port.port_belt:
			port.port_belt.break_part()
	for port: MachinePort in output_ports:
		if port and port.port_belt:
			port.port_belt.break_part()
	super()
