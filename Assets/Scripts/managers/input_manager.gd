extends Node

var full_screen_control: Control = null
var prev_mouse_position: Vector2 = Vector2(0, 0)
var is_move_input_frozen: bool = false

func update_components() -> void:
	full_screen_control = SceneManager.get_scene("ui/full_screen_control").instantiate() 
	add_child(full_screen_control)

func get_mouse_position() -> Vector2:
	return full_screen_control.get_global_mouse_position()
