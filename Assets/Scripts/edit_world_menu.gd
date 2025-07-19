extends CanvasLayer

@onready var edit_world_name_line_edit = $Content/ScrollContainer/VBoxContainer/WorldName/LineEdit
@onready var edit_world_allow_cheat_setting_button = $Content/ScrollContainer/VBoxContainer/AllowCheat/OptionButton
@onready var edit_world_achievement_setting_button = $Content/ScrollContainer/VBoxContainer/Achievement/OptionButton

var selected_world: String = ""

func init(original_world_name):
	edit_world_name_line_edit.text = original_world_name
	selected_world = original_world_name
	var worlds_path = "user://worlds"
	var world_config = ConfigFile.new()
	var world_info = world_config.load_encrypted_pass(worlds_path+"/"+selected_world+"/level.dat", SettingsManager.get_default_value("config_password"))
	if world_info != OK:
		return
	var allow_cheat_on = world_config.get_value("world", "allow_cheat", SettingsManager.get_default_world_info("allow_cheat"))
	var achievement_on = world_config.get_value("world", "achievement", SettingsManager.get_default_world_info("achievement"))
	#if allow_cheat_on == "on" and achievement_on == "on":
		#achievement_on = "off"
	edit_world_allow_cheat_setting_button.selected = SettingsManager.get_selection_by_on_or_off(allow_cheat_on)
	edit_world_achievement_setting_button.selected = SettingsManager.get_selection_by_on_or_off(achievement_on)
	_on_edit_world_allow_cheat_setting_button_item_selected(0)

func _on_edit_world_allow_cheat_setting_button_item_selected(index: int) -> void:
	pass
	#var allow_cheat_on = StaticLoad.get_on_or_off_by_selection(edit_world_allow_cheat_setting_button.selected)
	#if allow_cheat_on == "on":
		#if StaticLoad.get_on_or_off_by_selection(edit_world_achievement_setting_button.selected) == "on":
			#edit_world_achievement_setting_button.selected = SettingsManager.get_selection_by_on_or_off("off")
		#edit_world_achievement_setting_button.disabled = true
	#elif allow_cheat_on == "off" and edit_world_achievement_setting_button.disabled:
		#edit_world_achievement_setting_button.disabled = false

func _on_edit_world_menu_confirm_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	var world_path_tmp = "user://worlds/"
	var save_path = world_path_tmp+edit_world_name_line_edit.text
	if edit_world_name_line_edit.text == "":
		SceneManager.pop_notification(self, "WARNING", "WARNING_3")
		return
	if edit_world_name_line_edit.text != selected_world and DirAccess.dir_exists_absolute(save_path):
		SceneManager.pop_notification(self, "WARNING", "WARNING_1")
		return
	var level = ConfigFile.new()
	var current_time = Time.get_datetime_string_from_system(false, true).replace(" ", "  ").replace("-", "/")
	var allow_cheat_on = StaticLoad.get_on_or_off_by_selection(edit_world_allow_cheat_setting_button.selected)
	var achievement_on =StaticLoad.get_on_or_off_by_selection(edit_world_achievement_setting_button.selected)
	var level_change_value = {
		"last_modified": current_time,
		"allow_cheat": allow_cheat_on,
		"achievement": achievement_on
	}
	StaticLoad.save_level_dat(level, level_change_value)
	level.save_encrypted_pass(world_path_tmp+selected_world+"/level.dat", SettingsManager.get_default_value("config_password"))
	DirAccess.rename_absolute(world_path_tmp+selected_world, world_path_tmp+edit_world_name_line_edit.text)
	if has_node("/root/single_menu"):
		var single_menu = get_node("/root/single_menu")
		single_menu.selected_world = ""
		single_menu.update_world_list()
	if get_tree().get_root() != self:
		queue_free()

func _on_edit_world_menu_cancel_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	if get_tree().get_root() != self:
		queue_free()
