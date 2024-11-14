extends ScrollContainer

var isDrag = false
var startPos = 0
var dragDir = 0

func _on_scrollcontainer_gui_input(event):
	if StaticLoad.is_on_mobile_platform:
		return
	if event is InputEventMouseButton and event.pressed:
		isDrag = true
		startPos = event.position.y
		
	if event is InputEventMouseButton and not event.pressed:
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
