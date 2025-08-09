extends NinePatchRect

@onready var text_label = $HSplitContainer/Text
@onready var icon_texture_rect = $HSplitContainer/Icon

@export var text: String = "text"
@export var font_size: int = 35
@export var button_type: String = "normal"
@export var icon_path: String = "null"

signal pressed

var state = ButtonState.NORMAL
var prev_state = ButtonState.NORMAL

func _ready() -> void:
	text_label.text = tr(text)
	text_label.set("theme_override_font_sizes/font_size", font_size)
	if (button_type == "normal" or button_type == "icon") and icon_path.contains("/"):
		if button_type == "icon":
			text_label.visible = false
		icon_texture_rect.texture = TextureManager.get_texture(icon_path)
	else:
		icon_texture_rect.visible = false

func _process(delta: float) -> void:
	if text != text_label.text:
		text_label.text = tr(text)
	if state != prev_state:
		match state:
			ButtonState.NORMAL:
				texture = TextureManager.get_texture("ui/ui_button")
			ButtonState.HOVERD:
				texture = TextureManager.get_texture("ui/ui_button_hovered")
			ButtonState.DISABLED:
				texture = TextureManager.get_texture("ui/ui_button_disabled")
		prev_state = state

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 1 and not event.pressed:
			if Rect2(Vector2(), size).has_point(event.position):
				pressed.emit()
	elif event is InputEventScreenTouch:
		if event.pressed:
			if state == ButtonState.NORMAL:
				state = ButtonState.HOVERD
		else:
			if Rect2(Vector2(), size).has_point(event.position):
				pressed.emit()
				if state == ButtonState.HOVERD:
					state = ButtonState.NORMAL
			else:
				if state == ButtonState.HOVERD:
					state = ButtonState.NORMAL

func _on_mouse_entered() -> void:
	if state == ButtonState.NORMAL:
		state = ButtonState.HOVERD

func _on_mouse_exited() -> void:
	if state == ButtonState.HOVERD:
		state = ButtonState.NORMAL
