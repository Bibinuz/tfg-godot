class_name MachinePort extends StaticBody3D

var machine: Machine

var port_belt: Belt = null


func _process(_delta: float) -> void:

	pass

func interacted()-> void:
	print(global_rotation)

func try_pass_material(mat: Materials) -> bool:
	if port_belt:
		var vis_mat: VisualMaterial = GlobalScript.give_visual_material(mat.name)
		if vis_mat:
			var pos_in_belt: float = 0.0
			if is_zero_approx(port_belt.global_rotation.y) and (port_belt.global_position - global_position).x < 0:
				pos_in_belt = 0
			elif port_belt.global_rotation.y > 1.5 and (port_belt.global_position - global_position).z < 0:
				pos_in_belt = port_belt.belt_length

			if port_belt.try_add_item(pos_in_belt):
				port_belt.path.add_child(vis_mat)
				vis_mat.progress = pos_in_belt
				return true
			vis_mat.queue_free()
	return false
