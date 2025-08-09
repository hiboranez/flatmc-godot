extends CanvasLayer

@onready var server_vboxcontainer = $ColorRect/ScrollContainer/VBoxContainer

func add_server(server_name: String, server_ip: String, server_port: String) -> void:
	var server_list_path = SettingsManager.get_default_value("server_list_path")
	var server = ConfigFile.new()
	server.set_value("server", "server_type", "third_party")
	server.set_value("server", "server_ip", server_ip)
	server.set_value("server", "server_port", server_port)
	server.set_value("server", "server_icon", TextureManager.get_texture("ui/default_offline_server_icon").get_image().save_png_to_buffer())
	server.save_encrypted_pass(server_list_path+server_name+".srv", SettingsManager.get_default_value("config_password"))

func _on_add_server_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	if not server_vboxcontainer.has_node("ServerPort"):
		return
	var server_name = server_vboxcontainer.get_node("ServerName").get_line_edit_text()
	var server_ip = server_vboxcontainer.get_node("ServerIP").get_line_edit_text()
	var server_port = server_vboxcontainer.get_node("ServerPort").get_line_edit_text()
	var server_path = SettingsManager.get_default_value("server_list_path")+server_name+".srv"
	if server_name == "":
		SceneManager.pop_notification(self, "WARNING", "WARNING_4")
		return
	if FileAccess.file_exists(server_path):
		SceneManager.pop_notification(self, "WARNING", "WARNING_5")
		return
	if server_ip == "":
		SceneManager.pop_notification(self, "WARNING", "WARNING_6")
		return
	if server_port == "":
		SceneManager.pop_notification(self, "WARNING", "WARNING_7")
		return
	add_server(server_name, server_ip, server_port)
	if has_node("/root/MultiMenu"):
		var multi_menu = get_node("/root/MultiMenu")
		multi_menu.update_server_list()
		multi_menu.detect_all_server()
	if get_tree().get_root() != self:
		queue_free()

func _on_cancel_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	if get_tree().get_root() != self:
		queue_free()
