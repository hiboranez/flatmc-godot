extends HSplitContainer

@onready var title_label = $Title
@onready var scroll_bar = $HScrollBar
@onready var value_label = $HScrollBar/Value

@export var setting_name: String = ""
@export var title: String = ""
@export var value_type: String = "int"
@export var min_value: float = 1
@export var max_value: float = 1
@export var default_value: float = 1

func _ready() -> void:
	title_label.text = tr(title)
	scroll_bar.value = default_value
	scroll_bar.min_value = min_value
	scroll_bar.max_value = max_value
	if value_type == "percent":
		value_label.text = str(scroll_bar.value)+"%"
		scroll_bar.min_value = 0
		scroll_bar.max_value = 100
	elif value_type == "percent-switch":
		if scroll_bar.value == 0:
			value_label.text = tr("OFF")
		else:
			value_label.text = str(scroll_bar.value)+"%"
		scroll_bar.min_value = 0
		scroll_bar.max_value = 100
	elif value_type == "int":
		value_label.text = str(int(scroll_bar.value))

func load_setting(config: ConfigFile):
	scroll_bar.value = int(config.get_value("settings", setting_name, SettingsManager.get_default_setting(setting_name)))
	if value_type == "percent":
		value_label.text = str(scroll_bar.value)+"%"
		scroll_bar.min_value = 0
		scroll_bar.max_value = 100
	elif value_type == "percent-switch":
		if scroll_bar.value == 0:
			value_label.text = tr("OFF")
		else:
			value_label.text = str(scroll_bar.value)+"%"
		scroll_bar.min_value = 0
		scroll_bar.max_value = 100
	elif value_type == "int":
		value_label.text = str(int(scroll_bar.value))

func save_setting(change_dict: Dictionary):
	change_dict[setting_name] = str(scroll_bar.value)

func set_scroll_bar_value(got_value: float) -> void:
	scroll_bar.value = got_value

func get_scroll_bar_value() -> float:
	return scroll_bar.value

func _on_scroll_bar_scrolling() -> void:
	if value_type == "percent":
		value_label.text = str(scroll_bar.value)+"%"
	elif value_type == "percent-switch":
		if scroll_bar.value == 0:
			value_label.text = tr("OFF")
		else:
			value_label.text = str(scroll_bar.value)+"%"
	elif value_type == "int":
		value_label.text = str(int(scroll_bar.value))
