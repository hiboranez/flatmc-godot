extends Node2D

@onready var tile_map_layer = $TileMapLayer
@onready var no_reach_tile_map_layer = $NoReachTileMapLayer
@onready var back_tile_map_layer = $BackTileMapLayer
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
@onready var destroy_particle_scene = load("res://Assets/Scenes/DestroyParticle.tscn") as PackedScene
@onready var death_particle_scene = load("res://Assets/Scenes/DeathParticle.tscn") as PackedScene
@onready var move_center_button_normal = load("res://Assets/Textures/GUI/move_center_button_normal.tres") as AtlasTexture
@onready var jump_button_normal = load("res://Assets/Textures/GUI/jump_button_normal.tres") as AtlasTexture
@onready var move_center_button_fly = load("res://Assets/Textures/GUI/move_center_button_fly.tres") as AtlasTexture
#@onready var player_other_scene = load("res://Assets/Scenes/PlayerOther.tscn") as PackedScene
@onready var health_bar = $GameUI/ItemBarPanel/HealthBar
@onready var hunger_bar = $GameUI/ItemBarPanel/HungerBar
@onready var player
@onready var touch_time_counters = $TouchTimeCounters
@onready var item_grids = $GameUI/ItemBarPanel/ItemBar.get_children()
@onready var item_name_label = $GameUI/ItemBarPanel/ItemNameLabel
@onready var bgm_audio_player = $BgmAudioPlayer
@onready var sound_audio_manager = $SoundAudioManager
@onready var block_selection_ui = $BlockSelectionUI
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
@onready var death_button_2 = $DeathUI/VSplitContainer/FlowContainer/Button2
@onready var death_button_3 = $DeathUI/VSplitContainer/FlowContainer/Button3
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
@onready var crafting_inventory_back_grids = $GameUI/CraftingUI/Panel/InventoryPanel/Inventory/InventoryBackContainer
@onready var crafting_inventory_show_grids = $GameUI/CraftingUI/Panel/InventoryShowContainer
@onready var inventory_player_model = $GameUI/InventoryUI/Panel/InventoryPanel/Player/SubViewportContainer/SubViewport/PlayerModel
@onready var inventory_player_model_mesh = $GameUI/InventoryUI/Panel/InventoryPanel/Player/SubViewportContainer/SubViewport/PlayerModel/Root/Skeleton3D/Mesh
@onready var inventory_player_model_item_in_hand = $GameUI/InventoryUI/Panel/InventoryPanel/Player/SubViewportContainer/SubViewport/PlayerModel/Root/Skeleton3D/Hand/Item
@onready var items = $Items
@onready var arrows = $Arrows
@onready var mobs = $Mobs
@onready var undead_mobs = $UndeadMobs
@onready var inventory_tabs = $GameUI/InventoryUI/Panel/Tabs
@onready var blocks_infinite_container = $GameUI/InventoryUI/Panel/BlocksPanel/InfiniteScrollContainer/InfiniteContainer
@onready var items_infinite_container = $GameUI/InventoryUI/Panel/ItemsPanel/InfiniteScrollContainer/InfiniteContainer
@onready var delete_tab_panel = $GameUI/InventoryUI/Panel/DeleteTabPanel
@onready var background_sky = $StaticBackground/Sky
@onready var background_star = $StaticBackground/ParallaxLayer/Star
@onready var background_cloud = $MoveBackground/ParallaxLayer/Cloud
@onready var move_background = $MoveBackground
@onready var mini_map_sky_back = $GameUI/MiniMap/SkyBack
@onready var mini_map_star_back = $GameUI/MiniMap/SubViewportContainer/SubViewport/StaticBackground/ParallaxLayer/StarBack
@onready var front_particles = $FrontParticles
@onready var back_particles = $BackParticles
@onready var attack_icon = $GameUI/ItemBarPanel/AttackIcon
@onready var attack_indicator_progress = $GameUI/ItemBarPanel/AttackIcon/AttackIndicatorProgress
@onready var death_ui_flow_container = $DeathUI/VSplitContainer/FlowContainer
@onready var path_2d = $StaticBackground/Path2D
@onready var moon_path = $StaticBackground/Path2D/MoonPath
@onready var sun_path = $StaticBackground/Path2D/SunPath
@onready var moon_path_texture = $StaticBackground/Path2D/MoonPath/TextureRect
@onready var sun_path_texture = $StaticBackground/Path2D/SunPath/TextureRect
@onready var inventory_craft_grid = $GameUI/InventoryUI/Panel/InventoryPanel/Crafting/GridContainer
@onready var inventory_craft_result_grid = $GameUI/InventoryUI/Panel/InventoryPanel/Crafting/CraftResult
@onready var table_craft_grid = $GameUI/CraftingUI/Panel/InventoryPanel/Crafting/GridContainer
@onready var table_craft_result_grid = $GameUI/CraftingUI/Panel/InventoryPanel/Crafting/CraftResult
@onready var crafting_ui = $GameUI/CraftingUI

var frozen_entity_dict = {}
var destroy_light_names = {}
var mouse_in_inventory_grid = null
var light_thread = Thread.new()
var item_thread = Thread.new()
var refresh_thread = Thread.new()
var tick_cycle_thread = Thread.new()
var dispatch_thread = Thread.new()
var set_block_thread = Thread.new()
var nearby_thread = Thread.new()
var entity_spawn_thread = Thread.new()
var remove_chunks_thread = Thread.new()
var success_set_block_dict = {}
var fail_set_block_list = []
var player_icons = {}
var mouse_item_name_label
var touch_list = []
var world_info_dictionary = {}
var entities = {}
var mini_map_chunk_lights = {}
var chunk_lights = {}
var chunk_light_datas = {}
var chunk_sky_light_datas = {}
var chunk_sky_light_all_datas = {}
var item_to_combine = {}
var refresh_to_process = []
var refresh_to_process_double = []
var chunk_light_to_process = {}
var chunk_light_to_process_double = {}
var ui_freeze_timer: float = 0
var drag_press_timer: float = 0
var block_selection_timer: float = 0
var block_selection_box
var mini_map_on
var smooth_lighting_on
var mini_map_zoom: float
var chunk_to_load = []
var is_smooth_light: bool = false
var is_mouse_motion_updated: bool = false
var is_particle_effect_on: bool = true
var is_online_info: bool = false
var is_input_frozen: bool = false
var is_map: bool = false
var is_inventory: bool = false
var is_crafting: bool = false
var is_pause: bool = false
var is_chat: bool = false
var is_player_info_updated: bool = false
var is_chunk_modifing: bool = false
var is_light_pause: bool = false
var player_last_chunk: Vector2i
var loaded_chunk_packed_byte_arrays: Dictionary
var loaded_chunks: Dictionary #true代表已修改，需要最后保存
var loaded_chunks_timer: Dictionary
var database_chunks = []
var total_chunk_num = 0
var loaded_chunk_num = 0
var die_no_press_timer: float = 0
var item_name_timer: float = 0
var update_chunk_timer: float = 0
var last_mouse_in_world_pos: Vector2 = Vector2(0, 0)
var move_input_list = []
var last_left_time = 0.0
var last_right_time = 0.0
var last_jump_time = 0.0
var drop_timer = 0.0
var resource_pack = StaticLoad.default_resource_pack
var tick_timer: int = 9000
var world_day: int = 0
var set_block_list = []
var dragging_total_amount = 0
var drag_inventory_grid_state = "null"
var drag_inventory_grid_item_name = "null"
var drag_inventory_last_grid_name = "null"
var drag_inventory_grid_dict = {}
var drag_inventory_grid_amount_dict = {}
var current_sky_light: int = 255
var nearby_update_dict = {}
var nearby_update_double_dict = {}

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if StaticLoad.is_muti_mode and multiplayer.get_unique_id() != 1:
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
	if light_thread.is_started():
		light_thread.wait_to_finish()
	if item_thread.is_started():
		item_thread.wait_to_finish()
	if refresh_thread.is_started():
		refresh_thread.wait_to_finish()
	if tick_cycle_thread.is_started():
		tick_cycle_thread.wait_to_finish()
	if dispatch_thread.is_started():
		dispatch_thread.wait_to_finish()
	if set_block_thread.is_started():
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
	# 仅在务器更新
	process_entity_save()
	
	# 服务器和本地均更新
	update_local_player_nearby_chunk()
	#remove_outdated_chunks()
	
	if StaticLoad.is_dedicated_server:
		return
	
	# 本地更新
	update_ui_freeze_timer()
	update_die_no_press_timer()
	update_hotbar_attack_indicator()
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
		update_day_night_cycle()
		update_nature_growth()
		tick_timer += 1
		if tick_timer % 1000 == 0:
			if StaticLoad.is_muti_mode and multiplayer.get_unique_id() == 1:
				StaticLoad.rpc("reply_for_world_info", tick_timer, world_day, move_background.scroll_base_offset.x, true)
		if tick_timer == 9000:
			world_day += 1
			update_moon_phase()	
		if tick_timer >= 24000:
			tick_timer = 0

func update_path_2d():
	path_2d.curve.set_point_position(1, Vector2(background_sky.size.x+80, 500))

func update_day_night_cycle() -> void:
	var cloud_dark_ratio: float = 0.0
	
	# 更新云层暗度比例 (调整为24000一天)
	if tick_timer >= 0 and tick_timer < 6000:
		cloud_dark_ratio = 1
	elif tick_timer >= 6000 and tick_timer < 9000:
		cloud_dark_ratio = 1 - ((tick_timer - 6000) / 3000.0)
	elif tick_timer >= 9000 and tick_timer < 17000:
		cloud_dark_ratio = 0
	elif tick_timer >= 17000 and tick_timer <= 20500:
		cloud_dark_ratio = 1 - ((20500 - tick_timer) / 3500.0)
	elif tick_timer >= 20500 and tick_timer <= 24000:
		cloud_dark_ratio = 1
	
	var night_ratio = calculate_current_sky_light(false)
	
	# 更新各个节点的属性
	background_sky.modulate = Color(1, 1, 1, 1 - night_ratio)
	background_cloud.modulate = Color(1, 1, 1, 1 - cloud_dark_ratio)
	background_star.modulate = Color(1, 1, 1, night_ratio)
	mini_map_sky_back.color = lerp(Color(0.443, 0.698, 1),Color(0, 0.008, 0.137),night_ratio)
	mini_map_star_back.modulate = Color(1, 1, 1, night_ratio)

func calculate_current_sky_light(is_init):
	var night_ratio = 1
	# 更新夜晚比例 (调整为24000一天)
	if tick_timer >= 0 and tick_timer < 6000:
		night_ratio = 1
	elif tick_timer >= 6000 and tick_timer < 9000:
		night_ratio = 1 - ((tick_timer - 6000) / 3000.0)
	elif tick_timer >= 9000 and tick_timer < 18000:
		night_ratio = 0
	elif tick_timer >= 18000 and tick_timer <= 21000:
		night_ratio = 1 - ((21000 - tick_timer) / 3000.0)
	elif tick_timer >= 21000 and tick_timer <= 24000:
		night_ratio = 1
	
	var moon_ratio = 0
	if (tick_timer >= 18000 and tick_timer < 24000):
		moon_ratio = (tick_timer - 18000) / 12000.0
	elif (tick_timer >= 0 and tick_timer < 6000):
		moon_ratio = (tick_timer + (24000 - 18000)) / 12000.0
	else:
		moon_ratio = 0.0
	
	var sun_ratio = 0.0
	if tick_timer >= 6000 and tick_timer <= 18000:
		sun_ratio = (tick_timer - 6000) / 12000.0
	else:
		sun_ratio = 0.0
	
	if moon_path.progress_ratio != moon_ratio:
		moon_path.progress_ratio = moon_ratio
	if sun_path.progress_ratio != sun_ratio:
		sun_path.progress_ratio = sun_ratio
	var sky_light: int = 255 * (1 - night_ratio)
	if sky_light < 48:
		sky_light = 48
	if sky_light != current_sky_light:
		if sky_light % 16 == 0 or sky_light == 255 or is_init:
			current_sky_light = sky_light
			refresh_all_light()
	
	return night_ratio

func update_moon_phase():
	var moon_phase = world_day % 8
	var moon_phase_info = StaticLoad.moon_phase_dict[moon_phase]
	moon_path_texture.texture.set_region(Rect2(moon_phase_info[0], moon_phase_info[1], 8, 8))
	var brightness = moon_phase_info[2]
	moon_path_texture.modulate = Color(brightness, brightness, brightness)

func update_hotbar_attack_indicator():
	if player == null:
		return
	if player.attack_timer <= 0:
		if attack_icon.visible:
			attack_icon.visible = false
		return
	if not attack_icon.visible:
		attack_icon.visible = true
	if player.in_hand_item_name.contains("GOLD"):
		attack_indicator_progress.material.set_shader_parameter("progress", max((0.5-player.attack_timer)*2, 0))
	else:
		attack_indicator_progress.material.set_shader_parameter("progress", 1-player.attack_timer)

func update_ui_freeze_timer():
	if ui_freeze_timer > 0:
		ui_freeze_timer -= get_process_delta_time()
	elif ui_freeze_timer < 0:
		ui_freeze_timer = 0

func update_die_no_press_timer():
	if die_no_press_timer > 0:
		die_no_press_timer -= get_process_delta_time()
	elif die_no_press_timer < 0:
		for button in death_ui_flow_container.get_children():
			button.disabled = false
		die_no_press_timer = 0

func update_nature_growth():
	if not StaticLoad.is_muti_mode or (StaticLoad.is_muti_mode and multiplayer.get_unique_id() == 1):
		for chunk_name in loaded_chunks:
			var chunk = loaded_chunks[chunk_name]
			var splits = chunk_name.split(".")
			for dirt_pos in chunk.dirt_list.duplicate():
				var up_block_pos = Vector2i(int(splits[0])*16,int(splits[1])*16-1)+dirt_pos
				var up_block_id = StaticLoad.get_block_id_by_atlas_coords(tile_map_layer.get_cell_atlas_coords(up_block_pos))
				if up_block_id != 0 and not StaticLoad.get_is_transparent_by_id(up_block_id):
					continue
				var dirt_block_pos = Vector2i(int(splits[0])*16,int(splits[1])*16)+dirt_pos
				if not check_has_nearby_grass_block(dirt_block_pos):
					continue
				var rng = RandomNumberGenerator.new()
				var num = rng.randf()
				if num > 0.7:
					chunk.dirt_list.erase(dirt_pos)
					set_block(dirt_block_pos, StaticLoad.get_block_id_by_name("GRASS_BLOCK"), "solid", true)
					if StaticLoad.is_muti_mode and multiplayer.get_unique_id() == 1:
						StaticLoad.rpc("set_block", [dirt_block_pos, StaticLoad.get_block_id_by_name("GRASS_BLOCK"), "solid", true])
			for grass_pos in chunk.grass_block_list.duplicate():
				var up_block_pos = Vector2i(int(splits[0])*16,int(splits[1])*16-1)+grass_pos
				var up_block_id = StaticLoad.get_block_id_by_atlas_coords(tile_map_layer.get_cell_atlas_coords(up_block_pos))
				if up_block_id == 0 or StaticLoad.get_is_transparent_by_id(up_block_id):
					continue
				var grass_block_pos = Vector2i(int(splits[0])*16,int(splits[1])*16)+grass_pos
				var rng = RandomNumberGenerator.new()
				var num = rng.randf()
				if num > 0.7:
					chunk.grass_block_list.erase(grass_pos)
					set_block(grass_block_pos, StaticLoad.get_block_id_by_name("DIRT"), "solid", true)
					if StaticLoad.is_muti_mode and multiplayer.get_unique_id() == 1:
						StaticLoad.rpc("set_block", [grass_block_pos, StaticLoad.get_block_id_by_name("DIRT"), "solid", true])
			for farm_land_pos in chunk.farm_land_list.duplicate():
				var up_block_pos = Vector2i(int(splits[0])*16,int(splits[1])*16-1)+farm_land_pos
				var up_block_id = StaticLoad.get_block_id_by_atlas_coords(tile_map_layer.get_cell_atlas_coords(up_block_pos))
				if up_block_id == 0 or StaticLoad.get_is_transparent_by_id(up_block_id):
					continue
				var farm_land_block_pos = Vector2i(int(splits[0])*16,int(splits[1])*16)+farm_land_pos
				var rng = RandomNumberGenerator.new()
				var num = rng.randf()
				if num > 0.7:
					chunk.farm_land_list.erase(farm_land_pos)
					set_block(farm_land_block_pos, StaticLoad.get_block_id_by_name("DIRT"), "solid", true)
					if StaticLoad.is_muti_mode and multiplayer.get_unique_id() == 1:
						StaticLoad.rpc("set_block", [farm_land_block_pos, StaticLoad.get_block_id_by_name("DIRT"), "solid", true])
			for leaves_pos in chunk.leaves_list.duplicate():
				var rng = RandomNumberGenerator.new()
				var num = rng.randf()
				if num > 0.7:
					chunk.leaves_list.erase(leaves_pos)
					var leaves_block_pos = Vector2i(int(splits[0])*16,int(splits[1])*16)+leaves_pos
					set_block_list.append([Time.get_ticks_msec(), "destroy", 0, leaves_block_pos, "no_reach", false])
					var chunk_pos = get_chunk_position(leaves_block_pos)
					update_chunk_light_by_pos(chunk_pos)
					if StaticLoad.is_muti_mode and multiplayer.get_unique_id() == 1:
						rpc("update_chunk_light_by_pos", chunk_pos)
			for seed_pos in chunk.seed_list.duplicate():
				var seed_block_pos = Vector2i(int(splits[0])*16,int(splits[1])*16)+seed_pos
				var rng = RandomNumberGenerator.new()
				var num = rng.randf()
				if num > 0.7:
					var seed_block_id = StaticLoad.get_block_id_by_atlas_coords(tile_map_layer.get_cell_atlas_coords(seed_block_pos))
					var seed_block_name = StaticLoad.get_block_name_by_id(seed_block_id)
					if seed_block_name.contains("STAGE"):
						var seed_name_splits = seed_block_name.split("_")
						var next_stage_num = int(seed_name_splits[-1])+1
						if next_stage_num > 7:
							chunk.seed_list.erase(seed_pos)
							continue
						var next_stage_name: String
						for i in range(seed_name_splits.size()-1):
							next_stage_name += seed_name_splits[i] + "_"
						next_stage_name += str(next_stage_num)
						set_block(seed_block_pos, StaticLoad.get_block_id_by_name(next_stage_name), "solid", true)
						if next_stage_num == 7:
							chunk.seed_list.erase(seed_pos)
						if StaticLoad.is_muti_mode and multiplayer.get_unique_id() == 1:
							StaticLoad.rpc("set_block", [seed_block_pos, StaticLoad.get_block_id_by_name(next_stage_name), "solid", true])
					else:
						chunk.seed_list.erase(seed_pos)
			for sapling_pos in chunk.sapling_list.duplicate():
				var x_pos = sapling_pos[0]
				var y_pos = sapling_pos[1]
				if not(y_pos-5>=0 and x_pos-2>=0 and x_pos+2<=15):
					chunk.sapling_list.erase(sapling_pos)
					continue
				for i in range(3):
					var to_set_block_pos = Vector2i(int(splits[0])*16,int(splits[1])*16)+sapling_pos+Vector2i(0,-i)
					var to_set_block_id = StaticLoad.get_block_id_by_atlas_coords(tile_map_layer.get_cell_atlas_coords(to_set_block_pos))
					if to_set_block_id != 0 and not StaticLoad.get_block_name_by_id(to_set_block_id).contains("SAPLING"):
						chunk.sapling_list.erase(sapling_pos)
						continue
				for j in range(-2,3):
					var to_set_block_pos = Vector2i(int(splits[0])*16,int(splits[1])*16)+sapling_pos+Vector2i(j,-3)
					var to_set_block_id = StaticLoad.get_block_id_by_atlas_coords(tile_map_layer.get_cell_atlas_coords(to_set_block_pos))
					if to_set_block_id != 0 and not StaticLoad.get_block_name_by_id(to_set_block_id).contains("SAPLING"):
						chunk.sapling_list.erase(sapling_pos)
						continue
				for j in range(-1,2):
					var to_set_block_pos = Vector2i(int(splits[0])*16,int(splits[1])*16)+sapling_pos+Vector2i(j,-4)
					var to_set_block_id = StaticLoad.get_block_id_by_atlas_coords(tile_map_layer.get_cell_atlas_coords(to_set_block_pos))
					if to_set_block_id != 0 and not StaticLoad.get_block_name_by_id(to_set_block_id).contains("SAPLING"):
						chunk.sapling_list.erase(sapling_pos)
						continue
				var rng = RandomNumberGenerator.new()
				var num = rng.randf()
				if num > 0.7:
					chunk.sapling_list.erase(sapling_pos)
					for i in range(3):
						var to_set_block_pos = Vector2i(int(splits[0])*16,int(splits[1])*16)+sapling_pos+Vector2i(0,-i)
						set_block(to_set_block_pos, StaticLoad.get_block_id_by_name("LOG_OAK"), "no_reach", true)
						if StaticLoad.is_muti_mode and multiplayer.get_unique_id() == 1:
							StaticLoad.rpc("set_block", [to_set_block_pos, StaticLoad.get_block_id_by_name("LOG_OAK"), "no_reach", true])
						if i == 0:
							set_block(to_set_block_pos, StaticLoad.get_block_id_by_name("AIR"), "solid", true)
							if StaticLoad.is_muti_mode and multiplayer.get_unique_id() == 1:
								StaticLoad.rpc("set_block", [to_set_block_pos, StaticLoad.get_block_id_by_name("AIR"), "solid", true])
					for j in range(-2,3):
						var to_set_block_pos = Vector2i(int(splits[0])*16,int(splits[1])*16)+sapling_pos+Vector2i(j,-3)
						var no_reach_block_id = StaticLoad.get_block_id_by_atlas_coords(no_reach_tile_map_layer.get_cell_atlas_coords(to_set_block_pos))
						if no_reach_block_id == StaticLoad.get_block_id_by_name("LOG_OAK"):
							continue
						set_block(to_set_block_pos, StaticLoad.get_block_id_by_name("LEAVES"), "no_reach", true)
						if StaticLoad.is_muti_mode and multiplayer.get_unique_id() == 1:
							StaticLoad.rpc("set_block", [to_set_block_pos, StaticLoad.get_block_id_by_name("LEAVES"), "no_reach", true])
					for j in range(-1,2):
						var to_set_block_pos = Vector2i(int(splits[0])*16,int(splits[1])*16)+sapling_pos+Vector2i(j,-4)
						var no_reach_block_id = StaticLoad.get_block_id_by_atlas_coords(no_reach_tile_map_layer.get_cell_atlas_coords(to_set_block_pos))
						if no_reach_block_id == StaticLoad.get_block_id_by_name("LOG_OAK"):
							continue
						set_block(to_set_block_pos, StaticLoad.get_block_id_by_name("LEAVES"), "no_reach", true)
						if StaticLoad.is_muti_mode and multiplayer.get_unique_id() == 1:
							StaticLoad.rpc("set_block", [to_set_block_pos, StaticLoad.get_block_id_by_name("LEAVES"), "no_reach", true])
					var chunk_pos = get_chunk_position(Vector2i(int(splits[0])*16,int(splits[1])*16)+sapling_pos)
					await get_tree().process_frame
					update_chunk_light_by_pos(chunk_pos)
					if StaticLoad.is_muti_mode and multiplayer.get_unique_id() == 1:
						rpc("update_chunk_light_by_pos", chunk_pos)
			for sugar_cane_pos in chunk.sugar_cane_list.duplicate():
				var sugar_cane_block_pos = Vector2i(int(splits[0])*16,int(splits[1])*16)+sugar_cane_pos
				var top_block_pos = sugar_cane_block_pos+Vector2i(0,-2)
				var top_chunk_pos = get_chunk_position(top_block_pos)
				if loaded_chunks.has(str(top_chunk_pos[0])+"."+str(top_chunk_pos[1])):
					var top_block_id = StaticLoad.get_block_id_by_atlas_coords(no_reach_tile_map_layer.get_cell_atlas_coords(top_block_pos))
					if StaticLoad.get_block_name_by_id(top_block_id) == "REEDS":
						continue
				var rng = RandomNumberGenerator.new()
				var num = rng.randf()
				if num > 0.7:
					for i in range(1,3):
						var to_set_block_pos = sugar_cane_block_pos+Vector2i(0,-i)
						var chunk_pos = get_chunk_position(to_set_block_pos)
						if not loaded_chunks.has(str(chunk_pos[0])+"."+str(chunk_pos[1])):
							break
						var solid_block_id = StaticLoad.get_block_id_by_atlas_coords(tile_map_layer.get_cell_atlas_coords(to_set_block_pos))
						if solid_block_id != 0:
							break
						var no_reach_block_id = StaticLoad.get_block_id_by_atlas_coords(no_reach_tile_map_layer.get_cell_atlas_coords(to_set_block_pos))
						if no_reach_block_id != 0:
							break
						set_block(to_set_block_pos, StaticLoad.get_block_id_by_name("REEDS"), "solid", true)
						if StaticLoad.is_muti_mode and multiplayer.get_unique_id() == 1:
							StaticLoad.rpc("set_block", [to_set_block_pos, StaticLoad.get_block_id_by_name("REEDS"), "solid", true])

func check_has_nearby_grass_block(block_pos):
	var is_has_nearby_grass_block = false
	for selection in ["left", "right"]:
		if selection == "left":
			var chunk_pos_tmp = get_chunk_position(block_pos+Vector2i(-1,0))
			if not loaded_chunks.has(str(chunk_pos_tmp[0])+"."+str(chunk_pos_tmp[1])):
				continue
			for i in [-1, 0, 1]:
				var left_block_id = StaticLoad.get_block_id_by_atlas_coords(tile_map_layer.get_cell_atlas_coords(block_pos+Vector2i(-1, i)))
				if left_block_id == StaticLoad.get_block_id_by_name("GRASS_BLOCK"):
					is_has_nearby_grass_block = true
					break
		elif selection == "right":
			var chunk_pos_tmp = get_chunk_position(block_pos+Vector2i(1,0))
			if not loaded_chunks.has(str(chunk_pos_tmp[0])+"."+str(chunk_pos_tmp[1])):
				continue
			for i in [-1, 0, 1]:
				var left_block_id = StaticLoad.get_block_id_by_atlas_coords(tile_map_layer.get_cell_atlas_coords(block_pos+Vector2i(1, i)))
				if left_block_id == StaticLoad.get_block_id_by_name("GRASS_BLOCK"):
					is_has_nearby_grass_block = true
					break
		if is_has_nearby_grass_block:
			return is_has_nearby_grass_block
	return is_has_nearby_grass_block

func append_process_refresh(string):
	if not refresh_to_process.has(string):
		refresh_to_process.append(string)
	else:
		refresh_to_process_double.append(string)

func refresh_around_light(chunk_name):
	is_light_pause = true
	#for chunk_light_name in chunk_lights:
		#var splits = chunk_light_name.split(".")
		#if not chunk_sky_light_datas.has(splits[0]+"."+str(int(splits[1])-1)):
			#var sky_light: PackedByteArray
			#sky_light.resize(16)
			#sky_light.fill(current_sky_light)
			#chunk_sky_light_datas[chunk_light_name] = sky_light
	var splits = chunk_name.split(".")
	var chunk_pos = Vector2i(int(splits[0]), int(splits[1]))
	var refresh_chunk_list = []
	
	#if StaticLoad.game.chunk_lights.has(str(chunk_pos[0])+"."+str(chunk_pos[1])):
		#refresh_chunk_list.append(str(chunk_pos[0])+"."+str(chunk_pos[1]))
	if StaticLoad.game.chunk_lights.has(str(chunk_pos[0])+"."+str(chunk_pos[1]-1)):
		refresh_chunk_list.append(str(chunk_pos[0])+"."+str(chunk_pos[1]-1))
	if StaticLoad.game.chunk_lights.has(str(chunk_pos[0])+"."+str(chunk_pos[1]+1)):
		refresh_chunk_list.append(str(chunk_pos[0])+"."+str(chunk_pos[1]+1))
	if StaticLoad.game.chunk_lights.has(str(chunk_pos[0]-1)+"."+str(chunk_pos[1])):
		refresh_chunk_list.append(str(chunk_pos[0]-1)+"."+str(chunk_pos[1]))
	if StaticLoad.game.chunk_lights.has(str(chunk_pos[0]+1)+"."+str(chunk_pos[1])):
		refresh_chunk_list.append(str(chunk_pos[0]+1)+"."+str(chunk_pos[1]))
	
	
	#var wait_timer = 0
	#while wait_timer < 0.01:
		#wait_timer += get_process_delta_time()
	if StaticLoad.game.chunk_lights.has(str(chunk_pos[0]+1)+"."+str(chunk_pos[1]+1)):
		refresh_chunk_list.append(str(chunk_pos[0]+1)+"."+str(chunk_pos[1]+1))
	if StaticLoad.game.chunk_lights.has(str(chunk_pos[0]+1)+"."+str(chunk_pos[1]-1)):
		refresh_chunk_list.append(str(chunk_pos[0]+1)+"."+str(chunk_pos[1]-1))
	if StaticLoad.game.chunk_lights.has(str(chunk_pos[0]-1)+"."+str(chunk_pos[1]+1)):
		refresh_chunk_list.append(str(chunk_pos[0]-1)+"."+str(chunk_pos[1]+1))
	if StaticLoad.game.chunk_lights.has(str(chunk_pos[0]-1)+"."+str(chunk_pos[1]-1)):
		refresh_chunk_list.append(str(chunk_pos[0]-1)+"."+str(chunk_pos[1]-1))
	for chunk_light_name in refresh_chunk_list:
		if chunk_lights.has(chunk_light_name):
			if not chunk_light_to_process.has(chunk_light_name):
				chunk_light_to_process[chunk_light_name] = "null"
			else:
				chunk_light_to_process_double[chunk_light_name] = "null"
		else:
			chunk_light_to_process[chunk_light_name] = "create"
	is_light_pause = false

func refresh_all_light():
	is_light_pause = true
	for chunk_light_name in chunk_lights:
		var splits = chunk_light_name.split(".")
		if not chunk_sky_light_datas.has(splits[0]+"."+str(int(splits[1])-1)):
			var sky_light: PackedByteArray
			sky_light.resize(16)
			sky_light.fill(current_sky_light)
			chunk_sky_light_datas[chunk_light_name] = sky_light
	for chunk_light_name in loaded_chunks:
		if chunk_lights.has(chunk_light_name):
			if not chunk_light_to_process.has(chunk_light_name):
				chunk_light_to_process[chunk_light_name] = "null"
			else:
				chunk_light_to_process_double[chunk_light_name] = "null"
		else:
			chunk_light_to_process[chunk_light_name] = "create"
	is_light_pause = false

func process_dispatch():
	while(true):
		if not StaticLoad.is_in_game:
			break
		await get_tree().create_timer(StaticLoad.DISPATCH_DELTA_TIME).timeout
		dispatch_all_entity_state_dict()
		dispatch_set_block_state_dict()	

func process_set_block():
	while(true):
		if not StaticLoad.is_in_game:
			break
		await get_tree().process_frame
		if set_block_list.is_empty():
			continue
		var success_set_block_dict_tmp = {}
		#var fail_set_block_list_tmp = []
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
					success_set_block_dict_tmp[pos_string][2] = set_block_id
					success_set_block_dict_tmp[pos_string][3] = set_block_pos
					success_set_block_dict_tmp[pos_string][4] = set_block_layer
					#if uuid == "destroy" or set_time < success_set_block_dict_tmp[pos_string][0]:
						#success_set_block_dict_tmp[pos_string][2] = set_block_id
						#success_set_block_dict_tmp[pos_string][3] = set_block_pos
						#success_set_block_dict_tmp[pos_string][4] = set_block_layer
						#fail_set_block_list_tmp.append(success_set_block_dict_tmp[pos_string])
						#success_set_block_dict_tmp[pos_string] = set_block_info
					#else:
						#set_block_info[2] = success_set_block_dict_tmp[pos_string][2]
						#set_block_info[3] = success_set_block_dict_tmp[pos_string][3]
						#set_block_info[4] = success_set_block_dict_tmp[pos_string][4]
						#fail_set_block_list_tmp.append(set_block_info)
			else:
				success_set_block_dict_tmp[pos_string] = set_block_info
			set_block_list.erase(set_block_info)
		success_set_block_dict.merge(success_set_block_dict_tmp, true)
		#fail_set_block_list.append_array(fail_set_block_list_tmp)
		for pos_string in success_set_block_dict_tmp:
			var set_time = success_set_block_dict_tmp[pos_string][0]
			var uuid = success_set_block_dict_tmp[pos_string][1]
			var set_block_id = success_set_block_dict_tmp[pos_string][2]
			var set_block_pos = success_set_block_dict_tmp[pos_string][3]
			var set_block_layer = success_set_block_dict_tmp[pos_string][4]
			var is_to_sync = success_set_block_dict_tmp[pos_string][5]
			var chunk_pos = get_chunk_position(set_block_pos)
			var block_to_destroy_id = 0
			if set_block_layer == "back":
				block_to_destroy_id = StaticLoad.get_block_id_by_atlas_coords(back_tile_map_layer.get_cell_atlas_coords(set_block_pos))
			else:
				block_to_destroy_id = StaticLoad.get_block_id_by_atlas_coords(tile_map_layer.get_cell_atlas_coords(set_block_pos))
				if block_to_destroy_id == 0:
					block_to_destroy_id = StaticLoad.get_block_id_by_atlas_coords(no_reach_tile_map_layer.get_cell_atlas_coords(set_block_pos))
			var in_hand_item_name = "AIR"
			if uuid != "destroy":
				var entity = entities[uuid]
				if entity.get_entity_type() == "player":
					in_hand_item_name = entity.in_hand_item_name
					if StaticLoad.tools_type.has(in_hand_item_name):
						if not StaticLoad.is_muti_mode or (StaticLoad.is_muti_mode and uuid == player.get_uuid()):
							var is_to_wear = true
							var to_destroy_block_name = StaticLoad.get_block_name_by_id(block_to_destroy_id)
							if entity.gamemode == "creative":
								is_to_wear = false
							elif StaticLoad.special_block_destroy_time.has(to_destroy_block_name) and StaticLoad.special_block_destroy_time[to_destroy_block_name] < 0.1:
								is_to_wear = false
							elif StaticLoad.tools_type[in_hand_item_name].has("hoe"):
								is_to_wear = false
							if is_to_wear:
								entity.wear_and_update_in_hand_tool(1, false)
									
			var droppped_item_list = StaticLoad.get_dropped_item_by_name("block", StaticLoad.get_block_name_by_id(block_to_destroy_id), in_hand_item_name)
			if not StaticLoad.is_muti_mode or (StaticLoad.is_muti_mode and multiplayer.get_unique_id() == 1):
				if uuid != "destroy":
					#if not nearby_update_dict.has(set_block_pos):
						#nearby_update_dict[set_block_pos] = "before"
					#else:
						#nearby_update_double_dict[set_block_pos] = "before"
					update_nearby_block_state(set_block_pos, "before")
			if StaticLoad.get_block_name_by_id(block_to_destroy_id) == "GRASS_BLOCK" and StaticLoad.get_block_name_by_id(set_block_id) == "FARM_LAND":
				var rng = RandomNumberGenerator.new()
				var num = rng.randf()
				if num > 0.7:
					var item_pos = tile_map_layer.map_to_local(set_block_pos)-Vector2(0, 25)
					var summon_item_args = ["item", "SEEDS_WHEAT", item_pos, 1, 0, 0, UUID.v4()]
					if StaticLoad.is_muti_mode:
						if multiplayer.get_unique_id() == 1:
							StaticLoad.create_entity(summon_item_args)
							#StaticLoad.rpc("create_entity", summon_item_args)
					else:
						StaticLoad.create_entity(summon_item_args)
			if set_block(set_block_pos, set_block_id, set_block_layer):
				if set_block_id == 0 and uuid != "destroy":
					var entity = entities[uuid]
					if entity.get_entity_type() == "player" and entity.gamemode != "creative":
						summon_destroy_particle(tile_map_layer.map_to_local(set_block_pos), "block", StaticLoad.get_block_name_by_id(block_to_destroy_id))
				update_chunk_light_by_pos(chunk_pos)
				if StaticLoad.is_muti_mode and multiplayer.get_unique_id() == 1:
					rpc("update_chunk_light_by_pos", chunk_pos)
				if not StaticLoad.is_muti_mode or (StaticLoad.is_muti_mode and multiplayer.get_unique_id() == 1):
					if uuid != "destroy":
						#if not nearby_update_dict.has(set_block_pos):
							#nearby_update_dict[set_block_pos] = "after"
						#else:
							#nearby_update_double_dict[set_block_pos] = "after"
						update_nearby_block_state(set_block_pos, "after")
				#if StaticLoad.is_on_mobile_platform:
					#Input.vibrate_handheld(100, 0.5)
				if loaded_chunks.has(str(chunk_pos[0])+"."+str(chunk_pos[1])):
					loaded_chunks[str(chunk_pos[0])+"."+str(chunk_pos[1])].is_to_save = true
					loaded_chunks_timer[str(chunk_pos[0])+"."+str(chunk_pos[1])] = StaticLoad.CHUNK_FREE_TIME
				if uuid == "destroy":
					for droppped_item_name in droppped_item_list:
						if droppped_item_name != "AIR" and droppped_item_list[droppped_item_name] > 0:
							var item_pos = tile_map_layer.map_to_local(set_block_pos)+Vector2(0, 25)
							var summon_item_args = ["item", droppped_item_name, item_pos, droppped_item_list[droppped_item_name], 0, 0, UUID.v4()]
							if StaticLoad.is_muti_mode:
								if multiplayer.get_unique_id() == 1:
									StaticLoad.create_entity(summon_item_args)
									#StaticLoad.rpc("create_entity", summon_item_args)
							else:
								StaticLoad.create_entity(summon_item_args)
					if StaticLoad.is_muti_mode:
						if multiplayer.get_unique_id() == 1:
							StaticLoad.rpc("set_block", [set_block_pos, 0, set_block_layer, false])
				else:
					var entity = entities[uuid]
					if entity.get_entity_type() == "player":
						if entity.face_state < 0 and tile_map_layer.local_to_map(entity.position).x < set_block_pos.x:
							entity.face_state = 1
						elif entity.face_state > 0 and tile_map_layer.local_to_map(entity.position).x > set_block_pos.x:
							entity.face_state = -1
						if not StaticLoad.is_muti_mode or (StaticLoad.is_muti_mode and multiplayer.get_unique_id() == entity.player_peer_id):
							set_block_selection_pos(tile_map_layer.map_to_local(set_block_pos), true)
						if set_block_id == 0 and entity.gamemode != "creative":
							for droppped_item_name in droppped_item_list:
								if droppped_item_name != "AIR" and droppped_item_list[droppped_item_name] > 0:
									var item_pos = tile_map_layer.map_to_local(set_block_pos)+Vector2(0, 25)
									var summon_item_args = [droppped_item_name, item_pos, droppped_item_list[droppped_item_name], 0, 0, UUID.v4()]
									if StaticLoad.is_muti_mode:
										if multiplayer.get_unique_id() == 1:
											entity.summon_item(summon_item_args)
											StaticLoad.rpc_entity_func_by_uuid(entity.get_uuid(), "summon_item", summon_item_args, "others", true)
									else:
										entity.summon_item(summon_item_args)
							entity.destroy_timer = 0
							if destroy_light_names.has(entity.player_peer_id):
								destroy_light_names[player.player_peer_id].set_texture(null)
						elif set_block_id != 0:
							if entity.gamemode != "creative":
								if entity.in_hand_item_name.contains("HOE"):
									if not StaticLoad.is_muti_mode or (StaticLoad.is_muti_mode and uuid == player.get_uuid()):
										entity.wear_and_update_in_hand_tool(1, false)
								else:
									if entity.item_bar_amounts[entity.selected_item_grid] >= 1:
										entity.item_bar_amounts[entity.selected_item_grid] -= 1
									if entity.item_bar_amounts[entity.selected_item_grid] <= 0:
										entity.item_bar_names[entity.selected_item_grid] = "AIR"
										entity.item_bar_amounts[entity.selected_item_grid] = 0
										item_name_timer = 0
								refresh_item_grid(entity.selected_item_grid)
								inventory_show_grids.get_node("InventoryGrid"+str(entity.selected_item_grid)).init_inventory_grid(entity.item_bar_names[entity.selected_item_grid], entity.item_bar_amounts[entity.selected_item_grid])
						if is_to_sync and multiplayer.get_unique_id() != 1:
							if multiplayer.get_unique_id() == entity.player_peer_id:
								var player_set_block_info = [set_block_id, set_block_pos, set_block_layer]
								entity.success_set_block_list.append(player_set_block_info)

func process_entity_save():
	if StaticLoad.is_muti_mode and multiplayer.get_unique_id() != 1:
		return
	for uuid in entities:
		var entity = entities[uuid]
		if entity == null:
			continue
		if entity.get_entity_type() == "player":
			continue
		if frozen_entity_dict.has(uuid):
			continue
		var current_entity_pos = entity.position
		var current_chunk_pos = get_chunk_position(tile_map_layer.local_to_map(current_entity_pos))
		var last_chunk_pos = entity.get_chunk_pos()
		if current_chunk_pos != last_chunk_pos:
			var current_chunk_name = str(current_chunk_pos[0])+"."+str(current_chunk_pos[1])
			var last_chunk_name = str(last_chunk_pos[0])+"."+str(last_chunk_pos[1])
			if loaded_chunks.has(current_chunk_name) and loaded_chunks[current_chunk_name].is_loaded:
				loaded_chunks[current_chunk_name].entity_list.append(entity.get_uuid())
				loaded_chunks[current_chunk_name].is_to_save = true
				if loaded_chunks.has(last_chunk_name):
					loaded_chunks[last_chunk_name].entity_list.erase(entity.get_uuid())
					loaded_chunks[last_chunk_name].is_to_save = true
				entity.chunk_pos = current_chunk_pos
			else:
				entity.freeze()
				entity.position = entity.last_pos
				if not frozen_entity_dict.has(current_chunk_name):
					frozen_entity_dict[current_chunk_name] = []
				frozen_entity_dict[current_chunk_name].append(entity.get_uuid())
		else:
			entity.last_pos = current_entity_pos
			
func dispatch_set_block_state_dict():
	if not StaticLoad.is_muti_mode:
		return
	if not multiplayer.get_unique_id() == 1:
		return
	for pos_string in success_set_block_dict:
		var set_time = success_set_block_dict[pos_string][0]
		var uuid = success_set_block_dict[pos_string][1]
		var set_block_id = success_set_block_dict[pos_string][2]
		var set_block_pos = success_set_block_dict[pos_string][3]
		var set_block_layer = success_set_block_dict[pos_string][4]
		var is_to_sync = success_set_block_dict[pos_string][5]
		var except_player_id_list = []
		if uuid == "destroy":
			pass
		else:
			if entities[uuid].get_entity_type() == "player":
				except_player_id_list.append(entities[uuid].player_peer_id)
			StaticLoad.rpc_entity_func_by_uuid(uuid, "set_block", [set_block_id, set_block_pos, set_block_layer], except_player_id_list, false)
		success_set_block_dict.erase(pos_string)
	
	#for fail_info in fail_set_block_list:
		#var set_time = fail_info[0]
		#var uuid = fail_info[1]
		#var set_block_id = fail_info[2]
		#var set_block_pos = fail_info[3]
		#var set_block_layer = fail_info[4]
		#var is_to_sync = fail_info[5]
		#if uuid == "destroy":
			#fail_set_block_list.erase(fail_info)
			#continue
		#if entities[uuid].get_entity_type() == "player":
			#var player_tmp = entities[uuid]
			#var item_bar_names = player_tmp.item_bar_names
			#var item_bar_amounts = player_tmp.item_bar_amounts
			#StaticLoad.rpc_entity_func_by_uuid(uuid, "fail_set_block", [set_block_id, set_block_pos, set_block_layer, item_bar_names, item_bar_amounts], [player_tmp.player_peer_id], true)
		#fail_set_block_list.erase(fail_info)

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

func update_health_hunger_bar():
	if player.gamemode == "creative":
		health_bar.visible = false
		hunger_bar.visible = false
	elif player.gamemode == "survival":
		health_bar.visible = true
		hunger_bar.visible = true
	if player.is_flying:
		player.is_flying = false
	
func process_light():
	while(true):
		if not StaticLoad.is_in_game:
			break
		await get_tree().process_frame
		if is_light_pause:
			continue
		var chunk_light_to_process_tmp = chunk_light_to_process.duplicate()
		if chunk_light_to_process_tmp.is_empty():
			if not chunk_light_to_process_double.is_empty():
				chunk_light_to_process = chunk_light_to_process_double.duplicate()
				chunk_light_to_process_double.clear()
			continue
		else:
			for chunk_light_name in chunk_light_to_process_tmp:
				#if not chunk_sky_light_datas.has(chunk_light_name):
					#continue
				var splits = chunk_light_name.split(".")
				if not chunk_sky_light_datas.has(splits[0]+"."+str(int(splits[1])-1)):
					var sky_light: PackedByteArray
					sky_light.resize(16)
					sky_light.fill(current_sky_light)
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
				if get_tree() == null:
					return
				#await get_tree().process_frame
				chunk_light_to_process.erase(chunk_light_name)
				break

func process_refresh():
	while(true):
		if not StaticLoad.is_in_game:
			break
		await get_tree().process_frame
		var refresh_to_process_tmp = refresh_to_process
		if refresh_to_process_tmp.is_empty():
			if not refresh_to_process_double.is_empty():
				refresh_to_process = refresh_to_process_double.duplicate()
				refresh_to_process_double.clear()
			continue
		else:
			for key in refresh_to_process_tmp:
				if key == "refresh_item_grid":
					for i in range(9):
						refresh_item_grid(i)
						if get_tree() == null:
							break
						await get_tree().process_frame
					refresh_to_process.erase(key)
				elif key == "refresh_inventory":
					refresh_inventory()
					refresh_to_process.erase(key)
				elif key == "refresh_crafting_inventory":
					refresh_crafting_inventory()
					refresh_to_process.erase(key)
				elif key == "refresh_item_name_label":
					var item_name = player.item_bar_names[player.selected_item_grid]
					if item_name != "AIR":
						item_name_label.text = item_name
						item_name_timer = StaticLoad.ITEM_NAME_SHOW_TIME
						refresh_to_process.erase(key)

func process_item():
	while(true):
		if not StaticLoad.is_in_game:
			break
		await get_tree().process_frame
		var item_to_combine_tmp = item_to_combine.duplicate()
		if item_to_combine_tmp.is_empty():
			continue
		for item1_uuid in item_to_combine_tmp:
			if not items.has_node(str(item1_uuid)):
				continue
			var item1 = items.get_node(str(item1_uuid))
			if item1 == null:
				item_to_combine.erase(item1_uuid)
				continue
			var item2_uuid = item_to_combine[item1_uuid]
			item1.combine_item(item2_uuid)
			item_to_combine.erase(item1_uuid)
			if StaticLoad.is_muti_mode and multiplayer.get_unique_id() == 1:
				StaticLoad.rpc_entity_func_by_uuid(item1.get_uuid(), "combine_item", item2_uuid, "others", true)

func dispatch_all_entity_state_dict():
	if not StaticLoad.is_muti_mode:
		return
	if not multiplayer.get_unique_id() == 1:
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
			if peer_id == 1 and multiplayer.get_unique_id() == 1:
				continue
			elif multiplayer.get_unique_id() == 1:
				StaticLoad.ping_peer_dict[peer_id].start_ping()
				continue
			StaticLoad.rpc_id(1, "request_for_ping", multiplayer.get_unique_id(), peer_id)
			continue
		var player_tmp = StaticLoad.player_peer_dict[peer_id]
		var online_info_instance = online_info_scene.instantiate()
		online_ui_vbox_container.add_child(online_info_instance)
		online_info_instance.name = str(peer_id)
		online_info_instance.player_name.text = player_tmp.player_name
		if peer_id == 1 and multiplayer.get_unique_id() == 1:
			online_info_instance.animation.animation = "signal"
			online_info_instance.animation.frame = StaticLoad.get_level_by_ping(0)
		elif multiplayer.get_unique_id() == 1:
			StaticLoad.ping_peer_dict[peer_id].start_ping()
		else:
			StaticLoad.rpc_id(1, "request_for_ping", multiplayer.get_unique_id(), peer_id)

func decline_table_crafting_material(decline_amount):
	for y in range(3):
		for x in range(3):
			var craft_grid = table_craft_grid.get_node("Craft"+str(y*3+x))
			craft_grid.item_amount -= decline_amount
			if craft_grid.item_amount <= 0:
				craft_grid.item_name = "AIR"
			craft_grid.update_progress_bar(craft_grid.item_name, craft_grid.item_amount)
			craft_grid.init_inventory_grid(craft_grid.item_name, craft_grid.item_amount)
			
func refresh_table_crafting_result():
	var is_final_found = false
	for item in StaticLoad.crafting_recipe_dict:
		var recipe_list = StaticLoad.crafting_recipe_dict[item]
		for recipe in recipe_list:
			var is_found = false
			var splits = recipe[0].split("-")
			var location_list := []
			if splits[0] == "0":
				location_list = [Vector2i(0, 0)]
			elif splits[0] == "1":
				location_list = [Vector2i(0, 0), Vector2i(0, 1)]
			elif splits[0] == "2":
				location_list = [Vector2i(0, 0), Vector2i(1, 0)]
			elif splits[0] == "3":
				location_list = [Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2)]
			elif splits[0] == "4":
				location_list = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)]
			elif splits[0] == "5":
				location_list = [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 0), Vector2i(1, 1)]
			elif splits[0] == "6":
				location_list = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2), Vector2i(1, 2)]
			elif splits[0] == "7":
				location_list = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)]
			elif splits[0] == "8":
				location_list = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2)]
			if location_list.is_empty():
				continue
			for y in range(3):
				for x in range(3):
					var is_recipe_matched = true
					for location_index in range(location_list.size()):
						var location = location_list[location_index]
						if location[0]+x >= 3:
							is_recipe_matched = false
							break
						if location[1]+y >= 3:
							is_recipe_matched = false
							break
						var item_name = table_craft_grid.get_node("Craft"+str((y+location[1])*3+(x+location[0]))).item_name
						if item_name != recipe[location_index+1]:
							is_recipe_matched = false
							break
					if is_recipe_matched:
						var is_recipe_disrupt = false
						for y_other in range(3):
							for x_other in range(3):
								var is_repeated = false
								for location_tmp in location_list:
									if location_tmp[0]+x >= 3:
										continue
									if location_tmp[1]+y >= 3:
										continue
									if x_other == location_tmp[0]+x and y_other == location_tmp[1]+y:
										is_repeated = true
										break
								if is_repeated:
									continue
								var item_name_tmp = table_craft_grid.get_node("Craft"+str(y_other*3+x_other)).item_name
								if item_name_tmp != "AIR":
									is_recipe_disrupt = true
									break
							if is_recipe_disrupt:
								break
						if not is_recipe_disrupt:
							is_found = true
							break
					if is_found:
						break
				if is_found:
					break
			if is_found:
				var target_amount = int(splits[1])
				if StaticLoad.get_is_durable_by_name(item):
					target_amount = StaticLoad.get_max_amount_by_name(item)
				table_craft_result_grid.init_inventory_grid(item, target_amount)
				is_final_found = true
				break
	if not is_final_found:
		table_craft_result_grid.init_inventory_grid("AIR", 0)

func decline_inventory_crafting_material(decline_amount):
	for y in range(2):
		for x in range(2):
			var craft_grid = inventory_craft_grid.get_node("Craft"+str(y*3+x))
			craft_grid.item_amount -= decline_amount
			if craft_grid.item_amount <= 0:
				craft_grid.item_name = "AIR"
			craft_grid.update_progress_bar(craft_grid.item_name, craft_grid.item_amount)
			craft_grid.init_inventory_grid(craft_grid.item_name, craft_grid.item_amount)
			
func refresh_inventory_crafting_result():
	var is_final_found = false
	for item in StaticLoad.crafting_recipe_dict:
		var recipe_list = StaticLoad.crafting_recipe_dict[item]
		for recipe in recipe_list:
			var is_found = false
			var splits = recipe[0].split("-")
			var location_list := []
			if splits[0] == "0":
				location_list = [Vector2i(0, 0)]
			elif splits[0] == "1":
				location_list = [Vector2i(0, 0), Vector2i(0, 1)]
			elif splits[0] == "2":
				location_list = [Vector2i(0, 0), Vector2i(1, 0)]
			#elif splits[0] == "3":
				#location_list = [Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2)]
			#elif splits[0] == "4":
				#location_list = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)]
			elif splits[0] == "5":
				location_list = [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 0), Vector2i(1, 1)]
			#elif splits[0] == "6":
				#location_list = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2), Vector2i(1, 2)]
			#elif splits[0] == "7":
				#location_list = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)]
			#elif splits[0] == "8":
				#location_list = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2)]
			if location_list.is_empty():
				continue
			for y in range(2):
				for x in range(2):
					var is_recipe_matched = true
					for location_index in range(location_list.size()):
						var location = location_list[location_index]
						if location[0]+x >= 2:
							is_recipe_matched = false
							break
						if location[1]+y >= 2:
							is_recipe_matched = false
							break
						var item_name = inventory_craft_grid.get_node("Craft"+str((y+location[1])*3+(x+location[0]))).item_name
						if item_name != recipe[location_index+1]:
							is_recipe_matched = false
							break
					if is_recipe_matched:
						var is_recipe_disrupt = false
						for y_other in range(2):
							for x_other in range(2):
								var is_repeated = false
								for location_tmp in location_list:
									if location_tmp[0]+x >= 2:
										continue
									if location_tmp[1]+y >= 2:
										continue
									if x_other == location_tmp[0]+x and y_other == location_tmp[1]+y:
										is_repeated = true
										break
								if is_repeated:
									continue
								var item_name_tmp = inventory_craft_grid.get_node("Craft"+str(y_other*3+x_other)).item_name
								if item_name_tmp != "AIR":
									is_recipe_disrupt = true
									break
							if is_recipe_disrupt:
								break
						if not is_recipe_disrupt:
							is_found = true
							break
					if is_found:
						break
				if is_found:
					break
			if is_found:
				var target_amount = int(splits[1])
				if StaticLoad.get_is_durable_by_name(item):
					target_amount = StaticLoad.get_max_amount_by_name(item)
				inventory_craft_result_grid.init_inventory_grid(item, target_amount)
				is_final_found = true
				break
	if not is_final_found:
		inventory_craft_result_grid.init_inventory_grid("AIR", 0)

#func refresh_inventory_crafting_result():
	#var is_final_found = false
	#for item in StaticLoad.crafting_recipe_dict:
		#var recipe_list = StaticLoad.crafting_recipe_dict[item]
		#for recipe in recipe_list:
			#var is_found = false
			#var splits = recipe[0].split("-")
			#if splits[0] == "0":
				#for y in range(2):
					#for x in range(2):
						#var item_name_0 = inventory_craft_grid.get_node("Craft"+str(y*3+x)).item_name
						#if item_name_0 == recipe[1]:
							#var is_recipe_disrupt = false
							#for y_other in range(2):
								#for x_other in range(2):
									#if y_other == y and x_other == x:
										#continue
									#var item_name_tmp = inventory_craft_grid.get_node("Craft"+str(y_other*3+x_other)).item_name
									#if item_name_tmp != "AIR":
										#is_recipe_disrupt = true
										#break
								#if is_recipe_disrupt:
									#break
							#if not is_recipe_disrupt:
								#is_found = true
								#break
						#if is_found:
							#break
					#if is_found:
						#break
				#if is_found:
					#inventory_craft_result_grid.init_inventory_grid(item, int(splits[1]))
					#is_final_found = true
					#break
	#if not is_final_found:
		#inventory_craft_result_grid.init_inventory_grid("AIR", 0)

func screenshot():
	await RenderingServer.frame_post_draw
	var image = get_viewport().get_texture().get_image()
	var screenshot_name = Time.get_datetime_string_from_system(false, true).replace(":","-")
	var save_path = StaticLoad.screenshot_path+"/"+screenshot_name+".png"
	image.save_png(save_path)
	broadcast_to_person(player.player_name, tr("SCREENSHOT_SAVED")+screenshot_name+".png")

func get_max_craft_amount(type):
	if type == "inventory":
		var min_amount = 1e9
		for index in ["0", "1", "3", "4"]:
			var craft_grid = inventory_craft_grid.get_node("Craft"+index)
			if craft_grid.item_name == "AIR":
				continue
			if min_amount > craft_grid.item_amount:
				min_amount = craft_grid.item_amount
		if min_amount == 1e9:
			min_amount = 0
		return min_amount
	elif type == "table":
		var min_amount = 1e9
		for index in range(9):
			var craft_grid = table_craft_grid.get_node("Craft"+str(index))
			if craft_grid.item_name == "AIR":
				continue
			if min_amount > craft_grid.item_amount:
				min_amount = craft_grid.item_amount
		if min_amount == 1e9:
			min_amount = 0
		return min_amount
	return 0

func update_drag_inventory_grid(rollback_index):
	var is_refresh_item_grid = false
	var update_craft_result = "null"
	var max_amount = StaticLoad.get_max_amount_by_name(drag_inventory_grid_item_name)
	if drag_inventory_grid_state != "middle":
		for grid_name in drag_inventory_grid_amount_dict:
			var grid = drag_inventory_grid_dict[grid_name]
			grid.item_amount -= drag_inventory_grid_amount_dict[grid_name]
	if rollback_index is int:
		var drag_size_tmp = drag_inventory_grid_dict.size()
		for i in range(rollback_index+1, drag_size_tmp):
			var pop_grid = drag_inventory_grid_dict.pop_back()
			if pop_grid.item_amount == 0:
				pop_grid.item_name = "AIR"
			pop_grid.init_inventory_grid(pop_grid.item_name, pop_grid.item_amount)
			if pop_grid.name.contains("InventoryGrid"):
				var sort = int(pop_grid.name.replace("InventoryGrid", ""))
				player.item_bar_names[sort] = pop_grid.item_name
				player.item_bar_amounts[sort] = pop_grid.item_amount
			pop_grid.white_color_rect.visible = false
	drag_inventory_grid_amount_dict.clear()
	var drag_size = drag_inventory_grid_dict.size()
	var total_remain: int = 0
	if drag_inventory_grid_state == "left":
		var average = int(dragging_total_amount / drag_size)
		var remainder = dragging_total_amount % drag_size
		for grid_name in drag_inventory_grid_dict:
			var drag_amount = average
			if remainder > 0:
				drag_amount += 1
				remainder -= 1
			if drag_amount <= 0:
				break
			var grid = drag_inventory_grid_dict[grid_name]
			drag_inventory_grid_amount_dict[grid_name] = drag_amount
			var new_amount = grid.item_amount + drag_amount
			if new_amount > max_amount:
				var remain = new_amount - max_amount
				total_remain += remain
				drag_inventory_grid_amount_dict[grid_name] = drag_amount - remain
				new_amount = max_amount
			if grid.item_amount != new_amount:
				grid.init_inventory_grid(drag_inventory_grid_item_name, new_amount, false)
			if grid.name.contains("InventoryGrid"):
				var sort = int(grid.name.replace("InventoryGrid", ""))
				if not is_refresh_item_grid and sort < 9:
					is_refresh_item_grid = true
				player.item_bar_names[sort] = drag_inventory_grid_item_name
				player.item_bar_amounts[sort] = new_amount
			if grid.slot_function.contains("craft") and not grid.slot_function.contains("craft_result"):
				if grid.slot_function.contains("inventory"):
					update_craft_result = "inventory"
				elif grid.slot_function.contains("table"):
					update_craft_result = "table"
		if total_remain > 0:
			player.mouse_item_amount = total_remain
		else:
			player.mouse_item_amount = 0
		if player.mouse_item_amount == 0:
			player.mouse_item_name = "AIR"
		elif player.mouse_item_name == "AIR":
			player.mouse_item_name = drag_inventory_grid_item_name
	elif drag_inventory_grid_state == "right":
		var dragging_amount = dragging_total_amount
		for grid_name in drag_inventory_grid_dict:
			if dragging_amount <= 0:
				break
			var grid = drag_inventory_grid_dict[grid_name]
			if grid.item_amount >= max_amount:
				continue
			var new_amount = grid.item_amount+1
			grid.init_inventory_grid(drag_inventory_grid_item_name, new_amount, false)
			drag_inventory_grid_amount_dict[grid_name] = 1
			if grid.name.contains("InventoryGrid"):
				var sort = int(grid.name.replace("InventoryGrid", ""))
				if not is_refresh_item_grid and sort < 9:
					is_refresh_item_grid = true
				player.item_bar_names[sort] = drag_inventory_grid_item_name
				player.item_bar_amounts[sort] = new_amount
			if grid.slot_function.contains("craft") and not grid.slot_function.contains("craft_result"):
				if grid.slot_function.contains("inventory"):
					update_craft_result = "inventory"
				elif grid.slot_function.contains("table"):
					update_craft_result = "table"
			dragging_amount -= 1
		if dragging_amount > 0:
			player.mouse_item_name = drag_inventory_grid_item_name
			player.mouse_item_amount = dragging_amount
		else:
			player.mouse_item_name = "AIR"
			player.mouse_item_amount = 0
	elif drag_inventory_grid_state == "middle" and player.gamemode == "creative":
		for grid_name in drag_inventory_grid_dict:
			var grid = drag_inventory_grid_dict[grid_name]
			if drag_inventory_last_grid_name == grid_name:
				grid.init_inventory_grid(drag_inventory_grid_item_name, max_amount)
			if grid.name.contains("InventoryGrid"):
				var sort = int(grid.name.replace("InventoryGrid", ""))
				if not is_refresh_item_grid and sort < 9:
					is_refresh_item_grid = true
				player.item_bar_names[sort] = drag_inventory_grid_item_name
				player.item_bar_amounts[sort] = max_amount
			if grid.slot_function.contains("craft") and not grid.slot_function.contains("craft_result"):
				if grid.slot_function.contains("inventory"):
					update_craft_result = "inventory"
				elif grid.slot_function.contains("table"):
					update_craft_result = "table"
	if is_refresh_item_grid:
		StaticLoad.game.append_process_refresh("refresh_item_grid")
	if update_craft_result == "inventory":
		refresh_inventory_crafting_result()
	elif update_craft_result == "table":
		refresh_table_crafting_result()

@warning_ignore("unused_parameter")
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if (event.button_index == 1 and drag_inventory_grid_state == "left") or (event.button_index == 2 and drag_inventory_grid_state == "right") or (event.button_index == 3 and drag_inventory_grid_state == "middle"):
			if not event.pressed and drag_inventory_grid_state != "null":
				drag_inventory_grid_state = "null"
				drag_inventory_grid_item_name = "null"
				drag_inventory_last_grid_name = "null"
				for grid_name in drag_inventory_grid_dict:
					drag_inventory_grid_dict[grid_name].white_color_rect.visible = false
		if event.button_index == 2 and event.pressed and not Input.is_mouse_button_pressed(1):
			var mouse_in_world_pos
			if player.gamemode != "creative":
				mouse_in_world_pos = get_restricted_block_selection_pos()
			else:
				mouse_in_world_pos = tile_map_layer.get_local_mouse_position()
			var mouse_to_block_pos = tile_map_layer.local_to_map(mouse_in_world_pos)
			var original_block_id = StaticLoad.get_block_id_by_atlas_coords(tile_map_layer.get_cell_atlas_coords(mouse_to_block_pos))
			if StaticLoad.get_block_name_by_id(original_block_id) == "CRAFTING_TABLE":
				if not is_crafting and not is_map and not is_pause and not is_chat and not is_inventory:
					refresh_crafting_inventory()
					ui_freeze_timer = 0.3
					crafting_ui.visible = true
					is_input_frozen = true
					is_crafting = true
			elif player.in_hand_item_name.contains("SPAWN_EGG") and not is_map and not is_pause and not is_chat and not is_inventory and not is_crafting:
				var is_can_spawn = true
				if player.gamemode != "creative" and not player.check_attached_block(mouse_to_block_pos, tile_map_layer):
					is_can_spawn = false
				else:
					original_block_id = StaticLoad.get_block_id_by_atlas_coords(tile_map_layer.get_cell_atlas_coords(mouse_to_block_pos))
					if original_block_id != 0 and not StaticLoad.get_is_transparent_by_id(original_block_id):
						is_can_spawn = false
				if is_can_spawn:
					var splits = player.in_hand_item_name.split("_")
					var entity_type = splits[0].to_lower()
					var uuid = UUID.v4()
					var summon_entity_args = [entity_type, uuid, str(uuid) ,mouse_in_world_pos, "default"]
					if StaticLoad.is_muti_mode:
						if multiplayer.get_unique_id() == 1:
							player.create_entity(summon_entity_args)
							StaticLoad.rpc_entity_func_by_uuid(player.get_uuid(), "create_entity", summon_entity_args, "others", true)
						else:
							StaticLoad.rpc_entity_func_by_uuid(player.get_uuid(), "create_entity", summon_entity_args, [1, multiplayer.get_unique_id()], false)
					else:
						player.create_entity(summon_entity_args)
					player.is_punching = true
					if player.face_state < 0 and tile_map_layer.local_to_map(player.position).x < mouse_to_block_pos.x:
						player.face_state = 1
					elif player.face_state > 0 and tile_map_layer.local_to_map(player.position).x > mouse_to_block_pos.x:
						player.face_state = -1
					if player.gamemode != "creative":
						var select_sort = player.selected_item_grid
						player.item_bar_amounts[select_sort] -= 1
						if player.item_bar_amounts[select_sort] <= 0:
							player.item_bar_names[select_sort] = "AIR"
						refresh_item_grid(select_sort)
	
	if event is InputEventMouseMotion and not is_input_frozen and not player.is_dead:
		set_block_selection_pos(get_local_mouse_position(), true)
	
	if Input.is_action_just_pressed("esc"):
		if player.is_dead:
			pass
		elif is_chat:
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
		elif is_crafting:
			crafting_ui.visible = false
			is_input_frozen = false
			is_crafting = false
			mouse_in_inventory_grid = null
			player.stop_move()
		elif is_inventory:
			inventory_ui.visible = false
			is_input_frozen = false
			is_inventory = false
			mouse_in_inventory_grid = null
			player.stop_move()
		else:
			pause_ui.visible = !pause_ui.visible
			is_pause = pause_ui.visible
			is_input_frozen = is_pause
			if pause_ui.visible:
				move_input_list.clear()
				player.stop_move()
	
	if Input.is_action_just_pressed("inventory"):
		if player.is_dead:
			pass
		elif is_pause:
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
		elif is_crafting:
			crafting_ui.visible = false
			is_input_frozen = false
			is_crafting = false
			mouse_in_inventory_grid = null
			move_input_list.clear()
			player.stop_move()
		elif is_inventory:
			inventory_ui.visible = false
			is_input_frozen = false
			is_inventory = false
			mouse_in_inventory_grid = null
			move_input_list.clear()
			player.stop_move()
		elif not is_chat:
			is_input_frozen = true
			inventory_ui.visible = true
			is_inventory = true
			refresh_inventory()
			if StaticLoad.is_muti_mode and multiplayer.get_unique_id() != 1:
				player.changed_state_dict["inventory"] = [player.item_bar_names, player.item_bar_amounts, player.mouse_item_name, player.mouse_item_amount]
			move_input_list.clear()
			player.stop_move()
	
	if Input.is_action_just_pressed("open_map"):
		if player.is_dead:
			pass
		elif is_pause or is_chat or is_inventory or is_crafting:
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
	
	if mouse_in_inventory_grid != null and mouse_in_inventory_grid.name.contains("InfiniteGrid") and (is_inventory or is_crafting) and player != null and player.gamemode == "creative":
		if Input.is_action_just_pressed("select_item_grid_1"):
			player.item_bar_names[0] = mouse_in_inventory_grid.item_name
			player.item_bar_amounts[0] = StaticLoad.get_max_amount_by_name(mouse_in_inventory_grid.item_name)
			refresh_single_inventory_grid(0, "inventory")
			refresh_item_grid(0)
		if Input.is_action_just_pressed("select_item_grid_2"):
			player.item_bar_names[1] = mouse_in_inventory_grid.item_name
			player.item_bar_amounts[1] = StaticLoad.get_max_amount_by_name(mouse_in_inventory_grid.item_name)
			refresh_single_inventory_grid(1, "inventory")
			refresh_item_grid(1)
		if Input.is_action_just_pressed("select_item_grid_3"):
			player.item_bar_names[2] = mouse_in_inventory_grid.item_name
			player.item_bar_amounts[2] = StaticLoad.get_max_amount_by_name(mouse_in_inventory_grid.item_name)
			refresh_single_inventory_grid(2, "inventory")
			refresh_item_grid(2)
		if Input.is_action_just_pressed("select_item_grid_4"):
			player.item_bar_names[3] = mouse_in_inventory_grid.item_name
			player.item_bar_amounts[3] = StaticLoad.get_max_amount_by_name(mouse_in_inventory_grid.item_name)
			refresh_single_inventory_grid(3, "inventory")
			refresh_item_grid(3)
		if Input.is_action_just_pressed("select_item_grid_5"):
			player.item_bar_names[4] = mouse_in_inventory_grid.item_name
			player.item_bar_amounts[4] = StaticLoad.get_max_amount_by_name(mouse_in_inventory_grid.item_name)
			refresh_single_inventory_grid(4, "inventory")
			refresh_item_grid(4)
		if Input.is_action_just_pressed("select_item_grid_6"):
			player.item_bar_names[5] = mouse_in_inventory_grid.item_name
			player.item_bar_amounts[5] = StaticLoad.get_max_amount_by_name(mouse_in_inventory_grid.item_name)
			refresh_single_inventory_grid(5, "inventory")
			refresh_item_grid(5)
		if Input.is_action_just_pressed("select_item_grid_7"):
			player.item_bar_names[6] = mouse_in_inventory_grid.item_name
			player.item_bar_amounts[6] = StaticLoad.get_max_amount_by_name(mouse_in_inventory_grid.item_name)
			refresh_single_inventory_grid(6, "inventory")
			refresh_item_grid(6)
		if Input.is_action_just_pressed("select_item_grid_8"):
			player.item_bar_names[7] = mouse_in_inventory_grid.item_name
			player.item_bar_amounts[7] = StaticLoad.get_max_amount_by_name(mouse_in_inventory_grid.item_name)
			refresh_single_inventory_grid(7, "inventory")
			refresh_item_grid(7)
		if Input.is_action_just_pressed("select_item_grid_9"):
			player.item_bar_names[8] = mouse_in_inventory_grid.item_name
			player.item_bar_amounts[8] = StaticLoad.get_max_amount_by_name(mouse_in_inventory_grid.item_name)
			refresh_single_inventory_grid(8, "inventory")
			refresh_item_grid(8)
	
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
		if not player.is_dead:
			move_input_list.clear()
			player.stop_move()
			is_input_frozen = true
			is_chat = true
			chat_message_out.visible = false
			chat_panel.visible = true
			await get_tree().process_frame
			chat_history_in.scroll_vertical = 1e9
			chat_line_edit.grab_focus()
			chat_line_edit.text = ""
	
	if Input.is_action_just_pressed("grab_item"):
		if player.gamemode == "creative":
			var mouse_in_world_pos = tile_map_layer.get_local_mouse_position()
			var mouse_to_block_pos = tile_map_layer.local_to_map(mouse_in_world_pos)
			grab_item(mouse_to_block_pos)
	
	if Input.is_action_just_pressed("switch_layer"):
		StaticLoad.click_audio_player.play()
		if player.current_set_layer == "solid":
			player.current_set_layer = "back"
			tile_map_layer.modulate = Color(0.393,0.393,0.393,1)
			no_reach_tile_map_layer.modulate = Color(0.393,0.393,0.393,1)
			back_tile_map_layer.modulate = Color(1,1,1,1)
		elif player.current_set_layer == "back":
			player.current_set_layer = "solid"
			tile_map_layer.modulate = Color(1,1,1,1)
			no_reach_tile_map_layer.modulate = Color(1,1,1,1)
			back_tile_map_layer.modulate = Color(0.393,0.393,0.393,1)
	
	if Input.is_action_just_pressed("chat_slash"):
		if not player.is_dead:
			move_input_list.clear()
			player.stop_move()
			is_input_frozen = true
			is_chat = true
			chat_message_out.visible = false
			chat_panel.visible = true
			chat_history_in.scroll_vertical = 1e9
			await get_tree().process_frame
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
		if StaticLoad.get_is_durable_by_name(item_to_drop):
			sound_audio_manager.play_audio_static("player", "pop")
			player.drop_item(player.item_bar_names[selected_item_grid_tmp], player.item_bar_amounts[selected_item_grid_tmp])
			player.item_bar_amounts[selected_item_grid_tmp] = 0
			player.item_bar_names[selected_item_grid_tmp] = "AIR"
			StaticLoad.game.refresh_item_grid(selected_item_grid_tmp)
			inventory_show_grids.get_node("InventoryGrid"+str(selected_item_grid_tmp)).init_inventory_grid(player.item_bar_names[selected_item_grid_tmp], player.item_bar_amounts[selected_item_grid_tmp])
			drop_timer = 0
		elif drop_timer < StaticLoad.DROP_ALL_TIME and item_to_drop != "AIR":
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
			if check_place_block_state(block_pos, StaticLoad.get_block_id_by_name(player.item_bar_names[player.selected_item_grid]), player.current_set_layer):
				player.place_block(block_pos)
			grab_item(block_pos)
		else:
			var pressed_time = touch_time_counters.get_node(str(touch.index)).timer
			if pressed_time >= StaticLoad.LONG_TOUCH_TIME:
				player.destroy_block(tile_map_layer.local_to_map(camera_screen_pos_to_local_pos(player.camera, touch.position)))

func check_place_block_state(block_pos, block_id, selected_layer):
	if StaticLoad.get_is_untouchable_by_id(block_id):
		return true
	if selected_layer == "back":
		return true
	for id in StaticLoad.player_peer_dict:
		var player_tmp = StaticLoad.player_peer_dict[id]
		if player_tmp == null:
			StaticLoad.player_peer_dict.erase(id)
			continue
		var player_pos = tile_map_layer.local_to_map(player_tmp.position)
		if player_pos == block_pos:
			return false
		if player_pos - Vector2i(0, 1) == block_pos:
			return false
	var mouse_in_world_pos = tile_map_layer.get_local_mouse_position()
	var mouse_to_block_pos = tile_map_layer.local_to_map(mouse_in_world_pos)
	var mouse_chunk_pos = get_chunk_position(mouse_to_block_pos)
	if loaded_chunks.has(str(mouse_chunk_pos[0])+"."+str(mouse_chunk_pos[1])):
		var chunk_entity_list = loaded_chunks[str(mouse_chunk_pos[0])+"."+str(mouse_chunk_pos[1])].entity_list
		for uuid in chunk_entity_list:
			var entity = entities[uuid]
			var entity_type_tmp = entity.get_entity_type()
			if entity_type_tmp == "player":
				continue
			if entity_type_tmp == "item":
				continue
			if entity_type_tmp == "arrow":
				continue
			if entity == null:
				continue
			var entity_pos = tile_map_layer.local_to_map(entity.position)
			if entity_pos == block_pos:
				return false
			if ["zombie", "skeleton", "cow", "sheep"].has(entity_type_tmp):
				if entity_pos - Vector2i(0, 1) == block_pos:
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
				if check_place_block_state(block_pos, StaticLoad.get_block_id_by_name(player.item_bar_names[player.selected_item_grid]), player.current_set_layer):
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
	if not is_map and not is_pause and not is_chat and not is_inventory and not is_crafting:
		if not Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			if player.is_pulling:
				player.is_pulling = false
				if player.shoot_timer > 0:
					player.in_hand_item_name = "BOW"
					player.set_item_in_hand("BOW")
					player.shoot_arrow()
					player.shoot_timer = 0
					player.last_shoot_stage = -1
			elif player.is_eating:
				player.is_eating = false
				player.last_eat_stage = -1
				player.eat_timer = 0
		if Input.is_mouse_button_pressed(1) and not Input.is_mouse_button_pressed(2):
			if StaticLoad.tools_type.has(player.in_hand_item_name) and StaticLoad.tools_type[player.in_hand_item_name].has("sword"):
				if player.attack_timer <= 0:
					player.is_punching = true
			elif player.sword_breaking_timer > 0:
				pass
			else:
				var real_mouse_pos = mouse_to_block_pos
				if player.gamemode != "creative":
					real_mouse_pos = tile_map_layer.local_to_map(get_restricted_block_selection_pos())
				var block_id = StaticLoad.get_block_id_by_atlas_coords(tile_map_layer.get_cell_atlas_coords(real_mouse_pos))
				if player.punch_timer <= 0 and block_id == 0 and not player.animation_tree["parameters/Punch/active"]:
					var chunk_pos = get_chunk_position(real_mouse_pos)
					var chunk_name = str(chunk_pos[0])+"."+str(chunk_pos[1])
					if loaded_chunks.has(chunk_name) and loaded_chunks[chunk_name].is_loaded:
						for uuid in loaded_chunks[chunk_name].entity_list:
							var entity = entities[uuid]
							if entity == null:
								continue
							if ["arrow", "item"].has(entity.get_entity_type()):
								continue
							var entity_block_pos = tile_map_layer.local_to_map(entity.position)
							if entity_block_pos == real_mouse_pos:
								player.punch(entity)
								break
							elif ["zombie", "skeleton", "player"].has(entity.get_entity_type()) and entity_block_pos-Vector2i(0,1) == real_mouse_pos:
								player.punch(entity)
								break
				elif player.gamemode == "creative":
					player.destroy_block(mouse_to_block_pos)
				else:
					player.destroy_timer += get_process_delta_time()
		elif Input.is_mouse_button_pressed(2) and not Input.is_mouse_button_pressed(1):
			if player.in_hand_item_name.contains("SPAWN_EGG"):
				pass
			elif StaticLoad.food_dict.has(player.in_hand_item_name):
				if not player.is_eating and player.gamemode != "creative" and player.hunger < 20:
					player.is_eating = true
			elif player.in_hand_item_name.contains("BOW"):
				if player.gamemode != "creative" and not player.item_bar_names.has("ARROW"):
					pass
				elif player.item_bar_names[player.selected_item_grid].contains("BOW"):
					player.is_pulling = true
			elif player.gamemode == "creative":
				player.place_block(mouse_to_block_pos)
			else:
				player.place_block(tile_map_layer.local_to_map(get_restricted_block_selection_pos()))
	
	if not StaticLoad.is_on_mobile_platform and not Input.is_mouse_button_pressed(1):
		player.destroy_timer = 0
		if destroy_light_names.has(player.player_peer_id):
			destroy_light_names[player.player_peer_id].set_texture(null)
	
	if is_mouse_motion_updated and player.gamemode != "creative":
		var mouse_to_in_world_pos_tmp = get_restricted_block_selection_pos()
		if tile_map_layer.local_to_map(mouse_to_in_world_pos_tmp) != tile_map_layer.local_to_map(last_mouse_in_world_pos):
			player.destroy_timer = 0
			if destroy_light_names.has(player.player_peer_id):
				destroy_light_names[player.player_peer_id].set_texture(null)
		is_mouse_motion_updated = false
		last_mouse_in_world_pos = mouse_to_in_world_pos_tmp

func update_resource_pack():
	tile_map_layer.tile_set = load("res://Assets/TileSets/"+str(resource_pack)+".tres") as TileSet
	back_tile_map_layer.tile_set = load("res://Assets/TileSets/"+str(resource_pack)+".tres") as TileSet
	no_reach_tile_map_layer.tile_set = load("res://Assets/TileSets/"+str(resource_pack)+".tres") as TileSet
	mini_map_tile_map_layer.tile_set = load("res://Assets/TileSets/"+str(resource_pack)+".tres") as TileSet
	mini_map_back_tile_map_layer.tile_set = load("res://Assets/TileSets/"+str(resource_pack)+".tres") as TileSet
	mini_map_no_reach_tile_map_layer.tile_set = load("res://Assets/TileSets/"+str(resource_pack)+".tres") as TileSet
	moon_path_texture.texture.atlas = load("res://Assets/ResourcePacks/"+str(resource_pack)+"/Environments/moon_phases.png") as Texture2D
	sun_path_texture.texture.atlas = load("res://Assets/ResourcePacks/"+str(resource_pack)+"/Environments/sun.png") as Texture2D

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
		var block_id = 0
		if player_tmp.current_set_layer == "back":
			var atlas_coords = back_tile_map_layer.get_cell_atlas_coords(player_selected_block_pos)
			block_id = StaticLoad.get_block_id_by_atlas_coords(atlas_coords)
		else:
			var atlas_coords = tile_map_layer.get_cell_atlas_coords(player_selected_block_pos)
			block_id = StaticLoad.get_block_id_by_atlas_coords(atlas_coords)
			if block_id == 0:
				atlas_coords = no_reach_tile_map_layer.get_cell_atlas_coords(player_selected_block_pos)
				block_id = StaticLoad.get_block_id_by_atlas_coords(atlas_coords)
				if block_id == 0:
					continue
		var destroy_timer_tmp = player_tmp.destroy_timer
		if destroy_timer_tmp <= 0:
			if destroy_light_names.has(peer_id):
				destroy_light_names[peer_id].set_texture(null)
			continue
		if destroy_timer_tmp <= 0.01:
			if player_tmp.face_state < 0 and tile_map_layer.local_to_map(player_tmp.position).x < player_selected_block_pos.x:
				player_tmp.face_state = 1
			elif player_tmp.face_state > 0 and tile_map_layer.local_to_map(player_tmp.position).x > player_selected_block_pos.x:
				player_tmp.face_state = -1
		var tool = player.item_bar_names[player.selected_item_grid]
		var destroy_total_time = StaticLoad.get_destroy_total_time(block_id, tool)
		var block_name = StaticLoad.get_block_name_by_id(block_id)
		if StaticLoad.special_block_destroy_time.has(block_name):
			destroy_total_time = StaticLoad.special_block_destroy_time[block_name]
		if destroy_total_time < 0:
			continue
		if player_selected_block_pos != player_tmp.destroying_block_pos:
			player_tmp.destroying_block_pos = player_selected_block_pos
			player_tmp.destroy_timer = 0
			if destroy_light_names.has(peer_id):
				destroy_light_names[peer_id].update_block_pos(player_selected_block_pos)
				destroy_light_names[peer_id].set_texture(null)
			continue
		var destroy_sort = int((destroy_timer_tmp/destroy_total_time)*8)+1
		#if player_tmp.destroy_timer != destroy_timer_tmp:
			#if StaticLoad.is_muti_mode and multiplayer.get_unique_id() == player_tmp.player_peer_id:
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
			if StaticLoad.is_muti_mode and multiplayer.get_unique_id() == player_tmp.player_peer_id:
				player_tmp.state_dict["destroy_timer"] = 0
			continue
		elif not destroy_light_names.has(peer_id) or destroy_sort != destroy_light_names[peer_id].sort:
			if destroy_light_names.has(peer_id):
				if destroy_light_names[peer_id].sort != destroy_sort:
					destroy_light_names[peer_id].update_block_pos(player_selected_block_pos)
					destroy_light_names[peer_id].set_texture(StaticLoad.destroy_light_textures[destroy_sort])
					#var old_destroy_light = destroy_light_names[peer_id]
					#destroy_light_names.erase(peer_id)
					#old_destroy_light.queue_free()
					#var destroy_light = destory_light_scene.instantiate()
					#destroy_light_names[peer_id] = destroy_light
					#lights.add_child(destroy_light)
					#destroy_light.init_light(str(peer_id), player_selected_block_pos, destroy_sort)
			else:
				var destroy_light = destory_light_scene.instantiate()
				destroy_light.init_light(str(peer_id), player_selected_block_pos, 0)
				lights.add_child(destroy_light)
				destroy_light_names[peer_id] = destroy_light
				#if destroy_light_names.has(peer_id):
					#var old_destroy_light = destroy_light_names[peer_id]
					#destroy_light_names.erase(peer_id)
					#old_destroy_light.queue_free()
				#var destroy_light = destory_light_scene.instantiate()
				#destroy_light_names[peer_id] = destroy_light
				#lights.add_child(destroy_light)
				#destroy_light.init_light(str(peer_id), player_selected_block_pos, destroy_sort)

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
	refresh_all_light()

func update_mini_map_chunk_light(chunk_pos, image):
	var chunk_light_name = str(chunk_pos[0])+"."+str(chunk_pos[1])
	if not mini_map_chunk_lights.has(chunk_light_name):
		var chunk_light = chunk_light_scene.instantiate()
		mini_map_lights.add_child(chunk_light)
		chunk_light.name = chunk_light_name.replace(".", "_")
		chunk_light.chunk_pos = chunk_pos
		chunk_light.update_texture_from_image(image)
		mini_map_chunk_lights[chunk_light_name] = chunk_light
	mini_map_chunk_lights[chunk_light_name].update_texture_from_image(image)
	
func grab_item(block_pos):
	var block_id = StaticLoad.get_block_id_by_atlas_coords(tile_map_layer.get_cell_atlas_coords(block_pos))
	if block_id == 0:
		block_id = StaticLoad.get_block_id_by_atlas_coords(no_reach_tile_map_layer.get_cell_atlas_coords(block_pos))
	if block_id == 0 and player.current_set_layer == "back":
		block_id = StaticLoad.get_block_id_by_atlas_coords(back_tile_map_layer.get_cell_atlas_coords(block_pos))
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
		var item_name = player.item_bar_names[player_select_sort]
		if item_name != "AIR":
			item_name_label.text = item_name
			item_name_timer = StaticLoad.ITEM_NAME_SHOW_TIME
	
func process_remove_outdated_chunks():
	while(true):
		if get_tree() == null:
			return
		await get_tree().process_frame
		is_chunk_modifing = true
		if StaticLoad.is_muti_mode and multiplayer.get_unique_id() != 1:
			var player_block_pos = tile_map_layer.local_to_map(player.position)
			var chunk_pos_tmp = get_chunk_position(player_block_pos)
			var x_player_chunk = chunk_pos_tmp[0]
			var y_player_chunk = chunk_pos_tmp[1]
			for x in range(x_player_chunk-player.render_chunk, x_player_chunk+player.render_chunk+1):
				for y in range(y_player_chunk-player.render_chunk, y_player_chunk+player.render_chunk+1):	
					if loaded_chunks.has(str(x)+"."+str(y)):
						loaded_chunks_timer[str(x)+"."+str(y)] = StaticLoad.CHUNK_FREE_TIME
		else:
			for player_tmp in players.get_children():
				var player_block_pos = tile_map_layer.local_to_map(player_tmp.position)
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
			for i in range(30):
				if get_tree() == null:
					return
				await get_tree().process_frame
				for key in loaded_chunks_timer.keys():
					loaded_chunks_timer[key] -= get_process_delta_time()
			var splits = timer.split(".")
			var chunk_pos = Vector2i(int(splits[0]), int(splits[1]))
			if not StaticLoad.is_muti_mode or (StaticLoad.is_muti_mode and multiplayer.get_unique_id() == 1):
				save_chunk(chunk_pos)
			free_chunk(chunk_pos)
			loaded_chunks.erase(timer)
			loaded_chunks_timer.erase(timer)
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
	for key in StaticLoad.world_level_infos:
		world_info_dictionary[key] = world_config.get_value("world", key, StaticLoad.world_level_infos[key])
	tick_timer = int(world_info_dictionary["tick_timer"])
	world_day = int(world_info_dictionary["world_day"])
	calculate_current_sky_light(true)
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
	light_thread.start(process_light)
	set_block_thread.start(process_set_block)
	entity_spawn_thread.start(process_entity_spawn)
	remove_chunks_thread.start(process_remove_outdated_chunks)
	#nearby_thread.start(process_nearby)

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
		smooth_lighting_on = config.get_value("options", "smooth_lighting", StaticLoad.options["smooth_lighting"])
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
		if smooth_lighting_on == "on" and not is_smooth_light:
			is_smooth_light = true
			refresh_all_light()
		elif smooth_lighting_on == "off" and is_smooth_light:
			is_smooth_light = false
			refresh_all_light()
		var particle_effect_on = config.get_value("options", "particle_effect", StaticLoad.options["particle_effect"])
		if particle_effect_on == "off":
			is_particle_effect_on = false
		elif particle_effect_on == "on":
			is_particle_effect_on = true
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
	for key in StaticLoad.world_level_infos:
		world_info_dictionary[key] = world_config.get_value("world", key, StaticLoad.world_level_infos[key])
	tick_timer = int(world_info_dictionary["tick_timer"])
	world_day = int(world_info_dictionary["world_day"])
	calculate_current_sky_light(true)
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
			var value_list = StaticLoad.get_mca_value(Vector2i(x, y))
			if not value_list[0]:
				continue
			var chunk_config = value_list[1]
			var block_list = value_list[2]
			loaded_success_chunk_list.append(str(x)+"."+str(y))
			set_chunk(Vector2i(x, y), block_list)
			create_chunk_entities(str(x)+"."+str(y), chunk_config)
			#var chunk_entity_list = chunk_config.get_value("chunk", "entity_list")
			#if chunk_entity_list != null:
				#for uuid in chunk_entity_list:
					#var entity_info = chunk_config.get_value("entity", uuid)
					#if entity_info == null:
						#if not loaded_chunks.has(str(x)+"."+str(y)):
							#loaded_chunks[str(x)+"."+str(y)] = StaticLoad.Chunk.new()
						#loaded_chunks[str(x)+"."+str(y)].is_to_save = true
						#continue
					#if entity_info[0] == "item":
						#StaticLoad.create_entity(["item", entity_info[1], entity_info[3], entity_info[2], 0, 2, uuid])
					#else:
						#StaticLoad.create_entity([entity_info[0], uuid, entity_info[1], entity_info[2], entity_info[3]])
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
		sky_light.fill(current_sky_light)
		chunk_sky_light_datas[str(x)+"."+str(min_y)] = sky_light
	set_block_selection_pos(get_local_mouse_position())
	update_moon_phase()
	update_resource_pack()
	init_inventory_tabs()
	init_infinite_container()
	init_light()
	get_viewport().size_changed.connect(update_path_2d)
	item_thread.start(process_item)
	tick_cycle_thread.start(process_tick_cycle)
	dispatch_thread.start(process_dispatch)
	set_block_thread.start(process_set_block)
	light_thread.start(process_light)
	refresh_thread.start(process_refresh)
	entity_spawn_thread.start(process_entity_spawn)
	remove_chunks_thread.start(process_remove_outdated_chunks)
	#nearby_thread.start(process_nearby)

func init_game_as_client():
	StaticLoad.select_world = "new world"
	StaticLoad.update_select_world_path()
	StaticLoad.rpc_id(1, "request_for_world_info", multiplayer.get_unique_id(), true)
	StaticLoad.rpc_id(1, "request_for_player_info", multiplayer.get_unique_id(), player.player_name)
	StaticLoad.rpc_id(1, "request_for_update_player_inventory", multiplayer.get_unique_id(), player.player_name)
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
	smooth_lighting_on = config.get_value("options", "smooth_lighting", StaticLoad.options["smooth_lighting"])
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
	if smooth_lighting_on == "on" and not is_smooth_light:
		is_smooth_light = true
		refresh_all_light()
	elif smooth_lighting_on == "off" and is_smooth_light:
		is_smooth_light = false
		refresh_all_light()
	var particle_effect_on = config.get_value("options", "particle_effect", StaticLoad.options["particle_effect"])
	if particle_effect_on == "off":
		is_particle_effect_on = false
	elif particle_effect_on == "on":
		is_particle_effect_on = true
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
			StaticLoad.rpc_id(1, "request_for_update_chunk", multiplayer.get_unique_id(), true, x, y)
	set_block_selection_pos(get_local_mouse_position())
	update_resource_pack()
	init_inventory_tabs()
	init_infinite_container()
	get_viewport().size_changed.connect(update_path_2d)
	set_block_thread.start(process_set_block)
	light_thread.start(process_light)
	tick_cycle_thread.start(process_tick_cycle)
	dispatch_thread.start(process_dispatch)
	refresh_thread.start(process_refresh)
	remove_chunks_thread.start(process_remove_outdated_chunks)

func create_chunk_entities(chunk_name, chunk_config):
	var chunk_entity_list = chunk_config.get_value("chunk", "entity_list", "null")
	if chunk_entity_list is String and chunk_entity_list == "null":
		return
	for uuid in chunk_entity_list:
		var entity_info = chunk_config.get_value("entity", uuid)
		if entity_info == null:
			if not loaded_chunks.has(chunk_name):
				loaded_chunks[chunk_name] = StaticLoad.Chunk.new()
			loaded_chunks[chunk_name].is_to_save = true
			continue
		if entity_info[0] == "item":
			StaticLoad.create_entity(["item", entity_info[1], entity_info[3], entity_info[2], 0, 2, uuid])
		elif entity_info[0] == "arrow":
			if entity_info[5] != "player":
				continue
			StaticLoad.create_entity([entity_info[0], uuid, entity_info[1], entity_info[2], entity_info[3], entity_info[4], entity_info[5], entity_info[6], entity_info[7], entity_info[8]])
		else:
			StaticLoad.create_entity([entity_info[0], uuid, entity_info[1], entity_info[2], entity_info[3]])

func create_player(peer_id = 1):
	var player_instance = player_scene.instantiate()
	player_instance.name = str(peer_id)
	players.add_child(player_instance)
	if not StaticLoad.is_muti_mode:
		player = player_instance
		player.init_local(peer_id)
	elif peer_id == multiplayer.get_unique_id():
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

func process_entity_spawn():
	while(true):
		if not StaticLoad.is_in_game:
			break
		if get_tree() == null:
			return
		await get_tree().create_timer(30).timeout
		for chunk_name in loaded_chunks.duplicate():
			if not loaded_chunks.has(chunk_name):
				continue
			var splits = chunk_name.split(".")
			var is_player_nearby = false
			for player_tmp in players.get_children():
				if get_chunk_position(tile_map_layer.local_to_map(player_tmp.position)) == Vector2i(int(splits[0]), int(splits[1])):
					is_player_nearby = true
			if is_player_nearby:
				continue
			var is_spawned = false
			var undead_count: int = 0
			if current_sky_light <= 223:
				for uuid in loaded_chunks[chunk_name].entity_list:
					if entities[uuid] == null:
						continue
					if StaticLoad.undead_mob_list.has(entities[uuid].get_entity_type()):
						undead_count += 1
			for y in range(16):
				for x in range(16):
					var block_pos = Vector2i(int(splits[0])*16,int(splits[1])*16)+Vector2i(x, y)
					var block_id = StaticLoad.get_block_id_by_atlas_coords(tile_map_layer.get_cell_atlas_coords(block_pos))
					if StaticLoad.get_is_transparent_by_id(block_id) or block_id == 0:
						continue
					var up_block_pos = Vector2i(int(splits[0])*16,int(splits[1])*16)+Vector2i(x, y-1)
					var up_chunk_pos = get_chunk_position(up_block_pos)
					if loaded_chunks.has(str(up_chunk_pos[0])+"."+str(up_chunk_pos[1])):
						var up_block_id = StaticLoad.get_block_id_by_atlas_coords(tile_map_layer.get_cell_atlas_coords(up_block_pos))
						if up_block_id != 0:
							continue
					var top_block_pos = Vector2i(int(splits[0])*16,int(splits[1])*16)+Vector2i(x, y-2)
					var top_chunk_pos = get_chunk_position(top_block_pos)
					if loaded_chunks.has(str(top_chunk_pos[0])+"."+str(top_chunk_pos[1])):
						var top_block_id = StaticLoad.get_block_id_by_atlas_coords(tile_map_layer.get_cell_atlas_coords(top_block_pos))
						if top_block_id != 0:
							continue
					if not chunk_light_datas.has(chunk_name):
						continue
					var chunk_light_tmp = chunk_light_datas[chunk_name]
					var self_light = chunk_light_tmp[y*16+x]
					if mobs.get_child_count() <= 8 and undead_count <= 1 and current_sky_light <= 80 and self_light <= 80:
						var rng = RandomNumberGenerator.new()
						var num = rng.randf()
						if num < 0.9:
							continue
						var undead_mob_list_tmp = StaticLoad.undead_mob_list.duplicate()
						undead_mob_list_tmp.shuffle()
						var entity_type = undead_mob_list_tmp[0]
						var uuid = UUID.v4()
						var summon_entity_args = [entity_type, uuid, str(uuid) ,tile_map_layer.map_to_local(up_block_pos), "default"]
						StaticLoad.create_entity(summon_entity_args)
						is_spawned = true
						#print(chunk_name, " undead ", undead_count)
						break
					elif undead_mobs.get_child_count() <= 8 and self_light >= 112:
						if loaded_chunks[chunk_name].entity_list.size() >= 1:
							continue
						var rng = RandomNumberGenerator.new()
						var num = rng.randf()
						if num < 0.99:
							continue
						var common_mob_list_tmp = StaticLoad.common_mob_list.duplicate()
						common_mob_list_tmp.shuffle()
						var entity_type = common_mob_list_tmp[0]
						var uuid = UUID.v4()
						var summon_entity_args = [entity_type, uuid, str(uuid) ,tile_map_layer.map_to_local(up_block_pos), "default"]
						StaticLoad.create_entity(summon_entity_args)
						#print(chunk_name, " entity_list ", loaded_chunks[chunk_name].entity_list.size())
						is_spawned = true
						break
				if get_tree() == null:
					return
				await get_tree().process_frame
				if is_spawned:
					break
			if is_spawned:
				var rng = RandomNumberGenerator.new()
				var num = rng.randf()
				if get_tree() == null:
					return
				await get_tree().create_timer(num*30).timeout

func refresh_item_grid(sort):
	if player == null:
		return
	var item_name = player.item_bar_names[sort]
	var item_amount = player.item_bar_amounts[sort]
	var item_grid_tmp = item_grids[sort]
	if item_grid_tmp.item_name == item_name and item_grid_tmp.item_amount == item_amount:
		return
	if sort == player.selected_item_grid and player.in_hand_item_name.contains("BOW"):
		if not item_name.contains("BOW") and player.is_pulling:
			player.is_pulling = false
			player.shoot_timer = 0
			player.last_shoot_stage = -1
			player.in_hand_item_name = item_name
			player.set_item_in_hand(item_name)
	if item_name == "AIR":
		item_grid_tmp.item_name = "AIR"
		item_grid_tmp.item_amount = 0
		item_grid_tmp.get_node("ItemIcon").visible = false
		item_grid_tmp.get_node("ProgressBar").visible = false
		item_grid_tmp.get_node("Amount").visible = false
		item_grid_tmp.get_node("Amount").text = ""
		if sort == player.selected_item_grid and not block_selection_ui.visible:
			block_selection_ui.visible = true
	else:
		item_grid_tmp.item_name = item_name
		item_grid_tmp.item_amount = item_amount
		if sort == player.selected_item_grid and item_name.contains("SWORD"):
			if block_selection_ui.visible:
				block_selection_ui.visible = false
		item_grid_tmp.get_node("ItemIcon").init_icon(player.item_bar_names[sort].to_lower())
		item_grid_tmp.get_node("ItemIcon").visible = true
		if StaticLoad.get_is_durable_by_name(item_name):
			item_grid_tmp.get_node("Amount").visible = false
			item_grid_tmp.get_node("Amount").text = ""
			var progress_bar = item_grid_tmp.get_node("ProgressBar")
			progress_bar.max_value = StaticLoad.get_max_amount_by_name(item_name)
			progress_bar.value = item_amount
			var percentage =  item_amount / float(StaticLoad.get_max_amount_by_name(item_name))
			var stylebox = progress_bar.get_theme_stylebox("fill")
			if percentage > 0.667:
				stylebox.bg_color = Color(0, 0.727, 0.135)
			elif percentage > 0.333 and percentage <= 0.667:
				stylebox.bg_color = Color(0.863, 0.675, 0)
			elif percentage >= 0 and percentage <= 0.333:
				stylebox.bg_color = Color(0.73, 0, 0)
			progress_bar.add_theme_stylebox_override("fill", stylebox)
			progress_bar.visible = true
		else:
			item_grid_tmp.get_node("ProgressBar").visible = false
			if item_amount <= 1:
				item_grid_tmp.get_node("Amount").visible = false
				item_grid_tmp.get_node("Amount").text = ""
			else:
				item_grid_tmp.get_node("Amount").text = str(item_amount)
				item_grid_tmp.get_node("Amount").visible = true

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
				#if multiplayer.get_unique_id() == 1:
					#StaticLoad.rpc_entity_func_by_uuid(player.get_uuid(), "apply_changed_state_dict", state_tmp, "others", true)
				#else:
					#StaticLoad.rpc_entity_func_by_uuid(player.get_uuid(), "apply_changed_state_dict", state_tmp, [player.player_peer_id], false)
		last_jump_time = current_time
	
	if Input.is_action_just_pressed("move_left"):
		move_input_list.push_back("left")
		var current_time = Time.get_ticks_msec() / 1000.0
		if current_time - last_left_time < StaticLoad.DOUBLE_CLICK_THRESHOLD:
			if not player.is_sneaking and player.hunger > 6:
				player.move_state = "run"
			else:
				player.move_state = "walk"
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
			if not player.is_sneaking and player.hunger > 6:
				player.move_state = "run"
			else:
				player.move_state = "walk"
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
		if item.contains("BOW") and item != "BOW":
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
	var pos = tile_map_layer.local_to_map(player.position)
	details_position.text = tr("POSITON")+" : x="+str(pos[0])+", y="+str(-pos[1])
	var real_mouse_pos = tile_map_layer.get_local_mouse_position()
	if player != null and player.gamemode != "creative":
		real_mouse_pos = get_restricted_block_selection_pos()
	var selected_pos = tile_map_layer.local_to_map(real_mouse_pos)
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
		if player.gamemode == "creative":
			set_block_selection_pos(get_local_mouse_position())
		else:
			set_block_selection_pos(get_restricted_block_selection_pos())

func get_restricted_block_selection_pos():
	var mouse_in_world_pos = get_local_mouse_position()
	var player_head_pos = player.position - Vector2(0, 60)
	var player_center_pos = player.position - Vector2(0, 24)
	var relative_to_player_pos = mouse_in_world_pos - player_head_pos
	#player.sight_line.set_point_position(1, relative_to_player_pos)
	var stride = 5
	var length = relative_to_player_pos.length()
	var freq = stride / length
	var cycle_num = int(1 / freq)
	var orthogonal_relative_to_player_pos = relative_to_player_pos.orthogonal().normalized()*5
	for i in range(cycle_num):
		var pos_tmp1 = player_head_pos.lerp(mouse_in_world_pos, i*freq)
		var pos_tmp2 = pos_tmp1+orthogonal_relative_to_player_pos
		var pos_tmp3 = pos_tmp1-orthogonal_relative_to_player_pos
		for pos_tmp in [pos_tmp1, pos_tmp2, pos_tmp3]:
			var block_id = StaticLoad.get_block_id_by_atlas_coords(tile_map_layer.get_cell_atlas_coords(tile_map_layer.local_to_map(pos_tmp)))
			if block_id != 0 and not StaticLoad.get_is_untouchable_by_id(block_id):
				return pos_tmp
			if player_center_pos.distance_to(pos_tmp) > 250:
				return pos_tmp
	return mouse_in_world_pos

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
			#if multiplayer.get_unique_id() == 1:
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
	if player == null:
		return
	var render_chunk_tmp = player.render_chunk
	if is_pre_load or player_last_chunk != Vector2i(x_player_chunk, y_player_chunk):
		for x in range(x_player_chunk-render_chunk_tmp, x_player_chunk+render_chunk_tmp+1):
			for y in range(y_player_chunk-render_chunk_tmp, y_player_chunk+render_chunk_tmp+1):
				if not loaded_chunks.has(str(x)+"."+str(y)):
					if StaticLoad.is_muti_mode and multiplayer.get_unique_id() != 1:
						StaticLoad.rpc_id(1, "request_for_update_chunk", multiplayer.get_unique_id(), false, x, y)
						if not loaded_chunks.has(str(x)+"."+str(y)):
							loaded_chunks[str(x)+"."+str(y)] = StaticLoad.Chunk.new()
						loaded_chunks[str(x)+"."+str(y)].is_to_save = false #防止重复向服务器发送申请
						loaded_chunks_timer[str(x)+"."+str(y)] = StaticLoad.CHUNK_FREE_TIME
					else:
						if database_chunks.has(str(x)+"."+str(y)):
							var value_list = StaticLoad.get_mca_value(Vector2i(x, y))
							if not value_list[0]:
								return
							var chunk_config = value_list[1]
							var block_list = value_list[2]
							set_chunk(Vector2i(x, y), block_list)
							loaded_chunk_num += 1
							create_chunk_entities(str(x)+"."+str(y), chunk_config)
							#var chunk_entity_list = chunk_config.get_value("chunk", "entity_list")
							#if chunk_entity_list != null:
								#for uuid in chunk_entity_list:
									#var entity_info = chunk_config.get_value("entity", uuid, null)
									#if entity_info == null:
										#continue
									#if entity_info[0] == "item":
										#var item_info = ["item", entity_info[1], entity_info[3], entity_info[2], 0, 2, uuid]
										#StaticLoad.create_entity(item_info)
										#StaticLoad.rpc("create_entity", item_info)
						else:
							var mca = ConfigFile.new()
							var chunk = StaticLoad.generate_chunk(Vector2i(x, y), world_info_dictionary["seed"], world_info_dictionary["world_type"])
							set_chunk(Vector2i(x, y), chunk)
							loaded_chunk_num += 1
							var value_dict = {
									"blocks" : chunk[0],
									"no_reach_blocks" : chunk[1],
									"back_blocks" : chunk[2]
								}
							StaticLoad.set_mca_value(mca, value_dict)
							mca.save_encrypted_pass(StaticLoad.region_path+"/r."+str(x)+"."+str(y)+".mca", StaticLoad.CONFIG_PASSWORD)
							if not loaded_chunks.has(str(x)+"."+str(y)):
								loaded_chunks[str(x)+"."+str(y)] = StaticLoad.Chunk.new()
							loaded_chunks[str(x)+"."+str(y)].is_to_save = false
							loaded_chunks_timer[str(x)+"."+str(y)] = StaticLoad.CHUNK_FREE_TIME
							database_chunks.push_back(str(x)+"."+str(y))
						if not chunk_lights.has(str(x)+"."+str(y-1)):
							var sky_light: PackedByteArray
							sky_light.resize(16)
							sky_light.fill(current_sky_light)
							chunk_sky_light_datas[str(x)+"."+str(y)] = sky_light
						if not StaticLoad.is_muti_mode or (StaticLoad.is_muti_mode and multiplayer.get_unique_id() == 1):
							if chunk_lights.has(str(x)+"."+str(y)):
								chunk_light_to_process[str(x)+"."+str(y)] = "null"
							else:
								chunk_light_to_process[str(x)+"."+str(y)] = "create"
					for i in range(30):
						if get_tree() == null:
							return
						await get_tree().process_frame
					#await get_tree().process_frame
		player_last_chunk = Vector2i(x_player_chunk, y_player_chunk)

func free_chunk(pos: Vector2i) -> void:
	var chunk_name = str(pos[0])+"."+str(pos[1])
	loaded_chunks[chunk_name].is_loaded = false
	for uuid in loaded_chunks[chunk_name].entity_list.duplicate():
		if entities[uuid] == null:
			continue
		entities[uuid].destroy_entity([])
		if StaticLoad.is_muti_mode and multiplayer.get_unique_id() == 1:
			StaticLoad.rpc_entity_func_by_uuid(uuid, "destroy_entity", [], "others", true)
	for x in range(0, 16):
		for y in range(0, 16):
			set_block(Vector2i(pos[0] * 16 + x, pos[1] * 16 + y), 0, "solid", true)
			set_block(Vector2i(pos[0] * 16 + x, pos[1] * 16 + y), 0, "no_reach", true)
			set_block(Vector2i(pos[0] * 16 + x, pos[1] * 16 + y), 0, "back", true)
	loaded_chunk_num -= 1
	if chunk_lights.has(chunk_name):
		chunk_lights[chunk_name].destroy()
	if loaded_chunk_packed_byte_arrays.has(str(pos[0])+"."+str(pos[1])):
		var byte_array_tmp = loaded_chunk_packed_byte_arrays[str(pos[0])+"."+str(pos[1])]
		loaded_chunk_packed_byte_arrays.erase(str(pos[0])+"."+str(pos[1]))
		byte_array_tmp.clear()
	if chunk_sky_light_datas.has(str(pos[0])+"."+str(pos[1])):
		var chunk_sky_light_tmp = chunk_sky_light_datas[str(pos[0])+"."+str(pos[1])]
		chunk_sky_light_datas.erase(str(pos[0])+"."+str(pos[1]))
		chunk_sky_light_tmp.clear()

func set_chunk(pos: Vector2i, blocks_list) -> void:
	var chunk_name = str(pos[0])+"."+str(pos[1])
	if not loaded_chunk_packed_byte_arrays.has(chunk_name):
		var chunk_packed_byte_array: PackedByteArray
		chunk_packed_byte_array.resize(256)
		chunk_packed_byte_array.fill(0)
		loaded_chunk_packed_byte_arrays[chunk_name] = chunk_packed_byte_array
	if blocks_list[0].is_empty():
		return
	for x in range(0, 16):
		for y in range(0, 16):
			set_block(Vector2i(pos[0] * 16 + x, pos[1] * 16 + y), blocks_list[0][y][x], "solid", true)
			set_block(Vector2i(pos[0] * 16 + x, pos[1] * 16 + y), blocks_list[1][y][x], "no_reach", true)
			set_block(Vector2i(pos[0] * 16 + x, pos[1] * 16 + y), blocks_list[2][y][x], "back", true)
	if not loaded_chunks.has(chunk_name):
		loaded_chunks[chunk_name] = StaticLoad.Chunk.new()
	loaded_chunks[chunk_name].is_loaded = true
	if not StaticLoad.is_muti_mode or (StaticLoad.is_muti_mode and multiplayer.get_unique_id() == 1):
		if frozen_entity_dict.has(chunk_name):
			for uuid in frozen_entity_dict[chunk_name].duplicate():
				frozen_entity_dict[chunk_name].erase(uuid)
				if entities[uuid] == null:
					continue
				entities[uuid].unfreeze()
	if not StaticLoad.is_muti_mode or (StaticLoad.is_muti_mode and multiplayer.get_unique_id() == player.player_peer_id):
		if player != null and player.is_frozen and str(player.chunk_pos[0])+"."+str(player.chunk_pos[1]) == chunk_name:
			player.unfreeze()

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
		#if tile_map_type == "solid":
			#var original_block_id = StaticLoad.get_block_id_by_atlas_coords(tile_map_layer_tmp.get_cell_atlas_coords(block_pos))
			#if StaticLoad.get_block_name_by_id(original_block_id) == "DIRT":
				#var chunk_pos = get_chunk_position(block_pos)
				#var dirt_pos = block_pos-Vector2i(chunk_pos[0]*16,chunk_pos[1]*16)
				#if loaded_chunks.has(str(chunk_pos[0])+"."+str(chunk_pos[1])):
					#var chunk = loaded_chunks[str(chunk_pos[0])+"."+str(chunk_pos[1])]
					#if chunk.dirt_list.has(dirt_pos):
						#chunk.dirt_list.erase(dirt_pos)
		#if not is_pre_load and tile_map_type == "solid":
			#var down_block_pos = block_pos+Vector2i(0,1)
			#var chunk_pos = get_chunk_position(down_block_pos)
			#var dirt_pos = down_block_pos-Vector2i(chunk_pos[0]*16,chunk_pos[1]*16)
			#if loaded_chunks.has(str(chunk_pos[0])+"."+str(chunk_pos[1])):
				#var down_block_id = StaticLoad.get_block_id_by_atlas_coords(tile_map_layer_tmp.get_cell_atlas_coords(down_block_pos))
				#if StaticLoad.get_block_name_by_id(down_block_id) == "DIRT":
					#var chunk = loaded_chunks[str(chunk_pos[0])+"."+str(chunk_pos[1])]
					#if not chunk.dirt_list.has(dirt_pos):
						#chunk.dirt_list.append(dirt_pos)
		tile_map_layer_tmp.set_cell(block_pos)
		if not StaticLoad.is_dedicated_server:
			var chunk_pos = get_chunk_position(block_pos)
			mini_map_tile_map_layer_tmp.set_cell(block_pos)
			var relative_block_pos = block_pos-chunk_pos*16
			if relative_block_pos[0] > 15:
				relative_block_pos[0] = 15
			if relative_block_pos[1] > 15:
				relative_block_pos[1] = 15
			if tile_map_type != "back":
				if loaded_chunk_packed_byte_arrays.has(str(chunk_pos[0])+"."+str(chunk_pos[1])):
					loaded_chunk_packed_byte_arrays[str(chunk_pos[0])+"."+str(chunk_pos[1])][relative_block_pos[1]*16+relative_block_pos[0]] = 0
		return true
	if not is_pre_load and block_id != 0 and StaticLoad.get_is_clingling_by_name(StaticLoad.get_block_name_by_id(block_id)) != "null":
		if not check_has_nearby_solid_block(block_pos, block_id):
			return false
		if StaticLoad.get_block_name_by_id(block_id).contains("STAGE"):
			var down_block_pos = block_pos+Vector2i(0, 1)
			var down_chunk_pos = get_chunk_position(down_block_pos)
			if not loaded_chunks.has(str(down_chunk_pos[0])+"."+str(down_chunk_pos[1])):
				return false
			var down_block_id = StaticLoad.get_block_id_by_atlas_coords(tile_map_layer.get_cell_atlas_coords(down_block_pos))
			if StaticLoad.get_block_name_by_id(down_block_id) != "FARM_LAND":
				return false
		if StaticLoad.get_block_name_by_id(block_id).contains("SAPLING"):
			var down_block_pos = block_pos+Vector2i(0, 1)
			var down_chunk_pos = get_chunk_position(down_block_pos)
			if not loaded_chunks.has(str(down_chunk_pos[0])+"."+str(down_chunk_pos[1])):
				return false
			var down_block_id = StaticLoad.get_block_id_by_atlas_coords(tile_map_layer.get_cell_atlas_coords(down_block_pos))
			if StaticLoad.get_block_name_by_id(down_block_id) != "DIRT" and StaticLoad.get_block_name_by_id(down_block_id) != "GRASS_BLOCK":
				return false
		if StaticLoad.get_block_name_by_id(block_id) == "REEDS":
			var down_block_pos = block_pos+Vector2i(0, 1)
			var down_chunk_pos = get_chunk_position(down_block_pos)
			if not loaded_chunks.has(str(down_chunk_pos[0])+"."+str(down_chunk_pos[1])):
				return false
			var down_block_id = StaticLoad.get_block_id_by_atlas_coords(tile_map_layer.get_cell_atlas_coords(down_block_pos))
			if StaticLoad.get_block_name_by_id(down_block_id) != "DIRT" and StaticLoad.get_block_name_by_id(down_block_id) != "GRASS_BLOCK" and StaticLoad.get_block_name_by_id(down_block_id) != "SAND":
				return false
	#if not is_pre_load and tile_map_type == "solid" and StaticLoad.get_block_name_by_id(block_id) == "DIRT":
		#var chunk_pos = get_chunk_position(block_pos)
		#if loaded_chunks.has(str(chunk_pos[0])+"."+str(chunk_pos[1])):
			#var up_block_id = StaticLoad.get_block_id_by_atlas_coords(tile_map_layer.get_cell_atlas_coords(block_pos+Vector2i(0,-1)))
			#if up_block_id == 0 or StaticLoad.get_is_transparent_by_id(up_block_id):
				#var dirt_pos = block_pos-Vector2i(chunk_pos[0]*16,chunk_pos[1]*16)
				#var chunk = loaded_chunks[str(chunk_pos[0])+"."+str(chunk_pos[1])]
				#if not chunk.dirt_list.has(dirt_pos):
					#chunk.dirt_list.append(dirt_pos)
	if not is_pre_load and tile_map_layer_tmp.get_cell_source_id(block_pos) != -1:
		var original_block_name = StaticLoad.get_block_name_by_id(StaticLoad.get_block_id_by_atlas_coords(tile_map_layer.get_cell_atlas_coords(block_pos)))
		var new_block_name = StaticLoad.get_block_name_by_id(block_id)
		if new_block_name == "FARM_LAND":
			if original_block_name == "GRASS_BLOCK" or original_block_name == "DIRT":
				pass
			else:
				return false
		else:
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
		var chunk_pos = get_chunk_position(block_pos)
		mini_map_tile_map_layer_tmp.set_cell(block_pos, 9999, atlas_coords)
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

func process_nearby():
	while(true):
		if not StaticLoad.is_in_game:
			break
		await get_tree().process_frame
		var nearby_update_dict_tmp = nearby_update_dict.duplicate()
		if nearby_update_dict_tmp.is_empty():
			if not nearby_update_double_dict.is_empty():
				nearby_update_dict = nearby_update_double_dict.duplicate()
				nearby_update_double_dict.clear()
			continue
		else:
			for block_pos in nearby_update_dict_tmp:
				update_nearby_block_state(block_pos, nearby_update_dict_tmp[block_pos])
				nearby_update_dict.erase(block_pos)

func update_nearby_block_state(block_pos, update_state):
	for selection in [1, -1]:
		for delta in [1, 0, -1]:
			var nearby_block_pos
			if selection == -1:
				if delta == 0:
					continue
				nearby_block_pos = block_pos+Vector2i(delta, 0)
			else:
				nearby_block_pos = block_pos+Vector2i(0, delta)
			var nearby_block_chunk_pos = get_chunk_position(nearby_block_pos)
			if not loaded_chunks.has(str(nearby_block_chunk_pos[0])+"."+str(nearby_block_chunk_pos[1])):
				continue
			var nearby_block_id = StaticLoad.get_block_id_by_atlas_coords(tile_map_layer.get_cell_atlas_coords(nearby_block_pos))
			if nearby_block_id != 0 and update_state == "before":
				if delta == 0 and StaticLoad.get_block_name_by_id(nearby_block_id) == "REEDS":
					var local_sugar_cane_pos = nearby_block_pos-Vector2i(nearby_block_chunk_pos[0]*16,nearby_block_chunk_pos[1]*16)
					var chunk = loaded_chunks[str(nearby_block_chunk_pos[0])+"."+str(nearby_block_chunk_pos[1])]
					if chunk.sugar_cane_list.has(local_sugar_cane_pos):
						chunk.sugar_cane_list.erase(local_sugar_cane_pos)
					set_block_list.append([Time.get_ticks_msec(), "destroy", 0, nearby_block_pos, "solid", false])
					var up_block_pos = nearby_block_pos + Vector2i(0, -1)
					while(true):
						var up_chunk_pos = get_chunk_position(up_block_pos)
						if not loaded_chunks.has(str(up_chunk_pos[0])+"."+str(up_chunk_pos[1])):
							break
						var up_block_id = StaticLoad.get_block_id_by_atlas_coords(tile_map_layer.get_cell_atlas_coords(up_block_pos))
						if StaticLoad.get_block_name_by_id(up_block_id) != "REEDS":
							break
						var sugar_cane_pos = up_block_pos-Vector2i(up_chunk_pos[0]*16,up_chunk_pos[1]*16)
						var up_chunk = loaded_chunks[str(up_chunk_pos[0])+"."+str(up_chunk_pos[1])]
						if up_chunk.sugar_cane_list.has(sugar_cane_pos):
							up_chunk.sugar_cane_list.erase(sugar_cane_pos)
						set_block_list.append([Time.get_ticks_msec(), "destroy", 0, up_block_pos, "solid", false])
						up_block_pos += Vector2i(0, -1)
			if nearby_block_id == 0 and update_state == "after":
				var chunk_pos = get_chunk_position(nearby_block_pos)
				if loaded_chunks.has(str(chunk_pos[0])+"."+str(chunk_pos[1])):
					var relative_pos = nearby_block_pos-Vector2i(chunk_pos[0]*16,chunk_pos[1]*16)
					var chunk = loaded_chunks[str(chunk_pos[0])+"."+str(chunk_pos[1])]
					if chunk.dirt_list.has(relative_pos):
						chunk.dirt_list.erase(relative_pos)
					if chunk.grass_block_list.has(relative_pos):
						chunk.grass_block_list.erase(relative_pos)
					if chunk.seed_list.has(relative_pos):
						chunk.seed_list.erase(relative_pos)
					if chunk.farm_land_list.has(relative_pos):
						chunk.farm_land_list.erase(relative_pos)
					if chunk.sapling_list.has(relative_pos):
						chunk.sapling_list.erase(relative_pos)
					if chunk.sugar_cane_list.has(relative_pos):
						chunk.sugar_cane_list.erase(relative_pos)
				var no_reach_block_id = StaticLoad.get_block_id_by_atlas_coords(no_reach_tile_map_layer.get_cell_atlas_coords(nearby_block_pos))
				if delta == 0 and check_has_nearby_leaves(nearby_block_pos):
					var up_block_pos = nearby_block_pos+Vector2i(0,-1)
					var up_chunk_pos = get_chunk_position(up_block_pos)
					if loaded_chunks.has(str(up_chunk_pos[0])+"."+str(up_chunk_pos[1])):
						mark_nearby_leaves(up_block_pos)
			elif nearby_block_id != 0 and update_state == "after":
				if StaticLoad.get_block_name_by_id(nearby_block_id) == "SAPLING_OAK":
					var chunk_pos = get_chunk_position(nearby_block_pos)
					var sapling_pos = nearby_block_pos-Vector2i(chunk_pos[0]*16,chunk_pos[1]*16)
					var chunk = loaded_chunks[str(chunk_pos[0])+"."+str(chunk_pos[1])]
					if not chunk.sapling_list.has(sapling_pos):
						chunk.sapling_list.append(sapling_pos)
				if StaticLoad.get_block_name_by_id(nearby_block_id) == "REEDS":
					var down_block_pos = nearby_block_pos+Vector2i(0,1)
					var down_chunk_pos = get_chunk_position(down_block_pos)
					if loaded_chunks.has(str(down_chunk_pos[0])+"."+str(down_chunk_pos[1])):
						var down_block_id = StaticLoad.get_block_id_by_atlas_coords(tile_map_layer.get_cell_atlas_coords(down_block_pos))
						var down_block_name = StaticLoad.get_block_name_by_id(down_block_id)
						if down_block_name == "DIRT" or down_block_name == "GRASS_BLOCK" or down_block_name == "SAND":
							var chunk_pos = get_chunk_position(nearby_block_pos)
							var sugar_cane_pos = nearby_block_pos-Vector2i(chunk_pos[0]*16,chunk_pos[1]*16)
							var chunk = loaded_chunks[str(chunk_pos[0])+"."+str(chunk_pos[1])]
							if not chunk.sugar_cane_list.has(sugar_cane_pos):
								chunk.sugar_cane_list.append(sugar_cane_pos)
				if StaticLoad.get_block_name_by_id(nearby_block_id) == "DIRT":
					var up_block_pos = nearby_block_pos+Vector2i(0,-1)
					var up_chunk_pos = get_chunk_position(up_block_pos)
					if loaded_chunks.has(str(up_chunk_pos[0])+"."+str(up_chunk_pos[1])):
						var up_block_id = StaticLoad.get_block_id_by_atlas_coords(tile_map_layer.get_cell_atlas_coords(up_block_pos))
						if up_block_id == 0 or StaticLoad.get_is_transparent_by_id(up_block_id):
							var chunk_pos = get_chunk_position(nearby_block_pos)
							var dirt_pos = nearby_block_pos-Vector2i(chunk_pos[0]*16,chunk_pos[1]*16)
							var chunk = loaded_chunks[str(chunk_pos[0])+"."+str(chunk_pos[1])]
							if not chunk.dirt_list.has(dirt_pos):
								chunk.dirt_list.append(dirt_pos)
						else:
							var chunk_pos = get_chunk_position(nearby_block_pos)
							var dirt_pos = nearby_block_pos-Vector2i(chunk_pos[0]*16,chunk_pos[1]*16)
							var chunk = loaded_chunks[str(chunk_pos[0])+"."+str(chunk_pos[1])]
							if chunk.dirt_list.has(dirt_pos):
								chunk.dirt_list.erase(dirt_pos)
				if StaticLoad.get_block_name_by_id(nearby_block_id) == "GRASS_BLOCK":
					var up_block_pos = nearby_block_pos+Vector2i(0,-1)
					var up_chunk_pos = get_chunk_position(up_block_pos)
					if loaded_chunks.has(str(up_chunk_pos[0])+"."+str(up_chunk_pos[1])):
						var up_block_id = StaticLoad.get_block_id_by_atlas_coords(tile_map_layer.get_cell_atlas_coords(up_block_pos))
						if up_block_id == 0 or StaticLoad.get_is_transparent_by_id(up_block_id):
							var chunk_pos = get_chunk_position(nearby_block_pos)
							var grass_pos = nearby_block_pos-Vector2i(chunk_pos[0]*16,chunk_pos[1]*16)
							var chunk = loaded_chunks[str(chunk_pos[0])+"."+str(chunk_pos[1])]
							if chunk.grass_block_list.has(grass_pos):
								chunk.grass_block_list.erase(grass_pos)
						else:
							var chunk_pos = get_chunk_position(nearby_block_pos)
							var grass_pos = nearby_block_pos-Vector2i(chunk_pos[0]*16,chunk_pos[1]*16)
							var chunk = loaded_chunks[str(chunk_pos[0])+"."+str(chunk_pos[1])]
							if not chunk.grass_block_list.has(grass_pos):
								chunk.grass_block_list.append(grass_pos)
				if StaticLoad.get_block_name_by_id(nearby_block_id) == "FARM_LAND":
					var up_block_pos = nearby_block_pos+Vector2i(0,-1)
					var up_chunk_pos = get_chunk_position(up_block_pos)
					if loaded_chunks.has(str(up_chunk_pos[0])+"."+str(up_chunk_pos[1])):
						var up_block_id = StaticLoad.get_block_id_by_atlas_coords(tile_map_layer.get_cell_atlas_coords(up_block_pos))
						if up_block_id == 0 or StaticLoad.get_is_transparent_by_id(up_block_id):
							var chunk_pos = get_chunk_position(nearby_block_pos)
							var farm_land_pos = nearby_block_pos-Vector2i(chunk_pos[0]*16,chunk_pos[1]*16)
							var chunk = loaded_chunks[str(chunk_pos[0])+"."+str(chunk_pos[1])]
							if chunk.farm_land_list.has(farm_land_pos):
								chunk.farm_land_list.erase(farm_land_pos)
						else:
							var chunk_pos = get_chunk_position(nearby_block_pos)
							var farm_land_pos = nearby_block_pos-Vector2i(chunk_pos[0]*16,chunk_pos[1]*16)
							var chunk = loaded_chunks[str(chunk_pos[0])+"."+str(chunk_pos[1])]
							if not chunk.farm_land_list.has(farm_land_pos):
								chunk.farm_land_list.append(farm_land_pos)
				if StaticLoad.get_block_name_by_id(nearby_block_id).contains("STAGE"):
					var down_block_pos = nearby_block_pos+Vector2i(0,1)
					var down_chunk_pos = get_chunk_position(down_block_pos)
					if loaded_chunks.has(str(down_chunk_pos[0])+"."+str(down_chunk_pos[1])):
						var down_block_id = StaticLoad.get_block_id_by_atlas_coords(tile_map_layer.get_cell_atlas_coords(down_block_pos))
						if down_block_id != StaticLoad.get_block_id_by_name("FARM_LAND"):
							set_block(nearby_block_pos, 0, "no_reach", false)
							var chunk_pos = get_chunk_position(nearby_block_pos)
							update_chunk_light_by_pos(chunk_pos)
							if StaticLoad.is_muti_mode and multiplayer.get_unique_id() == 1:
								rpc("update_chunk_light_by_pos", chunk_pos)
							if StaticLoad.is_muti_mode and multiplayer.get_unique_id() == 1:
								StaticLoad.rpc("set_block", [nearby_block_pos, 0, "no_reach", false])
							var seed_pos = nearby_block_pos-Vector2i(chunk_pos[0]*16,chunk_pos[1]*16)
							var chunk = loaded_chunks[str(chunk_pos[0])+"."+str(chunk_pos[1])]
							if chunk.seed_list.has(seed_pos):
								chunk.seed_list.erase(seed_pos)
						else:
							var chunk_pos = get_chunk_position(nearby_block_pos)
							var seed_pos = nearby_block_pos-Vector2i(chunk_pos[0]*16,chunk_pos[1]*16)
							var chunk = loaded_chunks[str(chunk_pos[0])+"."+str(chunk_pos[1])]
							if not chunk.seed_list.has(seed_pos):
								chunk.seed_list.append(seed_pos)
				# 消除列表必须放最后，防止消除后立刻新增
				if StaticLoad.get_is_clingling_by_name(StaticLoad.get_block_name_by_id(nearby_block_id)) != "null":
					if not check_has_nearby_solid_block(nearby_block_pos, nearby_block_id):
						if StaticLoad.get_block_name_by_id(nearby_block_id) == "REEDS":
							var local_sugar_cane_pos = nearby_block_pos-Vector2i(nearby_block_chunk_pos[0]*16,nearby_block_chunk_pos[1]*16)
							var chunk = loaded_chunks[str(nearby_block_chunk_pos[0])+"."+str(nearby_block_chunk_pos[1])]
							if chunk.sugar_cane_list.has(local_sugar_cane_pos):
								chunk.sugar_cane_list.erase(local_sugar_cane_pos)
							set_block_list.append([Time.get_ticks_msec(), "destroy", 0, nearby_block_pos, "solid", false])
							var up_block_pos = nearby_block_pos + Vector2i(0, -1)
							while(true):
								var up_chunk_pos = get_chunk_position(up_block_pos)
								if not loaded_chunks.has(str(up_chunk_pos[0])+"."+str(up_chunk_pos[1])):
									break
								var up_block_id = StaticLoad.get_block_id_by_atlas_coords(tile_map_layer.get_cell_atlas_coords(up_block_pos))
								if StaticLoad.get_block_name_by_id(up_block_id) != "REEDS":
									break
								var sugar_cane_pos = up_block_pos-Vector2i(up_chunk_pos[0]*16,up_chunk_pos[1]*16)
								var up_chunk = loaded_chunks[str(up_chunk_pos[0])+"."+str(up_chunk_pos[1])]
								if up_chunk.sugar_cane_list.has(sugar_cane_pos):
									up_chunk.sugar_cane_list.erase(sugar_cane_pos)
								set_block_list.append([Time.get_ticks_msec(), "destroy", 0, up_block_pos, "solid", false])
								up_block_pos += Vector2i(0, -1)
						else:
							set_block_list.append([Time.get_ticks_msec(), "destroy", 0, nearby_block_pos, "solid", false])

@rpc("authority", "call_remote")
func update_chunk_light_by_pos(chunk_pos):
	if not StaticLoad.is_dedicated_server:
		if chunk_lights.has(str(chunk_pos[0])+"."+str(chunk_pos[1])):
			if not chunk_light_to_process.has(str(chunk_pos[0])+"."+str(chunk_pos[1])):
				chunk_light_to_process[str(chunk_pos[0])+"."+str(chunk_pos[1])] = "update"
			else:
				chunk_light_to_process_double[str(chunk_pos[0])+"."+str(chunk_pos[1])] = "update"
		else:
			chunk_light_to_process[str(chunk_pos[0])+"."+str(chunk_pos[1])] = "create"

func mark_nearby_leaves(start_pos):
	var chunk_pos = get_chunk_position(start_pos)
	for x in [-2, -1, 0, 1, 2]:
		for y in [-2, -1, 0, 1, 2]:
			var block_pos = start_pos + Vector2i(x, y)
			var block_id = StaticLoad.get_block_id_by_atlas_coords(no_reach_tile_map_layer.get_cell_atlas_coords(block_pos))
			if StaticLoad.get_block_name_by_id(block_id) != "LEAVES":
				continue
			var is_log_found = false
			var search_height = 1
			var down_block_id = StaticLoad.get_block_id_by_atlas_coords(no_reach_tile_map_layer.get_cell_atlas_coords(block_pos+Vector2i(0, 1)))
			if StaticLoad.get_block_name_by_id(down_block_id) == "LEAVES":
				search_height = 2
			for i in [-2, -1, 0, 1, 2]:
				var nearby_block_pos = block_pos + Vector2i(i, search_height)
				var nearby_block_id = StaticLoad.get_block_id_by_atlas_coords(no_reach_tile_map_layer.get_cell_atlas_coords(nearby_block_pos))
				if StaticLoad.get_block_name_by_id(nearby_block_id) == "LOG_OAK":
					is_log_found = true
					break
			var leaves_pos = block_pos-Vector2i(chunk_pos[0]*16,chunk_pos[1]*16)
			var chunk = loaded_chunks[str(chunk_pos[0])+"."+str(chunk_pos[1])]
			if not is_log_found:
				if not chunk.leaves_list.has(leaves_pos):
					chunk.leaves_list.append(leaves_pos)
			else:
				if chunk.leaves_list.has(leaves_pos):
					chunk.leaves_list.erase(leaves_pos)

func check_has_nearby_leaves(block_pos):
	var is_has_nearby_leaves = false
	for x in [-2, -1, 0, 1, 2]:
		for y in [-2, -1, 0]:
			var nearby_block_pos = block_pos + Vector2i(x, y)
			var nearby_chunk_pos = get_chunk_position(nearby_block_pos)
			if not loaded_chunks.has(str(nearby_chunk_pos[0])+"."+str(nearby_chunk_pos[1])):
				continue
			var nearby_block_id = StaticLoad.get_block_id_by_atlas_coords(no_reach_tile_map_layer.get_cell_atlas_coords(nearby_block_pos))
			if StaticLoad.get_block_name_by_id(nearby_block_id) == "LEAVES":
				is_has_nearby_leaves = true
				break
		if is_has_nearby_leaves:
			break
	return is_has_nearby_leaves

func check_has_nearby_solid_block(block_pos, to_set_block_id):
	var back_block_id = StaticLoad.get_block_id_by_atlas_coords(back_tile_map_layer.get_cell_atlas_coords(block_pos))
	var clinging_type = StaticLoad.get_is_clingling_by_name(StaticLoad.get_block_name_by_id(to_set_block_id))
	if back_block_id != 0:
		if clinging_type == "all" or clinging_type == "back":
			return true
	if clinging_type == "back":
		return false
	var is_has_nearby = false
	for selection in [1]:
		for delta in [1]:
			var nearby_block_pos
			if selection == -1:
				nearby_block_pos = block_pos+Vector2i(delta, 0)
			else:
				nearby_block_pos = block_pos+Vector2i(0, delta)
			var nearby_block_chunk_pos = get_chunk_position(nearby_block_pos)
			if not loaded_chunks.has(str(nearby_block_chunk_pos[0])+"."+str(nearby_block_chunk_pos[1])):
				continue
			var nearby_block_id = StaticLoad.get_block_id_by_atlas_coords(tile_map_layer.get_cell_atlas_coords(nearby_block_pos))
			if nearby_block_id != 0 and StaticLoad.get_is_clingling_by_name(StaticLoad.get_block_name_by_id(nearby_block_id)) == "null":
				is_has_nearby = true
				break
			if StaticLoad.get_block_name_by_id(to_set_block_id) == "REEDS":
				var no_reach_block_id = StaticLoad.get_block_id_by_atlas_coords(no_reach_tile_map_layer.get_cell_atlas_coords(nearby_block_pos))
				if no_reach_block_id != 0 and StaticLoad.get_block_name_by_id(no_reach_block_id) == "REEDS":
					is_has_nearby = true
					break
				var solid_block_id = StaticLoad.get_block_id_by_atlas_coords(tile_map_layer.get_cell_atlas_coords(nearby_block_pos))
				if solid_block_id != 0 and StaticLoad.get_block_name_by_id(solid_block_id) == "REEDS":
					is_has_nearby = true
					break
	return is_has_nearby

func save_world():
	for region in loaded_chunks:
		if loaded_chunks[region].is_to_save:
			loaded_chunks[region].is_to_save = false
			var splits = region.split(".")
			var x_chunk = int(splits[0])
			var y_chunk = int(splits[1])
			save_chunk(Vector2i(x_chunk, y_chunk))
	var level = ConfigFile.new()
	var current_time = Time.get_datetime_string_from_system(false, true).replace(" ", "  ").replace("-", "/")
	var level_change_value = {
		"last_modified": current_time,
		"version": world_info_dictionary["version"],
		"seed": world_info_dictionary["seed"],
		"world_type": world_info_dictionary["world_type"],
		"gamemode": world_info_dictionary["gamemode"],
		"tick_timer": str(tick_timer),
		"world_day": str(world_day)
	}
	StaticLoad.save_level_dat(level, level_change_value)
	level.save_encrypted_pass(StaticLoad.world_path+"/level.dat", StaticLoad.CONFIG_PASSWORD)

func save_player(peer_id = 0):
	var player_tmp
	var player_config = ConfigFile.new()
	if peer_id == 0:
		for id in StaticLoad.player_peer_dict:
			player_tmp = StaticLoad.player_peer_dict[id]
			if player_tmp.is_dead:
				player_tmp.respawn(false)
			
			if player_tmp.gamemode != "creative":
				player_tmp.is_flying = false
	else:
		player_tmp = StaticLoad.player_peer_dict[peer_id]
		if player_tmp.gamemode != "creative":
			player_tmp.is_flying = false
	player_config.set_value("player", "position", player_tmp.position)
	player_config.set_value("player", "face_state", player_tmp.face_state)
	player_config.set_value("player", "is_flying", player_tmp.is_flying)
	player_config.set_value("player", "gamemode", player_tmp.gamemode)
	player_config.set_value("player", "health", player_tmp.health)
	player_config.set_value("player", "hunger", player_tmp.hunger)
	player_config.set_value("player", "effect_dict", player_tmp.effect_dict)
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
	var chunk = loaded_chunks[str(x_chunk)+"."+str(y_chunk)]
	var value_dict = {}
	value_dict["blocks"] = blocks
	value_dict["no_reach_blocks"] = no_reach_blocks
	value_dict["back_blocks"] = back_blocks
	for para in StaticLoad.Chunk.para_list:
		value_dict[para] = chunk.get(para)
	StaticLoad.set_mca_value(mca, value_dict)
	for uuid in chunk.entity_list:
		var entity = entities[uuid]
		if entity == null:
			continue
		if entity.get_is_dead():
			continue
		if entity.get_entity_type() == "item":
			var entity_info = ["item", entity.item_name, entity.item_amount, entity.position]
			mca.set_value("entity", uuid, entity_info)
		elif entity.get_entity_type() == "arrow":
			if entity.shooter_type != "player":
				continue
			var entity_info = ["arrow", entity.entity_name, entity.position, entity.velocity, entity.current_velocity, entity.shooter_type, entity.shooter_uuid, entity.shooter_name, entity.is_undead_damage]
			mca.set_value("entity", uuid, entity_info)
		else:
			var entity_info = [entity.get_entity_type(), entity.get_entity_name(), entity.position, entity.get_health()]
			mca.set_value("entity", uuid, entity_info)
	mca.save_encrypted_pass(StaticLoad.region_path+"/r."+str(x_chunk)+"."+str(y_chunk)+".mca", StaticLoad.CONFIG_PASSWORD)
	
	var level = ConfigFile.new()
	var current_time = Time.get_datetime_string_from_system(false, true).replace(" ", "  ").replace("-", "/")
	var level_change_value = {
		"last_modified": current_time,
		"version": world_info_dictionary["version"],
		"seed": world_info_dictionary["seed"],
		"world_type": world_info_dictionary["world_type"],
		"gamemode": world_info_dictionary["gamemode"],
		"tick_timer": str(tick_timer),
		"world_day": str(world_day)
	}
	StaticLoad.save_level_dat(level, level_change_value)
	level.save_encrypted_pass(StaticLoad.world_path+"/level.dat", StaticLoad.CONFIG_PASSWORD)

func select_item_grid(grid_name) -> void:
	if str(grid_name) == "More":
		if is_inventory or is_crafting:
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
	if player.selected_item_grid != sort:
		if player.is_eating:
			player.is_eating = false
			player.eat_timer = 0
			player.last_eat_stage = -1
	player.selected_item_grid = sort
	item_grids[sort].get_node("SelectBar").visible = true
	var select_item_name = player.item_bar_names[sort]
	if player.in_hand_item_name.contains("BOW"):
		if not select_item_name.contains("BOW") and player.is_pulling:
			player.is_pulling = false
			player.shoot_timer = 0
			player.last_shoot_stage = -1
			player.in_hand_item_name = select_item_name
			player.set_item_in_hand(select_item_name)
	if StaticLoad.tools_type.has(select_item_name) and StaticLoad.tools_type[select_item_name].has("sword"):
		block_selection_ui.visible = false
	else:
		block_selection_ui.visible = true
	if player.item_bar_names[sort] == "AIR":
		return
	item_name_label.text = player.item_bar_names[sort]
	item_name_timer = StaticLoad.ITEM_NAME_SHOW_TIME

func refresh_single_inventory_grid(sort, type):
	var inventory_show_grids_tmp
	var inventory_back_grids_tmp
	if type == "inventory":
		inventory_show_grids_tmp = inventory_show_grids
		inventory_back_grids_tmp = inventory_back_grids
	elif type == "crafting":
		inventory_show_grids_tmp = crafting_inventory_show_grids
		inventory_back_grids_tmp = crafting_inventory_back_grids
	if sort >= 0 and sort < 9:
		var item_name = player.item_bar_names[sort]
		var item_amount = player.item_bar_amounts[sort]
		@warning_ignore("shadowed_variable")
		var inventory_grid = inventory_show_grids_tmp.get_node("InventoryGrid"+str(sort))
		if inventory_grid.item_name != item_name or inventory_grid.item_amount != item_amount:
			inventory_grid.init_inventory_grid(item_name, item_amount)
	elif sort >= 9:
		var item_name = player.item_bar_names[sort]
		var item_amount = player.item_bar_amounts[sort]
		@warning_ignore("shadowed_variable")
		var inventory_grid = inventory_back_grids_tmp.get_node("InventoryGrid"+str(sort))
		if inventory_grid.item_name != item_name or inventory_grid.item_amount != item_amount:
			inventory_grid.init_inventory_grid(item_name, item_amount)

func refresh_inventory():
	for i in range(0, 36):
		refresh_single_inventory_grid(i, "inventory")

func refresh_crafting_inventory():
	for i in range(0, 36):
		refresh_single_inventory_grid(i, "crafting")

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
	if button_name == "CraftingCloseButton":
		await get_tree().create_timer(0.01).timeout
		crafting_ui.visible = false
		is_crafting = false
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

func clear_particles():
	for particle in back_particles.get_children():
		particle.queue_free()
	for particle in front_particles.get_children():
		particle.queue_free()

func summon_destroy_particle(got_position, type, item_name):
	if not is_particle_effect_on:
		return
	if item_name == "TORCH":
		return
	var particle = destroy_particle_scene.instantiate()
	back_particles.add_child(particle)
	particle.init(got_position, type, item_name)

func summon_death_particle(got_position):
	if not is_particle_effect_on:
		return
	var particle = death_particle_scene.instantiate()
	front_particles.add_child(particle)
	particle.init(got_position)

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
		if multiplayer.get_unique_id() == 1:
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
			if multiplayer.get_unique_id() == 1:
				StaticLoad.rpc_entity_func_by_uuid(player.get_uuid(), "send_message", text, "others", true)
			else:
				StaticLoad.rpc_entity_func_by_uuid(player.get_uuid(), "send_message", text, [player.player_peer_id], false)
		else:
			player.send_command(text)
			if multiplayer.get_unique_id() == 1:
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
		if player.mouse_item_amount > 0:
			sound_audio_manager.play_audio_static("player", "pop")
			player.drop_item(player.mouse_item_name, player.mouse_item_amount)
			player.mouse_item_name = "AIR"
			player.mouse_item_amount = 0

func _on_inventory_ui_hidden() -> void:
	var is_to_pop = false
	if player.mouse_item_amount > 0:
		player.drop_item(player.mouse_item_name, player.mouse_item_amount)
		player.mouse_item_name = "AIR"
		player.mouse_item_amount = 0
		is_to_pop = true
	var pop_item_dict = {}
	for y in range(2):
		for x in range(2):
			var craft_grid = inventory_craft_grid.get_node("Craft"+str(y*3+x))
			if craft_grid.item_name == "AIR":
				continue
			if not pop_item_dict.has(craft_grid.item_name):
				pop_item_dict[craft_grid.item_name] = craft_grid.item_amount
			else:
				pop_item_dict[craft_grid.item_name] += craft_grid.item_amount
			craft_grid.init_inventory_grid("AIR", 0)
			is_to_pop = true
	for item in pop_item_dict:
		player.drop_item(item, pop_item_dict[item])
	if is_to_pop:
		sound_audio_manager.play_audio_static("player", "pop")
	refresh_inventory_crafting_result()

func _on_crafting_ui_hidden() -> void:
	var is_to_pop = false
	if player.mouse_item_amount > 0:
		player.drop_item(player.mouse_item_name, player.mouse_item_amount)
		player.mouse_item_name = "AIR"
		player.mouse_item_amount = 0
		is_to_pop = true
	var pop_item_dict = {}
	for y in range(3):
		for x in range(3):
			var craft_grid = table_craft_grid.get_node("Craft"+str(y*3+x))
			if craft_grid.item_name == "AIR":
				continue
			if not pop_item_dict.has(craft_grid.item_name):
				pop_item_dict[craft_grid.item_name] = craft_grid.item_amount
			else:
				pop_item_dict[craft_grid.item_name] += craft_grid.item_amount
			craft_grid.init_inventory_grid("AIR", 0)
			is_to_pop = true
	for item in pop_item_dict:
		player.drop_item(item, pop_item_dict[item])
	if is_to_pop:
		sound_audio_manager.play_audio_static("player", "pop")
	refresh_table_crafting_result()

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
