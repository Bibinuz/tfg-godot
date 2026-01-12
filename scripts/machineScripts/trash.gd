class_name Trash extends Machine


func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	accept_input()
	pass


func accept_input() -> void:
	if input_ports[0].port_belt:
		var temp: Belt = input_ports[0].port_belt
		if temp.speed > 0 and temp.trying_to_pass and is_equal_approx(temp.trying_to_pass.progress_ratio, 1):
			if temp.try_remove_item(temp.trying_to_pass):
				print("Erased")
				temp.trying_to_pass.queue_free()
