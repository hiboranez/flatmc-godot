extends Control

@onready var single_column_gridcontainer = $DragScrollContainer/VBoxContainer/SingleColumnCenterContainer/SingleColumnGridContainer
@onready var double_column_gridcontainer = $DragScrollContainer/VBoxContainer/DoubleColumnCenterContainer/DoubleColumnGridContainer
@onready var single_column_center_container = $DragScrollContainer/VBoxContainer/SingleColumnCenterContainer
@onready var double_column_center_container = $DragScrollContainer/VBoxContainer/DoubleColumnCenterContainer

var menu: Node = null
var title: String = "SETTINGS"
var content_top_margin: float = 120
var content_bottom_margin: float = 160

func _ready() -> void:
	get_viewport().size_changed.connect(refresh_size)
	#var canvas_size = (get_global_transform_with_canvas().affine_inverse()*get_viewport().get_screen_transform().affine_inverse()*Vector2(get_viewport().size))
	#scale = Vector2(menu.scale_factor, menu.scale_factor)
	#pivot_offset.x = canvas_size.x*(1-menu.scale_factor)/(2*(1-menu.scale_factor))

#func _gui_input(event: InputEvent) -> void:
	#if event is InputEventMouseButton:
		#if event.button_index == 1 and event.pressed:
			#grab_focus()
	#elif event is InputEventScreenTouch:
		#if event.pressed:
			#grab_focus()

func refresh_size() -> void:
	#var canvas_size = (get_global_transform_with_canvas().affine_inverse()*get_viewport().get_screen_transform().affine_inverse()*Vector2(get_viewport().size))
	#var margin = (canvas_size.x*0.96-(get_global_transform_with_canvas().affine_inverse()*Vector2(middle_size, middle_size)).x)/(2*menu.scale_factor)
	var canvas_size = get_viewport().get_screen_transform().affine_inverse()*Vector2(get_viewport().size)
	scale = Vector2(menu.scale_factor, menu.scale_factor)
	set_deferred("size", Vector2(canvas_size.x/menu.scale_factor, (canvas_size.y-((content_top_margin+content_bottom_margin)*menu.scale_factor))/menu.scale_factor))
	#var center_size = (get_global_transform_with_canvas().affine_inverse()*Vector2(middle_size, middle_size))
	#single_column_center_container.custom_minimum_size.x = center_size.x
	#double_column_center_container.custom_minimum_size.x = center_size.x
	
func load_settings() -> void:
	var config = ConfigFile.new()
	var result = config.load("user://configs.cfg")
	if result != OK:
		return
	for setting_node in single_column_gridcontainer.get_children():
		if setting_node.has_method("load_setting"):
			setting_node.load_setting(config)
			if get_tree() != null:
				await get_tree().process_frame
	for setting_node in double_column_gridcontainer.get_children():
		if setting_node.has_method("load_setting"):
			setting_node.load_setting(config)
			if get_tree() != null:
				await get_tree().process_frame

func save_settings() -> Dictionary:
	if single_column_gridcontainer.has_node("PlayerName"):
		var player_name = single_column_gridcontainer.get_node("PlayerName").get_line_edit_text()
		if player_name == "":
			SceneManager.pop_notification(self, "WARNING", "WARNING_2")
			return {"saving_state": false}
		if player_name.length() > int(SettingsManager.get_default_value("max_name_length")):
			SceneManager.pop_notification(self, "WARNING", "WARNING_9")
			return {"saving_state": false}
		if player_name.contains(" "):
			SceneManager.pop_notification(self, "WARNING", "WARNING_10")
			return {"saving_state": false}
	var last_setting_dict = SettingsManager.setting_dict.duplicate()
	var change_dict = {}
	for setting_node in single_column_gridcontainer.get_children():
		if setting_node.has_method("save_setting"):
			setting_node.save_setting(change_dict)
	for setting_node in double_column_gridcontainer.get_children():
		if setting_node.has_method("save_setting"):
			setting_node.save_setting(change_dict)
	SettingsManager.save_settings(change_dict)
	return last_setting_dict

func _on_save_button_pressed() -> void:
	var last_setting_dict = save_settings()
	if SettingsManager.get_current_setting("full_screen") == "on" and DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	elif SettingsManager.get_current_setting("full_screen") == "off" and DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	if SettingsManager.get_current_setting("v_sync") == "on" and DisplayServer.window_get_vsync_mode() != DisplayServer.VSYNC_ENABLED:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	elif SettingsManager.get_current_setting("v_sync") == "off" and DisplayServer.window_get_mode() != DisplayServer.VSYNC_DISABLED:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	if last_setting_dict.has("new_music") and SettingsManager.get_current_setting("new_music") != last_setting_dict["new_music"]:
		AudioManager.refresh_bgm()
	AudioManager.set_bgm_volume(int(SettingsManager.get_current_setting("bgm_volume"))/50.0)
	AudioManager.set_sound_volume(int(SettingsManager.get_current_setting("sound_volume"))/50.0)
	AudioManager.play_static_audio("sound/ui/click")
	if last_setting_dict.has("saving_state") and not last_setting_dict["saving_state"]:
		return
	if menu != null:
		await menu.menu_controller.vanish("menu")
	if has_node("/root/MainMenu"):
		var main_menu = get_node("/root/MainMenu")
		main_menu.menu_scroll_speed = float(SettingsManager.get_current_setting("menu_scroll"))/100.0
		main_menu.refresh_size()
		main_menu.menu_controller.appear("menu")
	if menu != null:
		get_viewport().size_changed.disconnect(refresh_size)
		menu.queue_free()

func _on_cancel_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	if menu != null:
		await menu.menu_controller.vanish("menu")
	if has_node("/root/MainMenu"):
		var main_menu = get_node("/root/MainMenu")
		main_menu.refresh_size()
		main_menu.menu_controller.appear("menu")
	if menu != null:
		get_viewport().size_changed.disconnect(refresh_size)
		menu.queue_free()

func _on_gui_scale_switch_button_changed() -> void:
	if not double_column_gridcontainer.has_node("GUIScale"):
		return
	var gui_scale_switch_button = double_column_gridcontainer.get_node("GUIScale")
	menu.scale_factor = SettingsManager.get_menu_scale_factor(gui_scale_switch_button.get_option_button_text())
	menu.refresh_size()
