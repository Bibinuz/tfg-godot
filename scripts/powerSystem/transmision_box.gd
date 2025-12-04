extends PowerNode


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	if not is_overstressed:
		meshes[0].rotate(Vector3(0,1,0), speed*delta)
		meshes[1].rotate(Vector3(0,1,0), -speed*delta)
		meshes[2].rotate(Vector3(1,0,0), speed*delta)
		meshes[3].rotate(Vector3(1,0,0), -speed*delta)

func get_port_rotation_axis(port: PowerNodePort) -> Vector3:
	var local_pos: Vector3 = port.position
	if abs(local_pos.x) > 0.1:
		return global_transform.basis.x.snappedf(1.0)
	return global_transform.basis.y.snappedf(1.0)
