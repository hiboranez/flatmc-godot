extends Control

@onready var progress_bar = $ProgressBar
@onready var title_label = $Title
@onready var tip_label = $ProgressBar/Tip
@onready var back_button = $BackButton

var menu: Node = null
var title: String = ""
var content_top_margin: float = 0
var content_bottom_margin: float = 0

var scene_load_progress = []
var scene_load_status = 0
var is_loaded_terrain: bool = false
var connecting_timer

func _ready() -> void:
	set_process(false)
	get_viewport().size_changed.connect(refresh_size)
	if StaticLoad.is_in_game:
		back_button.visible = false
		progress_bar.visible = true
		StaticLoad.game.freeze_game()
		StaticLoad.game.create_player(multiplayer.get_unique_id())
		StaticLoad.game.init_game_as_client()

func _process(delta: float) -> void:
	load_terrain()
	if not is_loaded_terrain:
		return
	var player_tmp = ClientManager.local_player
	if player_tmp == null or ClientManager.local_player.is_frozen:
		return
	title_label.text = tr("COMPLETED")
	ClientManager.local_player.velocity = Vector2(0, 0)
	ClientManager.local_player.unfreeze()
	await get_tree().create_timer(1).timeout
	load_finished()

func refresh_size() -> void:
	var canvas_size = get_viewport().get_screen_transform().affine_inverse()*Vector2(get_viewport().size)
	scale = Vector2(menu.scale_factor, menu.scale_factor)
	set_deferred("size", Vector2(canvas_size.x/menu.scale_factor, (canvas_size.y-((content_top_margin+content_bottom_margin)*menu.scale_factor))/menu.scale_factor))

func update_tip():
	if StaticLoad.is_dedicated_server:
		return
	var rng = RandomNumberGenerator.new()
	var num = rng.randi_range(0,1)
	tip_label.text = tr("TIP_"+str(num))

func start_connecting_timer():
	connecting_timer = get_tree().create_timer(StaticLoad.CONNECTING_TIME)  # 2秒后执行
	connecting_timer.connect("timeout", connection_timeout)

func connection_timeout():
	title_label.text = tr("CONNECTION_TIMEOUT")
	title_label.set("theme_override_colors/font_color", StaticLoad.colors["pink"])
	if multiplayer.multiplayer_peer != null and multiplayer.multiplayer_peer.get_connection_status() != multiplayer.multiplayer_peer.CONNECTION_DISCONNECTED:
		StaticLoad.clear_connections()
	return

func connect_server():
	ServerManager.connect_interrupt_reason = "null"
	ServerManager.is_server_connected = false
	ServerManager.is_server_state_checked = false
	StaticLoad.reset_signals(false)
	var err = StaticLoad.multiplayer_peer.create_client(ServerManager.server_ip, ServerManager.server_port)
	if OK != err:
		title_label.text = tr("CONNECTION_FAIL")
		title_label.set("theme_override_colors/font_color", StaticLoad.colors["pink"])
		return
	multiplayer.multiplayer_peer = StaticLoad.multiplayer_peer
	var config = ConfigFile.new()
	var result = config.load("user://configs.cfg")
	var player_name = SettingsManager.get_current_setting("player_name")
	start_connecting_timer()
	while not ServerManager.is_server_connected:
		await get_tree().create_timer(1).timeout
	title_label.text = tr("CONNECTION_SUCCESS")
	AudioManager.stop_bgm()
	StaticLoad.rpc_id(1, "request_for_connect_state_check", multiplayer.get_unique_id(), player_name, "0.2.0")
	while not ServerManager.is_server_state_checked:
		if ServerManager.connect_interrupt_reason != "null":
			if ServerManager.connect_interrupt_reason == "same_player_name":
				title_label.text = tr("SAME_PLAYER_NAME")
			elif ServerManager.connect_interrupt_reason == "version_conflict":
				title_label.text = tr("VERSION_CONFLICT")
			elif ServerManager.connect_interrupt_reason == "player_name_exceed":
				title_label.text = tr("PLAYER_NAME_EXCEED")
			elif ServerManager.connect_interrupt_reason == "player_name_space":
				title_label.text = tr("PLAYER_NAME_SPACE")
			title_label.set("theme_override_colors/font_color", StaticLoad.colors["pink"])
			if multiplayer.multiplayer_peer != null and multiplayer.multiplayer_peer.get_connection_status() != multiplayer.multiplayer_peer.CONNECTION_DISCONNECTED:
				StaticLoad.clear_connections()
			return
		await get_tree().create_timer(1).timeout
	progress_bar.visible = true
	back_button.visible = false
	StaticLoad.is_muti_mode = true
	StaticLoad.update_select_world_path()
	SceneManager.change_scene("others/game")

func load_game():
	update_tip()
	StaticLoad.update_select_world_path()
	set_process(true)
		
func load_terrain():
	title_label.text = tr("LOADING_TERRAIN")
	if StaticLoad.game.total_chunk_num == 0:
		return
	progress_bar.value = int(((StaticLoad.game.loaded_chunk_num * 1.0) / StaticLoad.game.total_chunk_num) * 100)
	if progress_bar.value == 100:
		is_loaded_terrain = true

func load_finished():
	set_process(false)
	StaticLoad.game.pause_button_5.visible = false
	StaticLoad.game.pause_button_6.visible = false
	StaticLoad.game.pause_button_7.visible = true
	StaticLoad.game.death_button_2.visible = false
	StaticLoad.game.death_button_3.visible = true
	StaticLoad.game.unfreeze_game()
	StaticLoad.rpc_id(1, "request_for_world_info", multiplayer.get_unique_id(), false)
	if menu != null:
		await menu.menu_controller.vanish("menu")

func _on_back_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	if multiplayer.multiplayer_peer != null and multiplayer.multiplayer_peer.get_connection_status() != multiplayer.multiplayer_peer.CONNECTION_DISCONNECTED:
		StaticLoad.clear_connections()
	if menu != null:
		await menu.menu_controller.vanish("loading_server_panel")
		menu.panel_control_dict.erase("loading_server_panel")
		get_viewport().size_changed.disconnect(refresh_size)
		var multi_game_panel = menu.panel_control_dict["multi_game_panel"]
		await multi_game_panel.update_server_list()
		multi_game_panel.detect_all_server()
		menu.base_content_panel.title = multi_game_panel.title
		menu.base_content_panel.content_top_margin = multi_game_panel.content_top_margin
		menu.base_content_panel.content_bottom_margin = multi_game_panel.content_bottom_margin
		menu.base_content_panel.animated_refresh_size(multi_game_panel)
		menu.menu_controller.appear("multi_game_panel")
	queue_free()
