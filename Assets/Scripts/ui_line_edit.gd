extends HSplitContainer

@onready var title_label = $Title
@onready var line_edit = $LineEdit

@export var setting_name: String = ""
@export var title: String = ""
@export var default_text: String = ""

func _ready() -> void:
	title_label.text = tr(title)
	line_edit.text = tr(default_text)

func _on_line_edit_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if not event.pressed and Rect2(Vector2(), size).has_point(event.position):
			line_edit.grab_focus()
			line_edit.select_all()

func load_setting(config: ConfigFile):
	line_edit.text = config.get_value("settings", setting_name, SettingsManager.get_default_setting(setting_name))	

func save_setting(change_dict: Dictionary):
	change_dict[setting_name] = line_edit.text

func set_line_edit_text(got_text: String) -> void:
	line_edit.text = got_text

func get_line_edit_text() -> String:
	return line_edit.text
