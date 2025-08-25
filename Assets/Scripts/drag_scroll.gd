extends ScrollContainer

var is_dragging = false
var start_position = 0
var drag_direction = 0

func _gui_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton or event is InputEventScreenTouch) and event.pressed:
		is_dragging = true
		start_position = event.position.y
		
	if (event is InputEventMouseButton or event is InputEventScreenTouch) and not event.pressed:
		is_dragging = false
		start_position = 0
		
	if is_dragging:
		var offset = event.position.y - start_position
		if offset > 0:
			drag_direction = -1
		elif offset < 0:
			drag_direction = 1
		self.scroll_vertical -= offset
		start_position = event.position.y
