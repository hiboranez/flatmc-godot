extends Node

var server_name: String = ""
var server_type: String = ""
var server_ip: String = ""
var server_port: int = -1

func update_data(args: Dictionary) -> void:
	if args.has("server_name") and args["server_name"] is String:
		server_name = args["server_name"]
	if args.has("server_type") and args["server_type"] is String:
		server_type = args["server_type"]
	if args.has("server_ip") and args["server_ip"] is String:
		server_ip = args["server_ip"]
	if args.has("server_port") and args["server_port"] is int:
		server_port = args["server_port"]
	if args.has("refresh") and args["refresh"] is bool and args["refresh"]:
		pass

func check_server_version(check_version):
	var splits_1 = check_version.split(".")
	var splits_2 = SettingsManager.get_default_setting("version").split(".")
	for i in range(3):
		if splits_1[i] != splits_2[i]:
			return false
	return true

func record_server_log(log_name, content, is_endl = true):
	pass
	#if not FileAccess.file_exists(server_log_path+"/"+log_name+".txt"):
		#var log_config = ConfigFile.new()
		#log_config.save(server_log_path+"/"+log_name+".txt")
	#var file_read = FileAccess.open(server_log_path+"/"+log_name+".txt", FileAccess.READ)
	#var content_read = file_read.get_as_text()
	#var file = FileAccess.open(server_log_path+"/"+log_name+".txt", FileAccess.WRITE)
	#file.store_string(content_read)
	#if is_endl:
		#file.store_string(content+"\n")
	#else:
		#file.store_string(content)
	#file.close()

func start_server():
	pass
	#reset_signals(true)
	#if not is_dedicated_server:
		#game.broadcast_to_person(game.player.player_name, tr("OPENING_PORT"), "gold")
		#game.op_list.append(game.player.player_name.to_lower())
	#var port
	#if is_dedicated_server:
		#port = 12419
	#else:
		#port = get_random_available_port()
	#var err = multiplayer_peer.create_server(port)
	#if OK != err:
		#game.broadcast_to_person(game.player.player_name, tr("OPEN_SERVER_FAIL_1")+StaticLoad.HOST_IP+":"+str(port)+tr("OPEN_SERVER_FAIL_2"), "pink")
		#return
	#if is_dedicated_server:
		#var text = "["+get_time_string(false)+" INFO]: "+"Server opened on 127.0.0.1:12419"
		#print(text)
		#record_server_log(Time.get_date_string_from_system(), text)
	#multiplayer.multiplayer_peer = multiplayer_peer
	#if not is_dedicated_server:
		#game.pause_button_5.disabled = true
		#game.broadcast_to_person(game.player.player_name, tr("OPEN_SERVER_SUCCESS")+StaticLoad.HOST_IP+":"+str(port), "chartreuse")
	#var ping_instance = ping_scene.instantiate()
	#ping_instance.target_peer_id = 1
	#ping_instance.ping = 1
	#ping_peer_dict[1] = ping_instance
	#StaticLoad.is_muti_mode = true
	#ServiceDiscovery.server_data = {'Name':str(port)+"|"+game.player.player_name}
	#ServiceDiscovery.set_server()
