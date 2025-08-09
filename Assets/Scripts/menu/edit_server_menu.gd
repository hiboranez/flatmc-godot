extends CanvasLayer

@onready var server_vboxcontainer = $ColorRect/ScrollContainer/VBoxContainer

func _ready() -> void:
	if not has_node("/root/MultiMenu"):
		return
	if server_vboxcontainer.has_node("ServerName"):
		server_vboxcontainer.get_node("ServerName").set_line_edit_text(get_node("/root/ServerManager").server_name)
	var server_list_path = SettingsManager.get_default_value("server_list_path")
	var server_config = ConfigFile.new()
	var server_info = server_config.load_encrypted_pass(SettingsManager.get_default_value("server_list_path")+get_node("/root/ServerManager").server_name+".srv", SettingsManager.get_default_value("config_password"))
	if server_info != OK:
		return
	var read_ip = server_config.get_value("server", "server_ip", "")
	var read_port = server_config.get_value("server", "server_port", "")
	if server_vboxcontainer.has_node("ServerIP"):
		server_vboxcontainer.get_node("ServerIP").set_line_edit_text(read_ip)
	if server_vboxcontainer.has_node("ServerPort"):
		server_vboxcontainer.get_node("ServerPort").set_line_edit_text(read_port)

func edit_server(server_name: String, server_ip: String, server_port: String):
	if not has_node("/root/MultiMenu"):
		return
	var multi_menu = get_node("/root/MultiMenu")
	var server_list_path = SettingsManager.get_default_value("server_list_path")
	var old_server_path = server_list_path+get_node("/root/ServerManager").server_name+".srv"
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
	if not has_node("/root/MultiMenu"):
		return
	var multi_menu = get_node("/root/MultiMenu")
	var server_name = server_vboxcontainer.get_node("ServerName").get_line_edit_text()
	var server_ip = server_vboxcontainer.get_node("ServerIP").get_line_edit_text()
	var server_port = server_vboxcontainer.get_node("ServerPort").get_line_edit_text()
	var server_path = SettingsManager.get_default_value("server_list_path")+server_name+".srv"
	if server_name == "":
		SceneManager.pop_notification(self, "WARNING", "WARNING_4")
		return
	if server_name != get_node("/root/ServerManager").server_name and FileAccess.file_exists(server_path):
		SceneManager.pop_notification(self, "WARNING", "WARNING_5")
		return
	if server_ip == "":
		SceneManager.pop_notification(self, "WARNING", "WARNING_6")
		return
	if server_port == "":
		SceneManager.pop_notification(self, "WARNING", "WARNING_7")
		return
	edit_server(server_name, server_ip, server_port)
	multi_menu.update_server_list()
	multi_menu.detect_all_server()
	if get_tree().get_root() != self:
		queue_free()

func _on_cancel_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	if get_tree().get_root() != self:
		queue_free()
