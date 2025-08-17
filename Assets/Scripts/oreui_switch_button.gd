extends Control

@onready var background_rect = $Background
@export var button_name: String = ""

signal pressed(is_pressed: bool)

var state = ButtonState.NORMAL
var prev_state = ButtonState.NORMAL

func _ready() -> void:
	background_rect.texture = TextureManager.get_texture("ui/oreui_"+button_name+"_button")

func _process(delta: float) -> void:
	if state != prev_state:
		match state:
			ButtonState.NORMAL:
				background_rect.texture = TextureManager.get_texture("ui/oreui_"+button_name+"_button")
			ButtonState.PRESSED:
				background_rect.texture = TextureManager.get_texture("ui/oreui_"+button_name+"_button_pressed")
		prev_state = state

func _gui_input(event: InputEvent) -> void:
	if state == ButtonState.DISABLED:
		return
	if button_name != "":
		if event is InputEventMouseButton:
			if event.button_index == 1 and not event.pressed:
				if Rect2(Vector2(), size).has_point(event.position):
					if state == ButtonState.NORMAL:
						pressed.emit(true)
						state = ButtonState.PRESSED
					elif state == ButtonState.PRESSED:
						pressed.emit(false)
						state = ButtonState.NORMAL
		elif event is InputEventScreenTouch:
			if not event.pressed:
				if Rect2(Vector2(), size).has_point(event.position):
					if state == ButtonState.NORMAL:
						pressed.emit(true)
						state = ButtonState.PRESSED
					elif state == ButtonState.PRESSED:
						pressed.emit(false)
						state = ButtonState.NORMAL
