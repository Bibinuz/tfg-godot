extends Node

class_name Formula

var input_materials : Dictionary[Materials, int]
var output_materials : Dictionary[Materials, int]
var time : float

func _init (input : Dictionary[Materials, int], output : Dictionary[Materials, int], t : float) -> void:
	input_materials = input
	output_materials = output
	time = t
