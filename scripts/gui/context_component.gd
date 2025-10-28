class_name ContextComponent extends CenterContainer

@export var icon : TextureRect
@export var context : Label
@export var default_icon : Texture2D



func _ready() -> void:
	MessageBus.interaction_focused.connect(update)
	MessageBus.interaction_unfocused.connect(reset)
	reset()

	
func reset() -> void:
	icon.texture = null
	context.text = ""

func update(message: String, image: Texture2D = default_icon, override: bool = false) -> void:
	context.text = message
	if override:
		icon.texture = image
	else:
		icon.texture = default_icon
