extends Control

@onready var world_info_gridcontainer = $DragScrollContainer/VBoxContainer/CenterContainer/GridContainer

var menu: Node = null
var title: String = "EDIT_WORLD"
var content_top_margin: float = 120
var content_bottom_margin: float = 160

func _ready() -> void:
	get_viewport().size_changed.connect(refresh_size)

func refresh_size() -> void:
	var canvas_size = get_viewport().get_screen_transform().affine_inverse()*Vector2(get_viewport().size)
	scale = Vector2(menu.scale_factor, menu.scale_factor)
	set_deferred("size", Vector2(canvas_size.x/menu.scale_factor, (canvas_size.y-((content_top_margin+content_bottom_margin)*menu.scale_factor))/menu.scale_factor))
	
func load_world_info() -> void:
	if menu == null:
		return
	var selected_world_name = menu.panel_control_dict["single_game_panel"].selected_world_name
	if world_info_gridcontainer.has_node("WorldName"):
		world_info_gridcontainer.get_node("WorldName").set_line_edit_text(selected_world_name)
	var world_list_path = SettingsManager.get_default_value("world_list_path")
	var world_config = ConfigFile.new()
	var world_info = world_config.load_encrypted_pass(world_list_path+selected_world_name+"/level.dat", SettingsManager.get_default_value("config_password"))
	if world_info != OK:
		return
	var read_allow_cheat = world_config.get_value("world", "allow_cheat", SettingsManager.get_default_world_info("allow_cheat"))
	var read_achievement = world_config.get_value("world", "achievement", SettingsManager.get_default_world_info("achievement"))
	if world_info_gridcontainer.has_node("AllowCheat"):
		world_info_gridcontainer.get_node("AllowCheat").set_option_button_text(read_allow_cheat)
	if world_info_gridcontainer.has_node("Achievement"):
		world_info_gridcontainer.get_node("Achievement").set_option_button_text(read_achievement)

func _on_confirm_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	if menu == null:
		return
	var old_world_name = menu.panel_control_dict["single_game_panel"].selected_world_name
	var new_world_name = ""
	if world_info_gridcontainer.has_node("WorldName"):
		new_world_name = world_info_gridcontainer.get_node("WorldName").get_line_edit_text()
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
	if world_info_gridcontainer.has_node("AllowCheat"):
		read_allow_cheat = world_info_gridcontainer.get_node("AllowCheat").get_option_button_text()
	if world_info_gridcontainer.has_node("Achievement"):
		read_achievement = world_info_gridcontainer.get_node("Achievement").get_option_button_text()
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
	if menu != null:
		await menu.menu_controller.vanish("edit_world_panel")
		menu.panel_control_dict.erase("edit_world_panel")
		get_viewport().size_changed.disconnect(refresh_size)
		var single_game_panel = menu.panel_control_dict["single_game_panel"]
		single_game_panel.selected_world_name = ""
		await single_game_panel.update_world_list()
		menu.base_content_panel.title = single_game_panel.title
		menu.base_content_panel.content_top_margin = single_game_panel.content_top_margin
		menu.base_content_panel.content_bottom_margin = single_game_panel.content_bottom_margin
		menu.base_content_panel.animated_refresh_size(single_game_panel)
		menu.menu_controller.appear("single_game_panel")
	queue_free()

func _on_cancel_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	if menu != null:
		await menu.menu_controller.vanish("edit_world_panel")
		menu.panel_control_dict.erase("edit_world_panel")
		get_viewport().size_changed.disconnect(refresh_size)
		var single_game_panel = menu.panel_control_dict["single_game_panel"]
		single_game_panel.selected_world_name = ""
		await single_game_panel.update_world_list()
		menu.base_content_panel.title = single_game_panel.title
		menu.base_content_panel.content_top_margin = single_game_panel.content_top_margin
		menu.base_content_panel.content_bottom_margin = single_game_panel.content_bottom_margin
		menu.base_content_panel.animated_refresh_size(single_game_panel)
		menu.menu_controller.appear("single_game_panel")
	queue_free()
