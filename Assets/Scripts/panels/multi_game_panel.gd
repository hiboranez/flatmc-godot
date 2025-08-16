extends Control

@onready var server_list_gridcontainer = $DragScrollContainer/VBoxContainer/CenterContainer/GridContainer

var menu: Node = null
var title: String = "MULTI_MODE"
var content_top_margin: float = 120
var content_bottom_margin: float = 360

var server_detect_list: Array

func _ready() -> void:
	ServiceDiscovery.port = 4040
	ServiceDiscovery.scanned_server.connect(_on_scan_server)
	ServiceDiscovery.scanned.connect(_on_scan_scanned)
	get_viewport().size_changed.connect(refresh_size)

func refresh_size() -> void:
	var canvas_size = get_viewport().get_screen_transform().affine_inverse()*Vector2(get_viewport().size)
	scale = Vector2(menu.scale_factor, menu.scale_factor)
	set_deferred("size", Vector2(canvas_size.x/menu.scale_factor, (canvas_size.y-((content_top_margin+content_bottom_margin)*menu.scale_factor))/menu.scale_factor))

func clear_selected_background():
	for server in server_list_gridcontainer.get_children():
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
			var server_button = server_list_gridcontainer.get_node(splits[0])
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
			"server_port":  int(server_config.get_value("server", "server_port", "-1")),
			"panel": self
		})
		server_detect_list.append(server_detect)
	if not server_detect_list.is_empty():
		var server_detect = server_detect_list.pop_front()
		server_detect.start()
	#thread.wait_to_finish()

func update_server_list():
	var current_servers = server_list_gridcontainer.get_children()
	for server_detect in StaticLoad.server_detects.get_children():
		server_detect.disconnect_and_free()
	for server in current_servers:
		server.free()
	var server_list = DirAccess.get_files_at(SettingsManager.get_default_value("server_list_path"))
	for server in server_list:
		var server_button = SceneManager.get_scene("ui/ui_server_button").instantiate()
		server_list_gridcontainer.add_child(server_button)
		var splits = server.split(".")
		server_button.update_data({
			"refresh": true,
			"server_name" : splits[0],
			"panel": self
		})
		if get_tree() != null:
			await get_tree().process_frame
	var searching_lan_instance = SceneManager.get_scene("others/searching_lan").instantiate()
	server_list_gridcontainer.add_child(searching_lan_instance)
	if get_tree() != null:
		await get_tree().process_frame
	ServerManager.update_data({
		"server_name": "",
		"server_type": "", 
		"server_ip": "",
		"server_port": -1
	})
	if get_tree() != null:
		await get_tree().process_frame
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
	server_list_gridcontainer.add_child(lan_server)
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

func _on_join_server_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	if ServerManager.server_name == "":
		return
	for server_detect in StaticLoad.server_detects.get_children():
		server_detect.disconnect_and_free()
	await menu.menu_controller.vanish("multi_game_panel")
	var loading_server_panel = SceneManager.get_scene("panels/loading_server_panel").instantiate()
	menu.panel_control_dict["loading_server_panel"] = loading_server_panel
	menu.base_content_panel.set_content(loading_server_panel)
	loading_server_panel.menu = menu
	menu.base_content_panel.title = loading_server_panel.title
	menu.base_content_panel.content_top_margin = loading_server_panel.content_top_margin
	menu.base_content_panel.content_bottom_margin = loading_server_panel.content_bottom_margin
	menu.base_content_panel.animated_refresh_size(loading_server_panel)
	await menu.menu_controller.appear("loading_server_panel")
	loading_server_panel.connect_server()

func _on_refresh_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	update_server_list()
	detect_all_server()
	
func _on_back_to_menu_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	for server_detect in StaticLoad.server_detects.get_children():
		server_detect.disconnect_and_free()
	ServerManager.update_data({
		"server_name": "",
		"server_type": "", 
		"server_ip": "",
		"server_port": -1
	})
	if menu != null:
		await menu.menu_controller.vanish("menu")
	if has_node("/root/MainMenu"):
		get_node("/root/MainMenu").menu_controller.appear("menu")
	if menu != null:
		menu.queue_free()

func _on_add_server_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	await menu.menu_controller.vanish("multi_game_panel")
	var add_server_panel = SceneManager.get_scene("panels/add_server_panel").instantiate()
	menu.panel_control_dict["add_server_panel"] = add_server_panel
	menu.base_content_panel.set_content(add_server_panel)
	add_server_panel.menu = menu
	menu.base_content_panel.title = add_server_panel.title
	menu.base_content_panel.content_top_margin = add_server_panel.content_top_margin
	menu.base_content_panel.content_bottom_margin = add_server_panel.content_bottom_margin
	menu.base_content_panel.animated_refresh_size(add_server_panel)
	menu.menu_controller.appear("add_server_panel")

func _on_edit_server_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	if ServerManager.server_name == "":
		return
	if ServerManager.server_type == "official":
		SceneManager.pop_notification(self, tr("WARNING"), tr("OFFICIAL_SERVER_EDIT"))
		return
	await menu.menu_controller.vanish("multi_game_panel")
	var edit_server_panel = SceneManager.get_scene("panels/edit_server_panel").instantiate()
	menu.panel_control_dict["edit_server_panel"] = edit_server_panel
	menu.base_content_panel.set_content(edit_server_panel)
	edit_server_panel.menu = menu
	edit_server_panel.load_server_info()
	menu.base_content_panel.title = edit_server_panel.title
	menu.base_content_panel.content_top_margin = edit_server_panel.content_top_margin
	menu.base_content_panel.content_bottom_margin = edit_server_panel.content_bottom_margin
	menu.base_content_panel.animated_refresh_size(edit_server_panel)
	menu.menu_controller.appear("edit_server_panel")
	
func _on_delete_server_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	if ServerManager.server_name == "":
		return
	if ServerManager.server_type == "official":
		SceneManager.pop_notification(self, tr("WARNING"), tr("OFFICIAL_SERVER_DELETE"))
		return
	SceneManager.pop_secondary_confirmation(self, ServerManager.server_name + tr("SECONDARY_CONFIRMATION_1"), Callable(self, "delete_server").bind(ServerManager.server_name))
