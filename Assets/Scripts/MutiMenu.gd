extends Node

@onready var add_server_ui = $AddServerUI
@onready var add_server_name_line_edit = $AddServerUI/ColorRect2/ScrollContainer/VBoxContainer/ServerName/LineEdit
@onready var add_server_ip_line_edit = $AddServerUI/ColorRect2/ScrollContainer/VBoxContainer/ServerIP/LineEdit
@onready var add_server_port_line_edit = $AddServerUI/ColorRect2/ScrollContainer/VBoxContainer/ServerPort/LineEdit
@onready var edit_server_ui = $EditServerUI
@onready var edit_server_name_line_edit = $EditServerUI/ColorRect2/ScrollContainer/VBoxContainer/ServerName/LineEdit
@onready var edit_server_ip_line_edit = $EditServerUI/ColorRect2/ScrollContainer/VBoxContainer/ServerIP/LineEdit
@onready var edit_server_port_line_edit = $EditServerUI/ColorRect2/ScrollContainer/VBoxContainer/ServerPort/LineEdit
@onready var secondary_confirmation_scene = load("res://Assets/Scenes/SecondaryConfirmation.tscn") as PackedScene
@onready var selection_scene = load("res://Assets/Scenes/Selection.tscn") as PackedScene
@onready var searching_lan_scene = load("res://Assets/Scenes/SearchingLan.tscn") as PackedScene
@onready var lan_server_scene = load("res://Assets/Scenes/LanServer.tscn") as PackedScene
@onready var server_list_vboxcontainer = $ColorRect/ScrollContainer/VBoxContainer
@onready var server_detect = $ServerDetect

func _ready() -> void:
	StaticLoad.is_lan_server = false
	ServiceDiscovery.port = 4040
	ServiceDiscovery.scanned_server.connect(on_scan_server)
	ServiceDiscovery.scanned.connect(on_scan_scanned)
	add_server_name_line_edit.text = tr("DEFAULT_SERVER_NAME")
	update_server_list()

func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		StaticLoad.click_audio_player.play()
		StaticLoad.select_world = null
		StaticLoad.change_scene("res://Assets/Scenes/Menu.tscn")

func update_server_list():
	var current_servers = server_list_vboxcontainer.get_children()
	for server in current_servers:
		server.free()
	var server_list = DirAccess.get_files_at(StaticLoad.server_path)
	for server in server_list:
		var selection = selection_scene.instantiate()
		selection.init("muti_menu")
		server_list_vboxcontainer.add_child(selection)
		var splits = server.split(".")
		selection.text = "   "+splits[0]
		selection.name = splits[0]
		var server_config = ConfigFile.new()
		var server_info = server_config.load_encrypted_pass(StaticLoad.server_path+"/"+splits[0]+".srv", StaticLoad.CONFIG_PASSWORD)
		if server_info != OK:
			continue
		var icon_buffer = server_config.get_value("server", "icon")
		if icon_buffer == null:
			continue
		var icon_image = Image.new()
		icon_image.load_png_from_buffer(icon_buffer)
		selection.icon = ImageTexture.create_from_image(icon_image)
	var searching_lan_instance = searching_lan_scene.instantiate()
	server_list_vboxcontainer.add_child(searching_lan_instance)
	ServiceDiscovery.scan_lan_servers()

func delete_server(server_name: String):
	var delete_path = "user://servers/"+server_name+".srv"
	if not FileAccess.file_exists(delete_path):
		return
	OS.move_to_trash(ProjectSettings.globalize_path(delete_path))
	update_server_list()
	StaticLoad.select_server = null

func add_server(server_name: String):
	var server_path = "user://servers/"
	var server = ConfigFile.new()
	server.set_value("server", "ip", add_server_ip_line_edit.text)
	server.set_value("server", "port", add_server_port_line_edit.text)
	server.set_value("server", "icon", StaticLoad.default_icon_gray_image.save_png_to_buffer())
	server.save_encrypted_pass(server_path+server_name+".srv", StaticLoad.CONFIG_PASSWORD)
	StaticLoad.select_server = null

func edit_server(server_name: String):
	var server_path = "user://servers/"
	var delete_path = server_path+StaticLoad.select_server+".srv"
	var server_config = ConfigFile.new()
	var server_info = server_config.load_encrypted_pass(delete_path, StaticLoad.CONFIG_PASSWORD)
	if server_info != OK:
		return
	var icon_buffer = server_config.get_value("server", "icon")
	var server = ConfigFile.new()
	server.set_value("server", "ip", edit_server_ip_line_edit.text)
	server.set_value("server", "port", edit_server_port_line_edit.text)
	server.set_value("server", "icon", icon_buffer)
	if FileAccess.file_exists(delete_path):
		DirAccess.remove_absolute(delete_path)
		#OS.move_to_trash(ProjectSettings.globalize_path(delete_path))
	var save_path = server_path+server_name+".srv"
	server.save_encrypted_pass(save_path, StaticLoad.CONFIG_PASSWORD)
	StaticLoad.select_server = null

func on_scan_server(data):
	add_lan_server(data)

func on_scan_scanned():
	pass

func add_lan_server(data):
	var lan_server = lan_server_scene.instantiate()
	server_list_vboxcontainer.add_child(lan_server)
	var splits = str(data.server_data.Name).split("|")
	var port = splits[0]
	var player_name = str(data.server_data.Name).substr(port.length()+1)
	lan_server.ip = str(data.server_ip)
	lan_server.port = int(port)
	lan_server.name_label.text = player_name+tr("S_SERVER")
	lan_server.ip_label.text = str(data.server_ip)+":"+port

func _on_muti_menu_button_1_pressed() -> void:
	StaticLoad.click_audio_player.play()
	if StaticLoad.select_server == null and not StaticLoad.is_lan_server:
		return
	StaticLoad.change_scene("res://Assets/Scenes/LoadingServerUI.tscn")

func _on_muti_menu_button_2_pressed() -> void:
	StaticLoad.click_audio_player.play()
	update_server_list()
	server_detect.start_detecting()
	
func _on_muti_menu_button_3_pressed() -> void:
	StaticLoad.click_audio_player.play()
	StaticLoad.select_server = null
	StaticLoad.change_scene("res://Assets/Scenes/Menu.tscn")

func _on_muti_menu_button_4_pressed() -> void:
	StaticLoad.click_audio_player.play()
	add_server_name_line_edit.text = tr("DEFAULT_SERVER_NAME")
	add_server_ip_line_edit.text = ""
	add_server_port_line_edit.text = ""
	add_server_ui.visible = true;

func _on_muti_menu_button_5_pressed() -> void:
	StaticLoad.click_audio_player.play()
	if StaticLoad.select_server == "FlatMC":
		StaticLoad.pop_notification(self, tr("WARNING"), tr("OFFICIAL_SERVER_EDIT"))
		return
	if StaticLoad.select_server == null:
		return
	var server_config = ConfigFile.new()
	var server_info = server_config.load_encrypted_pass(StaticLoad.server_path+"/"+StaticLoad.select_server+".srv", StaticLoad.CONFIG_PASSWORD)
	if server_info != OK:
		return
	edit_server_name_line_edit.text = StaticLoad.select_server
	edit_server_ip_line_edit.text = server_config.get_value("server", "ip")
	edit_server_port_line_edit.text = server_config.get_value("server", "port")
	edit_server_ui.visible = true
	
func _on_muti_menu_button_6_pressed() -> void:
	StaticLoad.click_audio_player.play()
	if StaticLoad.select_server == "FlatMC":
		StaticLoad.pop_notification(self, tr("WARNING"), tr("OFFICIAL_SERVER_DELETE"))
		return
	if StaticLoad.select_server == null:
		return
	StaticLoad.pop_secondary_confirmation(self, StaticLoad.select_server + tr("SECONDARY_CONFIRMATION_1"), Callable(self, "delete_server").bind(StaticLoad.select_server))

func _on_add_server_button_1_pressed() -> void:
	StaticLoad.click_audio_player.play()
	var save_path = "user://servers/"+add_server_name_line_edit.text+".srv"
	if add_server_name_line_edit.text == "":
		StaticLoad.pop_notification(self, "WARNING", "WARNING_4")
		return
	if FileAccess.file_exists(save_path):
		StaticLoad.pop_notification(self, "WARNING", "WARNING_5")
		return
	if add_server_ip_line_edit.text == "":
		StaticLoad.pop_notification(self, "WARNING", "WARNING_6")
		return
	if add_server_port_line_edit.text == "":
		StaticLoad.pop_notification(self, "WARNING", "WARNING_7")
		return
	add_server(add_server_name_line_edit.text)
	update_server_list()
	server_detect.start_detecting()
	add_server_ui.visible = false;

func _on_add_server_button_2_pressed() -> void:
	StaticLoad.click_audio_player.play()
	add_server_ui.visible = false;

func _on_edit_server_button_1_pressed() -> void:
	StaticLoad.click_audio_player.play()
	var save_path = "user://servers/"+edit_server_name_line_edit.text+".srv"
	if edit_server_name_line_edit.text == "":
		StaticLoad.pop_notification(self, "WARNING", "WARNING_4")
		return
	if edit_server_name_line_edit.text != StaticLoad.select_server and FileAccess.file_exists(save_path):
		StaticLoad.pop_notification(self, "WARNING", "WARNING_5")
		return
	if edit_server_ip_line_edit.text == "":
		StaticLoad.pop_notification(self, "WARNING", "WARNING_6")
		return
	if edit_server_port_line_edit.text == "":
		StaticLoad.pop_notification(self, "WARNING", "WARNING_7")
		return
	edit_server(edit_server_name_line_edit.text)
	update_server_list()
	server_detect.start_detecting()
	edit_server_ui.visible = false;

func _on_edit_server_button_2_pressed() -> void:
	StaticLoad.click_audio_player.play()
	edit_server_ui.visible = false;
