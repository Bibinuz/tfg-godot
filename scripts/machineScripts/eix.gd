class_name Shaft extends PowerNode


@onready var shaftMesh = $shaftMesh

func _ready() -> void:
	super()


func _process(delta: float) -> void:
	super(delta)
	if not is_overstressed:
		# Man what the fuck is this
		shaftMesh.rotate(Vector3(0,1,0), speed*delta)
	pass


func placed() -> void:
	super()
