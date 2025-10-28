class_name Furnace extends Machine



func _ready() -> void:
	var formula1 : Formula = Formula.new({IronOre.new(): 2}, {IronIngot.new(): 1}, 2)
	aviable_formulas = [formula1]
	pass
