extends Node

var default_value_dict: Dictionary
var default_setting_dict: Dictionary
var default_world_info_dict: Dictionary

var setting_dict: Dictionary

func _ready() -> void:
	var default_settings_json = DataManager.load_json_file("res://assets/data/default_settings.json", {})
	default_setting_dict = default_settings_json["settings"]
	default_value_dict = default_settings_json["values"]
	default_world_info_dict = default_settings_json["world_infos"]
	setting_dict = default_setting_dict.duplicate()
	
	var exist_settings = check_settings_outdated()
	if exist_settings["is_setting_outdated"]:
		generate_settings(exist_settings)
	
	var config = ConfigFile.new()
	var result = config.load("user://configs.cfg")
	if result == OK:
		var setting_list = config.get_section_keys("settings")
		if not setting_list.is_empty():
			for setting in setting_list:
				setting_dict[setting] = config.get_value("settings", setting, default_setting_dict[setting])
	
	TranslationServer.set_locale(setting_dict["language"])
	if setting_dict["full_screen"] == "on" and DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	elif setting_dict["full_screen"] == "off" and DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	if setting_dict["v_sync"] == "on" and DisplayServer.window_get_vsync_mode() != DisplayServer.VSYNC_ENABLED:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	elif setting_dict["v_sync"] == "off" and DisplayServer.window_get_mode() != DisplayServer.VSYNC_DISABLED:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	StaticLoad.click_audio_player.volume_db = linear_to_db(int(setting_dict["sound_volume"])/50.0)
	if setting_dict["updated"] == "false" or setting_dict["version"] == "null" or setting_dict["version"] != get_default_setting("version"):
		SceneManager.pop_big_notification(self, tr("RELEASE_NOTE"), tr("RELEASE_NOTE_TEXT"), tr("DO_NOT_SHOW_AGAIN"))
		generate_official_server()
		var change_value = {
		"updated": "true",
		"version": get_default_setting("version")
		}
		save_settings(change_value)
	
	if not DirAccess.dir_exists_absolute(default_value_dict["screenshot_path"]):
		DirAccess.make_dir_recursive_absolute(default_value_dict["screenshot_path"])
	if not DirAccess.dir_exists_absolute(default_value_dict["server_list_path"]):
		DirAccess.make_dir_recursive_absolute(default_value_dict["server_list_path"])
	if not DirAccess.dir_exists_absolute(default_value_dict["server_root_path"]):
		DirAccess.make_dir_recursive_absolute(default_value_dict["server_root_path"])
	if not DirAccess.dir_exists_absolute(default_value_dict["server_log_path"]):
		DirAccess.make_dir_recursive_absolute(default_value_dict["server_log_path"])

func get_default_world_info(info_name) -> String:
	return default_world_info_dict[info_name]

func get_default_value(value_name) -> String:
	return default_value_dict[value_name]

func get_default_setting(setting_name) -> String:
	return default_setting_dict[setting_name]

func get_current_setting(setting_name) -> String:
	return setting_dict[setting_name]
	
func set_current_setting(setting_name, value) -> void:
	setting_dict[setting_name] = value

func get_selection_by_on_or_off(on_or_off, default="on"):
	if on_or_off == "on":
		return 0
	elif on_or_off == "off":
		return 1

func generate_official_server() -> void:
	var server = ConfigFile.new()
	server.set_value("server", "ip", "flatmc.hiboranez.work")
	server.set_value("server", "port", "12419")
	server.set_value("server", "icon", TextureManager.get_texture("ui/fmc_icon").get_image().save_png_to_buffer())
	server.save_encrypted_pass(default_value_dict["server_list_path"]+"FlatMC.srv", default_value_dict["config_password"])

func check_settings_outdated() -> Dictionary:
	var exsit_settings = {"is_setting_outdated": false}
	var config = ConfigFile.new()
	var result = config.load("user://configs.cfg")
	if result != OK:
		exsit_settings["is_setting_outdated"] = true
		return exsit_settings
	for key in StaticLoad.settings.keys():
		var setting = config.get_value("settings", key, null)
		if setting == null:
			exsit_settings["is_setting_outdated"] = true
		else:
			exsit_settings[key] = setting
	return exsit_settings

func generate_settings(exist_settings: Dictionary) -> void:
	var default_config = ConfigFile.new()
	TranslationServer.set_locale("zh")
	for key in default_setting_dict.keys():
		if key == "version":
			continue
		if exist_settings.has(key):
			default_config.set_value("settings", key, exist_settings[key])
		else:
			default_config.set_value("settings", key, str(default_setting_dict[key]))
	default_config.save("user://configs.cfg")

func save_settings(change_value: Dictionary) -> void:
	var current_config = ConfigFile.new()
	var config = ConfigFile.new()
	var result = current_config.load("user://configs.cfg")
	if result != OK:
		return
	for key in default_setting_dict.keys():
		var current_value = current_config.get_value("settings", key, default_setting_dict[key])
		if key == "player_name" and current_value.length() > int(default_value_dict["max_name_length"]):
			current_value = current_value.substr(0, int(default_value_dict["max_name_length"]))
		config.set_value("settings", key, current_value)
	for key in change_value.keys():
		config.set_value("settings", key, change_value[key])
	config.save("user://configs.cfg")
