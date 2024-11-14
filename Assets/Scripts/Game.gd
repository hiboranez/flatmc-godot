extends Node2D

@onready var tile_map_layer = $World/TileMapLayer
@onready var pause_ui = $PauseUI
@onready var game_ui = $GameUI
@onready var options_ui = $Options
@onready var online_ui = $OnlineUI
@onready var online_ui_vbox_container = $OnlineUI/OnlineList/ScrollContainer/VBoxContainer
@onready var message_scene = load("res://Assets/Scenes/Message.tscn") as PackedScene
@onready var player_scene = load("res://Assets/Scenes/Player.tscn") as PackedScene
@onready var loading_world_ui_scene = load("res://Assets/Scenes/LoadingWorldUI.tscn") as PackedScene
@onready var loading_server_ui_scene = load("res://Assets/Scenes/LoadingServerUI.tscn") as PackedScene
@onready var online_info_scene = load("res://Assets/Scenes/OnlineInfo.tscn") as PackedScene
@onready var time_counter = load("res://Assets/Scenes/TimeCounter.tscn") as PackedScene
@onready var move_center_button_normal = load("res://Assets/Textures/GUI/move_center_button_normal.tres") as AtlasTexture
@onready var move_center_button_fly = load("res://Assets/Textures/GUI/move_center_button_fly.tres") as AtlasTexture
#@onready var player_other_scene = load("res://Assets/Scenes/PlayerOther.tscn") as PackedScene
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
@onready var players = $Players
@onready var mobile_ui = $MobileUI
@onready var move_buttons = $MobileUI/MoveButtons
@onready var move_up_left_button = $MobileUI/MoveButtons/UpLeftButton
@onready var move_up_right_button = $MobileUI/MoveButtons/UpRightButton
@onready var move_center_button_icon = $MobileUI/MoveButtons/CenterButton/CenterButton

var touch_list = []
var block_selection_timer: float = 0
var block_selection_box
var render_chunk: int
var chunk_to_load = []
var is_pause: bool = false
var is_chat: bool = false
var is_player_info_updated: bool = false
var player_last_chunk: Vector2i
var loaded_chunks: Dictionary #true代表已修改，需要最后保存
var total_chunk_num = 0
var loaded_chunk_num = 0
var item_name_timer: float = 0
var last_mouse_in_world_pos: Vector2 = Vector2(0, 0)
var move_input_list = []
var last_left_time = 0.0
var last_right_time = 0.0
var last_jump_time = 0.0
var last_player_state = {
	"face_state": StaticLoad.DEFAULT_PLAYER_FACE_STATE,
	"move_state": "idle",
	"is_jump_pressed": false,
	"is_down_pressed": false,
	"is_flying": false
}

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_world()
		save_player()
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
				move_input_list.clear()
				player.stop_player_move()
				if StaticLoad.is_muti_mode:
					player.rpc("remote_stop_player_move")
			Input.emulate_mouse_from_touch = true
	
func _ready() -> void:
	StaticLoad.update_game()
	StaticLoad.update_path()
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
		init_game_as_single()
		if StaticLoad.is_dedicated_server:
			StaticLoad.start_server()
			unfreeze_game()
		else:
			create_player()

func _process(delta: float) -> void:
	refresh_game()
	update_new_chunk(false)
	
	if StaticLoad.is_dedicated_server:
		return
	
	update_details(false)
	update_player_state()
	show_item_name(delta)
	update_block_selection_timer(delta)
	if not StaticLoad.is_on_mobile_platform:
		update_block_selection_ui(get_local_mouse_position())
	update_last_mouse_in_world_pos()
	process_touch_input()

func open_online_info_ui():
	online_ui.visible = true
	for peer_id in StaticLoad.online_peer_ids:
		if online_ui_vbox_container.has_node(str(peer_id)):
			if peer_id == 1 and StaticLoad.multiplayer.get_unique_id() == 1:
				continue
			elif StaticLoad.multiplayer.get_unique_id() == 1:
				StaticLoad.online_peer_pings[peer_id].start_ping()
				continue
			StaticLoad.rpc_id(1, "request_for_ping", StaticLoad.multiplayer.get_unique_id(), peer_id)
			continue
		var player_tmp = StaticLoad.online_peer_ids[peer_id]
		var online_info_instance = online_info_scene.instantiate()
		online_ui_vbox_container.add_child(online_info_instance)
		online_info_instance.name = str(peer_id)
		online_info_instance.player_name.text = player_tmp.player_name
		if peer_id == 1 and StaticLoad.multiplayer.get_unique_id() == 1:
			online_info_instance.animation.animation = "signal"
			online_info_instance.animation.frame = StaticLoad.get_level_by_ping(0)
		elif StaticLoad.multiplayer.get_unique_id() == 1:
			StaticLoad.online_peer_pings[peer_id].start_ping()
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
	
	if event is InputEventMouseMotion and not is_pause and not is_chat and not player.is_dead:
		update_block_selection_ui(get_local_mouse_position(), true)
	
	if Input.is_action_just_pressed("screenshot"):
		screenshot()
	
	if StaticLoad.is_muti_mode:
		if Input.is_action_just_pressed("online_info"):
			open_online_info_ui()
			
	if Input.is_action_just_released("online_info"):
		online_ui.visible = false
		
	if Input.is_action_just_pressed("esc"):
		if is_chat:
			close_chat_ui()
			
		else:
			pause_ui.visible = !pause_ui.visible
			is_pause = pause_ui.visible
			if pause_ui.visible:
				move_input_list.clear()
				player.stop_player_move()
				if StaticLoad.is_muti_mode:
					player.rpc("remote_stop_player_move")
			
	if Input.is_action_just_pressed("chat"):
		if not is_chat:
			move_input_list.clear()
			player.stop_player_move()
			if StaticLoad.is_muti_mode:
				player.rpc("remote_stop_player_move")
			is_chat = true
			chat_message_out.visible = false
			chat_panel.visible = true
			chat_history_in.scroll_vertical = 1e9
			await get_tree().create_timer(0.01).timeout
			chat_line_edit.grab_focus()
			chat_line_edit.text = ""
	
	if Input.is_action_just_pressed("chat_slash"):
		if not is_chat:
			move_input_list.clear()
			player.stop_player_move()
			if StaticLoad.is_muti_mode:
				player.rpc("remote_stop_player_move")
			is_chat = true
			chat_message_out.visible = false
			chat_panel.visible = true
			chat_history_in.scroll_vertical = 1e9
			await get_tree().create_timer(0.01).timeout
			chat_line_edit.grab_focus()
			chat_line_edit.insert_text_at_caret("/")
	
	if is_pause or is_chat:
		return
	
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

func process_touch_input():
	for touch in touch_list:
		if touch.double_tap:
			place_block(tile_map_layer.local_to_map(camera_screen_pos_to_local_pos(player.camera, touch.position)))
		else:
			var pressed_time = touch_time_counters.get_node(str(touch.index)).timer
			if pressed_time >= StaticLoad.LONG_TOUCH_TIME:
				destroy_block(tile_map_layer.local_to_map(camera_screen_pos_to_local_pos(player.camera, touch.position)))

@warning_ignore("unused_parameter")
func _unhandled_input(event: InputEvent) -> void:
	if is_pause or is_chat:
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
				place_block(tile_map_layer.local_to_map(camera_screen_pos_to_local_pos(player.camera, event.position)))
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
	
	if Input.is_action_just_released("mouse_scroll_down"):
		if player.selected_item_grid >= 1:
			select_item_grid(player.selected_item_grid)
		else:
			select_item_grid(9)
	
	if Input.is_action_just_released("mouse_scroll_up"):
		if player.selected_item_grid <= 7:
			select_item_grid(player.selected_item_grid+2)
		else:
			select_item_grid(0)
			
	var mouse_in_world_pos = tile_map_layer.get_local_mouse_position()
	var mouse_to_block_pos = tile_map_layer.local_to_map(mouse_in_world_pos)
	if mouse_in_world_pos != last_mouse_in_world_pos and Input.is_action_pressed("mouse_left"):
		destroy_block(mouse_to_block_pos)
	
	if mouse_in_world_pos != last_mouse_in_world_pos and Input.is_action_pressed("mouse_right"):
		place_block(mouse_to_block_pos)

func destroy_block(block_pos: Vector2i):
	var block_id = StaticLoad.get_block_id_by_atlas_coords(tile_map_layer.get_cell_atlas_coords(block_pos))
	if tile_map_layer.get_cell_source_id(block_pos) != -1 and block_id != 0:
		if set_block(block_pos, 0):
			update_block_selection_ui(tile_map_layer.map_to_local(block_pos), true)
			#if StaticLoad.is_on_mobile_platform:
				#Input.vibrate_handheld(100, 0.5)
			if StaticLoad.is_muti_mode:
				if StaticLoad.multiplayer.get_unique_id() == 1:
					StaticLoad.rpc("apply_for_set_block", block_pos, 0)
				else:
					StaticLoad.rpc_id(1, "request_for_set_block", block_pos, 0)
		var chunk_pos = get_chunk_position(block_pos)
		loaded_chunks[str(chunk_pos[0])+"."+str(chunk_pos[1])] = true
		if StaticLoad.is_muti_mode and StaticLoad.multiplayer.get_unique_id() != 1:
			StaticLoad.rpc_id(1, "request_for_mark_revised_chunk", chunk_pos)

func place_block(block_pos):
	var block_id = StaticLoad.get_block_id_by_name(player.item_bar_names[player.selected_item_grid])
	if tile_map_layer.get_cell_source_id(block_pos) == -1:
		if set_block(block_pos, block_id):
			update_block_selection_ui(tile_map_layer.map_to_local(block_pos), true)
			#if StaticLoad.is_on_mobile_platform:
				#Input.vibrate_handheld(100, 0.5)
			if StaticLoad.is_muti_mode:
				if StaticLoad.multiplayer.get_unique_id() == 1:
					StaticLoad.rpc("apply_for_set_block", block_pos, block_id)
				else:
					StaticLoad.rpc_id(1, "request_for_set_block", block_pos, block_id)
		var chunk_pos = get_chunk_position(block_pos)
		loaded_chunks[str(chunk_pos[0])+"."+str(chunk_pos[1])] = true
		if StaticLoad.is_muti_mode and StaticLoad.multiplayer.get_unique_id() != 1:
			StaticLoad.rpc_id(1, "request_for_mark_revised_chunk", chunk_pos)

func camera_screen_pos_to_local_pos(camera, pos):
	var inv_canv_tfm: Transform2D = camera.get_canvas_transform().affine_inverse()
	var half_screen: Transform2D = Transform2D().translated(pos)
	var actual_screen_center_pos: Vector2 = inv_canv_tfm * half_screen * Vector2(0, 0)
	return actual_screen_center_pos


func init_game_as_single():
	var config = ConfigFile.new()
	var result = config.load("user://configs.cfg")
	if result == OK:
		render_chunk = int(config.get_value("options", "render_chunk", StaticLoad.options["render_chunk"]))
		block_selection_box = config.get_value("options", "block_selection_box", StaticLoad.options["block_selection_box"])
		#player.player_name = config.get_value("options", "player_name", StaticLoad.options["player_name"])
		#player.name_label.text = player.player_name
		#var fov_zoom = 1+1.6*(int(config.get_value("options", "fov_zoom", StaticLoad.options["fov_zoom"]))/100.0)
		#player.camera.zoom = Vector2(fov_zoom, fov_zoom)
		#update_details(true)
	var regions = DirAccess.get_files_at(ProjectSettings.globalize_path(StaticLoad.region_path))
	if regions.is_empty():
		return
	total_chunk_num = regions.size()
	for region in regions:
		var splits = region.split(".")
		var x_chunk = int(splits[1])
		var y_chunk = int(splits[2])
		var chunk_config = ConfigFile.new()
		var chunk_result = chunk_config.load_encrypted_pass(StaticLoad.region_path+"/"+region, StaticLoad.CONFIG_PASSWORD)
		if chunk_result != OK:
			return
		var blocks = chunk_config.get_value("chunck", "blocks")
		set_chunk(Vector2i(x_chunk, y_chunk), blocks)
		loaded_chunks[str(x_chunk)+"."+str(y_chunk)] = false
		loaded_chunk_num += 1
	#var player_infos = DirAccess.get_files_at(ProjectSettings.globalize_path(StaticLoad.player_path))
	#for player_info in player_infos:
		#var player_config = ConfigFile.new()
		#var player_result = player_config.load_encrypted_pass(StaticLoad.player_path+"/"+player.player_name+".dat", StaticLoad.CONFIG_PASSWORD)
		#if player_result == OK:
			#player.position = player_config.get_value("player", "position", StaticLoad.DEFAULT_PLAYER_SPAWN_POS)
			#player.face_state = player_config.get_value("player", "face_state", StaticLoad.DEFAULT_PLAYER_FACE_STATE)
			#player.is_flying = player_config.get_value("player", "is_flying", false)
	#player.init()
	update_block_selection_ui(get_local_mouse_position())
	
func init_game_as_client():
	StaticLoad.select_world = "new world"
	StaticLoad.update_path()
	StaticLoad.rpc_id(1, "request_for_player_info", StaticLoad.multiplayer.get_unique_id(), player.player_name)
	while not is_player_info_updated:
		await get_tree().create_timer(1).timeout
	var config = ConfigFile.new()
	var result = config.load("user://configs.cfg")
	if result != OK:
		return
	render_chunk = int(config.get_value("options", "render_chunk", StaticLoad.options["render_chunk"]))
	block_selection_box = config.get_value("options", "block_selection_box", StaticLoad.options["block_selection_box"])
	var player_pos = tile_map_layer.local_to_map(player.position)
	var chunk_pos = get_chunk_position(player_pos)
	var x_player_chunk = chunk_pos[0]
	var y_player_chunk = chunk_pos[1]
	var loading_chunk_total_sum = 0
	for x in range(x_player_chunk-render_chunk, x_player_chunk+render_chunk+1):
		for y in range(y_player_chunk-render_chunk, y_player_chunk+render_chunk+1):
			loading_chunk_total_sum += 1
	total_chunk_num = loading_chunk_total_sum
	for x in range(x_player_chunk-render_chunk, x_player_chunk+render_chunk+1):
		for y in range(y_player_chunk-render_chunk, y_player_chunk+render_chunk+1):
			StaticLoad.rpc_id(1, "request_for_update_chunk", StaticLoad.multiplayer.get_unique_id(), x, y)
	update_block_selection_ui(get_local_mouse_position())

func create_player(peer_id = 1):
	var player_instance = player_scene.instantiate()
	player_instance.name = str(peer_id)
	player_instance.freeze_player()
	players.add_child(player_instance)
	if not StaticLoad.is_muti_mode:
		player = player_instance
		player.init(peer_id)
	elif peer_id == StaticLoad.multiplayer.get_unique_id():
		player = player_instance
		player.init(peer_id)
	else:
		player_instance.is_other = true
	if StaticLoad.is_dedicated_server:
		player_instance.unfreeze_player()

func freeze_game():
	set_process_unhandled_input(false)
	set_process(false)
	bgm_audio_player.stream_paused = true

func unfreeze_game():
	set_process_unhandled_input(true)
	set_process(true)
	bgm_audio_player.stream_paused = false
	player.camera.position_smoothing_enabled = true
	
func refresh_game():
	if not StaticLoad.is_muti_mode:
		return
	if StaticLoad.multiplayer.get_unique_id() != 1 and not StaticLoad.is_dedicated_server:
		return
	refresh_player()
	#if StaticLoad.refresh_timer > 0:
		#StaticLoad.refresh_timer -= delta
	#else:
		#StaticLoad.refresh_timer = StaticLoad.REFRESH_TIME
		#for peer_id in StaticLoad.online_peer_ids:
			#if peer_id == 1:
				#continue
			#for key in StaticLoad.online_peer_ids:
				#var player_tmp = StaticLoad.online_peer_ids[key]
				#player_tmp.rpc_id(peer_id, "refresh_player", player_tmp.position, player_tmp.face_state, player_tmp.move_state, player_tmp.is_flying)

func refresh_player():
	for peer_id in StaticLoad.online_peer_ids:
		var player_tmp = StaticLoad.online_peer_ids[peer_id]
		if peer_id != 1 and not player_tmp.is_frozen:
			player_tmp.rpc_id(peer_id, "remote_check_player_position", player_tmp.position)
		var player_refresh_timer = player_tmp.refresh_timer
		if player_refresh_timer <= 0:
			player_refresh_timer = StaticLoad.REFRESH_TIME
			for id in StaticLoad.online_peer_ids:
				if id == 1 or player_tmp.is_frozen:
					continue
				player_tmp.rpc_id(id, "refresh_player", player_tmp.position, player_tmp.face_state, player_tmp.move_state, player_tmp.is_flying)

func update_player_state():
	if player.is_dead or is_pause or is_chat or player.is_frozen:
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
		
	if Input.is_action_just_pressed("jump"):
		var current_time = Time.get_ticks_msec() / 1000.0
		if current_time - last_jump_time < StaticLoad.DOUBLE_CLICK_THRESHOLD:
			player.is_flying = not player.is_flying
			if player.is_flying:
				move_center_button_icon.texture = move_center_button_fly
			else:
				move_center_button_icon.texture = move_center_button_normal
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
		player.move_state = "stand"
		
	if not move_input_list.is_empty():
		if move_input_list.back() == "left":
			player.face_state = -1
		elif move_input_list.back() == "right":
			player.face_state = 1
	
	if not StaticLoad.is_muti_mode:
		return
	
	player.update_player_state()
	var is_update_required = false
	for key in last_player_state:
		if last_player_state[key] != player.player_state[key]:
			is_update_required = true
		last_player_state[key] = player.player_state[key]
	if is_update_required:
		player.broadcast_player_state_to_all()

func close_chat_ui():
	is_chat = false
	chat_panel.visible = false
	chat_message_out.visible = true
	await get_tree().create_timer(0.001).timeout
	chat_history_in.scroll_vertical = 1e9
	chat_history_out.scroll_vertical = 1e9
	chat_line_edit.text = ""

func update_details(is_pre_load: bool = false):
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

func update_last_mouse_in_world_pos():
	last_mouse_in_world_pos = tile_map_layer.get_local_mouse_position()

func update_block_selection_timer(delta):
	if block_selection_box == "show_when_changing":
		if is_pause:
			block_selection_timer = 0
		if block_selection_timer > 0 and block_selection_timer <= StaticLoad.BLOCK_SELECTION_DISAPPEAR_TIME:
			var alpha = block_selection_timer/StaticLoad.BLOCK_SELECTION_DISAPPEAR_TIME
			block_selection_ui.self_modulate = Color(1,1,1,alpha)
		elif block_selection_timer > StaticLoad.BLOCK_SELECTION_DISAPPEAR_TIME:
			block_selection_ui.self_modulate = Color(1,1,1,1)
		else:
			block_selection_ui.self_modulate = Color(1,1,1,0)
		if block_selection_timer > 0:
			block_selection_timer -= delta
	elif block_selection_box == "always_show":
		block_selection_ui.self_modulate = Color(1,1,1,1)
	elif block_selection_box == "never_show":
		block_selection_ui.self_modulate = Color(1,1,1,0)
	
func update_block_selection_ui(pos, is_timer_refresh = false):
	var x_offset = 25
	var y_offset = -25
	if pos.x < 0:
		x_offset = -25
	if pos.y > 0:
		y_offset = 25
	@warning_ignore("integer_division")
	var block_pos = Vector2((int(pos.x)/50)*50+x_offset, (int(pos.y)/50)*50+y_offset)
	block_selection_ui.position = block_pos
	if is_timer_refresh:
		block_selection_timer = StaticLoad.BLOCK_SELECTION_TIME

func switch_details_visibility():
	details.visible = not details.visible

func switch_ui_visibility():
	game_ui.visible = not game_ui.visible
	block_selection_ui.visible = game_ui.visible
	for peer_id in StaticLoad.online_peer_ids:
		StaticLoad.online_peer_ids[peer_id].name_label.visible = game_ui.visible

func show_item_name(delta: float):
	if item_name_timer < 0:
		return
	var alpha: float = 1
	if item_name_timer <= StaticLoad.ITEM_NAME_DISAPPEAR_TIME:
		alpha = item_name_timer/StaticLoad.ITEM_NAME_DISAPPEAR_TIME
	item_name_label.self_modulate = Color(1,1,1,alpha)
	item_name_timer -= delta
	if item_name_timer < 0:
		item_name_label.self_modulate = Color(1,1,1,0)

func get_chunk_position(block_pos: Vector2i):
	@warning_ignore("integer_division")
	var x_chunk = block_pos[0]/16
	@warning_ignore("integer_division")
	var y_chunk = block_pos[1]/16
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
		for x in range(x_player_chunk-render_chunk, x_player_chunk+render_chunk+1):
			for y in range(y_player_chunk-render_chunk, y_player_chunk+render_chunk+1):
				#if not FileAccess.file_exists(region_path+"/r."+str(x)+"."+str(y)+".mca"):
				if not loaded_chunks.has(str(x)+"."+str(y)):
					if StaticLoad.is_muti_mode and StaticLoad.multiplayer.get_unique_id() != 1:
						StaticLoad.rpc_id(1, "request_for_update_chunk", StaticLoad.multiplayer.get_unique_id(), x, y)
					else:
						var mca = ConfigFile.new()
						var blocks = StaticLoad.generate_chunk(Vector2i(x, y))
						set_chunk(Vector2i(x, y), blocks)
						loaded_chunk_num += 1
						mca.set_value("chunck", "blocks", blocks)
						mca.save_encrypted_pass(StaticLoad.region_path+"/r."+str(x)+"."+str(y)+".mca", StaticLoad.CONFIG_PASSWORD)
						loaded_chunks[str(x)+"."+str(y)] = false
		player_last_chunk = Vector2i(x_player_chunk, y_player_chunk)

func set_chunk(pos: Vector2i, blocks) -> void:
	for x in range(0, 16):
		for y in range(0, 16):
			set_block(Vector2i(pos[0] * 16 + x, pos[1] * 16 + y), blocks[y][x], true)

func set_block(block_pos: Vector2i, block_id: int, is_pre_load = false):
	if block_id == 0:
		if tile_map_layer.get_cell_source_id(block_pos) == -1:
			return false
		if not is_pre_load:
			@warning_ignore("confusable_local_declaration")
			var atlas_coords = tile_map_layer.get_cell_atlas_coords(block_pos)
			sound_audio_manager.play_random_audio_at_position("dig", StaticLoad.get_block_type_by_id(StaticLoad.get_block_id_by_atlas_coords(atlas_coords)), tile_map_layer.map_to_local(block_pos))
		tile_map_layer.set_cell(block_pos)
		return true
	if tile_map_layer.get_cell_source_id(block_pos) != -1:
		return false
	if not is_pre_load:
		for id in StaticLoad.online_peer_ids:
			var player_tmp = StaticLoad.online_peer_ids[id]
			var player_pos = tile_map_layer.local_to_map(player_tmp.position)
			if player_pos == block_pos:
				return false
			if player_pos - Vector2i(0, 1) == block_pos:
				return false
	var atlas_coords = StaticLoad.get_atlas_coords_by_block_id(block_id)
	tile_map_layer.set_cell(block_pos, 9999, atlas_coords)
	if not is_pre_load:
		sound_audio_manager.play_random_audio_at_position("dig", StaticLoad.get_block_type_by_id(block_id), tile_map_layer.map_to_local(block_pos))
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
	level.save_encrypted_pass(StaticLoad.world_path+"/level.dat", StaticLoad.CONFIG_PASSWORD)

func save_player(peer_id = 0):
	if peer_id == 0:
		for id in StaticLoad.online_peer_ids:
			var player_tmp = StaticLoad.online_peer_ids[id]
			var player_config = ConfigFile.new()
			player_config.set_value("player", "position", player_tmp.position)
			player_config.set_value("player", "face_state", player_tmp.face_state)
			player_config.set_value("player", "is_flying", player_tmp.is_flying)
			player_config.save_encrypted_pass(StaticLoad.player_path+"/"+player_tmp.player_name.to_lower()+".dat", StaticLoad.CONFIG_PASSWORD)
	else:
		var player_tmp = StaticLoad.online_peer_ids[peer_id]
		var player_config = ConfigFile.new()
		player_config.set_value("player", "position", player_tmp.position)
		player_config.set_value("player", "face_state", player_tmp.face_state)
		player_config.set_value("player", "is_flying", player_tmp.is_flying)
		player_config.save_encrypted_pass(StaticLoad.player_path+"/"+player_tmp.player_name.to_lower()+".dat", StaticLoad.CONFIG_PASSWORD)

func save_chunk(chunk_pos: Vector2i):
	var mca = ConfigFile.new()
	var blocks = []
	var x_chunk = chunk_pos[0]
	var y_chunk = chunk_pos[1]
	for y in range(16):
		var row = []
		for x in range(16):
			var block_pos = Vector2i(x_chunk*16+x, y_chunk*16+y)
			var id = 0
			if tile_map_layer.get_cell_source_id(block_pos) != -1:
				var atlas_coords = tile_map_layer.get_cell_atlas_coords(block_pos)
				id = StaticLoad.get_block_id_by_atlas_coords(atlas_coords)
			row.append(id)
		blocks.append(row)
	mca.set_value("chunck", "blocks", blocks)
	mca.save_encrypted_pass(StaticLoad.region_path+"/r."+str(x_chunk)+"."+str(y_chunk)+".mca", StaticLoad.CONFIG_PASSWORD)
	var level = ConfigFile.new()
	var current_time = Time.get_datetime_string_from_system(false, true).replace(" ", "  ").replace("-", "/")
	level.set_value("world", "last_modified", current_time)
	level.save_encrypted_pass(StaticLoad.world_path+"/level.dat", StaticLoad.CONFIG_PASSWORD)

func select_item_grid(grid_name) -> void:
	for i in range(9):
		@warning_ignore("confusable_local_declaration")
		var children = item_grids[i].get_children()
		children[1].visible = false
	var sort = int(str(grid_name))-1
	player.selected_item_grid = sort
	var children = item_grids[sort].get_children()
	children[1].visible = true
	item_name_label.text = player.item_bar_names[sort]
	item_name_timer = StaticLoad.ITEM_NAME_SHOW_TIME

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
	await get_tree().create_timer(0.001).timeout
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
	await get_tree().create_timer(0.001).timeout
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

func _on_pause_button_2_pressed() -> void:
	StaticLoad.click_audio_player.play()
	options_ui.visible = true

func _on_pause_button_3_pressed() -> void:
	StaticLoad.click_audio_player.play()
	language_ui.visible = true

func _on_pause_button_4_pressed() -> void:
	StaticLoad.click_audio_player.play()
	pause_ui.visible = false
	is_pause = false
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
	StaticLoad.is_in_game = false
	StaticLoad.change_scene("res://Assets/Scenes/Menu.tscn")
	
func _on_pause_button_6_pressed() -> void:
	Input.emulate_mouse_from_touch = true
	StaticLoad.click_audio_player.play()
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
			player.rpc("remote_update_message", StaticLoad.multiplayer.get_unique_id(), text)
		else:
			player.send_command(text)
			player.rpc("remote_update_command", StaticLoad.multiplayer.get_unique_id(), text)
	else:
		if text[0] != "/":
			player.send_message(text)
		else:
			player.send_command(text)
	await get_tree().create_timer(0.001).timeout
	chat_history_in.scroll_vertical = 1e9
	chat_history_out.scroll_vertical = 1e9
	if is_chat:
		chat_message_out.visible = false
	chat_line_edit.text = ""
	if StaticLoad.is_on_mobile_platform:
		close_chat_ui()

func _on_chat_history_out_pre_sort_children() -> void:
	chat_history_out.scroll_vertical = 1e9

func _on_mobile_f1_button_pressed():
	StaticLoad.click_audio_player.play()
	switch_ui_visibility()
	move_buttons.visible = game_ui.visible

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
		player.stop_player_move()
		if StaticLoad.is_muti_mode:
			player.rpc("remote_stop_player_move")
		is_chat = true
		chat_message_out.visible = false
		chat_panel.visible = true
		chat_history_in.scroll_vertical = 1e9
		await get_tree().create_timer(0.01).timeout
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
			move_input_list.clear()
			player.stop_player_move()
			if StaticLoad.is_muti_mode:
				player.rpc("remote_stop_player_move")
		Input.emulate_mouse_from_touch = true

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
