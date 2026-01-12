class_name BuildList extends Node

var all_power_nodes: Array[PowerNode] = []

func _ready() -> void:
	GlobalScript.build_list = self
