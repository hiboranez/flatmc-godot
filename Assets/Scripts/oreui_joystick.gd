extends Control

@onready var joystick = $JoystickPanel/Joystick

var max_len = 156
var on_draging = -1

func _input(event: InputEvent) -> void:
	if StaticLoad.game == null:
		return
	if StaticLoad.game.is_map or StaticLoad.game.is_pause or StaticLoad.game.is_chat or StaticLoad.game.is_inventory or StaticLoad.game.is_crafting or StaticLoad.game.is_sign_edit:
		return
	
	if event is InputEventMouseButton and event.is_pressed():
		var mouse_pos = (event.position - self.global_position - Vector2(170, 170)).length()
		if mouse_pos <= max_len or event.button_index == on_draging:
			on_draging = event.button_index
			joystick.set_global_position(event.position - Vector2(170, 170))
			if get_point_pos().length() > max_len:
				joystick.set_position(get_point_pos().normalized() * max_len)
	
	if event is InputEventMouseMotion and on_draging == 1:
		var mouse_pos = (event.position - self.global_position - Vector2(170, 170)).length()
		if mouse_pos <= max_len:
			on_draging = 1
			joystick.set_global_position(event.position - Vector2(170, 170))
			if get_point_pos().length() > max_len:
				joystick.set_position(get_point_pos().normalized() * max_len)
	
	if event is InputEventMouseButton and not event.is_pressed():
		if event.button_index == on_draging:
			set_center()
			on_draging = -1
	
	if event is InputEventScreenDrag or (event is InputEventScreenTouch and event.is_pressed()):
		var mouse_pos = (event.position - self.global_position - Vector2(170, 170)).length()
		if mouse_pos <= max_len or event.get_index() == on_draging:
			on_draging = event.get_index()
			joystick.set_global_position(event.position - Vector2(170, 170))
			if get_point_pos().length() > max_len:
				joystick.set_position(get_point_pos().normalized() * max_len)
	
	if event is InputEventScreenTouch and not event.is_pressed():
		if event.get_index() == on_draging:
			set_center()
			on_draging = -1

func get_point_pos():
	return joystick.position

func set_center():
	var tween = get_tree().create_tween()
	tween.tween_property(joystick, "position", Vector2(0, 0), 0.1)

func get_now_pos():
	return get_point_pos() / max_len
