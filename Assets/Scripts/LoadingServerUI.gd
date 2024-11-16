extends CanvasLayer

@onready var progress_bar = $ProgressBar
@onready var button1 = $Button1
@onready var title = $Title
@onready var game_path = "res://Assets/Scenes/Game.tscn"

var scene_load_progress = []
var scene_load_status = 0
var is_server_connected: bool = false
var is_server_state_checked: bool = false
var connect_interrupt_reason = "null"
var is_loaded_terrain: bool = false
var connecting_timer
var ip
var port

func _ready() -> void:
	progress_bar.max_value = 100
	if StaticLoad.is_in_game:
		is_server_connected = true
		button1.visible = false
		progress_bar.visible = true
		StaticLoad.game.freeze_game()
		StaticLoad.game.create_player(StaticLoad.multiplayer.get_unique_id())
		StaticLoad.game.init_game_as_client()

# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if not is_server_connected:
		connect_server()
		set_process(false)
	elif not StaticLoad.is_in_game:
		load_scene()
	else:
		load_terrain()
		if not is_loaded_terrain:
			return
		if StaticLoad.game.player == null or StaticLoad.game.player.is_frozen:
			return
		title.text = tr("COMPLETED")
		await get_tree().create_timer(1).timeout
		load_finished()

func start_connecting_timer():
	connecting_timer = get_tree().create_timer(StaticLoad.CONNECTING_TIME)  # 2秒后执行
	connecting_timer.connect("timeout", connection_timeout)

func connection_timeout():
	title.text = tr("CONNECTION_TIMEOUT")
	title.set("theme_override_colors/font_color", StaticLoad.colors["pink"])
	if StaticLoad.multiplayer.multiplayer_peer != null and StaticLoad.multiplayer.multiplayer_peer.get_connection_status() != StaticLoad.multiplayer.multiplayer_peer.CONNECTION_DISCONNECTED:
		StaticLoad.clear_connections()
	return

func connect_server():
	if StaticLoad.is_lan_server:
		ip = StaticLoad.lan_server_ip
		port = StaticLoad.lan_server_port
	else:
		var server_config = ConfigFile.new()
		var server_info = server_config.load_encrypted_pass(StaticLoad.server_path+"/"+StaticLoad.select_server+".srv", StaticLoad.CONFIG_PASSWORD)
		if server_info != OK:
			return
		ip = server_config.get_value("server", "ip")
		port = int(server_config.get_value("server", "port"))
	StaticLoad.reset_signals(false)
	var err = StaticLoad.multiplayer_peer.create_client(ip, port)
	if OK != err:
		title.text = tr("CONNECTION_FAIL")
		title.set("theme_override_colors/font_color", StaticLoad.colors["pink"])
		return
	StaticLoad.multiplayer.multiplayer_peer = StaticLoad.multiplayer_peer
	var config = ConfigFile.new()
	var result = config.load("user://configs.cfg")
	var player_name
	if result == OK:
		player_name = config.get_value("options", "player_name", StaticLoad.options["player_name"])
	start_connecting_timer()
	while not is_server_connected:
		await get_tree().create_timer(1).timeout
	title.text = tr("CONNECTION_SUCCESS")
	StaticLoad.rpc_id(1, "request_for_connect_state_check", StaticLoad.multiplayer.get_unique_id(), player_name, StaticLoad.options["version"])
	while not is_server_state_checked:
		if connect_interrupt_reason != "null":
			if connect_interrupt_reason == "same_player_name":
				title.text = tr("SAME_PLAYER_NAME")
			elif connect_interrupt_reason == "version_conflict":
				title.text = tr("VERSION_CONFLICT")
			title.set("theme_override_colors/font_color", StaticLoad.colors["pink"])
			if StaticLoad.multiplayer.multiplayer_peer != null and StaticLoad.multiplayer.multiplayer_peer.get_connection_status() != StaticLoad.multiplayer.multiplayer_peer.CONNECTION_DISCONNECTED:
				StaticLoad.clear_connections()
			return
		await get_tree().create_timer(1).timeout
	progress_bar.visible = true
	button1.visible = false
	StaticLoad.is_muti_mode = true
	ResourceLoader.load_threaded_request(game_path)
	StaticLoad.update_path()
	set_process(true)

func load_scene():
	title.text = tr("LOADING_SCENE")
	scene_load_status = ResourceLoader.load_threaded_get_status(game_path, scene_load_progress)
	progress_bar.value = scene_load_progress[0] * 100
	if scene_load_status == ResourceLoader.THREAD_LOAD_LOADED:
		StaticLoad.is_in_game = true
		set_process(false)
		StaticLoad.change_scene(ResourceLoader.load_threaded_get(game_path))
		
func load_terrain():
	title.text = tr("LOADING_TERRAIN")
	if StaticLoad.game.total_chunk_num == 0:
		return
	progress_bar.value = int(((StaticLoad.game.loaded_chunk_num * 1.0) / StaticLoad.game.total_chunk_num) * 100)
	if progress_bar.value == 100:
		is_loaded_terrain = true

func load_finished():
	StaticLoad.game.pause_button_4.visible = false
	StaticLoad.game.pause_button_5.visible = false
	StaticLoad.game.pause_button_6.visible = true
	StaticLoad.game.unfreeze_game()
	self.visible = false
	set_process(false)

func _on_loading_ui_button_1_pressed() -> void:
	StaticLoad.click_audio_player.play()
	if StaticLoad.multiplayer.multiplayer_peer != null and StaticLoad.multiplayer.multiplayer_peer.get_connection_status() != StaticLoad.multiplayer.multiplayer_peer.CONNECTION_DISCONNECTED:
		StaticLoad.clear_connections()
	StaticLoad.change_scene("res://Assets/Scenes/MutiMenu.tscn")
