extends Node

@onready var server_list_vboxcontainer = $ColorRect/ScrollContainer/VBoxContainer

var server_detect_list: Array

func _ready() -> void:
	ServiceDiscovery.port = 4040
	ServiceDiscovery.scanned_server.connect(_on_scan_server)
	ServiceDiscovery.scanned.connect(_on_scan_scanned)
	rectify_official_server()
	update_server_list()
	detect_all_server()

func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		AudioManager.play_static_audio("sound/ui/click")
		SceneManager.change_scene("menus/main_menu")

func clear_selected_background():
	for server in server_list_vboxcontainer.get_children():
		if server.has_method("set_selected_background_visible"):
			server.set_selected_background_visible(false)

func rectify_official_server() -> void:
	var server_list = DirAccess.get_files_at(SettingsManager.get_default_value("server_list_path"))
	var is_official_server_exsist: bool = false
	for server in server_list:
		if server == SettingsManager.get_default_official_server_info("server_name")+".srv":
			var server_config = ConfigFile.new()
			var server_config_state = server_config.load_encrypted_pass(SettingsManager.get_default_value("server_list_path")+SettingsManager.get_default_official_server_info("server_name")+".srv", SettingsManager.get_default_value("config_password"))
			if server_config_state == OK:
				var server_info_dict = {
					"server_type": server_config.get_value("server", "server_type", "third_party"),
					"server_ip": server_config.get_value("server", "server_ip", ""),
					"server_port": int(server_config.get_value("server", "server_port", "-1"))
				}
				var is_info_correct: bool = true
				for key in server_info_dict.keys():
					if str(server_info_dict[key]) != SettingsManager.get_default_official_server_info(key):
						is_info_correct = false
						break
				if is_info_correct:
					is_official_server_exsist = true
					break
	if not is_official_server_exsist:
		SettingsManager.generate_official_server()
	
func detect_all_server():
	await get_tree().create_timer(0.01).timeout
	var server_list = DirAccess.get_files_at(SettingsManager.get_default_value("server_list_path"))
	for server in server_list:
		var splits = server.split(".")
		var server_config = ConfigFile.new()
		var server_info = server_config.load_encrypted_pass(SettingsManager.get_default_value("server_list_path")+splits[0]+".srv", SettingsManager.get_default_value("config_password"))
		if server_info != OK:
			var server_button = server_list_vboxcontainer.get_node(splits[0])
			server_button.update_info({
				"animation": "disconnect",
				"online_info": tr("CANNOT_CONNECT")
			})
			continue
		server_detect_list.clear()
		var server_detect = SceneManager.get_scene("others/server_detect").instantiate()
		StaticLoad.server_detects.add_child(server_detect)
		server_detect.update_info({
			"server_name": splits[0],
			"server_ip": server_config.get_value("server", "server_ip", ""),
			"server_port":  int(server_config.get_value("server", "server_port", "-1"))
		})
		server_detect_list.append(server_detect)
	if not server_detect_list.is_empty():
		var server_detect = server_detect_list.pop_front()
		server_detect.start()
	#thread.wait_to_finish()

func update_server_list():
	var current_servers = server_list_vboxcontainer.get_children()
	for server_detect in StaticLoad.server_detects.get_children():
		server_detect.disconnect_and_free()
	for server in current_servers:
		server.free()
	var server_list = DirAccess.get_files_at(SettingsManager.get_default_value("server_list_path"))
	for server in server_list:
		var server_button = SceneManager.get_scene("ui/ui_server_button").instantiate()
		server_list_vboxcontainer.add_child(server_button)
		var splits = server.split(".")
		server_button.update_data({
			"server_name" : splits[0],
			"refresh": true
		})
	var searching_lan_instance = SceneManager.get_scene("others/searching_lan").instantiate()
	server_list_vboxcontainer.add_child(searching_lan_instance)
	get_node("/root/ServerManager").update_data({
		"server_name": "",
		"server_type": "", 
		"server_ip": "",
		"server_port": -1
	})
	ServiceDiscovery.scan_lan_servers()

func delete_server(server_name: String):
	var server_path = SettingsManager.get_default_value("server_list_path")+server_name+".srv"
	if not FileAccess.file_exists(server_path):
		return
	OS.move_to_trash(ProjectSettings.globalize_path(server_path))
	update_server_list()
	detect_all_server()

func add_lan_server(data):
	var lan_server = SceneManager.get_scene("ui/ui_lan_server_button").instantiate()
	server_list_vboxcontainer.add_child(lan_server)
	var splits = str(data.server_data.Name).split("|")
	var player_name = str(data.server_data.Name).substr(splits[0].length()+1)
	lan_server.init({
		"server_name": player_name+tr("S_SERVER"),
		"server_ip": str(data.server_ip),
		"server_port": int(splits[0])
	})

func _on_scan_server(data):
	add_lan_server(data)

func _on_scan_scanned():
	pass

func _on_muti_menu_join_server_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	if get_node("/root/ServerManager").server_name == "":
		return
	for server_detect in StaticLoad.server_detects.get_children():
		server_detect.disconnect_and_free()
	SceneManager.change_scene("menus/loading_server_menu")

func _on_muti_menu_refresh_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	update_server_list()
	detect_all_server()
	
func _on_muti_menu_back_to_menu_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	for server_detect in StaticLoad.server_detects.get_children():
		server_detect.disconnect_and_free()
	get_node("/root/ServerManager").update_data({
		"server_name": "",
		"server_type": "", 
		"server_ip": "",
		"server_port": -1
	})
	SceneManager.change_scene("menus/main_menu")

func _on_muti_menu_add_server_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	var add_server_menu = SceneManager.get_scene("menus/add_server_menu").instantiate()
	add_child(add_server_menu)

func _on_muti_menu_edit_server_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	if get_node("/root/ServerManager").server_name == "":
		return
	if get_node("/root/ServerManager").server_type == "official":
		SceneManager.pop_notification(self, tr("WARNING"), tr("OFFICIAL_SERVER_EDIT"))
		return
	var edit_server_menu = SceneManager.get_scene("menus/edit_server_menu").instantiate()
	add_child(edit_server_menu)
	
func _on_muti_menu_delete_server_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	if get_node("/root/ServerManager").server_name == "":
		return
	if get_node("/root/ServerManager").server_type == "official":
		SceneManager.pop_notification(self, tr("WARNING"), tr("OFFICIAL_SERVER_DELETE"))
		return
	SceneManager.pop_secondary_confirmation(self, get_node("/root/ServerManager").server_name + tr("SECONDARY_CONFIRMATION_1"), Callable(self, "delete_server").bind(get_node("/root/ServerManager").server_name))
