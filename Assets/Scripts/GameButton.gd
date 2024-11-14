extends Button

@onready var icon_texture = $Icon

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if disabled:
		icon_texture.texture = StaticLoad.button_disabled
		return
	#elif pressed():
		#self.icon = load("res://Assets/Textures/GUI/button_pressed.png") as Texture2D
	elif is_hovered():
		icon_texture.texture = StaticLoad.button_chosen
	else:
		icon_texture.texture = StaticLoad.button_normal
