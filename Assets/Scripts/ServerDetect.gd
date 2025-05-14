extends Control

var multiplayer_tmp = SceneMultiplayer.new()
var is_server_connected: bool = false
var is_server_info_received: bool = false
var is_server_version_conflict: bool = false
var connecting_timer: float = 0.001
var connect_thread = Thread.new()
var server_name: String
var ip: String
var port: int
var server_list_vboxcontainer

func init(got_server_name, got_ip, got_port):
	server_name = got_server_name
	ip = got_ip
	port = got_port
	name = server_name
	if not has_node("/root/MutiMenu"):
		queue_free()
		return
	server_list_vboxcontainer = get_node("/root/MutiMenu").server_list_vboxcontainer
	multiplayer.set_root_path(get_path())
	get_tree().set_multiplayer(multiplayer_tmp, get_path())
	multiplayer.set_root_path("/root")
	multiplayer.connected_to_server.connect(client_got_connected_to_server)
	#print(server_name, " ", get_tree().get_multiplayer(get_path()).multiplayer_peer, StaticLoad.multiplayer.multiplayer_peer)
	detect_server()
	#connect_thread.start(detect_server)

func detect_server():
	var multiplayer_peer = ENetMultiplayerPeer.new()
	var err = multiplayer_peer.create_client(ip, port)
	await get_tree().create_timer(0.01).timeout
	if OK != err:
		@warning_ignore("confusable_local_declaration")
		var server_selection = server_list_vboxcontainer.get_node(server_name)
		server_selection.animation.animation = "disconnect"
		server_selection.online_info_label.text = tr("CANNOT_CONNECT")
		if multiplayer_peer != null and multiplayer_peer.get_connection_status() != multiplayer_peer.CONNECTION_DISCONNECTED:
			clear_connections()
		is_server_connected = false
		is_server_info_received = false
		is_server_version_conflict = false
		connecting_timer = 0.001
		queue_free()
		return false
	
	multiplayer.multiplayer_peer = multiplayer_peer
	
	while not is_server_connected:
		if connecting_timer > 0.5:
			@warning_ignore("confusable_local_declaration")
			var server_selection = server_list_vboxcontainer.get_node(server_name)
			server_selection.animation.animation = "disconnect"
			server_selection.online_info_label.text = tr("CANNOT_CONNECT")
			if multiplayer_peer != null and multiplayer_peer.get_connection_status() != multiplayer_peer.CONNECTION_DISCONNECTED:
				clear_connections()
			is_server_connected = false
			is_server_info_received = false
			is_server_version_conflict = false
			connecting_timer = 0.001
			queue_free()
			return false
		connecting_timer += 0.001
		await get_tree().create_timer(0.001).timeout
	multiplayer_tmp.set_root_path(get_path())
	get_tree().set_multiplayer(multiplayer_tmp, get_path())
	multiplayer.set_root_path("/root")
	rpc_id(1, "request_for_server_state", multiplayer_peer.get_unique_id())
	while not is_server_info_received:
		if connecting_timer > 0.5 or is_server_version_conflict:
			@warning_ignore("confusable_local_declaration")
			var server_selection = server_list_vboxcontainer.get_node(server_name)
			server_selection.animation.animation = "disconnect"
			if not is_server_version_conflict:
				server_selection.online_info_label.text = tr("CANNOT_CONNECT")
			if multiplayer_peer != null and multiplayer_peer.get_connection_status() != multiplayer_peer.CONNECTION_DISCONNECTED:
				clear_connections()
			is_server_connected = false
			is_server_info_received = false
			is_server_version_conflict = false
			connecting_timer = 0.001
			queue_free()
			return false
		connecting_timer += 0.001
		await get_tree().create_timer(0.001).timeout
	if multiplayer_peer != null and multiplayer_peer.get_connection_status() != multiplayer_peer.CONNECTION_DISCONNECTED:
		clear_connections()
	var ping = int(connecting_timer*1000)
	var server_selection = server_list_vboxcontainer.get_node(server_name)
	server_selection.animation.animation = "signal"
	server_selection.animation.frame = StaticLoad.get_level_by_ping(ping)
	is_server_connected = false
	is_server_info_received = false
	is_server_version_conflict = false
	connecting_timer = 0.001
	queue_free()
	return true

func client_got_connected_to_server():
	name = str(multiplayer.get_unique_id())
	is_server_connected = true

func clear_connections():
	if multiplayer.multiplayer_peer == null:
		return
	multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = null

# 获取服务器在线状态
@rpc("any_peer", "call_remote", "reliable", 2)
func request_for_server_state(client_peer_id):
	rpc_id(client_peer_id, "reply_for_server_state", StaticLoad.player_peer_dict.size(), StaticLoad.world_icon_buffer, StaticLoad.options["version"])

@rpc("authority", "call_remote", "reliable", 2)
func reply_for_server_state(online_player_number, world_icon_buffer_tmp, version_tmp):
	if has_node("/root/MutiMenu"):
		#await get_tree().create_timer(0.1).timeout
		var selection = server_list_vboxcontainer.get_node(server_name)
		if selection == null:
			queue_free()
			return
		
		if world_icon_buffer_tmp != null:
			var icon = Image.new()
			icon.load_png_from_buffer(world_icon_buffer_tmp)
			selection.icon = ImageTexture.create_from_image(icon)
		
		var server_path_tmp = "user://servers/"+server_name+".srv"
		var server_config = ConfigFile.new()
		var server_info = server_config.load_encrypted_pass(server_path_tmp, StaticLoad.CONFIG_PASSWORD)
		if server_info != OK:
			queue_free()
			return
		var ip_tmp = server_config.get_value("server", "ip")
		var port_tmp = server_config.get_value("server", "port")
		var server = ConfigFile.new()
		server.set_value("server", "ip", ip_tmp)
		server.set_value("server", "port", port_tmp)
		if world_icon_buffer_tmp == null:
			var world_icon_image = selection.icon.get_image()
			world_icon_image.resize(256, 256)
			world_icon_buffer_tmp = world_icon_image.save_png_to_buffer()
		server.set_value("server", "icon", world_icon_buffer_tmp)
		server.save_encrypted_pass(server_path_tmp, StaticLoad.CONFIG_PASSWORD)
		if StaticLoad.check_server_version(version_tmp):
			selection.online_info_label.text = tr("ONLINE_PLAYERS")+" : "+str(online_player_number)
			is_server_info_received = true
		else:
			var splits = version_tmp.split(".")
			var server_version = splits[0]+"."+splits[1]+"."+splits[2]
			selection.online_info_label.text = tr("REQUIRED_VERSION")+" : "+str(server_version)
			is_server_version_conflict = true
