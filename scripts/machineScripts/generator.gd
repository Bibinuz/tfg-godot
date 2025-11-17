class_name Generator extends PowerNode

@onready var motorShaft : MeshInstance3D = $Shaft
@onready var ray : RayCast3D = $RayConnection
var stress : float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	speed = 1
	cost_per_speed = 8
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if connections != []:
		print(connections)
	stress = abs(speed)*cost_per_speed
	if not is_overstressed:
		motorShaft.rotate(Vector3(0,0,1), speed * delta)


	
