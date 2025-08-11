extends Control

@onready var single_column_gridcontainer = $DragScrollContainer/VBoxContainer/SingleColumnCenterContainer/SingleColumnGridContainer
@onready var double_column_gridcontainer = $DragScrollContainer/VBoxContainer/DoubleColumnCenterContainer/DoubleColumnGridContainer
@onready var single_column_center_container = $DragScrollContainer/VBoxContainer/SingleColumnCenterContainer
@onready var double_column_center_container = $DragScrollContainer/VBoxContainer/DoubleColumnCenterContainer

var middle_size: float = 1522
var menu: Node = null

func _ready() -> void:
	refresh_size()
	get_viewport().size_changed.connect(refresh_size)
	#var canvas_size = (get_global_transform_with_canvas().affine_inverse()*get_viewport().get_screen_transform().affine_inverse()*Vector2(get_viewport().size))
	#scale = Vector2(menu.scale_factor, menu.scale_factor)
	#pivot_offset.x = canvas_size.x*(1-menu.scale_factor)/(2*(1-menu.scale_factor))

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			grab_focus()
	elif event is InputEventScreenTouch:
		if event.pressed:
			grab_focus()

func refresh_size() -> void:
	#var canvas_size = (get_global_transform_with_canvas().affine_inverse()*get_viewport().get_screen_transform().affine_inverse()*Vector2(get_viewport().size))
	#var margin = (canvas_size.x*0.96-(get_global_transform_with_canvas().affine_inverse()*Vector2(middle_size, middle_size)).x)/(2*menu.scale_factor)
	
	var scale_factor = 1
	scale = Vector2(scale_factor, scale_factor)
	var canvas_size = (get_global_transform_with_canvas().affine_inverse()*get_viewport().get_screen_transform().affine_inverse()*Vector2(get_viewport().size))
	pivot_offset.x = (canvas_size.x/2)*scale_factor
	var center_size = (get_global_transform_with_canvas().affine_inverse()*Vector2(middle_size, middle_size))
	single_column_center_container.custom_minimum_size.x = center_size.x
	double_column_center_container.custom_minimum_size.x = center_size.x
	
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
	if double_column_gridcontainer.has_node("PlayerName"):
		var player_name = double_column_gridcontainer.get_node("PlayerName").get_line_edit_text()
		if player_name == "":
			SceneManager.pop_notification(self, "WARNING", "WARNING_2")
			return {}
		if player_name.length() > int(SettingsManager.get_default_value("max_name_length")):
			SceneManager.pop_notification(self, "WARNING", "WARNING_9")
			return {}
		if player_name.contains(" "):
			SceneManager.pop_notification(self, "WARNING", "WARNING_10")
			return {}
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
	if SettingsManager.get_current_setting("new_music") != last_setting_dict["new_music"]:
		AudioManager.refresh_bgm()
	AudioManager.set_bgm_volume(int(SettingsManager.get_current_setting("bgm_volume"))/50.0)
	AudioManager.set_sound_volume(int(SettingsManager.get_current_setting("sound_volume"))/50.0)
	AudioManager.play_static_audio("sound/ui/click")
	if menu != null:
		await menu.menu_controller.vanish()
	if has_node("/root/MainMenu"):
		get_node("/root/MainMenu").menu_controller.appear()
	if menu != null:
		get_viewport().size_changed.disconnect(refresh_size)
		menu.queue_free()

func _on_cancel_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	if menu != null:
		await menu.menu_controller.vanish()
	if has_node("/root/MainMenu"):
		get_node("/root/MainMenu").menu_controller.appear()
	if menu != null:
		get_viewport().size_changed.disconnect(refresh_size)
		menu.queue_free()
