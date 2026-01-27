class_name Generator extends PowerNode

@export var generate_per_speed : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	is_passive=false
	is_running = true
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	if not is_overstressed and is_running and is_placed:
		meshes[0].rotate(Vector3(0, 1, 0), speed * delta)
	#if not is_overstressed and is_running:

func interacted() -> void:
	#print(PowerGridManager.find_whole_grid_bfs(self))
	super()


func placed() -> void:
	super()
	speed = 1.0
