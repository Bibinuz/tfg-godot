class_name Generator extends Building

@export var speed : float = 0.0
@export var stressPerSpeed : float = 8
@onready var motorShaft : MeshInstance3D = $Shaft
@onready var ray : RayCast3D = $RayConnection
var stress : float
var isConnected : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	stress = abs(speed)*stressPerSpeed
	motorShaft.rotate(Vector3(0,0,1), speed * delta)
	isConnected = check_Connections()
	
		
func check_Connections() -> bool:
	if ray.is_colliding():
		var collider = ray.get_collider()
		if collider.get_parent():
			pass
	return false
	
