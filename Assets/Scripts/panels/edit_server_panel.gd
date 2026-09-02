extends Control

@onready var server_info_gridcontainer = $DragScrollContainer/VBoxContainer/CenterContainer/GridContainer

var menu: Node = null
var title: String = "ADD_SERVER"
var content_top_margin: float = 120
var content_bottom_margin: float = 160

func _ready() -> void:
	get_viewport().size_changed.connect(refresh_size)

func refresh_size() -> void:
	var canvas_size = get_viewport().get_screen_transform().affine_inverse()*Vector2(get_viewport().size)
	scale = Vector2(menu.scale_factor, menu.scale_factor)
	set_deferred("size", Vector2(canvas_size.x/menu.scale_factor, (canvas_size.y-((content_top_margin+content_bottom_margin)*menu.scale_factor))/menu.scale_factor))

func load_server_info() -> void:
	if server_info_gridcontainer.has_node("ServerName"):
		server_info_gridcontainer.get_node("ServerName").set_line_edit_text(ServerManager.server_name)
	var server_list_path = SettingsManager.get_default_value("server_list_path")
	var server_config = ConfigFile.new()
	var server_info = server_config.load_encrypted_pass(SettingsManager.get_default_value("server_list_path")+ServerManager.server_name+".srv", SettingsManager.get_default_value("config_password"))
	if server_info != OK:
		return
	var read_ip = server_config.get_value("server", "server_ip", "")
	var read_port = server_config.get_value("server", "server_port", "")
	if server_info_gridcontainer.has_node("ServerIP"):
		server_info_gridcontainer.get_node("ServerIP").set_line_edit_text(read_ip)
	if server_info_gridcontainer.has_node("ServerPort"):
		server_info_gridcontainer.get_node("ServerPort").set_line_edit_text(read_port)

func edit_server(server_name: String, server_ip: String, server_port: String):
	var server_list_path = SettingsManager.get_default_value("server_list_path")
	var old_server_path = server_list_path+ServerManager.server_name+".srv"
	var server_config = ConfigFile.new()
	var server_info = server_config.load_encrypted_pass(old_server_path, SettingsManager.get_default_value("config_password"))
	if server_info != OK:
		return
	var icon_buffer = server_config.get_value("server", "server_icon", TextureManager.get_texture("ui/default_offline_server_icon").get_image().save_png_to_buffer())
	var server = ConfigFile.new()
	server.set_value("server", "server_type", "third_party")
	server.set_value("server", "server_ip", server_ip)
	server.set_value("server", "server_port", server_port)
	server.set_value("server", "server_icon", icon_buffer)
	if FileAccess.file_exists(old_server_path):
		DirAccess.remove_absolute(old_server_path)
		#OS.move_to_trash(ProjectSettings.globalize_path(delete_path))
	var new_server_path = server_list_path+server_name+".srv"
	server.save_encrypted_pass(new_server_path, SettingsManager.get_default_value("config_password"))

func _on_confirm_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	var server_name = server_info_gridcontainer.get_node("ServerName").get_line_edit_text()
	var server_ip = server_info_gridcontainer.get_node("ServerIP").get_line_edit_text()
	var server_port = server_info_gridcontainer.get_node("ServerPort").get_line_edit_text()
	var server_path = SettingsManager.get_default_value("server_list_path")+server_name+".srv"
	if server_name == "":
		SceneManager.pop_notification(self, "WARNING", "WARNING_4")
		return
	if server_name != ServerManager.server_name and FileAccess.file_exists(server_path):
		SceneManager.pop_notification(self, "WARNING", "WARNING_5")
		return
	if server_ip == "":
		SceneManager.pop_notification(self, "WARNING", "WARNING_6")
		return
	if server_port == "":
		SceneManager.pop_notification(self, "WARNING", "WARNING_7")
		return
	edit_server(server_name, server_ip, server_port)
	if menu != null:
		await menu.menu_controller.vanish("edit_server_panel")
		menu.panel_control_dict.erase("edit_server_panel")
		get_viewport().size_changed.disconnect(refresh_size)
		var multi_game_panel = menu.panel_control_dict["multi_game_panel"]
		await multi_game_panel.update_server_list()
		multi_game_panel.detect_all_server()
		menu.base_content_panel.title = multi_game_panel.title
		menu.base_content_panel.content_top_margin = multi_game_panel.content_top_margin
		menu.base_content_panel.content_bottom_margin = multi_game_panel.content_bottom_margin
		menu.base_content_panel.animated_refresh_size(multi_game_panel)
		menu.menu_controller.appear("multi_game_panel")
	queue_free()

func _on_cancel_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	if menu != null:
		await menu.menu_controller.vanish("edit_server_panel")
		menu.panel_control_dict.erase("edit_server_panel")
		get_viewport().size_changed.disconnect(refresh_size)
		var multi_game_panel = menu.panel_control_dict["multi_game_panel"]
		await multi_game_panel.update_server_list()
		multi_game_panel.detect_all_server()
		menu.base_content_panel.title = multi_game_panel.title
		menu.base_content_panel.content_top_margin = multi_game_panel.content_top_margin
		menu.base_content_panel.content_bottom_margin = multi_game_panel.content_bottom_margin
		menu.base_content_panel.animated_refresh_size(multi_game_panel)
		menu.menu_controller.appear("multi_game_panel")
	queue_free()
