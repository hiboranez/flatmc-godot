extends Control

var multiplayer_tmp = SceneMultiplayer.new()
var is_server_connected: bool = false
var is_server_info_received: bool = false
var is_server_version_conflict: bool = false
var connecting_timer: float = 0.001
var connect_thread = Thread.new()
var server_name: String = ""
var server_ip: String = ""
var server_port: int = -1
var server_list_gridcontainer

var panel: Node = null

func update_info(args: Dictionary) -> void:
	if args.has("server_name") and args["server_name"] is String:
		server_name = args["server_name"]
		name = server_name
	if args.has("server_ip") and args["server_ip"] is String:
		server_ip = args["server_ip"]
	if args.has("server_port") and args["server_port"] is int:
		server_port = args["server_port"]
	if args.has("panel") and args["panel"] is Node:
		panel = args["panel"]

func start() -> void:
	if panel == null:
		disconnect_and_free()
		return
	server_list_gridcontainer = panel.server_list_gridcontainer
	get_tree().set_multiplayer(multiplayer_tmp, "/root")
	multiplayer.connected_to_server.connect(client_got_connected_to_server)
	#print(server_name, " ", get_tree().get_multiplayer(get_path()).multiplayer_peer, StaticLoad.multiplayer.multiplayer_peer)
	await detect_server()
	if not panel.server_detect_list.is_empty():
		var server_detect_info = panel.server_detect_list.pop_front()
		server_detect_info[0].init(server_detect_info[1],server_detect_info[2],server_detect_info[3])
	#connect_thread.start(detect_server)

func detect_server():
	var multiplayer_peer = ENetMultiplayerPeer.new()
	var err = multiplayer_peer.create_client(server_ip, server_port)
	await get_tree().create_timer(0.01).timeout
	if OK != err:
		@warning_ignore("confusable_local_declaration")
		var server_button = server_list_gridcontainer.get_node(server_name)
		server_button.animation_sprite.animation = "disconnect"
		server_button.online_info_label.text = tr("CANNOT_CONNECT")
		if multiplayer_peer != null and multiplayer_peer.get_connection_status() != multiplayer_peer.CONNECTION_DISCONNECTED:
			clear_connections()
		is_server_connected = false
		is_server_info_received = false
		is_server_version_conflict = false
		connecting_timer = 0.001
		disconnect_and_free()
		return false
	
	get_tree().set_multiplayer(multiplayer_tmp, "/root")
	multiplayer.multiplayer_peer = multiplayer_peer
	
	while not is_server_connected:
		if connecting_timer > 0.5:
			@warning_ignore("confusable_local_declaration")
			var server_button = server_list_gridcontainer.get_node(server_name)
			server_button.animation_sprite.animation = "disconnect"
			server_button.online_info_label.text = tr("CANNOT_CONNECT")
			if multiplayer_peer != null and multiplayer_peer.get_connection_status() != multiplayer_peer.CONNECTION_DISCONNECTED:
				clear_connections()
			is_server_connected = false
			is_server_info_received = false
			is_server_version_conflict = false
			connecting_timer = 0.001
			disconnect_and_free()
			return false
		connecting_timer += 0.001
		await get_tree().create_timer(0.001).timeout

	get_tree().set_multiplayer(multiplayer_tmp, "/root")

	rpc_id(1, "request_for_server_state", multiplayer_peer.get_unique_id())
	while not is_server_info_received:
		if connecting_timer > 0.5 or is_server_version_conflict:
			@warning_ignore("confusable_local_declaration")
			var server_button = server_list_gridcontainer.get_node(server_name)
			server_button.animation_sprite.animation = "disconnect"
			if not is_server_version_conflict:
				server_button.online_info_label.text = tr("CANNOT_CONNECT")
			if multiplayer_peer != null and multiplayer_peer.get_connection_status() != multiplayer_peer.CONNECTION_DISCONNECTED:
				clear_connections()
			is_server_connected = false
			is_server_info_received = false
			is_server_version_conflict = false
			connecting_timer = 0.001
			disconnect_and_free()
			return false
		connecting_timer += 0.001
		await get_tree().create_timer(0.001).timeout
	if multiplayer_peer != null and multiplayer_peer.get_connection_status() != multiplayer_peer.CONNECTION_DISCONNECTED:
		clear_connections()
	var ping = int(connecting_timer*1000)
	var server_button = server_list_gridcontainer.get_node(server_name)
	server_button.animation_sprite.animation = "signal"
	server_button.animation_sprite.frame = StaticLoad.get_level_by_ping(ping)
	is_server_connected = false
	is_server_info_received = false
	is_server_version_conflict = false
	connecting_timer = 0.001
	disconnect_and_free()
	return true

func client_got_connected_to_server():
	name = str(multiplayer.get_unique_id())
	is_server_connected = true

func clear_connections():
	if multiplayer.multiplayer_peer == null:
		return
	multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = null
	get_tree().set_multiplayer(StaticLoad.multiplayer, "/root")

func disconnect_and_free():
	clear_connections()
	queue_free()

# 获取服务器在线状态
@rpc("any_peer", "call_remote", "reliable", 2)
func request_for_server_state(client_peer_id):
	rpc_id(client_peer_id, "reply_for_server_state", StaticLoad.player_peer_dict.size(), StaticLoad.world_icon_buffer, SettingsManager.get_default_setting("version"))

@rpc("authority", "call_remote", "reliable", 2)
func reply_for_server_state(online_player_number, world_icon_buffer_tmp, version_tmp):
	if panel != null:
		#await get_tree().create_timer(0.1).timeout
		var server_button = server_list_gridcontainer.get_node(server_name)
		if server_button == null:
			disconnect_and_free()
			return
		
		if world_icon_buffer_tmp != null:
			var icon = Image.new()
			icon.load_png_from_buffer(world_icon_buffer_tmp)
			server_button.icon_rect = ImageTexture.create_from_image(icon)
		
		var server_path_tmp = "user://servers/"+server_name+".srv"
		var server_config = ConfigFile.new()
		var server_info = server_config.load_encrypted_pass(server_path_tmp, SettingsManager.get_default_value("config_password"))
		if server_info != OK:
			disconnect_and_free()
			return
		var server_type_tmp = server_config.get_value("server", "server_type", "third_party")
		var server_ip_tmp = server_config.get_value("server", "server_ip", "")
		var server_port_tmp = server_config.get_value("server", "server_port", "-1")
		var server = ConfigFile.new()
		server.set_value("server", "server_type", server_type_tmp)
		server.set_value("server", "server_ip", server_ip_tmp)
		server.set_value("server", "server_port", server_port_tmp)
		if world_icon_buffer_tmp == null:
			var world_icon_image = server_button.icon.get_image()
			world_icon_image.resize(256, 256)
			world_icon_buffer_tmp = world_icon_image.save_png_to_buffer()
		server.set_value("server", "server_icon", world_icon_buffer_tmp)
		server.save_encrypted_pass(server_path_tmp, SettingsManager.get_default_value("config_password"))
		if ServerManager.check_server_version(version_tmp):
			server_button.online_info_label.text = tr("ONLINE_PLAYERS")+" : "+str(online_player_number)
			is_server_info_received = true
		else:
			var splits = version_tmp.split(".")
			var server_version = splits[0]+"."+splits[1]+"."+splits[2]
			server_button.online_info_label.text = str(server_version)
			#server_button.online_info_label.text = tr("REQUIRED_VERSION")+" : "+str(server_version)
			is_server_version_conflict = true
