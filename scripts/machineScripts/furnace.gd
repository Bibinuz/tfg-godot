class_name Furnace extends Machine

@onready var gui : Control = $FurnaceGUI
#@onready var itemlist: ItemList = $FurnaceGUI/CenterContainer/ItemList

var gui_active = false

func _ready() -> void:
	gui.hide()
	var formula1 : Formula = Formula.new({IronOre.new(): 2}, {IronIngot.new(): 1}, 2)
	var formula2 : Formula = Formula.new({IronOre.new(): 2, Stone.new(): 2}, {IronIngot.new(): 2}, 2)
	aviable_formulas = [formula1, formula2]
	pass



func interacted() -> void:
	gui_active = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	gui.show()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("exit") and gui_active:
		gui_active = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		gui.hide()
		
