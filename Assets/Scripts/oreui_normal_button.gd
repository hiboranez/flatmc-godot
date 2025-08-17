extends Control

@onready var background_rect = $Background
@onready var text_label = $Background/GridContainer/Text
@onready var icon_texture_rect = $Background/GridContainer/MarginContainer/Icon
@onready var icon_margin_container = $Background/GridContainer/MarginContainer

@export var text: String = "text"
@export var font_size: int = 35
@export var button_type: String = "text"
@export var icon_path: String = ""
@export var background_path: String = ""

signal pressed

var state = ButtonState.NORMAL
var prev_state = ButtonState.NORMAL
var is_hovered: bool = false

func _ready() -> void:
	text_label.text = tr(text)
	text_label.set("theme_override_font_sizes/font_size", font_size)
	if background_path != "":
		background_rect.texture = TextureManager.get_texture(background_path)
		icon_margin_container.visible = false
		text_label.visible = false
		set_process(false)
		return
	if (button_type == "all" or button_type == "icon") and icon_path.contains("/"):
		icon_texture_rect.texture = TextureManager.get_texture(icon_path)
		if icon_texture_rect.texture == null:
			icon_margin_container.visile = false
	if button_type == "icon":
		text_label.visible = false
	elif button_type == "text":
		icon_margin_container.visible = false
		var background_size = background_rect.size
		if text_label.size.x > background_size.x:
			text_label.text_overrun_behavior = TextServer.OverrunBehavior.OVERRUN_TRIM_CHAR
			text_label.custom_minimum_size.x = background_size.x
	elif button_type == "all":
		var background_size = background_rect.size
		if text_label.size.x > background_size.x-background_size.y:
			text_label.text_overrun_behavior = TextServer.OverrunBehavior.OVERRUN_TRIM_CHAR
			text_label.custom_minimum_size.x = background_size.x-background_size.y

func _process(delta: float) -> void:
	if text != text_label.text:
		text_label.text = tr(text)
	if state != prev_state:
		match state:
			ButtonState.NORMAL:
				background_rect.texture = TextureManager.get_texture("ui/oreui_normal_button")
			ButtonState.HOVERD:
				background_rect.texture = TextureManager.get_texture("ui/oreui_normal_button")
			ButtonState.DISABLED:
				background_rect.texture = TextureManager.get_texture("ui/oreui_normal_button_disabled")
		prev_state = state

func _gui_input(event: InputEvent) -> void:
	if state == ButtonState.DISABLED:
		return
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

func set_available(is_available: bool) -> void:
	if state != ButtonState.DISABLED and not is_available:
		state = ButtonState.DISABLED
	elif state == ButtonState.DISABLED and is_available:
		if is_hovered:
			state = ButtonState.HOVERD
		else:
			state = ButtonState.NORMAL

func _on_mouse_entered() -> void:
	is_hovered = true
	if state == ButtonState.NORMAL:
		state = ButtonState.HOVERD

func _on_mouse_exited() -> void:
	is_hovered = false
	if state == ButtonState.HOVERD:
		state = ButtonState.NORMAL
