class_name Cog extends PowerNode

@onready var cogMesh = $Gear

func _ready() -> void:
	super()
	pass

func _process(delta: float) -> void:
	super(delta)
	if not is_overstressed:
		cogMesh.rotate(Vector3(0, 1, 0), speed * delta)

func placed() -> void:
	super()
