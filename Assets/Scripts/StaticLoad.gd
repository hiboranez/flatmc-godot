extends Node2D

@onready var stop_bgm = load("res://Assets//Sounds//Music//MoogCity2.mp3") as AudioStream
@onready var menu_bgm = load("res://Assets//Sounds//Music//WetHands.mp3") as AudioStream
@onready var notice_scene = load("res://Assets/Scenes/Notice.tscn") as PackedScene
@onready var big_notice_scene = load("res://Assets/Scenes/BigNotice.tscn") as PackedScene
@onready var secondary_confirmation_scene = load("res://Assets/Scenes/SecondaryConfirmation.tscn") as PackedScene
@onready var ping_scene = load("res://Assets/Scenes/Ping.tscn") as PackedScene
@onready var online_info_scene = load("res://Assets/Scenes/OnlineInfo.tscn") as PackedScene
@onready var mouse_item_name_label_scene = load("res://Assets/Scenes/MouseItemNameLabel.tscn") as PackedScene
@onready var animation:AnimationPlayer = $AnimationPlayer
@onready var click_audio_player = $ClickAudioPlayer

const ITEM_NAME_SHOW_TIME: float = 2
const ITEM_NAME_DISAPPEAR_TIME: float = 0.2
const DOUBLE_CLICK_THRESHOLD:float = 0.25
const CONFIG_PASSWORD: String = "QQ1241999312"
const DEFAULT_PLAYER_SPAWN_POS = Vector2(0, 0)
const DEFAULT_PLAYER_FACE_STATE = 1
const DEFAULT_PLAYER_IS_FLYING = false
const MESSAGE_TIME = 10
const MESSAGE_DISAPPEAR_TIME: float = 0.2
const BLOCK_SELECTION_TIME = 3
const BLOCK_SELECTION_DISAPPEAR_TIME: float = 0.2
const HOST_IP = "127.0.0.1"
const REFRESH_TIME = 1
const CONNECTING_TIME = 10
const LONG_TOUCH_TIME = 0.4
const POSITION_MAX_DIFFERENCE = 5
const INVENTORY_NAME_SHOW_STAY_TIME = 1

var is_dedicated_server: bool = false
var is_on_mobile_platform: bool = false
var multiplayer_peer = ENetMultiplayerPeer.new()
var online_peer_ids: Dictionary
var online_peer_pings: Dictionary
signal connect_signal(state)
var force_quit_reason: String = "null"
var refresh_timer: float = 0
var is_muti_mode: bool = false
var language: String
var default_icon_gray_image
var game_icon_image
var button_chosen
var button_disabled
var button_normal
var small_button_normal
var small_button_chosen
var options
var block_ids: Dictionary
var block_types: Dictionary
var commands: Dictionary
var colors: Dictionary
var select_world = null
var select_server = null
var is_lan_server: bool = false
var lan_server_ip
var lan_server_port
var is_in_game: bool = false
var world_icon_buffer
var game
var world_path
var region_path
var player_path
var server_path = "user://servers"
var screenshot_path = "user://screenshots"
var block_ids_0_1_0_1 = {
		"AIR": 0,
		"COBBLESTONE": 1,
		"DIRT": 2,
		"GRASS_BLOCK": 3,
		"OAK_LOG": 4,
		"OAK_PLANKS": 5,
		"STONE": 6
	}

func _ready() -> void:
	self.hide()
	if OS.has_feature("android"):
		is_on_mobile_platform = true
		get_tree().set_quit_on_go_back(false)
	if OS.has_feature("dedicated_server"):
		is_dedicated_server = true
	connect_signal.connect(connect_signal_received)
	button_chosen = load("res://Assets/Textures/GUI/button_chosen.png") as Texture2D
	button_disabled = load("res://Assets/Textures/GUI/button_disabled.png") as Texture2D
	button_normal = load("res://Assets/Textures/GUI/button_normal.png") as Texture2D
	small_button_chosen = load("res://Assets/Textures/GUI/small_button_chosen.png") as Texture2D
	small_button_normal = load("res://Assets/Textures/GUI/small_button.png") as Texture2D
	default_icon_gray_image = load("res://Assets/Textures/GUI/default_icon_gray.png").get_image()
	game_icon_image = load("res://Assets/Textures/GUI/icon.png").get_image()
	options = {
		"version": "0.1.1.0",
		"updated": "false",
		"player_name": "Steve",
		"language": "zh",
		"render_chunk": 4,
		'fov_zoom':50,
		"bgm_volume": 50,
		"sound_volume": 50,
		"block_selection_box": "show_when_changing"
		}
	block_ids = {
		"AIR": 0,
		"BEDROCK": 1,
		"COAL_ORE": 2,
		"COBBLESTONE": 3,
		"CRAFTING_TABLE": 4,
		"DIAMOND_BLOCK": 5,
		"DIAMOND_ORE": 6,
		"DIRT": 7,
		"GOLD_BLOCK": 8,
		"GOLD_ORE": 9,
		"GRASS_BLOCK": 10,
		"IRON_BLOCK": 11,
		"IRON_ORE": 12,
		"LEAVES": 13,
		"OAK_LOG": 14,
		"OAK_PLANKS": 15,
		"STONE": 16,
		"WOOL_BLACK": 17,
		"WOOL_BLUE": 18,
		"WOOL_BROWN": 19,
		"WOOL_CYAN": 20,
		"WOOL_GRAY": 21,
		"WOOL_GREEN": 22,
		"WOOL_LIGHT_BLUE": 23,
		"WOOL_LIGHT_GRAY": 24,
		"WOOL_LIME": 25,
		"WOOL_MAGENTA": 26,
		"WOOL_ORANGE": 27,
		"WOOL_PINK": 28,
		"WOOL_PURPLE": 29,
		"WOOL_RED": 30,
		"WOOL_WHITE": 31,
		"WOOL_YELLOW": 32,
	}
	block_types = {
		0: "air",
		1: "stone",
		2: "stone",
		3: "stone",
		4: "wood",
		5: "stone",
		6: "stone",
		7: "gravel",
		8: "stone",
		9: "stone",
		10: "grass",
		11: "stone",
		12: "stone",
		13: "grass",
		14: "wood",
		15: "wood",
		16: "stone",
		17: "cloth",
		18: "cloth",
		19: "cloth",
		20: "cloth",
		21: "cloth",
		22: "cloth",
		23: "cloth",
		24: "cloth",
		25: "cloth",
		26: "cloth",
		27: "cloth",
		28: "cloth",
		29: "cloth",
		30: "cloth",
		31: "cloth",
		32: "cloth"
	}
	commands = {
		"/help": tr("/HELP"),
		"/tp": tr("/TP")
	}
	colors = {
		"red": Color.RED,
		"yellow": Color.YELLOW,
		"blue": Color.BLUE,
		"green": Color.GREEN,
		"crimson": Color.CRIMSON,
		"violet": Color.VIOLET,
		"pink": Color.PINK,
		"gold": Color.GOLD,
		"cornflower_blue": Color.CORNFLOWER_BLUE,
		"chartreuse": Color.CHARTREUSE
	}
	if is_dedicated_server:
		var world_server_path = "user://worlds/world"
		if not DirAccess.dir_exists_absolute(world_server_path):
			DirAccess.make_dir_recursive_absolute(world_server_path)
			create_server_world()
			await get_tree().create_timer(1).timeout
		select_world = "world"
		StaticLoad.change_scene("res://Assets/Scenes/LoadingWorldUI.tscn")

func compare_version(version_1: String, version_2: String):
	var splits_1
	var splits_2
	if version_1 == "unknown":
		splits_1 = ["0", "1", "0", "1"]
	else:
		splits_1 = version_1.split(".")
	if version_2 == "unknown":
		splits_2 = ["0", "1", "0", "1"]
	else:
		splits_2 = version_2.split(".")
	var i = 0
	while i < 4:
		if int(splits_1[i]) > int(splits_2[i]):
			return "higher"
		elif int(splits_1[i]) < int(splits_2[i]):
			return "lower"
		i += 1
	return "equal"

func convert_world(world_name, old_version):
	var block_ids_old: Dictionary
	if old_version == "0.1.0.1":
		block_ids_old = block_ids_0_1_0_1
	var region_path_tmp = "user://worlds/"+world_name+"/regions"
	var regions = DirAccess.get_files_at(ProjectSettings.globalize_path(region_path_tmp))
	if regions.is_empty():
		return
	for region in regions:
		var splits = region.split(".")
		var chunk_config = ConfigFile.new()
		var chunk_result = chunk_config.load_encrypted_pass(region_path_tmp+"/"+region, StaticLoad.CONFIG_PASSWORD)
		if chunk_result != OK:
			return
		var blocks = chunk_config.get_value("chunck", "blocks")
		for i in range(16):
			for j in range(16):
				var old_id = blocks[i][j]
				var new_id
				if block_ids_old.find_key(old_id) != null:
					var block_name_tmp = block_ids_old.find_key(old_id)
					new_id = block_ids[block_name_tmp]
				else:
					new_id = old_id
				blocks[i][j] = new_id
		var mca = ConfigFile.new()
		mca.set_value("chunck", "blocks", blocks)
		mca.save_encrypted_pass(region_path_tmp+"/r."+splits[1]+"."+splits[2]+".mca", StaticLoad.CONFIG_PASSWORD)
	var world_path_tmp = "user://worlds/"+world_name
	var level = ConfigFile.new()
	var current_time = Time.get_datetime_string_from_system(false, true).replace(" ", "  ").replace("-", "/")
	level.set_value("world", "last_modified", current_time)
	level.set_value("world", "version", StaticLoad.options["version"])
	level.save_encrypted_pass(world_path_tmp+"/level.dat", StaticLoad.CONFIG_PASSWORD)

func update_path():
	if select_world != null:
		world_path = "user://worlds/"+select_world
		region_path = world_path+"/regions"
		player_path = world_path+"/players"

func change_scene(path):
	#self.show()
	#self.set_layer(999)
	#animation.play("show")
	#await animation.animation_finished
	if typeof(path) == TYPE_STRING:
		get_tree().change_scene_to_file(path)
	else:
		get_tree().change_scene_to_packed(path)
	#animation.play_backwards("show")
	#await animation.animation_finished
	#self.set_layer(-1)

func get_block_id_by_name(block_name: String) -> int:
	var value = 0
	if block_ids.has(block_name):
		value = block_ids[block_name]
	return value

func get_block_type_by_id(id: int) -> String:
	var value = "air"
	if StaticLoad.block_types.has(id):
		value = block_types[id]
	return value

func check_options_outdated():
	var exsit_options = {"is_option_outdated": false}
	var config = ConfigFile.new()
	var result = config.load("user://configs.cfg")
	if result != OK:
		exsit_options["is_option_outdated"] = true
		return exsit_options
	for key in StaticLoad.options.keys():
		var option = config.get_value("options", key, "null")
		if option == "null":
			exsit_options["is_option_outdated"] = true
		else:
			exsit_options[key] = option
	return exsit_options

func generate_options(exist_options: Dictionary):
	var default_config = ConfigFile.new()
	TranslationServer.set_locale("zh")
	for key in options.keys():
		if key == "version":
			continue
		if exist_options.has(key):
			default_config.set_value("options", key, exist_options[key])
		else:
			default_config.set_value("options", key, str(options[key]))
	default_config.save("user://configs.cfg")

func save_options(change_value: Dictionary):
	var current_config = ConfigFile.new()
	var config = ConfigFile.new()
	var result = current_config.load("user://configs.cfg")
	if result != OK:
		return
	for key in options.keys():
		var current_value = current_config.get_value("options", key)
		config.set_value("options", key, current_value)
	for key in change_value.keys():
		config.set_value("options", key, change_value[key])
	config.save("user://configs.cfg")

func generate_chunk(pos: Vector2i):
	@warning_ignore("unused_variable")
	var x = pos[0]
	var y = pos[1]
	var blocks = []
	if y <= -1:
		for i in range(16):
			var row = []
			for j in range(16):
				row.append(0)
			blocks.append(row)
	elif y == 0:
		for i in range(16):
			var row = []
			for j in range(16):
				if i == 0:
					row.append(10)
				elif i > 0 and i<=3:
					row.append(7)
				else:
					row.append(16)
			blocks.append(row)
	else:
		for i in range(16):
			var row = []
			for j in range(16):
				row.append(16)
			blocks.append(row)
	return blocks

func pop_notification(root, title: String, info: String, is_destroying = true):
	var notice = notice_scene.instantiate()
	root.add_child(notice)
	notice.set_title(title)
	notice.set_text(info)
	if is_destroying:
		notice.destroy_count_down()

func pop_big_notification(root, title: String, info: String, button_text: String):
	var notice = big_notice_scene.instantiate()
	root.add_child(notice)
	notice.set_title(title)
	notice.set_text(info)
	notice.set_button_text(button_text)

func pop_secondary_confirmation(root, info: String, function: Callable):
	var secondary_confirmation = secondary_confirmation_scene.instantiate()
	root.add_child(secondary_confirmation)
	secondary_confirmation.set_text(info)
	secondary_confirmation.connect_secondary_confirmation_button_1(function)

func get_atlas_coords_by_block_id(block_id: int):
	@warning_ignore("integer_division")
	return Vector2i((block_id-1)%10,(block_id-1)/10)
	
func get_block_id_by_atlas_coords(atlas_coords: Vector2i):
	if atlas_coords[0] == -1:
		return 0
	return atlas_coords[1]*10+atlas_coords[0]+1

func get_block_selection_box_by_selected(selected):
	if selected == 0:
		return "show_when_changing"
	elif selected == 1:
		return "always_show"
	return "never_show"

func get_selected_by_block_selection_box(block_selection_box):
	if block_selection_box == "show_when_changing":
		return 0
	elif block_selection_box == "always_show":
		return 1
	return 2

func get_level_by_ping(ping: int):
	if ping <= 50:
		return 5
	elif ping <= 100:
		return 4
	elif ping <= 150:
		return 3
	elif ping <= 200:
		return 2
	else:
		return 1	

func get_random_available_port():
	var port_range_start = 1024
	var port_range_end = 65535
	var attempts = 100  # 最大尝试次数

	for i in range(attempts):
		var random_port = randi() % (port_range_end - port_range_start + 1) + port_range_start
		var server = UDPServer.new()
		
		if server.listen(random_port) == OK:
			# 成功绑定端口，返回这个端口
			return random_port
		server.close()  # 关闭服务器

	return -1  # 如果没有找到可用端口，返回 -1

func update_game():
	game = $"/root/Game"

func reset_signals(is_server: bool):
	clear_signal(multiplayer_peer.peer_disconnected)
	clear_signal(multiplayer_peer.peer_connected)
	clear_signal(multiplayer.server_disconnected)
	clear_signal(multiplayer.connected_to_server)
	clear_signal(multiplayer.connection_failed)
	if is_server:
		multiplayer_peer.peer_disconnected.connect(peer_disconnected)
		multiplayer_peer.peer_connected.connect(peer_connected)
	else:
		multiplayer.server_disconnected.connect(server_disconnected)
		multiplayer.connected_to_server.connect(connected_to_server)
		multiplayer.connection_failed.connect(connection_failed)

func peer_disconnected(peer_id):
	#print(multiplayer.get_unique_id()," : peer ", peer_id, " disconnected")
	if online_peer_pings.has(peer_id):
		online_peer_pings.erase(peer_id)
	if online_peer_ids.has(peer_id):
		game.save_player(peer_id)
		game.save_world()
	call_deferred("rpc", "peer_disconnect_broadcast", peer_id)

@warning_ignore("unused_parameter")
func peer_connected(peer_id):
	#print(multiplayer.get_unique_id()," : peer ", peer_id, " connected")
	game.save_world()

func server_disconnected():
	destroy_peer(get_multiplayer_authority())
	is_in_game = false
	is_muti_mode = false
	force_quit_reason = "connection_interrupted"
	change_scene("res://Assets/Scenes/ForceQuitUI.tscn")

func connected_to_server():
	#print(multiplayer.get_unique_id()," : connected to server")
	connect_signal.emit("connected")

func connection_failed():
	#print(multiplayer.get_unique_id()," : connection failed")
	pass

func destroy_peer(peer_id):
	if peer_id == 1:
		#print("1 : server closed")
		clear_connections()
		return
	online_peer_ids[peer_id].queue_free()
	online_peer_ids.erase(peer_id)
	if game.online_ui_vbox_container.has_node(str(peer_id)):
		game.online_ui_vbox_container.get_node(str(peer_id)).queue_free()
	

func clear_signal(sgl: Signal):
	for conn in sgl.get_connections():
		conn["signal"].disconnect(conn.callable)

func clear_connections():
	multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = null
	if not is_in_game:
		return
	for peer_id in online_peer_ids:
		online_peer_ids[peer_id].queue_free()
	online_peer_ids.clear()
	online_peer_pings.clear()

func create_server_world():
	var world_name = "world"
	@warning_ignore("shadowed_variable")
	var world_path = "user://worlds/"+world_name
	@warning_ignore("shadowed_variable")
	var region_path = "user://worlds/"+world_name+"/regions"
	@warning_ignore("shadowed_variable")
	var player_path = "user://worlds/"+world_name+"/players"
	DirAccess.make_dir_recursive_absolute(region_path)
	DirAccess.make_dir_recursive_absolute(player_path)
	for x in range(-1,1):
		for y in range(-1,1):
			var mca = ConfigFile.new()
			var blocks = StaticLoad.generate_chunk(Vector2i(x, y))
			mca.set_value("chunck", "blocks", blocks)
			mca.save_encrypted_pass(region_path+"/r."+str(x)+"."+str(y)+".mca", StaticLoad.CONFIG_PASSWORD)
	var image = load("res://Assets/Textures/GUI/default_icon.png").get_image()
	image.save_png(world_path+"/icon.png")
	var level = ConfigFile.new()
	var current_time = Time.get_datetime_string_from_system(false, true).replace(" ", "  ").replace("-", "/")
	level.set_value("world", "last_modified", current_time)
	level.save_encrypted_pass(world_path+"/level.dat", StaticLoad.CONFIG_PASSWORD)

func start_server():
	reset_signals(true)
	if not is_dedicated_server:
		game.broadcast_to_person(game.player.player_name, tr("OPENING_PORT"), "gold")
	var port
	if is_dedicated_server:
		port = 12419
	else:
		port = get_random_available_port()
	var err = multiplayer_peer.create_server(port)
	if OK != err:
		game.broadcast_to_person(game.player.player_name, tr("OPEN_SERVER_FAIL_1")+StaticLoad.HOST_IP+":"+str(port)+tr("OPEN_SERVER_FAIL_2"), "pink")
		return
	if is_dedicated_server:
		print("["+get_time_string(false)+" INFO]: "+"Server opened on 127.0.0.1:12419")
	multiplayer.multiplayer_peer = multiplayer_peer
	if not is_dedicated_server:
		game.pause_button_4.disabled = true
		game.broadcast_to_person(game.player.player_name, tr("OPEN_SERVER_SUCCESS")+StaticLoad.HOST_IP+":"+str(port), "chartreuse")
	var ping_instance = ping_scene.instantiate()
	ping_instance.peer_id = 1
	ping_instance.ping = 1
	online_peer_pings[1] = ping_instance
	StaticLoad.is_muti_mode = true
	ServiceDiscovery.server_data = {'Name':str(port)+"|"+game.player.player_name}
	ServiceDiscovery.set_server()

func connect_signal_received(state):
	if state == "connected":
		if has_node("/root/LoadingServerUI"):
			get_node("/root/LoadingServerUI").is_server_connected = true
		elif has_node("/root/MutiMenu/ServerDetect"):
			get_node("/root/MutiMenu/ServerDetect").is_server_connected = true
	elif state == "state_checked":
		get_node("/root/LoadingServerUI").is_server_state_checked = true
	elif state == "same_player_name":
		get_node("/root/LoadingServerUI").connect_interrupt_reason = "same_player_name"
	elif state == "player_info_updated":
		game.is_player_info_updated = true
	elif state == "version_conflict":
		get_node("/root/LoadingServerUI").connect_interrupt_reason = "version_conflict"

func get_time_string(is_return_day: bool = true):
	var time_str = Time.get_datetime_string_from_system().split("T")
	var day = time_str[0].replace("-","/")
	var moment = time_str[1]
	var time = moment
	if is_return_day:
		time = day + " " + moment
	return time

@rpc("authority", "call_remote", "reliable", 1)
func check_ping():
	rpc_id(1, "got_ping", multiplayer.get_unique_id())
	
@rpc("any_peer", "call_remote", "reliable", 1)
func got_ping(peer_id):	
	online_peer_pings[peer_id].got_ping()

@rpc("any_peer", "call_local", "reliable", 1)
func new_peer_broadcast(peer_id):
	if multiplayer.get_unique_id() == peer_id:
		return
	game.create_player(peer_id)
	if multiplayer.get_unique_id() != 1:
		return
	rpc_id(peer_id, "old_peer_replication", online_peer_ids.keys())
	await get_tree().create_timer(0.5).timeout
	for old_peer_id in online_peer_ids:
		var player_tmp = online_peer_ids[old_peer_id]
		player_tmp.rpc_id(peer_id, "init_player", old_peer_id, player_tmp.player_name, player_tmp.position, player_tmp.face_state, player_tmp.is_flying)
	
@rpc("authority", "call_local", "reliable", 1)
func peer_disconnect_broadcast(peer_id):
	if not online_peer_ids.has(peer_id):
		return
	game.broadcast_to_all(online_peer_ids[peer_id].player_name+tr("LEFT_GAME"), "gold")
	if StaticLoad.is_dedicated_server:
		print("["+get_time_string(false)+" INFO]: "+online_peer_ids[peer_id].player_name+" left the game")
	destroy_peer(peer_id)

@rpc("authority", "call_remote", "reliable", 1)
func old_peer_replication(peer_ids):
	for peer_id in peer_ids:
		game.create_player(peer_id)

#@rpc("authority", "call_local", "reliable", 1)
#func same_player_name_connect_interrupt():
	#connect_signal.emit("same_player_name")

@rpc("any_peer", "call_remote", "reliable", 1)
func request_for_mark_revised_chunk(chunk_pos):
	if not is_in_game:
		return
	game.loaded_chunks[str(chunk_pos[0])+"."+str(chunk_pos[1])] = true

@rpc("any_peer", "call_remote", "reliable", 1)
func request_for_server_state(peer_id):
	rpc_id(peer_id, "reply_for_server_state", online_peer_ids.size(), world_icon_buffer, options["version"])

@rpc("authority", "call_remote", "reliable", 1)
func reply_for_server_state(online_player_number, world_icon_buffer_tmp, version_tmp):
	if has_node("/root/MutiMenu"):
		var muti_menu = get_node("/root/MutiMenu")
		var selection = muti_menu.server_list_vboxcontainer.get_node(muti_menu.server_detect.current_server_name)
		if selection == null:
			return
		var icon = Image.new()
		icon.load_png_from_buffer(world_icon_buffer_tmp)
		selection.icon = ImageTexture.create_from_image(icon)
		var server_path_tmp = "user://servers/"+muti_menu.server_detect.current_server_name+".srv"
		var server_config = ConfigFile.new()
		var server_info = server_config.load_encrypted_pass(server_path_tmp, CONFIG_PASSWORD)
		if server_info != OK:
			return
		var ip_tmp = server_config.get_value("server", "ip")
		var port_tmp = server_config.get_value("server", "port")
		var server = ConfigFile.new()
		server.set_value("server", "ip", ip_tmp)
		server.set_value("server", "port", port_tmp)
		server.set_value("server", "icon", world_icon_buffer_tmp)
		server.save_encrypted_pass(server_path_tmp, CONFIG_PASSWORD)
		if version_tmp == options["version"]:
			selection.online_info_label.text = tr("ONLINE_PLAYERS")+" : "+str(online_player_number)
			muti_menu.server_detect.is_server_info_received = true
		else:
			selection.online_info_label.text = tr("REQUIRED_VERSION")+" : "+str(version_tmp)
			muti_menu.server_detect.is_server_version_conflict = true

@rpc("any_peer", "call_remote", "reliable", 1)
func request_for_ping(peer_id, target_peer_id):
	rpc_id(peer_id, "reply_for_ping", target_peer_id, online_peer_pings[target_peer_id].ping)
	online_peer_pings[target_peer_id].start_ping()

@rpc("authority", "call_remote", "reliable", 1)
func reply_for_ping(peer_id, ping):
	var online_info = game.online_ui_vbox_container.get_node(str(peer_id))
	online_info.ping = ping
	online_info.update_ping()

@rpc("any_peer", "call_remote", "reliable", 1)
func request_for_set_block(pos, id):
	if not is_in_game:
		return
	game.set_block(pos, id)
	rpc("reply_for_set_block", pos, id)

@rpc("authority", "call_remote", "reliable", 1)
func reply_for_set_block(pos, id):
	if not is_in_game:
		return
	game.set_block(pos, id)
	
@rpc("any_peer", "call_remote", "reliable", 1)
func request_for_connect_state_check(peer_id, player_name, version_tmp):
	for id in online_peer_ids:
		if online_peer_ids[id].player_name.to_lower() == player_name.to_lower():
			rpc_id(peer_id, "reply_for_connect_state_check", "same_player_name")
			return
	if version_tmp != options["version"]:
		rpc_id(peer_id, "reply_for_connect_state_check", "version_conflict")
		return
	rpc_id(peer_id, "reply_for_connect_state_check", "state_checked")

@rpc("authority", "call_remote", "reliable", 1)
func reply_for_connect_state_check(check_state):
	connect_signal.emit(check_state)

@rpc("any_peer", "call_remote", "reliable", 1)
func request_for_player_info(peer_id, player_name):
	online_peer_ids[peer_id] = game.players.get_node(str(peer_id))
	var new_player = online_peer_ids[peer_id]
	if multiplayer.get_unique_id() == 1:
		var ping_instance = ping_scene.instantiate()
		ping_instance.peer_id = peer_id
		online_peer_pings[peer_id] = ping_instance
		ping_instance.start_ping()
	if FileAccess.file_exists(player_path+"/"+player_name.to_lower()+".dat"):
		var player_config = ConfigFile.new()
		var player_result = player_config.load_encrypted_pass(StaticLoad.player_path+"/"+player_name.to_lower()+".dat", StaticLoad.CONFIG_PASSWORD)
		if player_result != OK:
			return
		var player_position = player_config.get_value("player", "position", DEFAULT_PLAYER_SPAWN_POS)
		var face_state = player_config.get_value("player", "face_state", DEFAULT_PLAYER_FACE_STATE)
		var is_flying = player_config.get_value("player", "is_flying", DEFAULT_PLAYER_IS_FLYING)
		new_player.position = player_position
		new_player.face_state = face_state
		new_player.is_flying = is_flying
		rpc_id(peer_id, "reply_update_player_info", player_position, face_state, is_flying)
		new_player.rpc("init_player", peer_id, player_name, player_position, face_state, is_flying)
	else:
		rpc_id(peer_id, "reply_update_player_info", DEFAULT_PLAYER_SPAWN_POS, DEFAULT_PLAYER_FACE_STATE, DEFAULT_PLAYER_IS_FLYING)
		new_player.rpc("init_player", peer_id, player_name, DEFAULT_PLAYER_SPAWN_POS, DEFAULT_PLAYER_FACE_STATE, DEFAULT_PLAYER_IS_FLYING)
	new_player.rpc("broadcast_join_game", player_name)

		
@rpc("authority", "call_remote", "reliable", 1)
func reply_update_player_info(player_position, face_state, is_flying):
	game.player.position = player_position
	game.player.face_state = face_state
	game.player.is_flying = is_flying
	connect_signal.emit("player_info_updated")

@rpc("any_peer", "call_remote", "reliable", 1)
func request_for_update_chunk(peer_id, x_chunk, y_chunk):
	var blocks = []
	if not game.loaded_chunks.has(str(x_chunk)+"."+str(y_chunk)):
		var mca = ConfigFile.new()
		blocks = StaticLoad.generate_chunk(Vector2i(x_chunk, y_chunk))
		game.set_chunk(Vector2i(x_chunk, y_chunk), blocks)
		game.loaded_chunk_num += 1
		mca.set_value("chunck", "blocks", blocks)
		mca.save_encrypted_pass(region_path+"/r."+str(x_chunk)+"."+str(y_chunk)+".mca", CONFIG_PASSWORD)
		game.loaded_chunks[str(x_chunk)+"."+str(y_chunk)] = false
	for y in range(16):
		var row = []
		for x in range(16):
			var block_pos = Vector2i(x_chunk*16+x, y_chunk*16+y)
			var id = 0
			if game.tile_map_layer.get_cell_source_id(block_pos) != -1:
				var atlas_coords = game.tile_map_layer.get_cell_atlas_coords(block_pos)
				id = StaticLoad.get_block_id_by_atlas_coords(atlas_coords)
			row.append(id)
		blocks.append(row)
	rpc_id(peer_id, "reply_for_update_chunck",x_chunk, y_chunk, blocks)
		
@rpc("authority", "call_remote", "reliable", 1)
func reply_for_update_chunck(x_chunk, y_chunk, blocks):
	game.set_chunk(Vector2i(x_chunk, y_chunk), blocks)
	game.loaded_chunks[str(x_chunk)+"."+str(y_chunk)] = false
	game.loaded_chunk_num += 1
