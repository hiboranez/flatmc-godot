extends Control

@onready var ui_button = $UIButton
@onready var text_label = $UIButton/Text

@export var setting_name: String = ""
@export var title: String = ""
@export var option_type = "switch"
@export var default_option: String = "on"

var option_dict: Dictionary
var option_list: Array
var curr_option_name: String = ""

signal changed

func _ready() -> void:
	if option_type == "switch":
		option_dict = {
			"on": "ON",
			"off": "OFF",
		}
	elif option_type == "block_selection_box":
		option_dict = {
			"show_when_changing": "SHOW_WHEN_CHANGING",
			"always_show": "ALWAYS_SHOW",
			"never_show": "NEVER_SHOW",
		}
	elif option_type == "world_type":
		option_dict = {
			"default": "DEFAULT",
			"flat": "FLAT",
		}
	elif option_type == "gamemode":
		option_dict = {
			"survival": "SURVIVAL",
			"creative": "CREATIVE",
		}
	elif option_type == "resource_pack":
		option_dict = {
			"official_new": "OFFICIAL_NEW",
			"official_old": "OFFICIAL_OLD",
		}
	elif option_type == "gui_scale":
		option_dict = {
			"big": "BIG",
			"middle": "MIDDLE",
			"small": "SMALL",
		}
	option_list = option_dict.keys()

func load_setting(config: ConfigFile):
	var text = config.get_value("settings", setting_name, SettingsManager.get_default_setting(setting_name))
	curr_option_name = text
	text_label.text = tr(title)+" : "+tr(option_dict[text])

func save_setting(change_dict: Dictionary):
	change_dict[setting_name] = curr_option_name

func set_option_button_text(got_text: String) -> void:
	text_label.text = tr(title)+" : "+tr(option_dict[got_text])

func get_option_button_text() -> String:
	return curr_option_name

func _on_ui_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	grab_focus()
	var curr_option_index = option_list.find(curr_option_name)
	var next_option_index = curr_option_index + 1
	if next_option_index >= option_list.size():
		next_option_index = 0
	var next_option_name = option_list[next_option_index]
	curr_option_name = next_option_name
	text_label.text = tr(title)+" : "+tr(option_dict[next_option_name])
	changed.emit()
