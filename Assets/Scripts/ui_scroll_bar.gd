extends Control

@onready var title_label = $Title
@onready var scroll = $Background/Scroll

@export var setting_name: String = ""
@export var title: String = ""
@export var value_type: String = "int"
@export var min_value: float = 0
@export var max_value: float = 1
@export var default_value: float = 0
@export var step: float = 0

var value: float = 0
var is_dragging: bool = false
var scroll_state = ButtonState.NORMAL
var prev_scroll_state = ButtonState.NORMAL

func _ready() -> void:
	value = default_value
	update_display()

func _process(delta: float) -> void:
	if scroll_state != prev_scroll_state:
		match scroll_state:
			ButtonState.NORMAL:
				scroll.texture = TextureManager.get_texture("ui/ui_button")
			ButtonState.HOVERD:
				scroll.texture = TextureManager.get_texture("ui/ui_button_hovered")
			ButtonState.DISABLED:
				scroll.texture = TextureManager.get_texture("ui/ui_button_disabled")
		prev_scroll_state = scroll_state

func _gui_input(event: InputEvent) -> void:
	if not is_dragging:
		return
	if event is InputEventMouseMotion:
		var value_linear = (event.position.x)/size.x
		value_linear = min(value_linear, 1)
		value_linear = max(value_linear, 0)
		value = min_value+value_linear*(max_value-min_value)
		if step > 0:
			var remainder = fmod(value, step)
			if remainder >= step/2:
				value=value-remainder+step
			else:
				value=value-remainder			
		update_display()

func _on_scroll_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 1:
			if not event.pressed and is_dragging:
				if not Rect2(Vector2(), scroll.size).has_point(event.position):
					if scroll_state == ButtonState.HOVERD:
						scroll_state = ButtonState.NORMAL
			if event.pressed:
				is_dragging = true
			else:
				is_dragging = false
	if event is InputEventScreenTouch:
		if event.pressed:
			if scroll_state == ButtonState.NORMAL:
				scroll_state = ButtonState.HOVERD
		else:
			if scroll_state == ButtonState.HOVERD:
				scroll_state = ButtonState.NORMAL
		if event.pressed:
			is_dragging = true
		else:
			is_dragging = false

func _on_scroll_mouse_entered() -> void:
	if not is_dragging and scroll_state == ButtonState.NORMAL:
		scroll_state = ButtonState.HOVERD

func _on_scroll_mouse_exited() -> void:
	if not is_dragging and scroll_state == ButtonState.HOVERD:
		scroll_state = ButtonState.NORMAL

func update_display():
	scroll.position.x = (size.x-scroll.size.x)*((value-min_value)/(max_value-min_value))
	if value_type == "percent":
		title_label.text = tr(title)+" : "+str(value)+"%"
	elif value_type == "percent-switch":
		if value == 0:
			title_label.text = tr(title)+" : "+tr("OFF")
		else:
			title_label.text = tr(title)+" : "+str(value)+"%"
	elif value_type == "int":
		title_label.text = tr(title)+" : "+str(int(value))

func load_setting(config: ConfigFile):
	value = int(config.get_value("settings", setting_name, SettingsManager.get_default_setting(setting_name)))
	if value_type.contains("percent"):
		min_value = 0
		max_value = 100
	update_display()

func save_setting(change_dict: Dictionary):
	change_dict[setting_name] = str(value)

func set_scroll_bar_value(got_value: float) -> void:
	value = got_value

func get_scroll_bar_value() -> float:
	return value
