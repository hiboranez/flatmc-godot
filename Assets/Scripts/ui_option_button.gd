extends HSplitContainer

@onready var title_label = $Title
@onready var option_button = $OptionButton

@export var setting_name: String = ""
@export var title: String = ""
@export var option_type = "switch"
@export var default_option: String = "on"

func _ready() -> void:
	title_label.text = tr(title)
	if option_type == "block_selection_box":
		option_button.clear()
		option_button.add_item("SHOW_WHEN_CHANGING")
		option_button.add_item("ALWAYS_SHOW")
		option_button.add_item("NEVER_SHOW")
	elif option_type == "world_type":
		option_button.clear()
		option_button.add_item("DEFAULT")
		option_button.add_item("FLAT")
	elif option_type == "gamemode":
		option_button.clear()
		option_button.add_item("SURVIVAL")
		option_button.add_item("CREATIVE")
	elif option_type == "resource_pack":
		option_button.clear()
		option_button.add_item("OFFICIAL_NEW")
		option_button.add_item("OFFICIAL_OLD")
	for i in range(option_button.item_count):
		if option_button.get_item_text(i) == default_option.to_upper():
			option_button.selected = i
			break

func load_setting(config: ConfigFile):
	var text = config.get_value("settings", setting_name, SettingsManager.get_default_setting(setting_name))
	for i in range(option_button.item_count):
		if option_button.get_item_text(i) == text.to_upper():
			option_button.selected = i
			break

func save_setting(change_dict: Dictionary):
	change_dict[setting_name] = option_button.get_item_text(option_button.selected).to_lower()

func set_option_button_text(got_text: String) -> void:
	for i in range(option_button.item_count):
		if option_button.get_item_text(i) == got_text.to_upper():
			option_button.selected = i
			break

func get_option_button_text() -> String:
	return option_button.get_item_text(option_button.selected).to_lower()
