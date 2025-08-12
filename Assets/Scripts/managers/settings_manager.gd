extends Node

var default_value_dict: Dictionary
var default_setting_dict: Dictionary
var default_language_dict: Dictionary
var default_world_info_dict: Dictionary
var default_official_server_info_dict: Dictionary

var setting_dict: Dictionary

signal settings_applied
signal settings_saved

func get_resource_amount() -> int:
	return 1

func update_resource() -> void:
	ResourceLoadingMenu.call_deferred("set_loading_info", "res://assets/data/default_settings.json")
	var default_settings_json = DataManager.load_json_file("res://assets/data/default_settings.json", {})
	default_setting_dict = default_settings_json["settings"]
	default_value_dict = default_settings_json["values"]
	default_language_dict = default_settings_json["languages"]
	default_world_info_dict = default_settings_json["world_infos"]
	default_official_server_info_dict = default_settings_json["official_server_infos"]
	setting_dict = default_setting_dict.duplicate()
	ResourceLoadingMenu.call_deferred("add_loaded_amount")

func apply_settings():
	var exist_settings = check_settings_outdated()
	if exist_settings["is_setting_outdated"]:
		generate_settings(exist_settings)
	var config = ConfigFile.new()
	var result = config.load("user://configs.cfg")
	if result == OK:
		var setting_list = config.get_section_keys("settings")
		if not setting_list.is_empty():
			for setting in setting_list:
				set_current_setting(setting, config.get_value("settings", setting, get_default_setting(setting)))
	
	DataManager.update_block_id_dict()
	TranslationServer.set_locale(get_current_setting("language"))
	if get_current_setting("full_screen") == "on" and DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	elif get_current_setting("full_screen") == "off" and DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	if get_current_setting("v_sync") == "on" and DisplayServer.window_get_vsync_mode() != DisplayServer.VSYNC_ENABLED:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	elif get_current_setting("v_sync") == "off" and DisplayServer.window_get_mode() != DisplayServer.VSYNC_DISABLED:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	if int(get_current_setting("bgm_volume")) > 0:
		AudioManager.play_random_bgm()		
		
	if get_current_setting("updated") == "false" or get_current_setting("version") == "null" or get_current_setting("version") != get_default_setting("version"):
		SceneManager.pop_big_notification(self, tr("RELEASE_NOTE"), tr("RELEASE_NOTE_TEXT"), tr("DO_NOT_SHOW_AGAIN"))
		generate_official_server()
		var change_value = {
		"updated": "true",
		"version": get_default_setting("version")
		}
		save_settings(change_value)
	
	if not DirAccess.dir_exists_absolute(get_default_value("screenshot_path")):
		DirAccess.make_dir_recursive_absolute(get_default_value("screenshot_path"))
	if not DirAccess.dir_exists_absolute(get_default_value("server_list_path")):
		DirAccess.make_dir_recursive_absolute(get_default_value("server_list_path"))
	if not DirAccess.dir_exists_absolute(get_default_value("server_root_path")):
		DirAccess.make_dir_recursive_absolute(get_default_value("server_root_path"))
	if not DirAccess.dir_exists_absolute(get_default_value("server_log_path")):
		DirAccess.make_dir_recursive_absolute(get_default_value("server_log_path"))
	settings_applied.emit()

func generate_official_server() -> void:
	var server = ConfigFile.new()
	server.set_value("server", "server_ip", default_official_server_info_dict["server_ip"])
	server.set_value("server", "server_port", default_official_server_info_dict["server_port"])
	server.set_value("server", "server_type", default_official_server_info_dict["server_type"])
	server.set_value("server", "server_icon", TextureManager.get_texture(SettingsManager.get_default_official_server_info("server_icon_path")).get_image().save_png_to_buffer())
	server.save_encrypted_pass(default_value_dict["server_list_path"]+default_official_server_info_dict["server_name"]+".srv", default_value_dict["config_password"])

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

func save_settings(change_value_dict: Dictionary) -> void:
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
		setting_dict[key] = current_value
	for key in change_value_dict.keys():
		var change_value = change_value_dict[key]
		config.set_value("settings", key, change_value)
		setting_dict[key] = change_value
	config.save("user://configs.cfg")
	settings_saved.emit()

func compare_version(version_1: String, version_2: String):
	var splits_1
	var splits_2
	if version_1 == "unknown":
		splits_1 = ["0", "1", "0"]
	else:
		splits_1 = version_1.split(".")
	if version_2 == "unknown":
		splits_2 = ["0", "1", "0"]
	else:
		splits_2 = version_2.split(".")
	var i = 0
	while i < 3:
		if int(splits_1[i]) > int(splits_2[i]):
			return "higher"
		elif int(splits_1[i]) < int(splits_2[i]):
			return "lower"
		i += 1
	return "equal"

func get_default_official_server_info(info_name) -> String:
	return default_official_server_info_dict[info_name]

func get_default_language_name(language_abbr) -> String:
	return default_language_dict[language_abbr]

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

func get_menu_scale_factor(scale_text: String) -> float:
	match scale_text:
		"big":
			return 1.0
		"middle":
			return 0.8
		"small":
			return 0.6
	return 1.0
