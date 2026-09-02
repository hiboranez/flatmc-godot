extends Button

@onready var icon_texture = $Icon

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if is_hovered():
		icon_texture.texture = StaticLoad.middle_button_chosen
	else:
		icon_texture.texture = StaticLoad.middle_button_normal
