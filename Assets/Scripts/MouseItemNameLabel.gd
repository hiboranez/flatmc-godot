extends Label

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	position = get_viewport().get_mouse_position()+Vector2(29,25)

func start_following():
	position = get_viewport().get_mouse_position()+Vector2(29,25)
	set_process(true)
	self.visible = true
	
func stop_following():
	set_process(false)
	self.visible = false
