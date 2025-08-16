extends Control

@onready var animation = $AnimationPlayer
@onready var click_audio_player = $ClickAudioPlayer
@onready var server_detects = $ServerDetects

class Chunk:
	static var para_list = [
		"entity_list", "dirt_list", "grass_block_list",
		"seed_list", "sapling_list", "leaves_list",
		"farm_land_list", "sugar_cane_list", "sign_dict"
	]
	var is_loaded: bool = false
	var is_to_save: bool = false
	var entity_list: Array = []
	var dirt_list: Array = []
	var grass_block_list: Array = []
	var seed_list: Array = []
	var sapling_list: Array = []
	var leaves_list: Array = []
	var farm_land_list: Array = []
	var sugar_cane_list: Array = []
	var sign_dict: Dictionary = {}

# 常数据
const AIR_RESISTANCE = 5000
const DROPPED_ITEM_SPEED = 1000
const HEALTH_RECOVER_TIME = 10
const HURT_COLOR = Color(1, 0.392, 0.392, 1)
const DEFAULT_COLOR = Color(1, 1, 1, 1)
const UI_FLASH_TIME = 0.2
const DEFAULT_PLAYER_HEALTH = 20
const DEFAULT_PLAYER_HUNGER = 20
const FLOAT_DELTA: float = 0.01
const ITEM_NAME_SHOW_TIME: float = 2
const ITEM_NAME_DISAPPEAR_TIME: float = 0.2
const DOUBLE_CLICK_THRESHOLD:float = 0.25
const DEFAULT_PLAYER_SPAWN_POS = Vector2(0, -1)
const DEFAULT_PLAYER_FACE_STATE = 1
const DEFAULT_PLAYER_IS_FLYING = false
const DEFAULT_PLAYER_GAMEMODE = "survival"
const MESSAGE_TIME = 10
const MESSAGE_DISAPPEAR_TIME: float = 0.2
const BLOCK_SELECTION_TIME = 3
const BLOCK_SELECTION_DISAPPEAR_TIME: float = 0.2
const HOST_IP = "127.0.0.1"
const REFRESH_TIME = 5
const CONNECTING_TIME = 10
const LONG_TOUCH_TIME = 0.4
const INVENTORY_NAME_SHOW_STAY_TIME = 1
const RENDER_CHUNK_MIN = 1
const RENDER_CHUNK_MAX = 4
const TURN_STATE_SCALE_FACTOR = 0.5
const TURN_TIME: float = 0.1
const HURT_TIME: float = 0.4
const DISSOLVE_TIME: float = 0.5
const TELEPORT_TIME: float = 0.3
const MINI_MAP_SCALE_FACTOR = 0.07*48
const MINI_MAP_ICON_SIZE = 8
const MAP_SCALE_FACTOR = 0.7
const CHUNK_FREE_TIME = 5
const UPDATE_CHUNK_TIME = 0.5
const POSITION_MAX_DIFFERENCE = 120
const VELOCITY_MAX_DIFFERENCE = 200
const REFRESH_DELTA_TIME = 0.001
const REFRESH_DELTA_TIME_LONG = 0.2
const MAX_NAME_LENGTH = 16
const MAX_SPEED = 2000
const DIG_SOUND_DELTA = 0.25
const BLEND_SPEED = 15
const ATTRACT_SPEED = 50
const DEFAULT_NO_COLLECT_TIME = 2
const DROP_ALL_TIME = 1.0
const DISPATCH_DELTA_TIME = 0.005

# 固定数据
var default_resource_pack = "official_new"
var default_effect_dict = {
	"hungry": 0
}
var default_achievement_progress_dict = {}
var world_type_dictionary = {
	0: "default",
	1: "flat"
}
var gamemode_dictionary = {
	0: "survival",
	1: "creative"
}
var resource_pack_dictionary = {
	0: "official_old",
	1: "official_new"
}
var block_selection_box_dictionary = {
	0: "show_when_changing",
	1: "always_show",
	2: "never_show"
}
var colors = {
	"red": Color.RED,
	"yellow": Color.YELLOW,
	"blue": Color.BLUE,
	"green": Color.GREEN,
	"crimson": Color.CRIMSON,
	"violet": Color.VIOLET,
	"pink": Color.PINK,
	"gold": Color.GOLD,
	"light_sky_blue": Color.LIGHT_SKY_BLUE,
	"deep_sky_blue": Color.DEEP_SKY_BLUE,
	"cornflower_blue": Color.CORNFLOWER_BLUE,
	"chartreuse": Color.CHARTREUSE
}
var tps: int = 20
var spt: float = 1.0/tps
var destroy_light_textures: Dictionary
var block_ids: Dictionary
var block_ids_initial: Dictionary
var block_ids_0_1: Dictionary
var block_ids_0_2: Dictionary
var settings: Dictionary
var world_level_infos: Dictionary
var default_item_bar_names: Array
var default_item_bar_amounts: Array
var transparent_block_ids: Array
var transparent_block_names: Array
var step_types: Dictionary
var dig_types: Dictionary
var block_destroy_times: Dictionary
var block_name_alternatives: Array
var tab_panels: Dictionary
var light_colors: Dictionary
var untouchable_blocks: Array
var block_types: Dictionary
var item_model_types: Dictionary
var dropped_items: Dictionary
var entity_dropped_loots: Dictionary
var undead_mob_list: Array
var common_mob_list: Array
var item_max_amounts: Dictionary
var tools_efficiency: Dictionary
var tools_type: Dictionary
var spawn_egg_colors: Dictionary
var special_block_destroy_time: Dictionary
var achievement_progress_dict: Dictionary
var achievement_icon_dict: Dictionary
var crafting_recipe_dict: Dictionary
var commands: Dictionary
var clinging_block_dict: Dictionary
var special_place_dict: Dictionary
var moon_phase_dict: Dictionary
var food_dict: Dictionary

# 待更新数据
var multiplayer_peer = ENetMultiplayerPeer.new()
var player_peer_dict: Dictionary
var ping_peer_dict: Dictionary
var stored_entity_rpc_list: Array
var is_dedicated_server = false
var is_on_mobile_platform = false
var is_muti_mode = false
var select_world = null
var select_server = null
var is_lan_server = false
var is_in_game = false
var is_new_music_on = true
var force_quit_reason = "null"
var middle_button_normal
var middle_button_chosen
var small_button_normal
var small_button_chosen
var button_chosen
var button_disabled
var button_normal
var default_icon_gray_image
var game_icon_image
var world_icon_buffer
var lan_server_ip
var lan_server_port
var world_path
var region_path
var player_path
var language
var game

var texture_dict = {}

func _ready() -> void:
	# 隐藏自身
	self.hide()
	# 加载数据
	var game_data_type_dict = {
		"default_item_bar_amounts" : "int",
		"item_model_types" : "int",
		"item_max_amounts" : "int"
	}
	var recipe_dict = DataManager.load_json_file("res://assets/data/crafting_recipes.json", {})
	crafting_recipe_dict = recipe_dict["crafting_recipe_dict"]
	var game_dict = DataManager.load_json_file("res://assets/data/default_data.json", game_data_type_dict)
	default_item_bar_names = game_dict["default_item_bar_names"]
	default_item_bar_amounts = game_dict["default_item_bar_amounts"]
	transparent_block_names = game_dict["transparent_block_names"]
	step_types = game_dict["step_types"]
	dig_types = game_dict["dig_types"]
	block_destroy_times = game_dict["block_destroy_times"]
	block_name_alternatives = game_dict["block_name_alternatives"]
	tab_panels = game_dict["tab_panels"]
	light_colors = game_dict["light_colors"]
	untouchable_blocks = game_dict["untouchable_blocks"]
	block_types = game_dict["block_types"]
	item_model_types = game_dict["item_model_types"]
	dropped_items = game_dict["dropped_items"]
	entity_dropped_loots = game_dict["entity_dropped_loots"]
	undead_mob_list = game_dict["undead_mob_list"]
	common_mob_list = game_dict["common_mob_list"]
	item_max_amounts = game_dict["item_max_amounts"]
	tools_efficiency = game_dict["tools_efficiency"]
	tools_type = game_dict["tools_type"]
	food_dict = game_dict["food_dict"]
	spawn_egg_colors = game_dict["spawn_egg_colors"]
	special_block_destroy_time = game_dict["special_block_destroy_time"]
	achievement_progress_dict = game_dict["achievement_progress_dict"]
	achievement_icon_dict = game_dict["achievement_icon_dict"]
	commands = game_dict["commands"]
	clinging_block_dict = game_dict["clinging_block_dict"]
	special_place_dict = game_dict["special_place_dict"]
	for key in game_dict["moon_phase_dict"]:
		var splits = game_dict["moon_phase_dict"][key].split("-")
		moon_phase_dict[int(key)] = Vector3(12+32*int(splits[0]), 12+32*int(splits[1]), float(splits[2]))
	for achievement in achievement_progress_dict:
		default_achievement_progress_dict[achievement] = {}
		for progress in achievement_progress_dict[achievement]:
			default_achievement_progress_dict[achievement][progress] = false
	default_icon_gray_image = load("res://assets/textures/ui/default_offline_server_icon.png").get_image()
	game_icon_image = load("res://assets/textures/ui/fmc_icon.png").get_image()
	
	# 判断平台
	if OS.has_feature("android"):
		is_on_mobile_platform = true
		get_tree().set_quit_on_go_back(false)
	if OS.has_feature("dedicated_server"):
		is_dedicated_server = true
	
	# 初始化据
	for transparent_block_name in transparent_block_names:
		transparent_block_ids.append(DataManager.get_block_id(transparent_block_name))
	
	# 如果是专用服务器，直接开服
	#if is_dedicated_server:
		#var world_server_path = "user://worlds/world"
		#if not DirAccess.dir_exists_absolute(world_server_path):
			#DirAccess.make_dir_recursive_absolute(world_server_path)
			#dedicated_server_create_world()
			#await get_tree().create_timer(1).timeout
		#select_world = "world"
		#if not DirAccess.dir_exists_absolute(server_log_path):
			#DirAccess.make_dir_recursive_absolute(server_log_path)
		#if not FileAccess.file_exists(server_root_path+"/server.properties"):
			#var config = ConfigFile.new()
			#config.set_value("server", "spawn_protection_x_size", "16")
			#config.set_value("server", "spawn_protection_y_size", "-1")
			#config.save(server_root_path+"/server.properties")
		#if not FileAccess.file_exists(server_root_path+"/ops.txt"):
			#var config = ConfigFile.new()
			#config.save(server_root_path+"/ops.txt")
		#SceneManager.change_scene("menus/loading_world_menu")

func _process(delta: float) -> void:
	process_stored_rpc()
	
func update_game_node():
	game = $"/root/Game"

func update_select_world_path():
	if select_world != null:
		world_path = "user://worlds/"+select_world
		region_path = world_path+"/regions"
		player_path = world_path+"/players"

func get_mca_value(got_chunk_pos):
	var chunk_config = ConfigFile.new()
	var x_chunk = got_chunk_pos[0]
	var y_chunk = got_chunk_pos[1]
	var chunk_result = chunk_config.load_encrypted_pass(region_path+"/r."+str(x_chunk)+"."+str(y_chunk)+".mca", SettingsManager.get_default_value("config_password"))
	if chunk_result != OK:
		return [false]
	var blocks = chunk_config.get_value("chunk", "blocks", [])
	var no_reach_blocks = chunk_config.get_value("chunk", "no_reach_blocks", [])
	var back_blocks = chunk_config.get_value("chunk", "back_blocks", [])
	var chunk_block_list = [blocks, no_reach_blocks, back_blocks]
	
	var chunk_dirt_list = chunk_config.get_value("chunk", "dirt_list", [])
	var chunk_grass_block_list = chunk_config.get_value("chunk", "grass_block_list", [])
	var chunk_seed_list = chunk_config.get_value("chunk", "seed_list", [])
	var chunk_sapling_list = chunk_config.get_value("chunk", "sapling_list", [])
	var chunk_leaves_list = chunk_config.get_value("chunk", "leaves_list", [])
	var chunk_farm_land_list = chunk_config.get_value("chunk", "farm_land_list", [])
	var chunk_sugar_cane_list = chunk_config.get_value("chunk", "sugar_cane_list", [])
	var chunk_sign_dict = chunk_config.get_value("chunk", "sign_dict", {})
	var chunk_info_dict = {
		"chunk_dirt_list": chunk_dirt_list,
		"chunk_grass_block_list": chunk_grass_block_list,
		"chunk_seed_list": chunk_seed_list,
		"chunk_sapling_list": chunk_sapling_list,
		"chunk_leaves_list": chunk_leaves_list,
		"chunk_farm_land_list": chunk_farm_land_list,
		"chunk_sugar_cane_list": chunk_sugar_cane_list,
		"chunk_sign_dict": chunk_sign_dict
	}
	
	if not game.loaded_chunks.has(str(x_chunk)+"."+str(y_chunk)):
		game.loaded_chunks[str(x_chunk)+"."+str(y_chunk)] = Chunk.new()
	game.loaded_chunks[str(x_chunk)+"."+str(y_chunk)].is_to_save = false
	game.loaded_chunks[str(x_chunk)+"."+str(y_chunk)].dirt_list = chunk_dirt_list
	game.loaded_chunks[str(x_chunk)+"."+str(y_chunk)].grass_block_list = chunk_grass_block_list
	game.loaded_chunks[str(x_chunk)+"."+str(y_chunk)].seed_list = chunk_seed_list
	game.loaded_chunks[str(x_chunk)+"."+str(y_chunk)].sapling_list = chunk_sapling_list
	game.loaded_chunks[str(x_chunk)+"."+str(y_chunk)].leaves_list = chunk_leaves_list
	game.loaded_chunks[str(x_chunk)+"."+str(y_chunk)].farm_land_list = chunk_farm_land_list
	game.loaded_chunks[str(x_chunk)+"."+str(y_chunk)].sugar_cane_list = chunk_sugar_cane_list
	game.loaded_chunks[str(x_chunk)+"."+str(y_chunk)].sign_dict = chunk_sign_dict
	game.loaded_chunks_timer[str(x_chunk)+"."+str(y_chunk)] = CHUNK_FREE_TIME
	return [true, chunk_config, chunk_block_list, chunk_info_dict]

func process_stored_rpc():
	if not is_muti_mode:
		return
	await get_tree().create_timer(0.5)
	var current_time = Time.get_ticks_msec()
	for stored_rpc in stored_entity_rpc_list.duplicate():
		if multiplayer == null:
			continue
		if current_time - stored_rpc[0] > 10000:
			stored_entity_rpc_list.erase(stored_rpc)
			continue
		if game != null and not game.entities.has(stored_rpc[2]):
			continue
		if stored_rpc[1] == "request":
			process_request_for_entity_func_by_uuid(stored_rpc[2], stored_rpc[3], stored_rpc[4], stored_rpc[5])
			stored_entity_rpc_list.erase(stored_rpc)
		elif stored_rpc[1] == "reply":
			process_reply_for_entity_func_by_uuid(stored_rpc[2], stored_rpc[3], stored_rpc[4])
			stored_entity_rpc_list.erase(stored_rpc)



#func generate_chunk(pos: Vector2i):
	#@warning_ignore("unused_variable")
	#var x = pos[0]
	#var y = pos[1]
	#var blocks = []
	#if y <= -1:
		#for i in range(16):
			#var row = []
			#for j in range(16):
				#row.append(0)
			#blocks.append(row)
	#elif y == 0:
		#for i in range(16):
			#var row = []
			#for j in range(16):
				#if i == 0:
					#row.append(10)
				#elif i > 0 and i<=3:
					#row.append(7)
				#else:
					#row.append(16)
			#blocks.append(row)
	#else:
		#for i in range(16):
			#var row = []
			#for j in range(16):
				#row.append(16)
			#blocks.append(row)
	#return blocks

func calculate_sight_is_blocked(pos1, pos2):
	var tile_map_layer_tmp = game.tile_map_layer
	var relative_to_pos1 = pos2 - pos1
	var stride = 5
	var length = relative_to_pos1.length()
	var freq = stride / length
	var cycle_num = int(1 / freq)
	var orthogonal_relative_to_pos1 = relative_to_pos1.orthogonal().normalized()*5
	for i in range(cycle_num):
		var pos_tmp1 = pos1.lerp(pos2, i*freq)
		var pos_tmp2 = pos_tmp1+orthogonal_relative_to_pos1
		var pos_tmp3 = pos_tmp1-orthogonal_relative_to_pos1
		for pos_tmp in [pos_tmp1, pos_tmp2, pos_tmp3]:
			var block_id = get_block_id_by_atlas_coords(tile_map_layer_tmp.get_cell_atlas_coords(tile_map_layer_tmp.local_to_map(pos_tmp)))
			if block_id != 0 and not get_is_untouchable_by_id(block_id):
				return true
	return false

func get_time_string(is_return_day: bool = true):
	var time_str = Time.get_datetime_string_from_system().split("T")
	var day = time_str[0].replace("-","/")
	var moment = time_str[1]
	var time = moment
	if is_return_day:
		time = day + " " + moment
	return time

func get_destroy_total_time(block_id, tool):
	var block_type = get_block_type_by_id(block_id)
	var original_time = DataManager.get_default_data_dict("block_destroy_times")[block_type]
	if not tools_type.has(tool):
		return original_time
	if block_type == "stone" and tools_type[tool].has("pickaxe"):
		var block_name = DataManager.get_block_name(block_id)
		if dropped_items.has(block_name):
			var tool_type_dict = get_tools_type_by_name(tool)
			var tool_type = tool_type_dict.keys()[0]
			var info_dict = dropped_items[block_name]
			if info_dict.has(tool_type):
				var item_dict = info_dict[tool_type]
				if item_dict.has("MINE_LEVEL"):
					var tool_level = int(tool_type_dict[tool_type])
					if tool_level < item_dict["MINE_LEVEL"]:
						return original_time
		return original_time / tools_efficiency[tool]
	elif block_type == "wood" and tools_type[tool].has("axe"):
		return original_time / tools_efficiency[tool]
	elif block_type == "grass" and tools_type[tool].has("shovel"):
		return original_time / tools_efficiency[tool]
	elif block_type == "gravel" and tools_type[tool].has("shovel"):
		return original_time / tools_efficiency[tool]
	return original_time

func get_tools_type_by_name(tool_name):
	if tools_type.has(tool_name):
		return tools_type[tool_name]
	return {"null":1}

func get_step_type_by_name(block_name):
	var value = "stone"
	if block_types.has(block_name):
		value = block_types[block_name]
	if step_types.has(block_name):
		value = step_types[block_name]
	return value

func get_dig_type_by_block_type(block_type) -> String:
	var value = block_type
	if dig_types.has(block_type):
		value = dig_types[block_type]
	return value

func get_block_type_by_id(id: int) -> String:
	var value = "stone"
	var block_name = DataManager.get_block_name(id)
	if block_types.has(block_name):
		value = block_types[block_name]
	return value

func get_item_model_type_by_name(item_name) -> int:
	var value = 3
	if item_model_types.has(item_name):
		value = item_model_types[item_name]
	return value

func get_dropped_item_by_name(find_type, block_name, tool_name):
	var find_dict = dropped_items
	if find_type == "entity":
		find_dict = entity_dropped_loots
	if find_dict.has(block_name):
		var tool_type_dict = get_tools_type_by_name(tool_name)
		var tool_type = tool_type_dict.keys()[0]
		var tool_level = int(tool_type_dict[tool_type])
		var info_dict = find_dict[block_name]
		var item_dict = {}
		if not info_dict.has(tool_type):
			item_dict = info_dict["others"].duplicate()
		else:
			item_dict = info_dict[tool_type].duplicate()
		if item_dict.has("MINE_LEVEL"):
			if tool_level < item_dict["MINE_LEVEL"]:
				item_dict = info_dict["others"].duplicate()
			else:
				item_dict.erase("MINE_LEVEL")
		if item_dict.has("MUTEX"):
			for item_prop_list in item_dict["MUTEX"]:
				var prop_dict = {}
				for item_prop in item_prop_list:
					var splits = item_prop.split(":")
					prop_dict[splits[0]] = float(splits[1])
				var rng = RandomNumberGenerator.new()
				var num = rng.randf()
				var final_item = prop_dict.keys()[-1]
				for item in prop_dict:
					if num > prop_dict[item]:
						if num > 1.0:
							final_item = item
						continue
					else:
						final_item = item
						break
				item_dict.erase("MUTEX")
				for item in prop_dict:
					if item == final_item:
						continue
					item_dict.erase(item)
		var drop_item_dict = {}
		for item in item_dict:
			var item_prop_list = item_dict[item]
			var prop_dict = {}
			for item_prop in item_prop_list:
				var splits = item_prop.split(":")
				prop_dict[splits[0]] = float(splits[1])
			var rng = RandomNumberGenerator.new()
			var num = rng.randf()
			var final_drop_num = int(prop_dict.keys()[-1])
			for drop_num in prop_dict:
				if num > prop_dict[drop_num]:
					if num > 1.0:
						final_drop_num = int(drop_num)
					continue
				else:
					final_drop_num = int(drop_num)
					break
			drop_item_dict[item] = final_drop_num
		return drop_item_dict
	else:
		if find_type == "block":
			return {block_name:1}
		elif find_type == "entity":
			return {"AIR":1}

func get_light_color_by_id(id: int):
	var block_name = DataManager.get_block_name(id)
	if light_colors.has(block_name):
		return [true, light_colors[block_name]]
	return [false, null]

func get_is_untouchable_by_id(id: int):
	var block_name = DataManager.get_block_name(id)
	if untouchable_blocks.has(block_name):
		return true
	return false

func get_is_transparent_by_id(id):
	return transparent_block_ids.has(id)

func get_final_place_name_by_name(item_name):
	var final_name = item_name
	if special_place_dict.has(item_name):
		final_name = special_place_dict[item_name]
	return final_name

func get_max_amount_by_name(item_name):
	var value = 64
	if item_max_amounts.has(item_name):
		value = item_max_amounts[item_name]
	return value
	
func get_is_durable_by_name(got_name):
	return tools_type.has(got_name)

func get_is_clingling_by_name(block_name):
	if clinging_block_dict.has(block_name):
		return clinging_block_dict[block_name]
	return "null"

func get_is_valid_gamemode(gamemode):
	if gamemode == "creative":
		return true
	elif gamemode == "survival":
		return true
	return false

func get_gamemode_from_sort(sort):
	if sort == 0:
		return "survival"
	elif sort == 1:
		return "creative"
	return "null"

func get_can_fly_from_gamemode(gamemode):
	if str(gamemode) == "creative" or int(gamemode) == 1:
		return true
	return false

func get_atlas_coords_by_block_id(block_id: int):
	@warning_ignore("integer_division")
	return Vector2i((block_id-1)%10,(block_id-1)/10)
	
func get_block_id_by_atlas_coords(atlas_coords: Vector2i):
	if atlas_coords[0] == -1:
		return 0
	return atlas_coords[1]*10+atlas_coords[0]+1

func get_block_selection_box_by_selected(selected):
	return block_selection_box_dictionary[selected]

func get_selected_by_block_selection_box(block_selection_box):
	return block_selection_box_dictionary.find_key(block_selection_box)

func get_on_or_off_by_selection(selected, default="on"):
	if selected == 0:
		return "on"
	elif selected == 1:
		return "off"
	#if default == "on":
		#if selected == 0:
			#return "on"
		#elif selected == 1:
			#return "off"
	#else:
		#if selected == 1:
			#return "on"
		#elif selected == 0:
			#return "off"

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

func start_server():
	reset_signals(true)
	if not is_dedicated_server:
		game.broadcast_to_person(game.player.player_name, tr("OPENING_PORT"), "gold")
		game.op_list.append(game.player.player_name.to_lower())
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
		var text = "["+get_time_string(false)+" INFO]: "+"Server opened on 127.0.0.1:12419"
		print(text)
		ServerManager.record_server_log(Time.get_date_string_from_system(), text)
	multiplayer.multiplayer_peer = multiplayer_peer
	if not is_dedicated_server:
		game.pause_button_5.state = ButtonState.DISABLED
		game.broadcast_to_person(game.player.player_name, tr("OPEN_SERVER_SUCCESS")+StaticLoad.HOST_IP+":"+str(port), "chartreuse")
	var ping_instance = SceneManager.get_scene("others/ping").instantiate()
	ping_instance.target_peer_id = 1
	ping_instance.ping = 1
	ping_peer_dict[1] = ping_instance
	StaticLoad.is_muti_mode = true
	ServiceDiscovery.server_data = {'Name':str(port)+"|"+game.player.player_name}
	ServiceDiscovery.set_server()

func dedicated_server_create_world():
	var world_name = "world"
	world_path = "user://worlds/"+world_name
	region_path = "user://worlds/"+world_name+"/regions"
	player_path = "user://worlds/"+world_name+"/players"
	DirAccess.make_dir_recursive_absolute(region_path)
	DirAccess.make_dir_recursive_absolute(player_path)
	var image = load("res://assets/textures/ui/default_icon.png").get_image()
	image.save_png(world_path+"/icon.png")
	var level = ConfigFile.new()
	var current_time = Time.get_datetime_string_from_system(false, true).replace(" ", "  ").replace("-", "/")
	var level_change_value = {
		"last_modified": current_time,
		"version": settings["version"],
		"seed": "1241999312",
		"world_type": "default",
		"gamemode": "survival"
	}
	WorldManager.save_level_dat(level, level_change_value)
	level.save_encrypted_pass(world_path+"/level.dat", SettingsManager.get_default_value("config_password"))
	for x in range(-1,1):
		for y in range(-1,1):
			var mca = ConfigFile.new()
			var chunk = WorldManager.generate_chunk(Vector2i(x, y), seed, "default")
			var value_dict = {
				"blocks" : chunk[0],
				"no_reach_blocks" : chunk[1],
				"back_blocks" : chunk[2]
			}
			WorldManager.set_mca_value(mca, value_dict)
			mca.save_encrypted_pass(region_path+"/r."+str(x)+"."+str(y)+".mca", SettingsManager.get_default_value("config_password"))

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

func clear_connections():
	multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = null
	if not is_in_game:
		return
	for peer_id in player_peer_dict:
		player_peer_dict[peer_id].queue_free()
	player_peer_dict.clear()
	ping_peer_dict.clear()

func clear_signal(sgl: Signal):
	for conn in sgl.get_connections():
		conn["signal"].disconnect(conn.callable)

func reset_signals(is_server: bool):
	clear_signal(multiplayer.peer_disconnected)
	clear_signal(multiplayer.peer_connected)
	clear_signal(multiplayer.server_disconnected)
	clear_signal(multiplayer.connected_to_server)
	clear_signal(multiplayer.connection_failed)
	if is_server:
		multiplayer.peer_disconnected.connect(server_got_peer_disconnected)
		multiplayer.peer_connected.connect(server_got_peer_connected)
	else:
		multiplayer.server_disconnected.connect(client_got_server_disconnected)
		multiplayer.connected_to_server.connect(client_got_connected_to_server)
		multiplayer.connection_failed.connect(client_got_connection_failed)

func destroy_peer(client_peer_id):
	if client_peer_id == 1:
		#print("1 : server closed")
		clear_connections()
		return
	var player_name = player_peer_dict[client_peer_id].player_name
	game.player_icons[player_name].queue_free()
	game.player_icons.erase(player_name)
	var player_tmp = player_peer_dict[client_peer_id]
	player_peer_dict.erase(client_peer_id)
	player_tmp.leave_server_and_destroy()
	if game.online_ui_vbox_container.has_node(str(client_peer_id)):
		game.online_ui_vbox_container.get_node(str(client_peer_id)).queue_free()

func server_got_peer_disconnected(client_peer_id):
	for server_detect in server_detects.get_children():
		if server_detect.name == str(client_peer_id):
			server_detect.queue_free()
			break
	if ping_peer_dict.has(client_peer_id):
		ping_peer_dict.erase(client_peer_id)
	if player_peer_dict.has(client_peer_id):
		var left_player = player_peer_dict[client_peer_id]
		if left_player.is_dead:
			left_player.respawn(false)
		game.save_player(client_peer_id)
		game.save_world()
		call_deferred("rpc", "peer_disconnect_broadcast", client_peer_id)

func server_got_peer_connected(client_peer_id):
	var server_detect = SceneManager.get_scene("others/server_detect").instantiate()
	server_detect.name = str(client_peer_id)
	server_detects.add_child(server_detect)
	game.save_world()

func client_got_server_disconnected():
	#print(multiplayer.get_unique_id(), " : server_disconnected")
	destroy_peer(get_multiplayer_authority())
	is_in_game = false
	is_muti_mode = false
	force_quit_reason = "connection_interrupted"
	SceneManager.change_scene("menus/force_quit_menu")

func client_got_connected_to_server():
	#print(multiplayer.get_unique_id()," : connected to server")
	ServerManager.is_server_connected = true
	#if has_node("/root/LoadingServerUI"):
		#get_node("/root/LoadingServerUI").is_server_connected = true
	#elif has_node("/root/MutiMenu/ServerDetect"):
		#get_node("/root/MutiMenu/ServerDetect").is_server_connected = true

func client_got_connection_failed():
	#print(multiplayer.get_unique_id(), " : connection_failed")
	pass

@rpc("authority", "call_remote", "reliable", 1)
func check_ping():
	rpc_id(1, "got_ping", multiplayer.get_unique_id())
	
@rpc("any_peer", "call_remote", "reliable", 1)
func got_ping(client_peer_id):	
	if not ping_peer_dict.has(client_peer_id):
		return
	ping_peer_dict[client_peer_id].got_ping()

@rpc("any_peer", "call_remote", "reliable", 1)
func request_for_ping(client_peer_id, target_peer_id):
	rpc_id(client_peer_id, "reply_for_ping", target_peer_id, ping_peer_dict[target_peer_id].ping)
	ping_peer_dict[target_peer_id].start_ping()

@rpc("authority", "call_remote", "reliable", 1)
func reply_for_ping(target_peer_id, ping):
	var online_info = game.online_ui_vbox_container.get_node(str(target_peer_id))
	online_info.ping = ping
	online_info.update_ping()

@rpc("authority", "call_local", "reliable", 1)
func peer_disconnect_broadcast(client_peer_id):
	if not player_peer_dict.has(client_peer_id):
		return
	var left_player = player_peer_dict[client_peer_id]
	game.broadcast_to_all(left_player.player_name+tr("LEFT_GAME"), "gold")
	if is_dedicated_server:
		var text = "["+get_time_string(false)+" INFO]: "+player_peer_dict[client_peer_id].player_name+" left the game"
		print(text)
		ServerManager.record_server_log(Time.get_date_string_from_system(), text)
	destroy_peer(client_peer_id)

@rpc("any_peer", "call_remote", "reliable", 1)
func request_for_mark_revised_chunk(chunk_pos):
	if not is_in_game:
		return
	if not game.database_chunks.has(str(chunk_pos[0])+"."+str(chunk_pos[1])):
		return
	if not game.loaded_chunks.has(str(chunk_pos[0])+"."+str(chunk_pos[1])):
		return
	game.loaded_chunks[str(chunk_pos[0])+"."+str(chunk_pos[1])].is_to_save = true

@rpc("any_peer", "call_remote", "reliable", 1)
func request_for_update_chunk(client_peer_id, is_init, x_chunk, y_chunk):
	var blocks = []
	var no_reach_blocks = []
	var back_blocks = []
	var sign_dict = {}
	@warning_ignore("unused_variable")
	var trees = []
	if game.loaded_chunks.has(str(x_chunk)+"."+str(y_chunk)):
		sign_dict = game.loaded_chunks[str(x_chunk)+"."+str(y_chunk)].sign_dict
		for y in range(16):
			var row = []
			var no_reach_row = []
			var back_row = []
			for x in range(16):
				var block_pos = Vector2i(x_chunk*16+x, y_chunk*16+y)
				var id = 0
				if game.tile_map_layer.get_cell_source_id(block_pos) != -1:
					var atlas_coords = game.tile_map_layer.get_cell_atlas_coords(block_pos)
					id = get_block_id_by_atlas_coords(atlas_coords)
				row.append(id)
				var no_reach_id = 0
				if game.no_reach_tile_map_layer.get_cell_source_id(block_pos) != -1:
					var atlas_coords = game.no_reach_tile_map_layer.get_cell_atlas_coords(block_pos)
					no_reach_id = get_block_id_by_atlas_coords(atlas_coords)
				no_reach_row.append(no_reach_id)
				var back_id = 0
				if game.back_tile_map_layer.get_cell_source_id(block_pos) != -1:
					var atlas_coords = game.back_tile_map_layer.get_cell_atlas_coords(block_pos)
					back_id = get_block_id_by_atlas_coords(atlas_coords)
				back_row.append(back_id)
			blocks.append(row)
			no_reach_blocks.append(no_reach_row)
			back_blocks.append(back_row)
	elif game.database_chunks.has(str(x_chunk)+"."+str(y_chunk)):
		var value_list = get_mca_value(Vector2i(x_chunk, y_chunk))
		if not value_list[0]:
			return
		var chunk_config = value_list[1]
		var block_list = value_list[2]
		sign_dict = value_list[3]["chunk_sign_dict"]
		game.loaded_chunk_num += 1
		game.set_chunk(Vector2i(x_chunk, y_chunk), block_list)
		blocks = block_list[0]
		no_reach_blocks = block_list[1]
		back_blocks = block_list[2]
		game.create_chunk_entities(str(x_chunk)+"."+str(y_chunk), chunk_config)
	else:
		var mca = ConfigFile.new()
		var worlds_path = "user://worlds"
		var world_config = ConfigFile.new()
		var world_info = world_config.load_encrypted_pass(worlds_path+"/"+select_world+"/level.dat", SettingsManager.get_default_value("config_password"))
		if world_info != OK:
			return
		var seed = world_config.get_value("world", "seed", "1241999312")
		var world_type = world_config.get_value("world", "world_type", "default")
		var chunk = WorldManager.generate_chunk(Vector2i(x_chunk, y_chunk), seed, world_type)
		game.loaded_chunk_num += 1
		var value_dict = {
				"blocks" : chunk[0],
				"no_reach_blocks" : chunk[1],
				"back_blocks" : chunk[2]
			}
		blocks = chunk[0]
		no_reach_blocks = chunk[1]
		back_blocks = chunk[2]
		WorldManager.set_mca_value(mca, value_dict)
		mca.save_encrypted_pass(region_path+"/r."+str(x_chunk)+"."+str(y_chunk)+".mca", SettingsManager.get_default_value("config_password"))
		game.loaded_chunks[str(x_chunk)+"."+str(y_chunk)] = Chunk.new()
		game.loaded_chunks[str(x_chunk)+"."+str(y_chunk)].is_to_save = false
		game.loaded_chunks_timer[str(x_chunk)+"."+str(y_chunk)] = CHUNK_FREE_TIME
		game.database_chunks.push_back(str(x_chunk)+"."+str(y_chunk))
		game.set_chunk(Vector2i(x_chunk, y_chunk), [blocks, no_reach_blocks, back_blocks])
	var entities_to_transfer = []
	for uuid in game.entities:
		var entity = game.entities[uuid]
		if entity == null:
			continue
		var entity_block_pos = game.tile_map_layer.local_to_map(entity.position)
		if entity_block_pos.x >= x_chunk*16 and entity_block_pos.x < x_chunk*16+16:
			if entity_block_pos.y >= y_chunk*16 and entity_block_pos.y < y_chunk*16+16:
				if entity.entity_type == "item":
					var item = {}
					item["type"] = "item"
					item["uuid"] = entity.get_uuid()
					item["position"] = entity.position
					item["item_name"] = entity.item_name
					item["item_amount"] = entity.item_amount
					entities_to_transfer.append(item)
				elif entity.entity_type == "arrow":
					var arrow = {}
					arrow["type"] = "arrow"
					arrow["uuid"] = entity.get_uuid()
					arrow["position"] = entity.position
					arrow["entity_name"] = entity.get_entity_name()
					arrow["current_velocity"] = entity.current_velocity
					entities_to_transfer.append(arrow)
				else:
					var value_dict = {}
					value_dict["type"] = entity.entity_type
					value_dict["uuid"] = entity.get_uuid()
					value_dict["entity_name"] = entity.get_entity_name()
					value_dict["position"] = entity.position
					value_dict["health"] = entity.get_health()
					entities_to_transfer.append(value_dict)
			
	if not game.chunk_lights.has(str(x_chunk)+"."+str(y_chunk-1)):
		var sky_light: PackedByteArray
		sky_light.resize(16)
		sky_light.fill(game.current_sky_light)
		game.chunk_sky_light_datas[str(x_chunk)+"."+str(y_chunk)] = sky_light
	if game.chunk_lights.has(str(x_chunk)+"."+str(y_chunk)):
		if not game.chunk_light_to_process.has(str(x_chunk)+"."+str(y_chunk)):
			game.chunk_light_to_process[str(x_chunk)+"."+str(y_chunk)] = "null"
		else:
			game.chunk_light_to_process_double[str(x_chunk)+"."+str(y_chunk)] = "null"
	else:
		game.chunk_light_to_process[str(x_chunk)+"."+str(y_chunk)] = "create"
	rpc_id(client_peer_id, "reply_for_update_chunk", is_init, x_chunk, y_chunk, [blocks, no_reach_blocks, back_blocks], entities_to_transfer, sign_dict)
		
@rpc("authority", "call_remote", "reliable", 1)
func reply_for_update_chunk(is_init, x_chunk, y_chunk, blocks_list, entities_to_transfer, sign_dict):
	game.set_chunk(Vector2i(x_chunk, y_chunk), blocks_list)
	if not game.loaded_chunks.has(str(x_chunk)+"."+str(y_chunk)):
		game.loaded_chunks[str(x_chunk)+"."+str(y_chunk)] = Chunk.new()
	game.loaded_chunks[str(x_chunk)+"."+str(y_chunk)].is_to_save = false
	game.loaded_chunks[str(x_chunk)+"."+str(y_chunk)].sign_dict = sign_dict
	game.loaded_chunks_timer[str(x_chunk)+"."+str(y_chunk)] = CHUNK_FREE_TIME
	game.loaded_chunk_num += 1
	for entity in entities_to_transfer:
		if game.entities.has(entity["uuid"]):
			continue
		if entity["type"] == "item":
			var item = SceneManager.get_scene("entities/item").instantiate()
			game.items.add_child(item)
			item.init([UUID.v4(), entity["item_name"], entity["position"], entity["item_amount"], 1, 0])
			item.uuid = entity["uuid"]
			item.name = entity["uuid"]
			game.entities[item.get_uuid()] = item
		elif entity["type"] == "arrow":
			var arrow = SceneManager.get_scene("entities/arrow").instantiate()
			game.arrows.add_child(arrow)
			arrow.init([UUID.v4(), entity["entity_name"], entity["position"], Vector2(0, 0), entity["current_velocity"], "null", "null", "null", false])
			arrow.uuid = entity["uuid"]
			arrow.name = entity["uuid"]
			game.entities[arrow.get_uuid()] = arrow
		elif undead_mob_list.has(entity["type"]):
			var entity_instance = SceneManager.get_scene("entities/"+entity["type"]).instantiate()
			game.undead_mobs.add_child(entity_instance)
			entity_instance.init([entity["uuid"], entity["entity_name"], entity["position"], entity["health"]])
			game.entities[entity_instance.get_uuid()] = entity_instance
		elif entity["type"] != "player":
			var entity_instance = SceneManager.get_scene("entities/"+entity["type"]).instantiate()
			game.mobs.add_child(entity_instance)
			entity_instance.init([entity["uuid"], entity["entity_name"], entity["position"], entity["health"]])
			game.entities[entity_instance.get_uuid()] = entity_instance
	if not game.chunk_lights.has(str(x_chunk)+"."+str(y_chunk-1)):
		var sky_light: PackedByteArray
		sky_light.resize(16)
		sky_light.fill(game.current_sky_light)
		game.chunk_sky_light_datas[str(x_chunk)+"."+str(y_chunk)] = sky_light
	#if is_init:
		#return
	if game.chunk_lights.has(str(x_chunk)+"."+str(y_chunk)):
		if not game.chunk_light_to_process.has(str(x_chunk)+"."+str(y_chunk)):
			game.chunk_light_to_process[str(x_chunk)+"."+str(y_chunk)] = "null"
		else:
			game.chunk_light_to_process_double[str(x_chunk)+"."+str(y_chunk)] = "null"
	else:
		game.chunk_light_to_process[str(x_chunk)+"."+str(y_chunk)] = "create"

@rpc("authority", "call_remote", "reliable", 1)
func create_entity(args):
	if game == null:
		return
	if is_muti_mode and multiplayer.get_unique_id() == 1:
		rpc("create_entity", args)
	if args[0] == "item":
		var droppped_item_name = args[1]
		var pos = args[2]
		var block_pos = game.tile_map_layer.local_to_map(pos)
		var chunk_pos = game.get_chunk_position(block_pos)
		if not game.loaded_chunks.has(str(chunk_pos[0])+"."+str(chunk_pos[1])):
			return
		var amount = args[3]
		var x_velocity = args[4]
		if is_muti_mode and not multiplayer.get_unique_id() == 1:
			x_velocity = 0
		var no_collect_time = args[5]
		var uuid = args[6]
		var item = SceneManager.get_scene("entities/item").instantiate()
		game.items.add_child(item)
		item.init([uuid, droppped_item_name, pos, amount, no_collect_time, x_velocity])
		game.entities[item.get_uuid()] = item
	elif args[0] == "arrow":
		var uuid = args[1]
		var entity_name = args[2]
		var pos = args[3]
		var velocity = args[4]
		var current_velocity = args[5]
		var shooter_type = args[6]
		var shooter_uuid = args[7]
		var shooter_name = args[8]
		var is_undead_damage = bool(args[9])
		var block_pos = game.tile_map_layer.local_to_map(pos)
		var chunk_pos = game.get_chunk_position(block_pos)
		if not game.loaded_chunks.has(str(chunk_pos[0])+"."+str(chunk_pos[1])):
			return
		var health = args[4]
		var entity = SceneManager.get_scene("entities/"+args[0]).instantiate()
		if undead_mob_list.has(args[0]):
			game.undead_mobs.add_child(entity)
		else:
			game.mobs.add_child(entity)
		entity.init([uuid, entity_name, pos, velocity, current_velocity, shooter_type, shooter_uuid, shooter_name, is_undead_damage])
		game.entities[entity.get_uuid()] = entity
	else:
		var uuid = args[1]
		var entity_name = args[2]
		var pos = args[3]
		var block_pos = game.tile_map_layer.local_to_map(pos)
		var chunk_pos = game.get_chunk_position(block_pos)
		if not game.loaded_chunks.has(str(chunk_pos[0])+"."+str(chunk_pos[1])):
			return
		var health = args[4]
		var entity = SceneManager.get_scene("entities/"+args[0]).instantiate()
		if undead_mob_list.has(args[0]):
			game.undead_mobs.add_child(entity)
		else:
			game.mobs.add_child(entity)
		entity.init([uuid, entity_name, pos, health])
		game.entities[entity.get_uuid()] = entity

@rpc("authority", "call_remote", "reliable", 1)
func set_block(args):
	if not is_in_game:
		return
	var block_pos = args[0]
	var block_id = args[1]
	var tile_map_type = args[2]
	var is_pre_load = args[3]
	game.set_block(block_pos, block_id, tile_map_type, is_pre_load)

# 一次握手：检查服务器准入状态
@rpc("any_peer", "call_remote", "reliable", 1)
func request_for_connect_state_check(client_peer_id, player_name, version_tmp):
	for id in player_peer_dict:
		if player_peer_dict[id].player_name.to_lower() == player_name.to_lower():
			rpc_id(client_peer_id, "reply_for_connect_state_check", "same_player_name")
			return
	if version_tmp != settings["version"]:
		rpc_id(client_peer_id, "reply_for_connect_state_check", "version_conflict")
		return
	if player_name.length() > MAX_NAME_LENGTH:
		rpc_id(client_peer_id, "reply_for_connect_state_check", "player_name_exceed")
		return
	if player_name.contains(" "):
		rpc_id(client_peer_id, "reply_for_connect_state_check", "player_name_space")
		return
	rpc_id(client_peer_id, "reply_for_connect_state_check", "state_checked")

@rpc("authority", "call_remote", "reliable", 1)
func reply_for_connect_state_check(state):
	if state == "state_checked":
		ServerManager.is_server_state_checked = true
	elif state == "same_player_name":
		ServerManager.connect_interrupt_reason = "same_player_name"
	elif state == "version_conflict":
		ServerManager.connect_interrupt_reason = "version_conflict"
	elif state == "player_name_exceed":
		ServerManager.connect_interrupt_reason = "player_name_exceed"
	elif state == "player_name_space":
		ServerManager.connect_interrupt_reason = "player_name_space"

# 二次握手：获取玩家信息
@rpc("any_peer", "call_remote", "reliable", 1)
func request_for_player_info(client_peer_id, player_name):
	player_peer_dict[client_peer_id] = game.players.get_node(str(client_peer_id))
	var new_player = player_peer_dict[client_peer_id]
	if multiplayer.get_unique_id() == 1:
		var ping_instance = SceneManager.get_scene("others/ping").instantiate()
		ping_instance.target_peer_id = client_peer_id
		ping_peer_dict[client_peer_id] = ping_instance
		ping_instance.start_ping()
	var state_dict_tmp = new_player.state_dict.duplicate()
	state_dict_tmp.erase("position")
	if FileAccess.file_exists(player_path+"/"+player_name.to_lower()+".dat"):
		var worlds_path = "user://worlds"
		var world_config = ConfigFile.new()
		var world_info = world_config.load_encrypted_pass(worlds_path+"/"+select_world+"/level.dat", SettingsManager.get_default_value("config_password"))
		var gamemode
		if world_info == OK:
			gamemode = world_config.get_value("world", "gamemode", "survival")
		var player_config = ConfigFile.new()
		var player_result = player_config.load_encrypted_pass(player_path+"/"+player_name.to_lower()+".dat", SettingsManager.get_default_value("config_password"))
		if player_result != OK:
			return
		var player_position = player_config.get_value("player", "position", DEFAULT_PLAYER_SPAWN_POS)
		var face_state = player_config.get_value("player", "face_state", DEFAULT_PLAYER_FACE_STATE)
		var is_flying = player_config.get_value("player", "is_flying", DEFAULT_PLAYER_IS_FLYING)
		gamemode = player_config.get_value("player", "gamemode", gamemode)
		var health = player_config.get_value("player", "health", DEFAULT_PLAYER_HEALTH)
		var hunger = player_config.get_value("player", "hunger", DEFAULT_PLAYER_HUNGER)
		var effect_dict = player_config.get_value("player", "effect_dict", default_effect_dict)
		var achievement_progress_dict = player_config.get_value("player", "achievement_progress_dict", default_achievement_progress_dict)
		if gamemode != "creative":
			is_flying = false
		new_player.position = player_position
		new_player.face_state = face_state
		new_player.gamemode = gamemode
		new_player.is_flying = is_flying
		new_player.health = health
		new_player.hunger = hunger
		new_player.effect_dict = effect_dict
		new_player.achievement_progress_dict = achievement_progress_dict
		new_player.update_achievement_progress_dict(achievement_progress_dict)
		new_player.update_state_dict()
		state_dict_tmp = new_player.state_dict.duplicate()
		rpc_id(client_peer_id, "reply_for_player_info", player_position, face_state, is_flying, gamemode, health, hunger, effect_dict, achievement_progress_dict)
		rpc_entity_func_by_uuid(new_player.get_uuid(), "init_remote", [client_peer_id, player_name, state_dict_tmp], [client_peer_id], true)
	else:
		rpc_id(client_peer_id, "reply_for_player_info", DEFAULT_PLAYER_SPAWN_POS, DEFAULT_PLAYER_FACE_STATE, DEFAULT_PLAYER_IS_FLYING, DEFAULT_PLAYER_GAMEMODE, DEFAULT_PLAYER_HEALTH, DEFAULT_PLAYER_HUNGER, default_effect_dict, default_achievement_progress_dict)
		rpc_entity_func_by_uuid(new_player.get_uuid(), "init_remote", [client_peer_id, player_name, state_dict_tmp], [client_peer_id], true)
	call_entity_func(new_player.get_uuid(), "init_remote", [client_peer_id, player_name, state_dict_tmp])
	rpc("broadcast_player_join_game", player_name)

@rpc("authority", "call_remote", "reliable", 1)
func reply_for_player_info(player_position, face_state, is_flying, gamemode, health, hunger, effect_dict, achievement_progress_dict):
	game.player.position = player_position
	game.player.face_state = face_state
	game.player.is_flying = is_flying
	game.player.gamemode = gamemode
	game.player.health = health
	game.player.hunger = hunger
	game.player.effect_dict = effect_dict
	game.player.update_achievement_progress_dict(achievement_progress_dict)
	game.refresh_achievement_info()
	if game.player.gamemode != "creative":
		game.player.is_flying = false
	if game.player.is_flying:
		game.update_jump_button()
		game.player.velocity.y = 0
	game.is_player_info_updated = true

@rpc("authority", "call_local", "reliable", 1)
func broadcast_player_join_game(got_name_tag):
	if not is_in_game:
		return
	game.broadcast_to_all(got_name_tag+tr("JOINED_GAME"), "gold")
	if is_dedicated_server:
		var text = "["+get_time_string(false)+" INFO]: "+got_name_tag+" joined the game"
		print(text)
		ServerManager.record_server_log(Time.get_date_string_from_system(), text)

@rpc("any_peer", "call_remote", "reliable", 1)
func request_for_world_info(client_peer_id, is_fresh):
	rpc_id(client_peer_id, "reply_for_world_info", game.tick_timer, game.world_day, game.move_background.scroll_base_offset.x, is_fresh)

@rpc("authority", "call_remote", "reliable", 1)
func reply_for_world_info(got_tick_timer, got_world_day, got_cloud_offset, is_fresh):
	update_game_node()
	if game == null:
		return
	game.tick_timer = got_tick_timer
	game.world_day = got_world_day
	game.move_background.scroll_base_offset.x = got_cloud_offset
	game.calculate_current_sky_light(true)
	game.update_moon_phase()
	if is_fresh:
		game.refresh_all_light()

@rpc("any_peer", "call_remote", "reliable", 1)
func request_for_update_player_inventory(client_peer_id, player_name):
	player_peer_dict[client_peer_id] = game.players.get_node(str(client_peer_id))
	var new_player = player_peer_dict[client_peer_id]
	if FileAccess.file_exists(player_path+"/"+player_name.to_lower()+".dat"):
		var worlds_path = "user://worlds"
		var player_config = ConfigFile.new()
		var player_result = player_config.load_encrypted_pass(player_path+"/"+player_name.to_lower()+".dat", SettingsManager.get_default_value("config_password"))
		if player_result != OK:
			return
		var item_bar_names = player_config.get_value("player", "item_bar_names", default_item_bar_names)
		var item_bar_amounts = player_config.get_value("player", "item_bar_amounts", default_item_bar_amounts)
		new_player.item_bar_names = item_bar_names
		new_player.item_bar_amounts = item_bar_amounts
		new_player.inventory_dict = new_player.calculate_inventory_dict([item_bar_names, item_bar_amounts, "AIR", 0])
		rpc_id(client_peer_id, "reply_for_update_player_inventory", item_bar_names, item_bar_amounts, "AIR", 0)
	else:
		rpc_id(client_peer_id, "reply_for_update_player_inventory", default_item_bar_names, default_item_bar_amounts, "AIR", 0)

@rpc("authority", "call_remote", "reliable", 1)
func reply_for_update_player_inventory(item_bar_names, item_bar_amounts, mouse_item_name, mouse_item_amount):
	game.player.item_bar_names = item_bar_names
	game.player.item_bar_amounts = item_bar_amounts
	game.player.mouse_item_name = mouse_item_name
	game.player.mouse_item_amount = mouse_item_amount
	game.player.inventory_dict = game.player.calculate_inventory_dict([item_bar_names, item_bar_amounts, mouse_item_name, mouse_item_amount])
	game.append_process_refresh("refresh_item_grid")
	game.append_process_refresh("refresh_inventory")

# 三次握手：同步各个客户端玩家及信息
@rpc("any_peer", "call_local", "reliable", 1)
func create_new_peer_player(client_peer_id):
	if multiplayer.get_unique_id() == client_peer_id:
		return
	game.create_player(client_peer_id)
	if multiplayer.get_unique_id() != 1:
		return
	rpc_id(client_peer_id, "old_peer_replication", player_peer_dict.keys())	

@rpc("authority", "call_remote", "reliable", 1)
func old_peer_replication(peer_ids):
	for peer_id in peer_ids:
		game.create_player(peer_id)
	var local_player = game.player
	if local_player.skin_path != "null":
		rpc_entity_func_by_uuid(local_player.get_uuid(), "change_skin", local_player.skin_texture_buffer, peer_ids, true)
	rpc_id(1, "old_peer_replication_finished", multiplayer.get_unique_id())

@rpc("any_peer", "call_remote", "reliable", 1)
func old_peer_replication_finished(client_peer_id):
	var new_player = game.players.get_node(str(client_peer_id))
	rpc_entity_func_by_uuid(new_player.get_uuid(), "init_remote", [client_peer_id, new_player.player_name, new_player.state_dict], [client_peer_id], false)
	for old_peer_id in player_peer_dict:
		if old_peer_id == client_peer_id:
			continue
		var player_tmp = player_peer_dict[old_peer_id]
		rpc_entity_func_by_uuid(player_tmp.get_uuid(), "init_remote", [old_peer_id, player_tmp.player_name, player_tmp.state_dict], [client_peer_id], true)
		rpc_entity_func_by_uuid(player_tmp.get_uuid(), "change_skin", player_tmp.skin_texture_buffer, [client_peer_id], true)

# 向peer_id_list所有peer调用uuid实体的函数rpc_func_name，参数为args
# 对于服务端，is_to_send若为false，则排除peer_id_list
# 若peer_id_list包含自身peer_id，自动忽略
# 若peer_id_list为"others"，则可理解为向除自身之外的所有peer发送
# 对于客户端，peer_id_list不代表要发送的peer，因为自动向1(主机)发送，不能不经校验向其他玩家同步信息
# 若is_to_send为true，则peer_id_list代表服务端收到request后单独向哪些peer发送
# 若is_to_send为false，则peer_id_list代表服务端收到request后向除了哪些peer的所有群体发送
# 不论哪种情况，都不会向自身发送
func rpc_entity_func_by_uuid(uuid, rpc_func_name, args, peer_id_list, is_to_send):
	var local_peer_id = multiplayer.get_unique_id()
	if peer_id_list is String and peer_id_list == "others":
		peer_id_list = player_peer_dict.duplicate()
		if peer_id_list.has(local_peer_id):
			peer_id_list.erase(local_peer_id)
	if is_to_send:
		if local_peer_id == 1:
			for peer_id in peer_id_list:
				if local_peer_id == peer_id:
					continue
				rpc_id(peer_id, "reply_for_entity_func_by_uuid", uuid, rpc_func_name, args)
		else:
			rpc_id(1, "request_for_entity_func_by_uuid", uuid, rpc_func_name, args, peer_id_list)
	else:
		if local_peer_id == 1:
			for peer_id in player_peer_dict:
				if peer_id_list.has(peer_id):
					continue
				if local_peer_id == peer_id:
					continue
				rpc_id(peer_id, "reply_for_entity_func_by_uuid", uuid, rpc_func_name, args)
		else:
			var to_send_peer_id_list = []
			for peer_id in player_peer_dict:
				if peer_id_list.has(peer_id):
					continue
				to_send_peer_id_list.append(peer_id)
			rpc_id(1, "request_for_entity_func_by_uuid", uuid, rpc_func_name, args, to_send_peer_id_list)

@rpc("any_peer", "call_remote", "reliable", 1)
func request_for_entity_func_by_uuid(uuid, rpc_func_name, args, to_send_peer_id_list):
	if not game.entities.has(uuid) or game.entities[uuid] == null:
		stored_entity_rpc_list.append([Time.get_ticks_msec(), "request", uuid, rpc_func_name, args, to_send_peer_id_list])
		return
	process_request_for_entity_func_by_uuid(uuid, rpc_func_name, args, to_send_peer_id_list)

func process_request_for_entity_func_by_uuid(uuid, rpc_func_name, args, to_send_peer_id_list):
	game.entities[uuid].call(rpc_func_name, args)
	var local_peer_id = multiplayer.get_unique_id()
	for peer_id in to_send_peer_id_list:
		if local_peer_id == peer_id:
			continue
		rpc_id(peer_id, "reply_for_entity_func_by_uuid", uuid, rpc_func_name, args)

@rpc("authority", "call_remote", "reliable", 1)
func reply_for_entity_func_by_uuid(uuid, rpc_func_name, args):
	#print(multiplayer.get_unique_id()," ",uuid," ", rpc_func_name," ", args)
	if not rpc_func_name is String:
		return
	if rpc_func_name == "init_remote":
		for player_tmp in game.players.get_children():
			if player_tmp.name == str(args[0]):
				player_tmp.call(rpc_func_name, args)
				break
	elif not game.entities.has(uuid) or game.entities[uuid] == null:
		stored_entity_rpc_list.append([Time.get_ticks_msec(), "reply", uuid, rpc_func_name, args])
		return
	else:
		process_reply_for_entity_func_by_uuid(uuid, rpc_func_name, args)

func process_reply_for_entity_func_by_uuid(uuid, rpc_func_name, args):
	if game != null and game.entities.has(uuid):
		if game.entities[uuid] != null:
			game.entities[uuid].call(rpc_func_name, args)

func call_entity_func(uuid, rpc_func_name, args):
	if not game.entities.has(uuid):
		return
	if game.entities[uuid] != null:
		game.entities[uuid].call(rpc_func_name, args)
