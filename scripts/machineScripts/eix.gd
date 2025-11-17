class_name Shaft extends PowerNode

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	cost_per_speed = 0
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if len(connections) == 2:
		if connections[0].speed != 0 and (connections[1].speed ==0 or connections[1].speed == connections[0].speed):
			speed = connections[0].speed
		elif connections[1].speed != 0 and (connections[0].speed ==0 or connections[0].speed == connections[1].speed):
			speed = connections[1].speed
		elif connections[0].speed == 0 and connections[1].speed == 0:
			speed = 0
		else:
			remove_building()
			return
	elif len(connections) == 1:
		speed = connections[0].speed
	else:
		speed = 0
	if not is_overstressed:
		rotate(Vector3(0, 0, 1), speed*delta)
	pass
	
func _physics_process(_delta: float) -> void:
	pass
