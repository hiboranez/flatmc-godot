extends ScrollContainer

var isDrag = false
var startPos = 0
var dragDir = 0

func _gui_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton or event is InputEventScreenTouch) and event.pressed:
		isDrag = true
		startPos = event.position.y
		
	if (event is InputEventMouseButton or event is InputEventScreenTouch) and not event.pressed:
		isDrag = false
		startPos = 0
		
	if isDrag:
		var offset = event.position.y - startPos
		if offset > 0:
			dragDir = -1
		elif offset < 0:
			dragDir = 1
		self.scroll_vertical -= offset
		startPos = event.position.y
