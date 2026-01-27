class_name Shaft extends PowerNode

@onready var shaftMesh = $shaftMesh


func _ready() -> void:
	super()


func _process(delta: float) -> void:
	super(delta)
	if not is_overstressed:
		shaftMesh.rotate(Vector3(0,1,0), speed*delta)
	pass

func break_part() -> void:
	var key = connections.keys()[0]
	for con: PortConnection in connections[key]:
		if con.node is Belt:
			con.node.is_shaft_in_ends(self)

	super()


func placed() -> void:
	super()

func interacted() -> void:
	super()
	#print(connections)
