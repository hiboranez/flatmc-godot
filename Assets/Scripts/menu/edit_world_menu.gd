extends CanvasLayer

@onready var setting_vboxcontainer = $Content/ScrollContainer/VBoxContainer

func _ready() -> void:
	if not has_node("/root/SingleMenu"):
		return
	var selected_world_name = get_node("/root/SingleMenu").selected_world_name
	if setting_vboxcontainer.has_node("WorldName"):
		setting_vboxcontainer.get_node("WorldName").set_line_edit_text(selected_world_name)
	var world_list_path = SettingsManager.get_default_value("world_list_path")
	var world_config = ConfigFile.new()
	var world_info = world_config.load_encrypted_pass(world_list_path+selected_world_name+"/level.dat", SettingsManager.get_default_value("config_password"))
	if world_info != OK:
		return
	var read_allow_cheat = world_config.get_value("world", "allow_cheat", SettingsManager.get_default_world_info("allow_cheat"))
	var read_achievement = world_config.get_value("world", "achievement", SettingsManager.get_default_world_info("achievement"))
	if setting_vboxcontainer.has_node("AllowCheat"):
		setting_vboxcontainer.get_node("AllowCheat").set_option_button_text(read_allow_cheat)
	if setting_vboxcontainer.has_node("Achievement"):
		setting_vboxcontainer.get_node("Achievement").set_option_button_text(read_achievement)

func _on_edit_world_menu_confirm_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	if not has_node("/root/SingleMenu"):
		return
	var old_world_name = get_node("/root/SingleMenu").selected_world_name
	var new_world_name = ""
	if setting_vboxcontainer.has_node("WorldName"):
		new_world_name = setting_vboxcontainer.get_node("WorldName").get_line_edit_text()
	var world_list_path = SettingsManager.get_default_value("world_list_path")
	var old_world_path = world_list_path+old_world_name
	var new_world_path = world_list_path+new_world_name
	if new_world_name == "":
		SceneManager.pop_notification(self, "WARNING", "WARNING_3")
		return
	if new_world_name != old_world_name and DirAccess.dir_exists_absolute(new_world_path):
		SceneManager.pop_notification(self, "WARNING", "WARNING_1")
		return
	var level = ConfigFile.new()
	var current_time = Time.get_datetime_string_from_system(false, true).replace(" ", "  ").replace("-", "/")
	var read_allow_cheat = SettingsManager.get_default_world_info("allow_cheat")
	var read_achievement = SettingsManager.get_default_world_info("achievement")
	if setting_vboxcontainer.has_node("AllowCheat"):
		read_allow_cheat = setting_vboxcontainer.get_node("AllowCheat").get_option_button_text()
	if setting_vboxcontainer.has_node("Achievement"):
		read_achievement = setting_vboxcontainer.get_node("Achievement").get_option_button_text()
	var level_change_value = {
		"last_modified": current_time,
		"allow_cheat": read_allow_cheat,
		"achievement": read_achievement
	}
	WorldManager.save_level_dat(level, level_change_value)
	level.save_encrypted_pass(old_world_path+"/level.dat", SettingsManager.get_default_value("config_password"))
	DirAccess.rename_absolute(old_world_path, new_world_path)
	if has_node("/root/SingleMenu"):
		var single_menu = get_node("/root/SingleMenu")
		single_menu.selected_world_name = ""
		single_menu.update_world_list()
	if get_tree().get_root() != self:
		queue_free()

func _on_edit_world_menu_cancel_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	if get_tree().get_root() != self:
		queue_free()
