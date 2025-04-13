extends Node2D

@onready var tile_map_layer = $World/TileMapLayer
@onready var no_reach_tile_map_layer = $World/NoReachTileMapLayer
@onready var back_tile_map_layer = $World/BackTileMapLayer
@onready var death_ui = $DeathUI
@onready var pause_ui = $PauseUI
@onready var game_ui = $GameUI
@onready var options_ui = $Options
@onready var online_ui = $OnlineUI
@onready var online_ui_vbox_container = $OnlineUI/OnlineList/ScrollContainer/VBoxContainer
@onready var item_scene = load("res://Assets/Scenes/Item.tscn") as PackedScene
@onready var chunk_light_scene = load("res://Assets/Scenes/ChunkLight.tscn") as PackedScene
@onready var message_scene = load("res://Assets/Scenes/Message.tscn") as PackedScene
@onready var player_scene = load("res://Assets/Scenes/Player.tscn") as PackedScene
@onready var loading_world_ui_scene = load("res://Assets/Scenes/LoadingWorldUI.tscn") as PackedScene
@onready var loading_server_ui_scene = load("res://Assets/Scenes/LoadingServerUI.tscn") as PackedScene
@onready var online_info_scene = load("res://Assets/Scenes/OnlineInfo.tscn") as PackedScene
@onready var time_counter = load("res://Assets/Scenes/TimeCounter.tscn") as PackedScene
@onready var inventory_grid_scene = load("res://Assets/Scenes/InventoryGrid.tscn") as PackedScene
@onready var destory_light_scene = load("res://Assets/Scenes/DestroyLight.tscn") as PackedScene
@onready var item_icon_scene = load("res://Assets/Scenes/ItemIcon.tscn") as PackedScene
@onready var tab_panel_scene = load("res://Assets/Scenes/TabPanel.tscn") as PackedScene
@onready var move_center_button_normal = load("res://Assets/Textures/GUI/move_center_button_normal.tres") as AtlasTexture
@onready var jump_button_normal = load("res://Assets/Textures/GUI/jump_button_normal.tres") as AtlasTexture
@onready var move_center_button_fly = load("res://Assets/Textures/GUI/move_center_button_fly.tres") as AtlasTexture
#@onready var player_other_scene = load("res://Assets/Scenes/PlayerOther.tscn") as PackedScene
@onready var health_bar = $GameUI/ItemBarPanel/HealthBar
@onready var player
@onready var touch_time_counters = $TouchTimeCounters
@onready var item_grids = $GameUI/ItemBarPanel/ItemBar.get_children()
@onready var item_name_label = $GameUI/ItemBarPanel/ItemNameLabel
@onready var bgm_audio_player = $BgmAudioPlayer
@onready var sound_audio_manager = $SoundAudioManager
@onready var block_selection_ui = $World/TileMapLayer/BlockSelectionUI
@onready var chat_panel = $GameUI/ChatPanel
@onready var chat_line_edit = $GameUI/ChatPanel/ChatLineEdit
@onready var chat_history_in = $GameUI/ChatPanel/ChatHistory
@onready var chat_message_in = $GameUI/ChatPanel/ChatHistory/ChatMessage
@onready var chat_history_out = $GameUI/ChatHistory
@onready var chat_message_out = $GameUI/ChatHistory/ChatMessage
@onready var details = $GameUI/Details
@onready var details_player_name = $GameUI/Details/PlayerName
@onready var details_position = $GameUI/Details/Position
@onready var details_selected_position = $GameUI/Details/SelectedPosition
@onready var details_chunk = $GameUI/Details/Chunk
@onready var details_fps = $GameUI/Details/Fps
@onready var language_ui = $Language
@onready var pause_button_4 = $PauseUI/FlowContainer/Button4
@onready var pause_button_5 = $PauseUI/FlowContainer/Button5
@onready var pause_button_6 = $PauseUI/FlowContainer/Button6
@onready var death_button_2 = $DeathUI/FlowContainer/Button2
@onready var death_button_3 = $DeathUI/FlowContainer/Button3
@onready var players = $Players
@onready var mobile_ui = $MobileUI
@onready var move_buttons_left = $MobileUI/MoveButtonsLeft
@onready var move_buttons_right = $MobileUI/MoveButtonsRight
@onready var move_up_left_button = $MobileUI/MoveButtonsLeft/UpLeftButton
@onready var move_up_right_button = $MobileUI/MoveButtonsLeft/UpRightButton
@onready var move_jump_button_icon = $MobileUI/MoveButtonsRight/JumpButton/JumpButton
@onready var inventory_ui = $GameUI/InventoryUI
@onready var mini_map_camera = $GameUI/MiniMap/SubViewportContainer/SubViewport/Camera2D
@onready var mini_map_tile_map_layer = $GameUI/MiniMap/SubViewportContainer/SubViewport/TileMapLayer
@onready var mini_map_no_reach_tile_map_layer = $GameUI/MiniMap/SubViewportContainer/SubViewport/NoReachTileMapLayer
@onready var mini_map_back_tile_map_layer = $GameUI/MiniMap/SubViewportContainer/SubViewport/BackTileMapLayer
@onready var mini_map_players = $GameUI/MiniMap/SubViewportContainer/SubViewport/Players
@onready var mini_map_lights = $GameUI/MiniMap/SubViewportContainer/SubViewport/Lights
@onready var mini_map = $GameUI/MiniMap
@onready var item_bar_panel = $GameUI/ItemBarPanel
@onready var lights = $Lights
@onready var inventory_back_grids = $GameUI/InventoryUI/Panel/InventoryPanel/Inventory/InventoryBackContainer
@onready var inventory_show_grids = $GameUI/InventoryUI/Panel/InventoryShowContainer
@onready var inventory_player_model = $GameUI/InventoryUI/Panel/InventoryPanel/Player/SubViewportContainer/SubViewport/PlayerModel
@onready var inventory_player_model_mesh = $GameUI/InventoryUI/Panel/InventoryPanel/Player/SubViewportContainer/SubViewport/PlayerModel/Root/Skeleton3D/Mesh
@onready var inventory_player_model_item_in_hand = $GameUI/InventoryUI/Panel/InventoryPanel/Player/SubViewportContainer/SubViewport/PlayerModel/Root/Skeleton3D/Hand/Item
@onready var items = $Items
@onready var inventory_tabs = $GameUI/InventoryUI/Panel/Tabs
@onready var blocks_infinite_container = $GameUI/InventoryUI/Panel/BlocksPanel/InfiniteScrollContainer/InfiniteContainer
@onready var items_infinite_container = $GameUI/InventoryUI/Panel/ItemsPanel/InfiniteScrollContainer/InfiniteContainer
@onready var delete_tab_panel = $GameUI/InventoryUI/Panel/DeleteTabPanel

var is_mouse_motion_updated = false
var destroy_light_names = {}
var mouse_item_name = "AIR"
var mouse_item_amount = 0
var light_thread = Thread.new()
var item_thread = Thread.new()
var refresh_thread = Thread.new()
var tick_cycle_thread = Thread.new()
var dispatch_thread = Thread.new()
var set_block_thread = Thread.new()
var success_set_block_dict = {}
var fail_set_block_list = []
var player_icons = {}
var mouse_item_name_label
var touch_list = []
signal chunk_light_updated_signal
var world_info_dictionary = {}
var entities = {}
var mini_map_chunk_lights = {}
var chunk_lights = {}
var chunk_light_datas = {}
var chunk_sky_light_datas = {}
var item_to_combine = {}
var refresh_to_process = []
var chunk_light_to_process = {}
var chunk_light_to_process_double = {}
var block_selection_timer: float = 0
var block_selection_box
var mini_map_on
var mini_map_zoom: float
var chunk_to_load = []
var is_online_info: bool = false
var is_input_frozen: bool = false
var is_map: bool = false
var is_inventory: bool = false
var is_pause: bool = false
var is_chat: bool = false
var is_player_info_updated: bool = false
var is_chunk_modifing: bool = false
var player_last_chunk: Vector2i
var loaded_chunk_packed_byte_arrays: Dictionary
var loaded_chunks: Dictionary #true代表已修改，需要最后保存
var loaded_chunks_timer: Dictionary
var database_chunks = []
var total_chunk_num = 0
var loaded_chunk_num = 0
var item_name_timer: float = 0
var update_chunk_timer: float = 0
var last_mouse_in_world_pos: Vector2 = Vector2(0, 0)
var move_input_list = []
var last_left_time = 0.0
var last_right_time = 0.0
var last_jump_time = 0.0
var drop_timer = 0.0
var resource_pack = StaticLoad.default_resource_pack
var tick_timer: float = 0
var set_block_list = []

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if StaticLoad.is_muti_mode and StaticLoad.multiplayer.get_unique_id() != 1:
			return
		save_world()
		save_player()
		var change_value = {
			"mini_map_zoom": str(int(mini_map_camera.zoom[0]*100))
		}
		StaticLoad.save_options(change_value)
		if not StaticLoad.is_muti_mode:
			print("窗口意外关闭，游戏已自动保存")
	elif what == NOTIFICATION_WM_GO_BACK_REQUEST:
		StaticLoad.click_audio_player.play()
		if is_chat:
			close_chat_ui()
			Input.emulate_mouse_from_touch = false
		else:
			pause_ui.visible = !pause_ui.visible
			is_pause = pause_ui.visible
			if pause_ui.visible:
				is_input_frozen = true
				move_input_list.clear()
				player.stop_move()
			Input.emulate_mouse_from_touch = true

func _exit_tree():
	light_thread.wait_to_finish()
	item_thread.wait_to_finish()
	refresh_thread.wait_to_finish()
	tick_cycle_thread.wait_to_finish()
	dispatch_thread.wait_to_finish()
	set_block_thread.wait_to_finish()

func _ready() -> void:
	StaticLoad.update_game_node()
	StaticLoad.update_select_world_path()
	if StaticLoad.is_on_mobile_platform:
		mobile_ui.visible = true
		Input.emulate_mouse_from_touch = false
	if StaticLoad.is_muti_mode:
		var loading_ui = loading_server_ui_scene.instantiate()
		add_child(loading_ui)
	else:
		freeze_game()
		var loading_ui = loading_world_ui_scene.instantiate()
		add_child(loading_ui)
		if StaticLoad.is_dedicated_server:
			init_game_as_dedicated_server()
		else:
			init_game_as_single()
		if StaticLoad.is_dedicated_server:
			StaticLoad.start_server()
			unfreeze_game()
		else:
			create_player()

func _process(delta: float) -> void:
	# 服务器和本地均更新
	update_local_player_nearby_chunk()
	remove_outdated_chunks()
	
	if StaticLoad.is_dedicated_server:
		return
	
	# 本地更新
	update_inventroy_player_model()
	update_game_details()
	update_local_player_data()
	update_mini_map()
	update_item_bar_text()
	update_block_selection()
	update_destroy_ui()
	process_mouse_action()
	process_touch_input()
	process_drop_action()
	rectify_emulate_mouse_from_touch()

func process_tick_cycle():
	while(true):
		await get_tree().create_timer(StaticLoad.spt).timeout
		pass

func process_dispatch():
	while(true):
		await get_tree().create_timer(0.01).timeout
		dispatch_all_entity_state_dict()
		dispatch_set_block_state_dict()	

func process_set_block():
	while(true):
		await get_tree().create_timer(0.001).timeout
		if set_block_list.is_empty():
			continue
		var success_set_block_dict_tmp = {}
		var fail_set_block_list_tmp = []
		for set_block_info in set_block_list.duplicate():
			var set_time = set_block_info[0]
			var uuid = set_block_info[1]
			var set_block_id = set_block_info[2]
			var set_block_pos = set_block_info[3]
			var set_block_layer = set_block_info[4]
			var is_to_sync = set_block_info[5]
			var pos_string = str(set_block_pos[0])+"_"+str(set_block_pos[1])
			if success_set_block_dict_tmp.has(pos_string):
				if set_block_layer == success_set_block_dict_tmp[pos_string][4]:
					if set_time < success_set_block_dict_tmp[pos_string][0]:
						success_set_block_dict_tmp[pos_string][2] = set_block_id
						success_set_block_dict_tmp[pos_string][3] = set_block_pos
						success_set_block_dict_tmp[pos_string][4] = set_block_layer
						fail_set_block_list_tmp.append(success_set_block_dict_tmp[pos_string])
						success_set_block_dict_tmp[pos_string] = set_block_info
					else:
						set_block_info[2] = success_set_block_dict_tmp[pos_string][2]
						set_block_info[3] = success_set_block_dict_tmp[pos_string][3]
						set_block_info[4] = success_set_block_dict_tmp[pos_string][4]
						fail_set_block_list_tmp.append(set_block_info)
			else:
				success_set_block_dict_tmp[pos_string] = set_block_info
			set_block_list.erase(set_block_info)
		success_set_block_dict.merge(success_set_block_dict_tmp, true)
		fail_set_block_list.append_array(fail_set_block_list_tmp)
		for pos_string in success_set_block_dict_tmp:
			var set_time = success_set_block_dict_tmp[pos_string][0]
			var uuid = success_set_block_dict_tmp[pos_string][1]
			var set_block_id = success_set_block_dict_tmp[pos_string][2]
			var set_block_pos = success_set_block_dict_tmp[pos_string][3]
			var set_block_layer = success_set_block_dict_tmp[pos_string][4]
			var is_to_sync = success_set_block_dict_tmp[pos_string][5]
			var chunk_pos = get_chunk_position(set_block_pos)
			var block_to_destroy_id = StaticLoad.get_block_id_by_atlas_coords(tile_map_layer.get_cell_atlas_coords(set_block_pos))
			if block_to_destroy_id == 0:
				block_to_destroy_id = StaticLoad.get_block_id_by_atlas_coords(no_reach_tile_map_layer.get_cell_atlas_coords(set_block_pos))
			var droppped_item_name = StaticLoad.get_dropped_item_by_name(StaticLoad.get_block_name_by_id(block_to_destroy_id))
			if set_block(set_block_pos, set_block_id, set_block_layer):
				if not player.is_frozen:
					if chunk_lights.has(str(chunk_pos[0])+"."+str(chunk_pos[1])):
						if not chunk_light_to_process.has(str(chunk_pos[0])+"."+str(chunk_pos[1])):
							chunk_light_to_process[str(chunk_pos[0])+"."+str(chunk_pos[1])] = "update"
						else:
							chunk_light_to_process_double[str(chunk_pos[0])+"."+str(chunk_pos[1])] = "update"
					else:
						chunk_light_to_process[str(chunk_pos[0])+"."+str(chunk_pos[1])] = "create"
				#if StaticLoad.is_on_mobile_platform:
					#Input.vibrate_handheld(100, 0.5)
				if loaded_chunks.has(str(chunk_pos[0])+"."+str(chunk_pos[1])):
					loaded_chunks[str(chunk_pos[0])+"."+str(chunk_pos[1])] = true
					loaded_chunks_timer[str(chunk_pos[0])+"."+str(chunk_pos[1])] = StaticLoad.CHUNK_FREE_TIME
				var entity = entities[uuid]
				if entity.get_entity_type() == "player":
					if not StaticLoad.is_muti_mode or (StaticLoad.is_muti_mode and StaticLoad.multiplayer.get_unique_id() == entity.player_peer_id):
						set_block_selection_pos(tile_map_layer.map_to_local(set_block_pos), true)
					if set_block_id == 0 and entity.gamemode != "creative":
						if droppped_item_name != "AIR":
							var item_pos = tile_map_layer.map_to_local(set_block_pos)+Vector2(0, 25)
							var summon_item_args = [droppped_item_name, item_pos, 1, 0, 0, UUID.v4()]
							if StaticLoad.is_muti_mode:
								if StaticLoad.multiplayer.get_unique_id() == 1:
									entity.summon_item(summon_item_args)
									StaticLoad.rpc_entity_func_by_uuid(entity.get_uuid(), "summon_item", summon_item_args, "others", true)
							else:
								entity.summon_item(summon_item_args)
						entity.destroy_timer = 0
						if destroy_light_names.has(entity.player_peer_id):
							var old_destroy_light = destroy_light_names[entity.player_peer_id]
							destroy_light_names.erase(entity.player_peer_id)
							old_destroy_light.queue_free()
					elif set_block_id != 0:
						if entity.gamemode != "creative":
							if entity.item_bar_amounts[entity.selected_item_grid] >= 1:
								entity.item_bar_amounts[entity.selected_item_grid] -= 1
							if entity.item_bar_amounts[entity.selected_item_grid] <= 0:
								entity.item_bar_names[entity.selected_item_grid] = "AIR"
								entity.item_bar_amounts[entity.selected_item_grid] = 0
								item_name_timer = 0
							refresh_item_grid(entity.selected_item_grid)
							inventory_show_grids.get_node("InventoryGrid"+str(entity.selected_item_grid)).init_inventory_grid(entity.item_bar_names[entity.selected_item_grid], entity.item_bar_amounts[entity.selected_item_grid])
					if is_to_sync and StaticLoad.multiplayer.get_unique_id() != 1:
						if StaticLoad.multiplayer.get_unique_id() == entity.player_peer_id:
							var player_set_block_info = [set_block_id, set_block_pos, set_block_layer]
							entity.success_set_block_list.append(player_set_block_info)

func dispatch_set_block_state_dict():
	if not StaticLoad.is_muti_mode:
		return
	if not StaticLoad.multiplayer.get_unique_id() == 1:
		return
	for pos_string in success_set_block_dict:
		var set_time = success_set_block_dict[pos_string][0]
		var uuid = success_set_block_dict[pos_string][1]
		var set_block_id = success_set_block_dict[pos_string][2]
		var set_block_pos = success_set_block_dict[pos_string][3]
		var set_block_layer = success_set_block_dict[pos_string][4]
		var is_to_sync = success_set_block_dict[pos_string][5]
		var except_player_id_list = []
		if entities[uuid].get_entity_type() == "player":
			except_player_id_list.append(entities[uuid].player_peer_id)
		StaticLoad.rpc_entity_func_by_uuid(uuid, "set_block", [set_block_id, set_block_pos, set_block_layer], except_player_id_list, false)
		success_set_block_dict.erase(pos_string)
	
	for fail_info in fail_set_block_list:
		var set_time = fail_info[0]
		var uuid = fail_info[1]
		var set_block_id = fail_info[2]
		var set_block_pos = fail_info[3]
		var set_block_layer = fail_info[4]
		var is_to_sync = fail_info[5]
		if entities[uuid].get_entity_type() == "player":
			var player_tmp = entities[uuid]
			var item_bar_names = player_tmp.item_bar_names
			var item_bar_amounts = player_tmp.item_bar_amounts
			StaticLoad.rpc_entity_func_by_uuid(uuid, "fail_set_block", [set_block_id, set_block_pos, set_block_layer, item_bar_names, item_bar_amounts], [player_tmp.player_peer_id], true)
		fail_set_block_list.erase(fail_info)

func process_drop_action():
	var selected_item_grid_tmp = player.selected_item_grid
	if player.item_bar_names[selected_item_grid_tmp] == "AIR":
		return
	if Input.is_action_pressed("drop_item"):
		drop_timer += get_process_delta_time()
	if drop_timer > StaticLoad.DROP_ALL_TIME:
		player.drop_item(player.item_bar_names[selected_item_grid_tmp], player.item_bar_amounts[selected_item_grid_tmp])
		player.item_bar_amounts[selected_item_grid_tmp] = 0
		player.item_bar_names[selected_item_grid_tmp] = "AIR"
		StaticLoad.game.refresh_item_grid(selected_item_grid_tmp)
		inventory_show_grids.get_node("InventoryGrid"+str(selected_item_grid_tmp)).init_inventory_grid(player.item_bar_names[selected_item_grid_tmp], player.item_bar_amounts[selected_item_grid_tmp])
		sound_audio_manager.play_audio_static("player", "pop")
		drop_timer = 0

func update_health_bar():
	if player.gamemode == "creative":
		health_bar.visible = false
	elif player.gamemode == "survival":
		health_bar.visible = true
	if player.is_flying:
		player.is_flying = false
	
func process_light():
	while(true):
		await get_tree().create_timer(0.01).timeout
		var chunk_light_to_process_tmp = chunk_light_to_process.duplicate()
		if chunk_light_to_process_tmp.is_empty():
			if not chunk_light_to_process_double.is_empty():
				chunk_light_to_process = chunk_light_to_process_double.duplicate()
				chunk_light_to_process_double.clear()
			continue
		else:
			for chunk_light_name in chunk_light_to_process_tmp:
				if not chunk_sky_light_datas.has(chunk_light_name):
					continue
				var splits = chunk_light_name.split(".")
				if not chunk_sky_light_datas.has(splits[0]+"."+str(int(splits[1])-1)):
					var sky_light: PackedByteArray
					sky_light.resize(16)
					sky_light.fill(255)
					chunk_sky_light_datas[chunk_light_name] = sky_light
				if chunk_light_to_process_tmp[chunk_light_name] == "create":
					var chunk_light = chunk_light_scene.instantiate()
					lights.add_child(chunk_light)
					chunk_light.name = chunk_light_name.replace(".", "_")
					chunk_light.chunk_pos = Vector2i(int(splits[0]), int(splits[1]))
					chunk_light.init("update")
				else:
					if not chunk_lights.has(chunk_light_name):
						continue
					chunk_lights[chunk_light_name].update_chunk_light(Vector2i(int(splits[0]), int(splits[1])), chunk_light_to_process_tmp[chunk_light_name])
					await chunk_light_updated_signal
				await get_tree().create_timer(0.001).timeout
				chunk_light_to_process.erase(chunk_light_name)
				break

func process_refresh():
	while(true):
		await get_tree().create_timer(0.05).timeout
		if refresh_to_process.is_empty():
			continue
		if refresh_to_process[0] == "refresh_item_grid":
			for i in range(9):
				refresh_item_grid(i)
			refresh_to_process.pop_front()
		elif refresh_to_process[0] == "refresh_inventory":
			refresh_inventory()
			refresh_to_process.pop_front()
		elif refresh_to_process[0] == "refresh_item_name_label":
			item_name_label.text = player.item_bar_names[player.selected_item_grid]
			item_name_timer = StaticLoad.ITEM_NAME_SHOW_TIME
			refresh_to_process.pop_front()

func process_item():
	while(true):
		await get_tree().create_timer(0.001).timeout
		var item_to_combine_tmp = item_to_combine.duplicate()
		if item_to_combine_tmp.is_empty():
			continue
		for item1_uuid in item_to_combine_tmp:
			var item1 = items.get_node(str(item1_uuid))
			if item1 == null:
				item_to_combine.erase(item1_uuid)
				continue
			var item2_uuid = item_to_combine[item1_uuid]
			item1.combine_item(item2_uuid)
			item_to_combine.erase(item1_uuid)
			if StaticLoad.is_muti_mode and StaticLoad.multiplayer.get_unique_id() == 1:
				StaticLoad.rpc_entity_func_by_uuid(item1.get_uuid(), "combine_item", item2_uuid, "others", true)

func dispatch_all_entity_state_dict():
	if not StaticLoad.is_muti_mode:
		return
	if not StaticLoad.multiplayer.get_unique_id() == 1:
		return
	for peer_id in StaticLoad.player_peer_dict:
		var player_tmp = StaticLoad.player_peer_dict[peer_id]
		if player_tmp.is_frozen:
			continue
		if not player_tmp.changed_state_dict.is_empty():
			player_tmp.rectify_changed_state_dict()
			if not player_tmp.player_peer_id == 1:
				player_tmp.apply_changed_state_dict(player_tmp.changed_state_dict)
			StaticLoad.rpc_entity_func_by_uuid(player_tmp.get_uuid(), "apply_changed_state_dict", player_tmp.changed_state_dict, [player_tmp.player_peer_id], false)
			player_tmp.changed_state_dict.clear()
		if not player_tmp.only_server_change_state_dict.is_empty():
			StaticLoad.rpc_entity_func_by_uuid(player_tmp.get_uuid(), "apply_changed_state_dict", player_tmp.only_server_change_state_dict, "others", true)
			player_tmp.only_server_change_state_dict.clear()
	for key in entities:
		var entity = entities[key]
		if entity == null:
			entities.erase(key)
			continue
		if entity.get_entity_type() == "player":
			continue
		if not entity.changed_state_dict.is_empty():
			entity.rectify_changed_state_dict()
			StaticLoad.rpc_entity_func_by_uuid(entity.get_uuid(), "apply_changed_state_dict", entity.changed_state_dict, "others", true)
			entity.changed_state_dict.clear()

func update_mini_map():
	mini_map_camera.position = player.camera.get_screen_center_position()
	var icon_scale = StaticLoad.MINI_MAP_SCALE_FACTOR/mini_map_camera.zoom[0]
	var half_icon_size = StaticLoad.MINI_MAP_ICON_SIZE*icon_scale*0.5
	for player_tmp in players.get_children():
		if player_icons.has(player_tmp.player_name):
			player_icons[player_tmp.player_name].position = player_tmp.position-Vector2(0, half_icon_size)

func open_online_info_ui():
	is_online_info = true
	online_ui.visible = true
	for peer_id in StaticLoad.player_peer_dict:
		if online_ui_vbox_container.has_node(str(peer_id)):
			if peer_id == 1 and StaticLoad.multiplayer.get_unique_id() == 1:
				continue
			elif StaticLoad.multiplayer.get_unique_id() == 1:
				StaticLoad.ping_peer_dict[peer_id].start_ping()
				continue
			StaticLoad.rpc_id(1, "request_for_ping", StaticLoad.multiplayer.get_unique_id(), peer_id)
			continue
		var player_tmp = StaticLoad.player_peer_dict[peer_id]
		var online_info_instance = online_info_scene.instantiate()
		online_ui_vbox_container.add_child(online_info_instance)
		online_info_instance.name = str(peer_id)
		online_info_instance.player_name.text = player_tmp.player_name
		if peer_id == 1 and StaticLoad.multiplayer.get_unique_id() == 1:
			online_info_instance.animation.animation = "signal"
			online_info_instance.animation.frame = StaticLoad.get_level_by_ping(0)
		elif StaticLoad.multiplayer.get_unique_id() == 1:
			StaticLoad.ping_peer_dict[peer_id].start_ping()
		else:
			StaticLoad.rpc_id(1, "request_for_ping", StaticLoad.multiplayer.get_unique_id(), peer_id)

func screenshot():
	await RenderingServer.frame_post_draw
	var image = get_viewport().get_texture().get_image()
	var screenshot_name = Time.get_datetime_string_from_system(false, true).replace(":","-")
	var save_path = StaticLoad.screenshot_path+"/"+screenshot_name+".png"
	image.save_png(save_path)
	broadcast_to_person(player.player_name, tr("SCREENSHOT_SAVED")+screenshot_name+".png")
	
@warning_ignore("unused_parameter")
func _input(event: InputEvent) -> void:
	
	if event is InputEventMouseMotion and not is_input_frozen and not player.is_dead:
		set_block_selection_pos(get_local_mouse_position(), true)
	
	if Input.is_action_just_pressed("esc"):
		if is_chat:
			close_chat_ui()
		elif is_map:
			mini_map.set_anchors_preset(Control.PRESET_TOP_RIGHT)
			mini_map.size = Vector2(270, 270)
			mini_map.position = Vector2(get_viewport_rect().size[0]-270, 0)
			if StaticLoad.is_on_mobile_platform:
				mobile_ui.visible = true
			item_bar_panel.visible = true
			move_input_list.clear()
			player.stop_move()
			is_map = false
			is_input_frozen = false
		elif is_inventory:
			inventory_ui.visible = false
			is_input_frozen = false
			is_inventory = false
			player.stop_move()
		else:
			pause_ui.visible = !pause_ui.visible
			is_pause = pause_ui.visible
			is_input_frozen = is_pause
			if pause_ui.visible:
				move_input_list.clear()
				player.stop_move()
	
	if Input.is_action_just_pressed("inventory"):
		if is_pause:
			pass
		elif is_map:
			mini_map.set_anchors_preset(Control.PRESET_TOP_RIGHT)
			mini_map.size = Vector2(270, 270)
			mini_map.position = Vector2(get_viewport_rect().size[0]-270, 0)
			if StaticLoad.is_on_mobile_platform:
				mobile_ui.visible = true
			item_bar_panel.visible = true
			move_input_list.clear()
			player.stop_move()
			is_map = false
			is_input_frozen = false
		elif is_inventory:
			inventory_ui.visible = false
			is_input_frozen = false
			is_inventory = false
			move_input_list.clear()
			player.stop_move()
		elif not is_chat:
			is_input_frozen = true
			inventory_ui.visible = true
			is_inventory = true
			refresh_inventory()
			move_input_list.clear()
			player.stop_move()
	
	if Input.is_action_just_pressed("open_map"):
		if is_pause or is_chat or is_inventory:
			pass
		elif is_map:
			mini_map.set_anchors_preset(Control.PRESET_TOP_RIGHT)
			mini_map.size = Vector2(270, 270)
			mini_map.position = Vector2(get_viewport_rect().size[0]-270, 0)
			if StaticLoad.is_on_mobile_platform:
				mobile_ui.visible = true
			item_bar_panel.visible = true
			move_input_list.clear()
			player.stop_move()
			is_map = false
			is_input_frozen = false
		else:
			mini_map.set_anchors_preset(Control.PRESET_FULL_RECT)
			mini_map.size = get_viewport_rect().size
			mini_map.position = Vector2(0, 0)
			if StaticLoad.is_on_mobile_platform:
				mobile_ui.visible = false
			item_bar_panel.visible = false
			move_input_list.clear()
			player.stop_move()
			is_map = true
			is_input_frozen = true
	
	if is_input_frozen:
		return
	
	if Input.is_action_just_pressed("screenshot"):
		screenshot()
	
	if StaticLoad.is_muti_mode:
		if Input.is_action_just_pressed("online_info"):
			open_online_info_ui()
			
	if Input.is_action_just_released("online_info"):
		online_ui.visible = false
		is_online_info = false
			
	if Input.is_action_just_pressed("chat"):
		move_input_list.clear()
		player.stop_move()
		is_input_frozen = true
		is_chat = true
		chat_message_out.visible = false
		chat_panel.visible = true
		await get_tree().create_timer(0.001).timeout
		chat_history_in.scroll_vertical = 1e9
		chat_line_edit.grab_focus()
		chat_line_edit.text = ""
	
	if Input.is_action_just_pressed("grab_item"):
		if player.gamemode == "creative":
			var mouse_in_world_pos = tile_map_layer.get_local_mouse_position()
			var mouse_to_block_pos = tile_map_layer.local_to_map(mouse_in_world_pos)
			grab_item(mouse_to_block_pos)
	
	if Input.is_action_just_pressed("chat_slash"):
		move_input_list.clear()
		player.stop_move()
		is_input_frozen = true
		is_chat = true
		chat_message_out.visible = false
		chat_panel.visible = true
		chat_history_in.scroll_vertical = 1e9
		await get_tree().create_timer(0.01).timeout
		chat_line_edit.grab_focus()
		chat_line_edit.insert_text_at_caret("/")
	
	if Input.is_action_just_pressed("switch_ui_visibility"):
		switch_ui_visibility()
	
	if Input.is_action_just_pressed("switch_details_visibility"):
		switch_details_visibility()
	
	if Input.is_action_just_pressed("select_item_grid_1"):
		select_item_grid(1)
	if Input.is_action_just_pressed("select_item_grid_2"):
		select_item_grid(2)
	if Input.is_action_just_pressed("select_item_grid_3"):
		select_item_grid(3)
	if Input.is_action_just_pressed("select_item_grid_4"):
		select_item_grid(4)
	if Input.is_action_just_pressed("select_item_grid_5"):
		select_item_grid(5)
	if Input.is_action_just_pressed("select_item_grid_6"):
		select_item_grid(6)
	if Input.is_action_just_pressed("select_item_grid_7"):
		select_item_grid(7)
	if Input.is_action_just_pressed("select_item_grid_8"):
		select_item_grid(8)
	if Input.is_action_just_pressed("select_item_grid_9"):
		select_item_grid(9)
	
	if Input.is_action_just_released("drop_item"):
		var selected_item_grid_tmp = player.selected_item_grid
		var item_to_drop = player.item_bar_names[selected_item_grid_tmp]
		if drop_timer < StaticLoad.DROP_ALL_TIME and item_to_drop != "AIR":
			sound_audio_manager.play_audio_static("player", "pop")
			player.drop_item(item_to_drop, 1)
			player.item_bar_amounts[selected_item_grid_tmp] -= 1
			if player.item_bar_amounts[selected_item_grid_tmp] <= 0:
				player.item_bar_names[selected_item_grid_tmp] = "AIR"
				player.item_bar_amounts[selected_item_grid_tmp] = 0
			StaticLoad.game.refresh_item_grid(selected_item_grid_tmp)
			inventory_show_grids.get_node("InventoryGrid"+str(selected_item_grid_tmp)).init_inventory_grid(player.item_bar_names[selected_item_grid_tmp], player.item_bar_amounts[selected_item_grid_tmp])
		
func update_inventroy_player_model():
	if not is_inventory:
		return
	var mouse_pos = get_viewport().get_mouse_position()
	var viewport_size = get_viewport_rect().size
	var viewport_half_size = viewport_size/2.0
	var target_pos = mouse_pos-viewport_half_size+Vector2(viewport_size[0]*0.112,viewport_size[1]*0.25)
	inventory_player_model.look_at(Vector3(target_pos[0], -target_pos[1], 3250), Vector3.UP, true)

func process_touch_input():
	if is_input_frozen:
		return
	
	for touch in touch_list:
		if touch.double_tap:
			var block_pos = tile_map_layer.local_to_map(camera_screen_pos_to_local_pos(player.camera, touch.position))
			if check_place_block_state(block_pos, StaticLoad.get_block_id_by_name(player.item_bar_names[player.selected_item_grid])):
				player.place_block(block_pos)
			grab_item(block_pos)
		else:
			var pressed_time = touch_time_counters.get_node(str(touch.index)).timer
			if pressed_time >= StaticLoad.LONG_TOUCH_TIME:
				player.destroy_block(tile_map_layer.local_to_map(camera_screen_pos_to_local_pos(player.camera, touch.position)))

func check_place_block_state(block_pos, block_id):
	if StaticLoad.get_is_untouchable_by_id(block_id):
		return true
	for id in StaticLoad.player_peer_dict:
		var player_tmp = StaticLoad.player_peer_dict[id]
		if player_tmp == null:
			StaticLoad.player_peer_dict.erase(id)
			continue
		var player_pos = tile_map_layer.local_to_map(player_tmp.position - Vector2(0, 0.1))
		if player_pos == block_pos:
			return false
		if player_pos - Vector2i(0, 1) == block_pos:
			return false
	return true

@warning_ignore("unused_parameter")
func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_released("mouse_scroll_down"):
		if Input.is_action_pressed("ctrl"):
			if mini_map_camera.zoom[0] >= 0.2:
				mini_map_camera.zoom -= Vector2(0.1, 0.1)
			if mini_map_camera.zoom[0] < 0.1:
				mini_map_camera.zoom = Vector2(0.1, 0.1)
			var icon_scale = StaticLoad.MINI_MAP_SCALE_FACTOR/mini_map_camera.zoom[0]
			for player_icon in mini_map_players.get_children():
				player_icon.scale = Vector2(icon_scale, icon_scale)
		elif is_online_info:
			pass
		elif is_chat:
			pass
		else:
			if player.selected_item_grid >= 1:
				select_item_grid(player.selected_item_grid)
			else:
				select_item_grid(9)
	
	if Input.is_action_just_released("mouse_scroll_up"):
		if Input.is_action_pressed("ctrl"):
			if mini_map_camera.zoom[0] <= 0.9:
				mini_map_camera.zoom += Vector2(0.1, 0.1)
			if mini_map_camera.zoom[0] > 1:
				mini_map_camera.zoom = Vector2(1, 1)
			var icon_scale = StaticLoad.MINI_MAP_SCALE_FACTOR/mini_map_camera.zoom[0]
			for player_icon in mini_map_players.get_children():
				player_icon.scale = Vector2(icon_scale, icon_scale)
		elif is_online_info:
			pass
		elif is_chat:
			pass
		else:
			if player.selected_item_grid <= 7:
				select_item_grid(player.selected_item_grid+2)
			else:
				select_item_grid(1)
	
	if is_input_frozen:
		return
	
	if event is InputEventScreenTouch:
		if event.pressed:
			touch_list.push_back(event)
			var time_counter_instance = time_counter.instantiate()
			touch_time_counters.add_child(time_counter_instance)
			time_counter_instance.name = str(event.index)
			time_counter_instance.start_counting()
		else:
			var pressed_time = touch_time_counters.get_node(str(event.index)).timer
			if pressed_time < StaticLoad.LONG_TOUCH_TIME:
				var block_pos = tile_map_layer.local_to_map(camera_screen_pos_to_local_pos(player.camera, event.position))
				if check_place_block_state(block_pos, StaticLoad.get_block_id_by_name(player.item_bar_names[player.selected_item_grid])):
					player.place_block(block_pos)
			var touch_to_remove_index
			for i in range(touch_list.size()):
				if touch_list[i].index == event.index:
					touch_to_remove_index = i
					break
			touch_list.remove_at(touch_to_remove_index)
			@warning_ignore("shadowed_variable")
			var time_counter = touch_time_counters.get_node(str(event.index))
			time_counter.stop_counting()
			time_counter.queue_free()	
	
	if event is InputEventScreenDrag:
		for touch in touch_list:
			if touch.index == event.index:
				touch.position = event.position
				break

	if event is InputEventMouseMotion:
		is_mouse_motion_updated = true

func process_mouse_action():
	if player.is_dead:
		return
	var mouse_in_world_pos = tile_map_layer.get_local_mouse_position()
	var mouse_to_block_pos = tile_map_layer.local_to_map(mouse_in_world_pos)
	if not is_pause and not is_chat and not is_inventory:
		if Input.is_mouse_button_pressed(1) and not Input.is_mouse_button_pressed(2):
			if player.gamemode == "creative":
				player.destroy_block(mouse_to_block_pos)
			else:
				player.destroy_timer += get_process_delta_time()
		elif Input.is_mouse_button_pressed(2) and not Input.is_mouse_button_pressed(1):
			player.place_block(mouse_to_block_pos)
	
	if not StaticLoad.is_on_mobile_platform and not Input.is_mouse_button_pressed(1):
		player.destroy_timer = 0
		if destroy_light_names.has(player.player_peer_id):
			var old_destroy_light = destroy_light_names[player.player_peer_id]
			destroy_light_names.erase(player.player_peer_id)
			old_destroy_light.queue_free()
	
	if is_mouse_motion_updated:
		if mouse_to_block_pos != tile_map_layer.local_to_map(last_mouse_in_world_pos):
			player.destroy_timer = 0
			if destroy_light_names.has(player.player_peer_id):
				var old_destroy_light = destroy_light_names[player.player_peer_id]
				destroy_light_names.erase(player.player_peer_id)
				old_destroy_light.queue_free()
		is_mouse_motion_updated = false
	last_mouse_in_world_pos = mouse_in_world_pos

func update_resource_pack():
	tile_map_layer.tile_set = load("res://Assets/TileSets/"+str(resource_pack)+".tres") as TileSet
	back_tile_map_layer.tile_set = load("res://Assets/TileSets/"+str(resource_pack)+".tres") as TileSet
	no_reach_tile_map_layer.tile_set = load("res://Assets/TileSets/"+str(resource_pack)+".tres") as TileSet
	mini_map_tile_map_layer.tile_set = load("res://Assets/TileSets/"+str(resource_pack)+".tres") as TileSet
	mini_map_back_tile_map_layer.tile_set = load("res://Assets/TileSets/"+str(resource_pack)+".tres") as TileSet
	mini_map_no_reach_tile_map_layer.tile_set = load("res://Assets/TileSets/"+str(resource_pack)+".tres") as TileSet

func init_inventory_tabs():
	for tab_name in StaticLoad.tab_panels:
		var tab_panel = tab_panel_scene.instantiate()
		inventory_tabs.add_child(tab_panel)
		tab_panel.name = tab_name+"Tab"
		tab_panel.init_tab_panel(StaticLoad.tab_panels[tab_name], tab_name)
		if tab_name == "Inventory":
			tab_panel.z_index = 1
			tab_panel.dark_mask.visible = false

func update_destroy_ui():
	for peer_id in StaticLoad.player_peer_dict:
		if StaticLoad.player_peer_dict[peer_id] == null:
			StaticLoad.player_peer_dict.erase(peer_id)
			continue
		var player_tmp = StaticLoad.player_peer_dict[peer_id]
		var player_selected_block_pos = player_tmp.selected_block_pos
		var atlas_coords = tile_map_layer.get_cell_atlas_coords(player_selected_block_pos)
		var block_id = StaticLoad.get_block_id_by_atlas_coords(atlas_coords)
		if block_id == 0:
			atlas_coords = no_reach_tile_map_layer.get_cell_atlas_coords(player_selected_block_pos)
			block_id = StaticLoad.get_block_id_by_atlas_coords(atlas_coords)
			if block_id == 0:
				continue
		var destroy_timer_tmp = StaticLoad.player_peer_dict[peer_id].destroy_timer
		if destroy_timer_tmp <= 0:
			if destroy_light_names.has(peer_id):
				var old_destroy_light = destroy_light_names[peer_id]
				destroy_light_names.erase(peer_id)
				old_destroy_light.queue_free()
			continue
		var tool = player.item_bar_names[player.selected_item_grid]
		var destroy_total_time = StaticLoad.get_destroy_total_time(block_id, tool)
		var block_name = StaticLoad.get_block_name_by_id(block_id)
		if StaticLoad.special_block_destroy_time.has(block_name):
			destroy_total_time = StaticLoad.special_block_destroy_time[block_name]
		if destroy_total_time < 0:
			continue
		var destroy_sort = int((destroy_timer_tmp/destroy_total_time)*8)+1
		#if player_tmp.destroy_timer != destroy_timer_tmp:
			#if StaticLoad.is_muti_mode and StaticLoad.multiplayer.get_unique_id() == player_tmp.player_peer_id:
				#var state_tmp = {"destroy_timer" : player_tmp.state_dict["destroy_timer"]}
				#if player_tmp.player_peer_id == 1:
					#StaticLoad.rpc_entity_func_by_uuid(player_tmp.get_uuid(), "apply_changed_state_dict", state_tmp, "others", true)
				#else:
					#StaticLoad.rpc_entity_func_by_uuid(player_tmp.get_uuid(), "set_changed_state_dict", state_tmp, [], true)
		if int((destroy_timer_tmp-0.08)*100) % int(StaticLoad.DIG_SOUND_DELTA*100) == 0:
			sound_audio_manager.play_random_audio_at_position("dig", StaticLoad.get_block_type_by_id(block_id), tile_map_layer.map_to_local(player_selected_block_pos), 0.7)
		if destroy_sort > 0 and destroy_sort < 9:
			player_tmp.is_punching = true
		if destroy_sort >= 9:
			player_tmp.destroy_block(player_selected_block_pos)
			if StaticLoad.is_muti_mode and StaticLoad.multiplayer.get_unique_id() == player_tmp.player_peer_id:
				player_tmp.state_dict["destroy_timer"] = 0
			continue
		elif not destroy_light_names.has(peer_id) or destroy_sort != destroy_light_names[peer_id].sort:
			if destroy_light_names.has(peer_id):
				if destroy_light_names[peer_id].sort != destroy_sort:
					var old_destroy_light = destroy_light_names[peer_id]
					destroy_light_names.erase(peer_id)
					old_destroy_light.queue_free()
					var destroy_light = destory_light_scene.instantiate()
					destroy_light_names[peer_id] = destroy_light
					lights.add_child(destroy_light)
					destroy_light.init_light(str(peer_id), player_selected_block_pos, destroy_sort)
			else:
				if destroy_light_names.has(peer_id):
					var old_destroy_light = destroy_light_names[peer_id]
					destroy_light_names.erase(peer_id)
					old_destroy_light.queue_free()
				var destroy_light = destory_light_scene.instantiate()
				destroy_light_names[peer_id] = destroy_light
				lights.add_child(destroy_light)
				destroy_light.init_light(str(peer_id), player_selected_block_pos, destroy_sort)

func init_light():
	for chunk_light_name in chunk_lights:
		chunk_lights[chunk_light_name].queue_free()
	chunk_lights.clear()
	for chunk_light_name in loaded_chunks:
		var chunk_light = chunk_light_scene.instantiate()
		lights.add_child(chunk_light)
		chunk_light.name = chunk_light_name.replace(".", "_")
		var splits = chunk_light_name.split(".")
		chunk_light.chunk_pos = Vector2i(int(splits[0]), int(splits[1]))
		chunk_light.init("null")

func update_mini_map_chunk_light(chunk_pos, image):
	var chunk_light_name = str(chunk_pos[0])+"."+str(chunk_pos[1])
	if mini_map_chunk_lights.has(chunk_light_name):
		mini_map_chunk_lights[chunk_light_name].queue_free()
		mini_map_chunk_lights.erase(chunk_light_name)
	var chunk_light = chunk_light_scene.instantiate()
	mini_map_lights.add_child(chunk_light)
	chunk_light.name = chunk_light_name.replace(".", "_")
	chunk_light.chunk_pos = chunk_pos
	chunk_light.update_texture_from_image(image)
	mini_map_chunk_lights[chunk_light_name] = chunk_light

func grab_item(block_pos):
	var block_id = StaticLoad.get_block_id_by_atlas_coords(tile_map_layer.get_cell_atlas_coords(block_pos))
	if block_id == 0:
		block_id = StaticLoad.get_block_id_by_atlas_coords(no_reach_tile_map_layer.get_cell_atlas_coords(block_pos))
	var player_select_sort = player.selected_item_grid
	if block_id == 0:
		return
	if block_id == StaticLoad.get_block_id_by_name(player.item_bar_names[player.selected_item_grid]):
		return
	var existed_item_grid_sort = -1
	for i in range(9):
		if StaticLoad.get_block_id_by_name(player.item_bar_names[i]) == block_id:
			existed_item_grid_sort = i
			break
	if player_select_sort == existed_item_grid_sort:
		return
	if existed_item_grid_sort != -1:
		select_item_grid(existed_item_grid_sort+1)
	else:
		player.item_bar_names[player_select_sort] = StaticLoad.get_block_name_by_id(block_id)
		player.item_bar_amounts[player_select_sort] = 1
		refresh_item_grid(player_select_sort)
		@warning_ignore("shadowed_variable")
		var inventory_grid = inventory_show_grids.get_node("InventoryGrid"+str(player_select_sort))
		inventory_grid.init_inventory_grid(player.item_bar_names[player_select_sort], player.item_bar_amounts[player_select_sort])
		sound_audio_manager.play_audio_static("player", "pop")
		item_name_label.text = player.item_bar_names[player_select_sort]
		item_name_timer = StaticLoad.ITEM_NAME_SHOW_TIME
	
func remove_outdated_chunks():
	is_chunk_modifing = true
	if StaticLoad.is_muti_mode and StaticLoad.multiplayer.get_unique_id() != 1:
		var player_block_pos = tile_map_layer.local_to_map(player.position-Vector2(0,24))
		var chunk_pos_tmp = get_chunk_position(player_block_pos)
		var x_player_chunk = chunk_pos_tmp[0]
		var y_player_chunk = chunk_pos_tmp[1]
		for x in range(x_player_chunk-player.render_chunk, x_player_chunk+player.render_chunk+1):
			for y in range(y_player_chunk-player.render_chunk, y_player_chunk+player.render_chunk+1):	
				if loaded_chunks.has(str(x)+"."+str(y)):
					loaded_chunks_timer[str(x)+"."+str(y)] = StaticLoad.CHUNK_FREE_TIME
	else:
		for player_tmp in players.get_children():
			var player_block_pos = tile_map_layer.local_to_map(player_tmp.position-Vector2(0,24))
			var chunk_pos_tmp = get_chunk_position(player_block_pos)
			var x_player_chunk = chunk_pos_tmp[0]
			var y_player_chunk = chunk_pos_tmp[1]
			for x in range(x_player_chunk-player_tmp.render_chunk, x_player_chunk+player_tmp.render_chunk+1):
				for y in range(y_player_chunk-player_tmp.render_chunk, y_player_chunk+player_tmp.render_chunk+1):	
					if loaded_chunks.has(str(x)+"."+str(y)):
						loaded_chunks_timer[str(x)+"."+str(y)] = StaticLoad.CHUNK_FREE_TIME
	var to_removed_timers = []
	for key in loaded_chunks_timer.keys():
		loaded_chunks_timer[key] -= get_process_delta_time()
		if loaded_chunks_timer[key] <= 0:
			to_removed_timers.push_back(key)
	for timer in to_removed_timers:
		var splits = timer.split(".")
		var chunk_pos = Vector2i(int(splits[0]), int(splits[1]))
		if not StaticLoad.is_muti_mode or (StaticLoad.is_muti_mode and StaticLoad.multiplayer.get_unique_id() == 1):
			save_chunk(chunk_pos)
		loaded_chunks.erase(timer)
		loaded_chunks_timer.erase(timer)
		free_chunk(chunk_pos)
	is_chunk_modifing = false

func camera_screen_pos_to_local_pos(camera, pos):
	var inv_canv_tfm: Transform2D = camera.get_canvas_transform().affine_inverse()
	var half_screen: Transform2D = Transform2D().translated(pos)
	var actual_screen_center_pos: Vector2 = inv_canv_tfm * half_screen * Vector2(0, 0)
	return actual_screen_center_pos

func init_game_as_dedicated_server():
	var worlds_path = "user://worlds"
	var world_config = ConfigFile.new()
	var world_info = world_config.load_encrypted_pass(worlds_path+"/"+StaticLoad.select_world+"/level.dat", StaticLoad.CONFIG_PASSWORD)
	if world_info != OK:
		return
	world_info_dictionary["version"] = world_config.get_value("world", "version", StaticLoad.options["version"])
	world_info_dictionary["seed"] = world_config.get_value("world", "seed", "1241999312")
	world_info_dictionary["world_type"] = world_config.get_value("world", "world_type", "default")
	world_info_dictionary["gamemode"] = world_config.get_value("world", "gamemode", "survival")
	var regions = DirAccess.get_files_at(ProjectSettings.globalize_path(StaticLoad.region_path))
	if regions.is_empty():
		return
	for region in regions:
		var splits = region.split(".")
		database_chunks.push_back(splits[1]+"."+splits[2])
	total_chunk_num = 1
	loaded_chunk_num = 1
	item_thread.start(process_item)
	tick_cycle_thread.start(process_tick_cycle)
	dispatch_thread.start(process_dispatch)
	set_block_thread.start(process_set_block)

func init_game_as_single():
	var config = ConfigFile.new()
	var result = config.load("user://configs.cfg")
	var player_name_tmp
	var render_chunk_tmp = 1
	if result == OK:
		player_name_tmp = config.get_value("options", "player_name", StaticLoad.options["player_name"])
		render_chunk_tmp = int(config.get_value("options", "render_chunk", StaticLoad.options["render_chunk"]))
		block_selection_box = config.get_value("options", "block_selection_box", StaticLoad.options["block_selection_box"])
		mini_map_on = config.get_value("options", "mini_map", StaticLoad.options["mini_map"])
		mini_map_zoom = float(config.get_value("options", "mini_map_zoom", StaticLoad.options["mini_map_zoom"]))
		bgm_audio_player.volume_db = linear_to_db(int(config.get_value("options", "bgm_volume", StaticLoad.options["bgm_volume"]))/50.0)
		sound_audio_manager.volume_db = linear_to_db(int(config.get_value("options", "sound_volume", StaticLoad.options["sound_volume"]))/50.0)
		resource_pack = config.get_value("options", "resource_pack")
		var mini_map_zoom_tmp = mini_map_zoom/100
		mini_map_camera.zoom = Vector2(mini_map_zoom_tmp, mini_map_zoom_tmp)
		var icon_scale = StaticLoad.MINI_MAP_SCALE_FACTOR/mini_map_camera.zoom[0]
		for player_icon in mini_map_players.get_children():
			player_icon.scale = Vector2(icon_scale, icon_scale)
		if mini_map_on == "off":
			mini_map.visible = false
		elif mini_map_on == "on":
			mini_map.visible = true
		#player.player_name = config.get_value("options", "player_name", StaticLoad.options["player_name"])
		#player.name_label.text = player.player_name
		#var fov_zoom = 1+1.6*(int(config.get_value("options", "fov_zoom", StaticLoad.options["fov_zoom"]))/100.0)
		#player.camera.zoom = Vector2(fov_zoom, fov_zoom)
		#update_game_details(true)
	var worlds_path = "user://worlds"
	var world_config = ConfigFile.new()
	var world_info = world_config.load_encrypted_pass(worlds_path+"/"+StaticLoad.select_world+"/level.dat", StaticLoad.CONFIG_PASSWORD)
	if world_info != OK:
		return
	world_info_dictionary["version"] = world_config.get_value("world", "version", StaticLoad.options["version"])
	world_info_dictionary["seed"] = world_config.get_value("world", "seed", "1241999312")
	world_info_dictionary["world_type"] = world_config.get_value("world", "world_type", "default")
	world_info_dictionary["gamemode"] = world_config.get_value("world", "gamemode", "survival")
	var regions = DirAccess.get_files_at(ProjectSettings.globalize_path(StaticLoad.region_path))
	if regions.is_empty():
		return
	for region in regions:
		var splits = region.split(".")
		database_chunks.push_back(splits[1]+"."+splits[2])
	var player_config = ConfigFile.new()
	var player_position_tmp = Vector2(0, 1)
	if FileAccess.file_exists(StaticLoad.player_path+"/"+player_name_tmp.to_lower()+".dat"):
		var player_result = player_config.load_encrypted_pass(StaticLoad.player_path+"/"+player_name_tmp.to_lower()+".dat", StaticLoad.CONFIG_PASSWORD)
		if player_result == OK:
			player_position_tmp = player_config.get_value("player", "position", StaticLoad.DEFAULT_PLAYER_SPAWN_POS)
	var chunk_pos = get_chunk_position(tile_map_layer.local_to_map(player_position_tmp))
	var x_player_chunk = chunk_pos[0]
	var y_player_chunk = chunk_pos[1]
	var count = 0
	count += range(x_player_chunk-render_chunk_tmp, x_player_chunk+render_chunk_tmp+1).size()
	count += range(y_player_chunk-render_chunk_tmp, y_player_chunk+render_chunk_tmp+1).size()
	total_chunk_num = count
	var loaded_success_chunk_list = []
	for x in range(x_player_chunk-render_chunk_tmp, x_player_chunk+render_chunk_tmp+1):
		for y in range(y_player_chunk-render_chunk_tmp, y_player_chunk+render_chunk_tmp+1):
			var chunk_config = ConfigFile.new()
			var chunk_result = chunk_config.load_encrypted_pass(StaticLoad.region_path+"/r."+str(x)+"."+str(y)+".mca", StaticLoad.CONFIG_PASSWORD)
			if chunk_result != OK:
				continue
			loaded_success_chunk_list.append(str(x)+"."+str(y))
			var blocks = chunk_config.get_value("chunk", "blocks")
			var no_reach_blocks = chunk_config.get_value("chunk", "no_reach_blocks")
			var back_blocks = chunk_config.get_value("chunk", "back_blocks")
			set_chunk(Vector2i(x, y), [blocks, no_reach_blocks, back_blocks])
			loaded_chunks[str(x)+"."+str(y)] = false
			loaded_chunks_timer[str(x)+"."+str(y)] = StaticLoad.CHUNK_FREE_TIME
			loaded_chunk_num += 1
	for x in range(x_player_chunk-render_chunk_tmp, x_player_chunk+render_chunk_tmp+1):
		var min_y: int = 2000000
		for chunk_name in loaded_success_chunk_list:
			var splits = chunk_name.split(".")
			if int(splits[0]) != x:
				continue
			if int(splits[1]) < min_y:
				min_y = int(splits[1])
		var sky_light: PackedByteArray
		sky_light.resize(16)
		sky_light.fill(255)
		chunk_sky_light_datas[str(x)+"."+str(min_y)] = sky_light
	set_block_selection_pos(get_local_mouse_position())
	update_resource_pack()
	init_inventory_tabs()
	init_infinite_container()
	init_light()
	item_thread.start(process_item)
	tick_cycle_thread.start(process_tick_cycle)
	dispatch_thread.start(process_dispatch)
	set_block_thread.start(process_set_block)
	light_thread.start(process_light)
	refresh_thread.start(process_refresh)

func init_game_as_client():
	StaticLoad.select_world = "new world"
	StaticLoad.update_select_world_path()
	StaticLoad.rpc_id(1, "request_for_player_info", StaticLoad.multiplayer.get_unique_id(), player.player_name)
	StaticLoad.rpc_id(1, "request_for_update_player_inventory", StaticLoad.multiplayer.get_unique_id(), player.player_name)
	while not is_player_info_updated:
		await get_tree().create_timer(1).timeout
	var config = ConfigFile.new()
	var result = config.load("user://configs.cfg")
	if result != OK:
		return
	player.render_chunk = int(config.get_value("options", "render_chunk", StaticLoad.options["render_chunk"]))
	if player.render_chunk > StaticLoad.RENDER_CHUNK_MAX:
		player.render_chunk = StaticLoad.RENDER_CHUNK_MAX
	if player.render_chunk < StaticLoad.RENDER_CHUNK_MIN:
		player.render_chunk = StaticLoad.RENDER_CHUNK_MIN
	resource_pack = config.get_value("options", "resource_pack")
	block_selection_box = config.get_value("options", "block_selection_box", StaticLoad.options["block_selection_box"])
	mini_map_on = config.get_value("options", "mini_map", StaticLoad.options["mini_map"])
	mini_map_zoom = float(config.get_value("options", "mini_map_zoom", StaticLoad.options["mini_map_zoom"]))
	bgm_audio_player.volume_db = linear_to_db(int(config.get_value("options", "bgm_volume", StaticLoad.options["bgm_volume"]))/50.0)
	sound_audio_manager.volume_db = linear_to_db(int(config.get_value("options", "sound_volume", StaticLoad.options["sound_volume"]))/50.0)
	var mini_map_zoom_tmp = mini_map_zoom/100
	mini_map_camera.zoom = Vector2(mini_map_zoom_tmp, mini_map_zoom_tmp)
	var icon_scale = StaticLoad.MINI_MAP_SCALE_FACTOR/mini_map_camera.zoom[0]
	for player_icon in mini_map_players.get_children():
		player_icon.scale = Vector2(icon_scale, icon_scale)
	if mini_map_on == "off":
		mini_map.visible = false
	elif mini_map_on == "on":
		mini_map.visible = true
	var player_pos = tile_map_layer.local_to_map(player.position)
	var chunk_pos = get_chunk_position(player_pos)
	var x_player_chunk = chunk_pos[0]
	var y_player_chunk = chunk_pos[1]
	var loading_chunk_total_sum = 0
	for x in range(x_player_chunk-player.render_chunk, x_player_chunk+player.render_chunk+1):
		for y in range(y_player_chunk-player.render_chunk, y_player_chunk+player.render_chunk+1):
			loading_chunk_total_sum += 1
	total_chunk_num = loading_chunk_total_sum
	for x in range(x_player_chunk-player.render_chunk, x_player_chunk+player.render_chunk+1):
		for y in range(y_player_chunk-player.render_chunk, y_player_chunk+player.render_chunk+1):
			StaticLoad.rpc_id(1, "request_for_update_chunk", StaticLoad.multiplayer.get_unique_id(), true, x, y)
	set_block_selection_pos(get_local_mouse_position())
	update_resource_pack()
	init_inventory_tabs()
	init_infinite_container()
	set_block_thread.start(process_set_block)
	light_thread.start(process_light)
	tick_cycle_thread.start(process_tick_cycle)
	dispatch_thread.start(process_dispatch)
	refresh_thread.start(process_refresh)

func create_player(peer_id = 1):
	var player_instance = player_scene.instantiate()
	player_instance.name = str(peer_id)
	players.add_child(player_instance)
	if not StaticLoad.is_muti_mode:
		player = player_instance
		player.init_local(peer_id)
	elif peer_id == StaticLoad.multiplayer.get_unique_id():
		player = player_instance
		player.init_local(peer_id)
	else:
		player_instance.is_other = true
		var tween1 = get_tree().create_tween()
		tween1.tween_method(player_instance.set_shader_transparent_intensity, 1.0, 0.0, StaticLoad.TELEPORT_TIME/2.0)
		var tween2 = get_tree().create_tween()
		tween2.tween_method(player_instance.set_name_label_modulate, Color(1,1,1,0), Color(1,1,1,1), StaticLoad.TELEPORT_TIME/2.0)
		var tween3 = get_tree().create_tween()
		tween3.tween_method(player_instance.set_shader_blink_intensity, -1.0, 0.0, StaticLoad.TELEPORT_TIME/2.0)
	if StaticLoad.is_dedicated_server:
		player_instance.unfreeze()
	players.move_child(player,-1)
	entities[player_instance.get_uuid()] = player_instance

func refresh_item_grid(sort):
	var item_name = player.item_bar_names[sort]
	var item_amount = player.item_bar_amounts[sort]
	if item_name == "AIR":
		item_grids[sort].get_node("ItemIcon").visible = false
		item_grids[sort].get_node("Amount").text = ""
	else:
		item_grids[sort].get_node("ItemIcon").init_icon(player.item_bar_names[sort].to_lower())
		item_grids[sort].get_node("ItemIcon").visible = true
		if item_amount <= 1:
			item_grids[sort].get_node("Amount").text = ""
		else:
			item_grids[sort].get_node("Amount").text = str(item_amount)

func rectify_emulate_mouse_from_touch():
	if is_input_frozen:
		if not Input.emulate_mouse_from_touch:
			Input.emulate_mouse_from_touch = true
	else:
		if Input.emulate_mouse_from_touch:
			Input.emulate_mouse_from_touch = false

func freeze_game():
	set_process_unhandled_input(false)
	set_process(false)
	bgm_audio_player.stream_paused = true

func unfreeze_game():
	set_process_unhandled_input(true)
	set_process(true)
	bgm_audio_player.stream_paused = false
	player.camera.position_smoothing_enabled = true

func update_local_player_nearby_chunk():
	if update_chunk_timer > 0:
		update_chunk_timer -= get_process_delta_time()
	else:
		update_chunk_timer = StaticLoad.UPDATE_CHUNK_TIME
		update_new_chunk(false)

func update_jump_button():
	if player.is_flying:
		move_jump_button_icon.texture = move_center_button_fly
	else:
		move_jump_button_icon.texture = jump_button_normal

func update_local_player_data():
	if player.is_dead or player.is_frozen or is_input_frozen:
		return
	#if StaticLoad.is_muti_mode and not player.is_multiplayer_authority():
		#return
	
	if Input.is_action_pressed("down"):
		player.is_down_pressed = true
	else:
		player.is_down_pressed = false
		
	if Input.is_action_pressed("jump"):
		player.is_jump_pressed = true
	else:
		player.is_jump_pressed = false
		
	if Input.is_action_just_pressed("jump") and StaticLoad.get_can_fly_from_gamemode(player.gamemode):
		var current_time = Time.get_ticks_msec() / 1000.0
		if current_time - last_jump_time < StaticLoad.DOUBLE_CLICK_THRESHOLD:
			player.is_flying = not player.is_flying
			update_jump_button()
			#if StaticLoad.is_muti_mode:
				#var state_tmp = {"is_flying" : player.state_dict["is_flying"]}
				#if StaticLoad.multiplayer.get_unique_id() == 1:
					#StaticLoad.rpc_entity_func_by_uuid(player.get_uuid(), "apply_changed_state_dict", state_tmp, "others", true)
				#else:
					#StaticLoad.rpc_entity_func_by_uuid(player.get_uuid(), "apply_changed_state_dict", state_tmp, [player.player_peer_id], false)
		last_jump_time = current_time
	
	if Input.is_action_just_pressed("move_left"):
		move_input_list.push_back("left")
		var current_time = Time.get_ticks_msec() / 1000.0
		if current_time - last_left_time < StaticLoad.DOUBLE_CLICK_THRESHOLD:
			player.move_state = "run"
		else:
			player.move_state = "walk"
		last_left_time = current_time
	if Input.is_action_just_released("move_left"):
		var index_to_remove = move_input_list.find("left")
		if index_to_remove != -1:
			move_input_list.remove_at(index_to_remove)
		
	if Input.is_action_just_pressed("move_right"):
		move_input_list.push_back("right")
		var current_time = Time.get_ticks_msec() / 1000.0
		if current_time - last_right_time < StaticLoad.DOUBLE_CLICK_THRESHOLD:
			player.move_state = "run"
		else:
			player.move_state = "walk"
		last_right_time = current_time
	if Input.is_action_just_released("move_right"):
		var index_to_remove = move_input_list.find("right")
		if index_to_remove != -1:
			move_input_list.remove_at(index_to_remove)
		
	if move_input_list.is_empty():
		player.move_state = "idle"
		
	if not move_input_list.is_empty():
		if move_input_list.back() == "left":
			player.face_state = -1
		elif move_input_list.back() == "right":
			player.face_state = 1

func init_infinite_container():
	var count = 0
	for block in StaticLoad.block_ids:
		if block == "AIR":
			continue
		if block == "MISSING_TEXTURE":
			continue
		var inventory_grid = inventory_grid_scene.instantiate()
		inventory_grid.name = "InfiniteGrid"+str(count)
		blocks_infinite_container.add_child(inventory_grid)
		inventory_grid.init_inventory_grid(block, 1)
		count += 1
	count = 0
	for item in StaticLoad.item_model_types:
		if item == "AIR":
			continue
		if item == "MISSING_TEXTURE":
			continue
		if StaticLoad.block_ids.has(item):
			continue
		var inventory_grid = inventory_grid_scene.instantiate()
		inventory_grid.name = "InfiniteGrid"+str(count)
		items_infinite_container.add_child(inventory_grid)
		inventory_grid.init_inventory_grid(item, 1)
		count += 1

func close_chat_ui():
	is_chat = false
	is_input_frozen = false
	chat_panel.visible = false
	chat_message_out.visible = true
	await get_tree().create_timer(0.01).timeout
	chat_history_in.scroll_vertical = 1e9
	chat_history_out.scroll_vertical = 1e9
	chat_line_edit.text = ""

func update_game_details(is_pre_load: bool = false):
	if is_pre_load:
		details_player_name.text = tr("PLAYER_NAME")+" : "+player.player_name
	var pos = tile_map_layer.local_to_map(player.position-Vector2(0,24))
	details_position.text = tr("POSITON")+" : x="+str(pos[0])+", y="+str(-pos[1])
	var selected_pos = tile_map_layer.local_to_map(tile_map_layer.get_local_mouse_position())
	details_selected_position.text = tr("SELECTED_POSITION")+" : x="+str(selected_pos[0])+", y="+str(-selected_pos[1])
	var chunk = get_chunk_position(pos)
	details_chunk.text = tr("CHUNK")+" : x="+str(chunk[0])+", y="+str(-chunk[1])
	var fps = Engine.get_frames_per_second()
	details_fps.text = tr("FPS")+" : "+str(fps)

func update_block_selection():
	if block_selection_box == "show_when_changing":
		if is_input_frozen:
			block_selection_timer = 0
		if block_selection_timer > 0 and block_selection_timer <= StaticLoad.BLOCK_SELECTION_DISAPPEAR_TIME:
			var alpha = block_selection_timer/StaticLoad.BLOCK_SELECTION_DISAPPEAR_TIME
			block_selection_ui.self_modulate = Color(1,1,1,alpha)
		elif block_selection_timer > StaticLoad.BLOCK_SELECTION_DISAPPEAR_TIME:
			block_selection_ui.self_modulate = Color(1,1,1,1)
		else:
			block_selection_ui.self_modulate = Color(1,1,1,0)
		if block_selection_timer > 0:
			block_selection_timer -= get_process_delta_time()
	elif block_selection_box == "always_show":
		block_selection_ui.self_modulate = Color(1,1,1,1)
	elif block_selection_box == "never_show":
		block_selection_ui.self_modulate = Color(1,1,1,0)
	
	if not StaticLoad.is_on_mobile_platform:
		set_block_selection_pos(get_local_mouse_position())
	
func set_block_selection_pos(pos, is_timer_refresh = false):
	var x_offset = 25
	var y_offset = -25
	if pos.x < 0:
		x_offset = -25
	if pos.y > 0:
		y_offset = 25
	var block_x_offset = -1
	var block_y_offset = -1
	if pos.x > 0:
		block_x_offset = 0
	if pos.y > 0:
		block_y_offset = 0
	@warning_ignore("integer_division")
	var block_pos = Vector2i(int(pos.x)/50+block_x_offset, int(pos.y)/50+block_y_offset)
	@warning_ignore("integer_division")
	block_selection_ui.position = Vector2((int(pos.x)/50)*50+x_offset, (int(pos.y)/50)*50+y_offset)
	if player != null and player.selected_block_pos != block_pos:
		player.selected_block_pos = block_pos
		#if StaticLoad.is_muti_mode:
			#var state_tmp = {"selected_block_pos" : player.state_dict["selected_block_pos"]}
			#if StaticLoad.multiplayer.get_unique_id() == 1:
				#StaticLoad.rpc_entity_func_by_uuid(player.get_uuid(), "apply_changed_state_dict", state_tmp, "others", true)
			#else:
				#StaticLoad.rpc_entity_func_by_uuid(player.get_uuid(), "apply_changed_state_dict", state_tmp, [player.player_peer_id], false)
	if is_timer_refresh:
		block_selection_timer = StaticLoad.BLOCK_SELECTION_TIME

func switch_details_visibility():
	details.visible = not details.visible

func switch_ui_visibility():
	game_ui.visible = not game_ui.visible
	block_selection_ui.visible = game_ui.visible
	for peer_id in StaticLoad.player_peer_dict:
		StaticLoad.player_peer_dict[peer_id].name_label.visible = game_ui.visible

func update_item_bar_text():
	if item_name_timer < 0:
		return
	var alpha: float = 1
	if item_name_timer <= StaticLoad.ITEM_NAME_DISAPPEAR_TIME:
		alpha = item_name_timer/StaticLoad.ITEM_NAME_DISAPPEAR_TIME
	item_name_label.self_modulate = Color(1,1,1,alpha)
	item_name_timer -= get_process_delta_time()
	if item_name_timer < 0:
		item_name_label.self_modulate = Color(1,1,1,0)

func get_chunk_position(block_pos: Vector2i):
	var block_pos_tmp = Vector2i(block_pos)
	if block_pos[0] < 0:
		block_pos_tmp[0] += 1
	if block_pos[1] < 0:
		block_pos_tmp[1] += 1
	@warning_ignore("integer_division")
	var x_chunk = block_pos_tmp[0]/16
	@warning_ignore("integer_division")
	var y_chunk = block_pos_tmp[1]/16
	if block_pos[0] < 0:
		x_chunk -= 1
	if block_pos[1] < 0:
		y_chunk -= 1
	return Vector2i(x_chunk, y_chunk)

func update_new_chunk(is_pre_load: bool):
	var player_pos = tile_map_layer.local_to_map(player.position)
	var chunk_pos = get_chunk_position(player_pos)
	var x_player_chunk = chunk_pos[0]
	var y_player_chunk = chunk_pos[1]
	if is_pre_load or player_last_chunk != Vector2i(x_player_chunk, y_player_chunk):
		for x in range(x_player_chunk-player.render_chunk, x_player_chunk+player.render_chunk+1):
			for y in range(y_player_chunk-player.render_chunk, y_player_chunk+player.render_chunk+1):
				if not loaded_chunks.has(str(x)+"."+str(y)):
					if StaticLoad.is_muti_mode and StaticLoad.multiplayer.get_unique_id() != 1:
						StaticLoad.rpc_id(1, "request_for_update_chunk", StaticLoad.multiplayer.get_unique_id(), false, x, y)
						loaded_chunks[str(x)+"."+str(y)] = false #防止重复向服务器发送申请
						loaded_chunks_timer[str(x)+"."+str(y)] = StaticLoad.CHUNK_FREE_TIME
					else:
						if database_chunks.has(str(x)+"."+str(y)):
							var chunk_config = ConfigFile.new()
							var chunk_result = chunk_config.load_encrypted_pass(StaticLoad.region_path+"/r."+str(x)+"."+str(y)+".mca", StaticLoad.CONFIG_PASSWORD)
							if chunk_result != OK:
								return
							var blocks = chunk_config.get_value("chunk", "blocks")
							var no_reach_blocks = chunk_config.get_value("chunk", "no_reach_blocks")
							var back_blocks = chunk_config.get_value("chunk", "back_blocks")
							set_chunk(Vector2i(x, y), [blocks, no_reach_blocks, back_blocks])
							loaded_chunk_num += 1
							loaded_chunks[str(x)+"."+str(y)] = false
							loaded_chunks_timer[str(x)+"."+str(y)] = StaticLoad.CHUNK_FREE_TIME
						else:
							var mca = ConfigFile.new()
							var chunk = StaticLoad.generate_chunk(Vector2i(x, y), world_info_dictionary["seed"], world_info_dictionary["world_type"])
							set_chunk(Vector2i(x, y), chunk)
							loaded_chunk_num += 1
							mca.set_value("chunk", "blocks", chunk[0])
							mca.set_value("chunk", "no_reach_blocks", chunk[1])
							mca.set_value("chunk", "back_blocks", chunk[2])
							mca.save_encrypted_pass(StaticLoad.region_path+"/r."+str(x)+"."+str(y)+".mca", StaticLoad.CONFIG_PASSWORD)
							loaded_chunks[str(x)+"."+str(y)] = false
							loaded_chunks_timer[str(x)+"."+str(y)] = StaticLoad.CHUNK_FREE_TIME
							database_chunks.push_back(str(x)+"."+str(y))
						if not StaticLoad.is_dedicated_server:
							if not chunk_sky_light_datas.has(str(x)+"."+str(y-1)):
								var sky_light: PackedByteArray
								sky_light.resize(16)
								sky_light.fill(255)
								chunk_sky_light_datas[str(x)+"."+str(y)] = sky_light
							if not StaticLoad.is_muti_mode or (StaticLoad.is_muti_mode and StaticLoad.multiplayer.get_unique_id() == 1):
								if chunk_lights.has(str(x)+"."+str(y)):
									chunk_light_to_process[str(x)+"."+str(y)] = "null"
								else:
									chunk_light_to_process[str(x)+"."+str(y)] = "create"
		player_last_chunk = Vector2i(x_player_chunk, y_player_chunk)

func free_chunk(pos: Vector2i) -> void:
	for x in range(0, 16):
		for y in range(0, 16):
			set_block(Vector2i(pos[0] * 16 + x, pos[1] * 16 + y), 0, "solid", true)
			set_block(Vector2i(pos[0] * 16 + x, pos[1] * 16 + y), 0, "no_reach", true)
			set_block(Vector2i(pos[0] * 16 + x, pos[1] * 16 + y), 0, "back", true)
	loaded_chunk_num -= 1
	var chunk_name = str(pos[0])+"."+str(pos[1])
	if chunk_lights.has(chunk_name):
		chunk_lights[chunk_name].destroy()
	if loaded_chunk_packed_byte_arrays.has(str(pos[0])+"."+str(pos[1])):
		var byte_array_tmp = loaded_chunk_packed_byte_arrays[str(pos[0])+"."+str(pos[1])]
		loaded_chunk_packed_byte_arrays.erase(str(pos[0])+"."+str(pos[1]))
		byte_array_tmp.clear()

func set_chunk(pos: Vector2i, blocks_list) -> void:
	if not loaded_chunk_packed_byte_arrays.has(str(pos[0])+"."+str(pos[1])):
		var chunk_packed_byte_array: PackedByteArray
		chunk_packed_byte_array.resize(256)
		chunk_packed_byte_array.fill(0)
		loaded_chunk_packed_byte_arrays[str(pos[0])+"."+str(pos[1])] = chunk_packed_byte_array
	for x in range(0, 16):
		for y in range(0, 16):
			set_block(Vector2i(pos[0] * 16 + x, pos[1] * 16 + y), blocks_list[0][y][x], "solid", true)
			set_block(Vector2i(pos[0] * 16 + x, pos[1] * 16 + y), blocks_list[1][y][x], "no_reach", true)
			set_block(Vector2i(pos[0] * 16 + x, pos[1] * 16 + y), blocks_list[2][y][x], "back", true)
	if not StaticLoad.is_muti_mode or (StaticLoad.is_muti_mode and StaticLoad.multiplayer.get_unique_id() == 1):
		load_entities(pos)

func set_block(block_pos: Vector2i, block_id: int, tile_map_type, is_pre_load = false):
	var tile_map_layer_tmp = tile_map_layer
	var mini_map_tile_map_layer_tmp = mini_map_tile_map_layer
	if tile_map_type == "back":
		tile_map_layer_tmp = back_tile_map_layer
		mini_map_tile_map_layer_tmp = mini_map_back_tile_map_layer
	elif tile_map_type == "no_reach":
		tile_map_layer_tmp = no_reach_tile_map_layer
		mini_map_tile_map_layer_tmp = mini_map_no_reach_tile_map_layer
	if block_id == 0:
		if tile_map_layer_tmp.get_cell_source_id(block_pos) == -1:
			return false
		if not is_pre_load:
			@warning_ignore("confusable_local_declaration")
			var atlas_coords = tile_map_layer_tmp.get_cell_atlas_coords(block_pos)
			sound_audio_manager.play_random_audio_at_position("dig", StaticLoad.get_block_type_by_id(StaticLoad.get_block_id_by_atlas_coords(atlas_coords)), tile_map_layer_tmp.map_to_local(block_pos), 1)
		tile_map_layer_tmp.set_cell(block_pos)
		if not StaticLoad.is_dedicated_server:
			mini_map_tile_map_layer_tmp.set_cell(block_pos)
			var chunk_pos = get_chunk_position(block_pos)
			var relative_block_pos = block_pos-chunk_pos*16
			if relative_block_pos[0] > 15:
				relative_block_pos[0] = 15
			if relative_block_pos[1] > 15:
				relative_block_pos[1] = 15
			if tile_map_type != "back":
				if loaded_chunk_packed_byte_arrays.has(str(chunk_pos[0])+"."+str(chunk_pos[1])):
					loaded_chunk_packed_byte_arrays[str(chunk_pos[0])+"."+str(chunk_pos[1])][relative_block_pos[1]*16+relative_block_pos[0]] = 0
		return true
	if tile_map_layer_tmp.get_cell_source_id(block_pos) != -1:
		return false
	#if not is_pre_load:
		#for id in StaticLoad.player_peer_dict:
			#var player_tmp = StaticLoad.player_peer_dict[id]
			#var player_pos = tile_map_layer_tmp.local_to_map(player_tmp.position)
			#if player_pos == block_pos:
				#return false
			#if player_pos - Vector2i(0, 1) == block_pos:
				#return false
	var atlas_coords = StaticLoad.get_atlas_coords_by_block_id(block_id)
	tile_map_layer_tmp.set_cell(block_pos, 9999, atlas_coords)
	if not StaticLoad.is_dedicated_server:
		mini_map_tile_map_layer_tmp.set_cell(block_pos, 9999, atlas_coords)
		var chunk_pos = get_chunk_position(block_pos)
		var relative_block_pos = block_pos-chunk_pos*16
		if relative_block_pos[0] > 15:
			relative_block_pos[0] = 15
		if relative_block_pos[1] > 15:
			relative_block_pos[1] = 15
		if tile_map_type != "back":
			if loaded_chunk_packed_byte_arrays.has(str(chunk_pos[0])+"."+str(chunk_pos[1])):
				loaded_chunk_packed_byte_arrays[str(chunk_pos[0])+"."+str(chunk_pos[1])][relative_block_pos[1]*16+relative_block_pos[0]] = block_id
	if not is_pre_load:
		sound_audio_manager.play_random_audio_at_position("dig", StaticLoad.get_dig_type_by_block_type(StaticLoad.get_block_type_by_id(block_id)), tile_map_layer_tmp.map_to_local(block_pos), 1)
	return true

func save_world():
	for region in loaded_chunks:
		if loaded_chunks[region]:
			loaded_chunks[region] = false
			var splits = region.split(".")
			var x_chunk = int(splits[0])
			var y_chunk = int(splits[1])
			save_chunk(Vector2i(x_chunk, y_chunk))
	var level = ConfigFile.new()
	var current_time = Time.get_datetime_string_from_system(false, true).replace(" ", "  ").replace("-", "/")
	level.set_value("world", "last_modified", current_time)
	level.set_value("world", "version", world_info_dictionary["version"])
	level.set_value("world", "seed", world_info_dictionary["seed"])
	level.set_value("world", "world_type", world_info_dictionary["world_type"])
	level.set_value("world", "gamemode", world_info_dictionary["gamemode"])
	level.save_encrypted_pass(StaticLoad.world_path+"/level.dat", StaticLoad.CONFIG_PASSWORD)
	#save_entities()

func save_player(peer_id = 0):
	if peer_id == 0:
		for id in StaticLoad.player_peer_dict:
			var player_tmp = StaticLoad.player_peer_dict[id]
			if player_tmp.is_dead:
				player_tmp.respawn_player(false)
			var player_config = ConfigFile.new()
			if player_tmp.gamemode != "creative":
				player_tmp.is_flying = false
			player_config.set_value("player", "position", player_tmp.position)
			player_config.set_value("player", "face_state", player_tmp.face_state)
			player_config.set_value("player", "is_flying", player_tmp.is_flying)
			player_config.set_value("player", "gamemode", player_tmp.gamemode)
			player_config.set_value("player", "health", player_tmp.health)
			player_config.set_value("player", "item_bar_names", player_tmp.item_bar_names)
			player_config.set_value("player", "item_bar_amounts", player_tmp.item_bar_amounts)
			player_config.save_encrypted_pass(StaticLoad.player_path+"/"+player_tmp.player_name.to_lower()+".dat", StaticLoad.CONFIG_PASSWORD)
	else:
		var player_tmp = StaticLoad.player_peer_dict[peer_id]
		var player_config = ConfigFile.new()
		if player_tmp.gamemode != "creative":
			player_tmp.is_flying = false
		player_config.set_value("player", "position", player_tmp.position)
		player_config.set_value("player", "face_state", player_tmp.face_state)
		player_config.set_value("player", "is_flying", player_tmp.is_flying)
		player_config.set_value("player", "gamemode", player_tmp.gamemode)
		player_config.set_value("player", "health", player_tmp.health)
		player_config.set_value("player", "item_bar_names", player_tmp.item_bar_names)
		player_config.set_value("player", "item_bar_amounts", player_tmp.item_bar_amounts)
		player_config.save_encrypted_pass(StaticLoad.player_path+"/"+player_tmp.player_name.to_lower()+".dat", StaticLoad.CONFIG_PASSWORD)

func save_chunk(chunk_pos: Vector2i):
	var mca = ConfigFile.new()
	var blocks = []
	var no_reach_blocks = []
	var back_blocks = []
	var x_chunk = chunk_pos[0]
	var y_chunk = chunk_pos[1]
	for y in range(16):
		var row = []
		var no_reach_row = []
		var back_row = []
		for x in range(16):
			var block_pos = Vector2i(x_chunk*16+x, y_chunk*16+y)
			var id = 0
			if tile_map_layer.get_cell_source_id(block_pos) != -1:
				var atlas_coords = tile_map_layer.get_cell_atlas_coords(block_pos)
				id = StaticLoad.get_block_id_by_atlas_coords(atlas_coords)
			row.append(id)
			var no_reach_id = 0
			if no_reach_tile_map_layer.get_cell_source_id(block_pos) != -1:
				var atlas_coords = no_reach_tile_map_layer.get_cell_atlas_coords(block_pos)
				no_reach_id = StaticLoad.get_block_id_by_atlas_coords(atlas_coords)
			no_reach_row.append(no_reach_id)
			var back_id = 0
			if back_tile_map_layer.get_cell_source_id(block_pos) != -1:
				var atlas_coords = back_tile_map_layer.get_cell_atlas_coords(block_pos)
				back_id = StaticLoad.get_block_id_by_atlas_coords(atlas_coords)
			back_row.append(back_id)
		blocks.append(row)
		no_reach_blocks.append(no_reach_row)
		back_blocks.append(back_row)
	mca.set_value("chunk", "blocks", blocks)
	mca.set_value("chunk", "no_reach_blocks", no_reach_blocks)
	mca.set_value("chunk", "back_blocks", back_blocks)
	mca.save_encrypted_pass(StaticLoad.region_path+"/r."+str(x_chunk)+"."+str(y_chunk)+".mca", StaticLoad.CONFIG_PASSWORD)
	var level = ConfigFile.new()
	var current_time = Time.get_datetime_string_from_system(false, true).replace(" ", "  ").replace("-", "/")
	level.set_value("world", "last_modified", current_time)
	level.set_value("world", "version", world_info_dictionary["version"])
	level.set_value("world", "seed", world_info_dictionary["seed"])
	level.set_value("world", "world_type", world_info_dictionary["world_type"])
	level.set_value("world", "gamemode", world_info_dictionary["gamemode"])
	level.save_encrypted_pass(StaticLoad.world_path+"/level.dat", StaticLoad.CONFIG_PASSWORD)
	
	#var is_item_save_required = false
	#var entity_mca = ConfigFile.new()
	#for item in items.get_children():
		#if item.position.x >= x_chunk*16 and item.position.x < x_chunk*16+16:
			#if item.position.y >= y_chunk*16 and item.position.y < y_chunk*16+16:
				#is_item_save_required = true
				#entity_mca.set_value(str(item.get_uuid()), "type", "item")
				#entity_mca.set_value(str(item.get_uuid()), "item_name", item.item_name)
				#entity_mca.set_value(str(item.get_uuid()), "item_amount", item.item_name)
				#entity_mca.set_value(str(item.get_uuid()), "position", item.position)
	#if is_item_save_required:
		#entity_mca.save_encrypted_pass(StaticLoad.entity_path+"/r."+str(x_chunk)+"."+str(y_chunk)+".mca", StaticLoad.CONFIG_PASSWORD)

func save_entities():
	var entity_mca = ConfigFile.new()
	for item in items.get_children():
		var item_pos = tile_map_layer.local_to_map(item.position)
		var chunk_pos = get_chunk_position(item_pos)
		if FileAccess.file_exists(StaticLoad.entity_path+"/"+str(chunk_pos[0])+"."+str(chunk_pos[1])+".mca"):
			var entity_config = ConfigFile.new()
			if entity_config.load_encrypted_pass(StaticLoad.entity_path+"/r."+str(chunk_pos[0])+"."+str(chunk_pos[1])+".mca", StaticLoad.CONFIG_PASSWORD) != OK:
				return
			for uuid in entity_config.get_sections():
				if entity_config.get_value(uuid, "item", "entity") == "item":
					entity_mca.set_value(uuid, "type", "item")
					entity_mca.set_value(uuid, "item_name", entity_config.get_value(uuid, "item_name"))
					entity_mca.set_value(uuid, "item_amount", entity_config.get_value(uuid, "item_amount"))
					entity_mca.set_value(uuid, "position", entity_config.get_value(uuid, "position"))
		entity_mca.set_value(str(item.get_uuid()), "type", "item")
		entity_mca.set_value(str(item.get_uuid()), "item_name", item.item_name)
		entity_mca.set_value(str(item.get_uuid()), "item_amount", item.item_amount)
		entity_mca.set_value(str(item.get_uuid()), "position", item.position)
		entity_mca.save_encrypted_pass(StaticLoad.entity_path+"/r."+str(chunk_pos[0])+"."+str(chunk_pos[1])+".mca", StaticLoad.CONFIG_PASSWORD)

func load_entities(chunk_pos):
	if FileAccess.file_exists(StaticLoad.entity_path+"/r."+str(chunk_pos[0])+"."+str(chunk_pos[1])+".mca"):
		var entity_config = ConfigFile.new()
		if entity_config.load_encrypted_pass(StaticLoad.entity_path+"/r."+str(chunk_pos[0])+"."+str(chunk_pos[1])+".mca", StaticLoad.CONFIG_PASSWORD) != OK:
			return
		for uuid in entity_config.get_sections():
			if entity_config.get_value(uuid, "type", "entity") == "item":
				var item_name = entity_config.get_value(uuid, "item_name")
				var item_pos = entity_config.get_value(uuid, "position")
				var item_amount = int(entity_config.get_value(uuid, "item_amount"))
				var item = item_scene.instantiate()
				items.add_child(item)
				item.init(item_name, item_pos, item_amount, 1)
				entities[item.get_uuid()] = item

func select_item_grid(grid_name) -> void:
	if str(grid_name) == "More":
		if is_inventory:
			return
		StaticLoad.click_audio_player.play()
		inventory_ui.visible = true
		is_inventory = true
		is_input_frozen = true
		move_input_list.clear()
		player.stop_move()
		return
	for i in range(9):
		@warning_ignore("confusable_local_declaration")
		item_grids[i].get_node("SelectBar").visible = false
	var sort = int(str(grid_name))-1
	player.selected_item_grid = sort
	item_grids[sort].get_node("SelectBar").visible = true
	if player.item_bar_names[sort] == "AIR":
		return
	item_name_label.text = player.item_bar_names[sort]
	item_name_timer = StaticLoad.ITEM_NAME_SHOW_TIME

func refresh_inventory():
	for i in range(0, 9):
		var item_name = player.item_bar_names[i]
		var item_amount = player.item_bar_amounts[i]
		@warning_ignore("shadowed_variable")
		var inventory_grid = inventory_show_grids.get_node("InventoryGrid"+str(i))
		inventory_grid.init_inventory_grid(item_name, item_amount)
	for i in range(9, 36):
		var item_name = player.item_bar_names[i]
		var item_amount = player.item_bar_amounts[i]
		@warning_ignore("shadowed_variable")
		var inventory_grid = inventory_back_grids.get_node("InventoryGrid"+str(i))
		inventory_grid.init_inventory_grid(item_name, item_amount)

func init_inventory():
	refresh_inventory()
	for i in range(9):
		var item_icon = item_icon_scene.instantiate()
		item_grids[i].add_child(item_icon)
		refresh_item_grid(i)

func touch_button(button_name):
	StaticLoad.click_audio_player.play()
	if button_name == "InventoryCloseButton":
		await get_tree().create_timer(0.01).timeout
		inventory_ui.visible = false
		is_inventory = false
		is_input_frozen = false
		move_input_list.clear()
		player.stop_move()

func broadcast_to_person(player_name: String, text:String, color="white"):
	if player_name != player.player_name:
		return
	var messgae_in_instance = message_scene.instantiate()
	messgae_in_instance.text = text
	var messgae_out_instance = message_scene.instantiate()
	messgae_out_instance.text = text
	if color != "white":
		messgae_in_instance.set("theme_override_colors/font_color", StaticLoad.colors[color])
		messgae_out_instance.set("theme_override_colors/font_color", StaticLoad.colors[color])
	chat_message_in.add_child(messgae_in_instance)
	chat_message_out.add_child(messgae_out_instance)
	await get_tree().create_timer(0.01).timeout
	if is_chat:
		chat_message_out.visible = false
	chat_history_in.scroll_vertical = 1e9
	messgae_out_instance.is_disappearing = true
	messgae_out_instance.detect_and_disappear()
	
func broadcast_to_all(text:String, color="white"):
	var messgae_in_instance = message_scene.instantiate()
	messgae_in_instance.text = text
	var messgae_out_instance = message_scene.instantiate()
	messgae_out_instance.text = text
	if color != "white":
		messgae_in_instance.set("theme_override_colors/font_color", StaticLoad.colors[color])
		messgae_out_instance.set("theme_override_colors/font_color", StaticLoad.colors[color])
	chat_message_in.add_child(messgae_in_instance)
	chat_message_out.add_child(messgae_out_instance)
	await get_tree().create_timer(0.01).timeout
	if is_chat:
		chat_message_out.visible = false
	chat_history_in.scroll_vertical = 1e9
	messgae_out_instance.is_disappearing = true
	messgae_out_instance.detect_and_disappear()

func _on_pause_button_1_pressed() -> void:
	StaticLoad.click_audio_player.play()
	if StaticLoad.is_on_mobile_platform:
		Input.emulate_mouse_from_touch = false
	pause_ui.visible = false
	is_pause = false
	is_input_frozen = false

func _on_pause_button_2_pressed() -> void:
	StaticLoad.click_audio_player.play()
	options_ui.load_in_game_options()
	options_ui.visible = true

func _on_pause_button_3_pressed() -> void:
	StaticLoad.click_audio_player.play()
	language_ui.visible = true

func _on_pause_button_4_pressed() -> void:
	StaticLoad.click_audio_player.play()
	pause_ui.visible = false
	is_pause = false
	is_input_frozen = false
	StaticLoad.start_server()

func _on_pause_button_5_pressed() -> void:
	StaticLoad.click_audio_player.play()
	Input.emulate_mouse_from_touch = true
	save_world()
	save_player()
	if StaticLoad.is_muti_mode:
		StaticLoad.clear_connections()
		ServiceDiscovery.close_server()
		StaticLoad.is_muti_mode = false
	var change_value = {
		"mini_map_zoom": str(int(mini_map_camera.zoom[0]*100))
	}
	StaticLoad.save_options(change_value)
	StaticLoad.is_in_game = false
	StaticLoad.change_scene("res://Assets/Scenes/Menu.tscn")
	
func _on_pause_button_6_pressed() -> void:
	Input.emulate_mouse_from_touch = true
	StaticLoad.click_audio_player.play()
	StaticLoad.clear_connections()
	StaticLoad.is_muti_mode = false
	StaticLoad.is_in_game = false
	StaticLoad.change_scene("res://Assets/Scenes/Menu.tscn")

func _on_death_button_1_pressed() -> void:
	StaticLoad.click_audio_player.play()
	player.respawn(true)
	if StaticLoad.is_muti_mode:
		if StaticLoad.multiplayer.get_unique_id() == 1:
			StaticLoad.rpc_entity_func_by_uuid(player.get_uuid(), "respawn", true, "others", true)
		else:
			StaticLoad.rpc_entity_func_by_uuid(player.get_uuid(), "respawn", true, [player.player_peer_id], false)

func _on_death_button_2_pressed() -> void:
	StaticLoad.click_audio_player.play()
	Input.emulate_mouse_from_touch = true
	save_world()
	save_player()
	if StaticLoad.is_muti_mode:
		StaticLoad.clear_connections()
		ServiceDiscovery.close_server()
		StaticLoad.is_muti_mode = false
	var change_value = {
		"mini_map_zoom": str(int(mini_map_camera.zoom[0]*100))
	}
	StaticLoad.save_options(change_value)
	StaticLoad.is_in_game = false
	StaticLoad.change_scene("res://Assets/Scenes/Menu.tscn")
	
func _on_death_button_3_pressed() -> void:
	StaticLoad.click_audio_player.play()
	Input.emulate_mouse_from_touch = true
	StaticLoad.clear_connections()
	StaticLoad.is_muti_mode = false
	StaticLoad.is_in_game = false
	StaticLoad.change_scene("res://Assets/Scenes/Menu.tscn")

@warning_ignore("unused_parameter")
func _on_chat_line_edit_text_submitted(new_text: String) -> void:
	if chat_line_edit.text == "":
		return
	var text: String = chat_line_edit.text
	if StaticLoad.is_muti_mode:
		if text[0] != "/":
			player.send_message(text)
			if StaticLoad.multiplayer.get_unique_id() == 1:
				StaticLoad.rpc_entity_func_by_uuid(player.get_uuid(), "send_message", text, "others", true)
			else:
				StaticLoad.rpc_entity_func_by_uuid(player.get_uuid(), "send_message", text, [player.player_peer_id], false)
		else:
			player.send_command(text)
			if StaticLoad.multiplayer.get_unique_id() == 1:
				StaticLoad.rpc_entity_func_by_uuid(player.get_uuid(), "send_command", text, "others", true)
			else:
				StaticLoad.rpc_entity_func_by_uuid(player.get_uuid(), "send_command", text, [player.player_peer_id], false)
	else:
		if text[0] != "/":
			player.send_message(text)
		else:
			player.send_command(text)
	await get_tree().create_timer(0.01).timeout
	chat_history_in.scroll_vertical = 1e9
	chat_history_out.scroll_vertical = 1e9
	if is_chat:
		chat_message_out.visible = false
	chat_line_edit.text = ""
	if StaticLoad.is_on_mobile_platform:
		close_chat_ui()
		Input.emulate_mouse_from_touch = false

func _on_chat_history_out_pre_sort_children() -> void:
	chat_history_out.scroll_vertical = 1e9

func _on_mobile_f1_button_pressed():
	StaticLoad.click_audio_player.play()
	switch_ui_visibility()
	move_buttons_left.visible = game_ui.visible
	move_buttons_right.visible = game_ui.visible

func _on_mobile_f2_button_pressed():
	StaticLoad.click_audio_player.play()
	screenshot()
	
func _on_mobile_f3_button_pressed():
	StaticLoad.click_audio_player.play()
	switch_details_visibility()
	
func _on_mobile_tab_button_pressed():
	StaticLoad.click_audio_player.play()
	if online_ui.visible:
		online_ui.visible = false
	elif StaticLoad.is_muti_mode:
		open_online_info_ui()

func _on_mobile_chat_button_pressed():
	StaticLoad.click_audio_player.play()
	if not is_chat:
		move_input_list.clear()
		player.stop_move()
		is_input_frozen = true
		is_chat = true
		chat_message_out.visible = false
		chat_panel.visible = true
		await get_tree().create_timer(0.001).timeout
		chat_history_in.scroll_vertical = 1e9
		chat_line_edit.grab_focus()
		chat_line_edit.text = ""
		Input.emulate_mouse_from_touch = true
	else:
		close_chat_ui()
		Input.emulate_mouse_from_touch = false

func _on_mobile_pause_button_pressed():
	StaticLoad.click_audio_player.play()
	if is_chat:
		close_chat_ui()
		Input.emulate_mouse_from_touch = false
	else:
		pause_ui.visible = !pause_ui.visible
		is_pause = pause_ui.visible
		if pause_ui.visible:
			is_input_frozen = true
			move_input_list.clear()
			player.stop_move()
		Input.emulate_mouse_from_touch = true

func _on_mobile_map_button_pressed():
	StaticLoad.click_audio_player.play()
	mini_map.set_anchors_preset(Control.PRESET_FULL_RECT)
	mini_map.size = get_viewport_rect().size
	mini_map.position = Vector2(0, 0)
	mobile_ui.visible = false
	item_bar_panel.visible = false
	move_input_list.clear()
	player.stop_move()
	is_input_frozen = true
	is_map = true

func _on_mobile_map_button_released():
	mini_map.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	mini_map.size = Vector2(270, 270)
	mini_map.position = Vector2(get_viewport_rect().size[0]-270, 0)
	mobile_ui.visible = true
	item_bar_panel.visible = true
	move_input_list.clear()
	player.stop_move()
	is_input_frozen = false
	is_map = false

func _on_mobile_move_button_up_pressed():
	Input.action_release("down")
	Input.action_release("move_left")
	Input.action_release("move_right")
	if not Input.is_action_pressed("jump"):
		Input.action_press("jump")
		
func _on_mobile_move_button_up_released():
	Input.action_release("jump")

func _on_mobile_move_button_down_pressed():
	Input.action_release("jump")
	Input.action_release("move_left")
	Input.action_release("move_right")
	if not Input.is_action_pressed("down"):
		Input.action_press("down")
	
func _on_mobile_move_button_down_released():
	Input.action_release("down")

func _on_mobile_move_button_left_pressed():
	Input.action_release("jump")
	Input.action_release("down")
	Input.action_release("move_right")
	if not Input.is_action_pressed("move_left"):
		Input.action_press("move_left")
		
func _on_mobile_move_button_left_released():
	Input.action_release("jump")
	Input.action_release("down")
	Input.action_release("move_left")
	Input.action_release("move_right")

func _on_mobile_move_button_right_pressed():
	Input.action_release("jump")
	Input.action_release("down")
	Input.action_release("move_left")
	if not Input.is_action_pressed("move_right"):
		Input.action_press("move_right")

func _on_mobile_move_button_right_released():
	Input.action_release("jump")
	Input.action_release("down")
	Input.action_release("move_left")
	Input.action_release("move_right")

func _on_mobile_move_button_up_left_pressed():
	Input.action_release("down")
	Input.action_release("move_right")
	if not Input.is_action_pressed("jump"):
		Input.action_press("jump")
	if not Input.is_action_pressed("move_left"):
		Input.action_press("move_left")
		
func _on_mobile_move_button_up_right_pressed():
	Input.action_release("down")
	Input.action_release("move_left")
	if not Input.is_action_pressed("jump"):
		Input.action_press("jump")
	if not Input.is_action_pressed("move_right"):
		Input.action_press("move_right")

func _on_mobile_move_button_down_left_pressed():
	Input.action_release("jump")
	Input.action_release("move_right")
	if not Input.is_action_pressed("down"):
		Input.action_press("down")
	if not Input.is_action_pressed("move_left"):
		Input.action_press("move_left")
		
func _on_mobile_move_button_down_right_pressed():
	Input.action_release("jump")
	Input.action_release("move_left")
	if not Input.is_action_pressed("down"):
		Input.action_press("down")
	if not Input.is_action_pressed("move_right"):
		Input.action_press("move_right")

func _on_mobile_move_button_jump_pressed():
	Input.action_release("down")
	#Input.action_release("move_left")
	#Input.action_release("move_right")
	if not Input.is_action_pressed("jump"):
		Input.action_press("jump")
		
func _on_mobile_move_button_jump_released():
	Input.action_release("jump")

func _on_inventory_ui_dark_mask_gui_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	if event.button_index == 1:
		if mouse_item_amount > 0:
			sound_audio_manager.play_audio_static("player", "pop")
			player.drop_item(mouse_item_name, mouse_item_amount)
			mouse_item_name = "AIR"
			mouse_item_amount = 0

func _on_inventory_ui_hidden() -> void:
	if mouse_item_amount > 0:
		sound_audio_manager.play_audio_static("player", "pop")
		player.drop_item(mouse_item_name, mouse_item_amount)
		mouse_item_name = "AIR"
		mouse_item_amount = 0

func _on_inventory_ui_visibility_changed() -> void:
	if player.gamemode != "creative":
		if inventory_tabs.visible:
			inventory_tabs.visible = false
		if delete_tab_panel.visible:
			delete_tab_panel.visible = false
		var inventory_panel = inventory_ui.get_node("Panel").get_node("InventoryPanel")
		if not inventory_panel.visible:
			inventory_panel.visible = true
			inventory_ui.get_node("Panel").get_node("BlocksPanel").visible = false
			inventory_ui.get_node("Panel").get_node("ItemsPanel").visible = false
	else:
		if not inventory_tabs.visible:
			inventory_tabs.visible = true
			for tab in StaticLoad.game.inventory_tabs.get_children():
				tab.dark_mask.visible = true
				tab.panel.visible = false
				tab.z_index = 0
			var inventory_tab = inventory_tabs.get_node("InventoryTab")
			inventory_tab.dark_mask.visible = false
			inventory_tab.panel.visible = true
			inventory_tab.z_index = 1
		if not delete_tab_panel.visible:
			delete_tab_panel.visible = true
