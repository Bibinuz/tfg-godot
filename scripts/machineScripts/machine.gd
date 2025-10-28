extends Node3D

class_name Machine

enum Strategy {
	FORWARD,
	GENERATE,
	CONVERT
}

var input_ports : Array[Machine]
var output_ports : Array[Machine]
var aviable_formulas : Array[Formula]
var selected_formula : int
var strategy : Strategy
var cost : float
var speed : float = 1.0
