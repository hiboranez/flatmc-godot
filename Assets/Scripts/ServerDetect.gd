extends Control

@onready var server_list_vboxcontainer = $"../ColorRect/ScrollContainer/VBoxContainer"

var is_server_connected: bool = false
var is_server_info_received: bool = false
var is_server_version_conflict: bool = false
var connecting_timer: float = 0.001
var current_server_name
#var thread: Thread 

func _ready() -> void:
	await get_tree().create_timer(1).timeout
	start_detecting()

func start_detecting():
	#if thread != null and thread.is_started():
		#thread.wait_to_finish()
	#thread = Thread.new()
	#thread.start(detect_all)
	detect_all()

func detect_all():
	is_server_connected = false
	is_server_info_received = false
	is_server_version_conflict = false
	connecting_timer = 0.001
	var server_list = DirAccess.get_files_at(StaticLoad.server_path)
	for server in server_list:
		var splits = server.split(".")
		var server_config = ConfigFile.new()
		var server_info = server_config.load_encrypted_pass(StaticLoad.server_path+"/"+splits[0]+".srv", StaticLoad.CONFIG_PASSWORD)
		if server_info != OK:
			var server_selection = server_list_vboxcontainer.get_node(splits[0])
			server_selection.animation.animation = "disconnect"
			server_selection.online_info_label.text = tr("CANNOT_CONNECT")
			continue
		current_server_name = splits[0]
		var ip = server_config.get_value("server", "ip")
		var port = int(server_config.get_value("server", "port"))
		detect_server(splits[0], ip, port)
		await get_tree().create_timer(0.5).timeout
	#thread.wait_to_finish()

func detect_server(server_name, ip, port):
	StaticLoad.reset_signals(false)
	var err = StaticLoad.multiplayer_peer.create_client(ip, port)
	if OK != err:
		@warning_ignore("confusable_local_declaration")
		var server_selection = server_list_vboxcontainer.get_node(server_name)
		server_selection.animation.animation = "disconnect"
		server_selection.online_info_label.text = tr("CANNOT_CONNECT")
		if StaticLoad.multiplayer.multiplayer_peer != null and StaticLoad.multiplayer.multiplayer_peer.get_connection_status() != StaticLoad.multiplayer.multiplayer_peer.CONNECTION_DISCONNECTED:
			StaticLoad.clear_connections()
		is_server_connected = false
		is_server_info_received = false
		is_server_version_conflict = false
		connecting_timer = 0.001
		return false
	StaticLoad.multiplayer.multiplayer_peer = StaticLoad.multiplayer_peer
	while not is_server_connected:
		if connecting_timer > 0.1:
			@warning_ignore("confusable_local_declaration")
			var server_selection = server_list_vboxcontainer.get_node(server_name)
			server_selection.animation.animation = "disconnect"
			server_selection.online_info_label.text = tr("CANNOT_CONNECT")
			if StaticLoad.multiplayer.multiplayer_peer != null and StaticLoad.multiplayer.multiplayer_peer.get_connection_status() != StaticLoad.multiplayer.multiplayer_peer.CONNECTION_DISCONNECTED:
				StaticLoad.clear_connections()
			is_server_connected = false
			is_server_info_received = false
			is_server_version_conflict = false
			connecting_timer = 0.001
			return false
		connecting_timer += 0.001
		await get_tree().create_timer(0.001).timeout
	StaticLoad.rpc_id(1, "request_for_server_state", StaticLoad.multiplayer.get_unique_id())
	while not is_server_info_received:
		if connecting_timer > 0.1 or is_server_version_conflict:
			@warning_ignore("confusable_local_declaration")
			var server_selection = server_list_vboxcontainer.get_node(server_name)
			server_selection.animation.animation = "disconnect"
			if not is_server_version_conflict:
				server_selection.online_info_label.text = tr("CANNOT_CONNECT")
			if StaticLoad.multiplayer.multiplayer_peer != null and StaticLoad.multiplayer.multiplayer_peer.get_connection_status() != StaticLoad.multiplayer.multiplayer_peer.CONNECTION_DISCONNECTED:
				StaticLoad.clear_connections()
			is_server_connected = false
			is_server_info_received = false
			is_server_version_conflict = false
			connecting_timer = 0.001
			return false
		connecting_timer += 0.001
		await get_tree().create_timer(0.001).timeout
	if StaticLoad.multiplayer.multiplayer_peer != null and StaticLoad.multiplayer.multiplayer_peer.get_connection_status() != StaticLoad.multiplayer.multiplayer_peer.CONNECTION_DISCONNECTED:
		StaticLoad.clear_connections()
	var ping = int(connecting_timer*1000)
	var server_selection = server_list_vboxcontainer.get_node(server_name)
	server_selection.animation.animation = "signal"
	server_selection.animation.frame = StaticLoad.get_level_by_ping(ping)
	is_server_connected = false
	is_server_info_received = false
	is_server_version_conflict = false
	connecting_timer = 0.001
	return true
