extends Button

@onready var nine_patch_rect = $Icon

func _process(delta: float) -> void:
	if disabled:
		nine_patch_rect.texture = TextureManager.texture_dict["ui"]["ui_button_disabled"]
		return
	#elif pressed():
		#self.icon = load("res://Assets/Textures/GUI/button_pressed.png") as Texture2D
	elif is_hovered():
		nine_patch_rect.texture = TextureManager.texture_dict["ui"]["ui_button_hovered"]
	else:
		nine_patch_rect.texture = TextureManager.texture_dict["ui"]["ui_button"]
