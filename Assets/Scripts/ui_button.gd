extends NinePatchRect

@onready var text_label = $Text
@onready var icon_texture_rect = $Icon

@export var text: String = "text"
@export var font_size: int = 35
@export var icon_path: String = "null"
var state = ButtonState.NORMAL
var prev_state = ButtonState.NORMAL
signal pressed

func _ready() -> void:
	text_label.text = tr(text)
	text_label.set("theme_override_font_sizes/font_size", font_size)
	if icon_path.contains("/"):
		text_label.visible = false
		icon_texture_rect.texture = TextureManager.get_texture(icon_path)
	else:
		icon_texture_rect.queue_free()

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
		if event.button_index == 1 and event.pressed:
			pressed.emit()
	elif event is InputEventScreenTouch:
		if event.pressed:
			pressed.emit()
	
func _on_mouse_entered() -> void:
	if state == ButtonState.NORMAL:
		state = ButtonState.HOVERD

func _on_mouse_exited() -> void:
	if state == ButtonState.HOVERD:
		state = ButtonState.NORMAL
