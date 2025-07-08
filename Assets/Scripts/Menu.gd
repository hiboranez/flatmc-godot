extends CanvasLayer

@onready var player_model = $Player/SubViewportContainer/SubViewport/PlayerModel
@onready var player_model_mesh = $Player/SubViewportContainer/SubViewport/PlayerModel/Root/Skeleton3D/Mesh
@onready var change_skin_file_dialog = $ChangeSkinFileDialog
@onready var back_ground_camera = $Background/SubViewportContainer/SubViewport/Camera3D

func _process(delta: float) -> void:
	update_player_model()
	back_ground_camera.rotate(Vector3.UP, -0.0001)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if OS.has_feature("dedicated_server"):
		return
	if OS.has_feature("android"):
		change_skin_file_dialog.current_dir = "/storage/emulated/0/"
	StaticLoad.select_server = null
	StaticLoad.select_world = null
	var exist_options = StaticLoad.check_options_outdated()
	if exist_options["is_option_outdated"]:
		StaticLoad.generate_options(exist_options)
	var config = ConfigFile.new()
	var result = config.load("user://configs.cfg")
	if result == OK:
		StaticLoad.language = config.get_value("options", "language")
		TranslationServer.set_locale(StaticLoad.language)
		var new_music_on = config.get_value("options", "new_music", "off")
		if new_music_on == "on":
			StaticLoad.is_new_music_on = true
		elif new_music_on == "off":
			StaticLoad.is_new_music_on = false
		if config.get_value("options", "full_screen") == "on":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		if config.get_value("options", "v_sync") == "on":
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		else:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		var updated = config.get_value("options", "updated", "false")
		var version = config.get_value("options", "version", "null")
		var sound_volume = config.get_value("options", "sound_volume", 100)
		StaticLoad.click_audio_player.volume_db = linear_to_db(int(sound_volume)/50.0)
		if updated == "false" or version == "null" or version != StaticLoad.options["version"]:
			StaticLoad.pop_big_notification(self, tr("RELEASE_NOTE"), tr("RELEASE_NOTE_TEXT"), tr("DO_NOT_SHOW_AGAIN"))
			var server_path = "user://servers/"
			if not DirAccess.dir_exists_absolute(server_path):
				DirAccess.make_dir_recursive_absolute(server_path)
			var server = ConfigFile.new()
			server.set_value("server", "ip", "flatmc.hiboranez.work")
			server.set_value("server", "port", "12419")
			server.set_value("server", "icon", StaticLoad.game_icon_image.save_png_to_buffer())
			server.save_encrypted_pass(server_path+"FlatMC.srv", StaticLoad.CONFIG_PASSWORD)
			var change_value = {
			"updated": "true",
			"version": StaticLoad.options["version"]
			}
			StaticLoad.save_options(change_value)
	if not DirAccess.dir_exists_absolute(StaticLoad.screenshot_path):
		DirAccess.make_dir_recursive_absolute(StaticLoad.screenshot_path)
	if not DirAccess.dir_exists_absolute(StaticLoad.server_path):
		DirAccess.make_dir_recursive_absolute(StaticLoad.server_path)
	if not DirAccess.dir_exists_absolute(StaticLoad.server_log_path):
		DirAccess.make_dir_recursive_absolute(StaticLoad.server_log_path)
	StaticLoad.update_default_skin_path()
	await get_tree().create_timer(0.05).timeout
	update_player_model_skin()

func update_player_model():
	var mouse_pos = get_viewport().get_mouse_position()
	var viewport_size = $Background.get_viewport_rect().size
	var viewport_half_size = viewport_size/2.0
	var target_pos = mouse_pos-viewport_half_size+Vector2(viewport_size[0]*0.375, 0)
	player_model.look_at(Vector3(target_pos[0], -target_pos[1], 3250), Vector3.UP, true)

func update_player_model_skin():
	var player_texture = load(StaticLoad.default_skin_path) as Texture2D
	var player_material = load("res://Assets/Materials/PlayerSkin.tres").duplicate(true)
	var config = ConfigFile.new()
	var result = config.load("user://configs.cfg")
	if result == OK:
		var skin_path = config.get_value("options", "skin_path")
		if skin_path != "null":	
			var player_texture_tmp = ImageTexture.create_from_image(Image.load_from_file(skin_path))
			if player_texture_tmp != null:
				player_texture = player_texture_tmp
	player_material.albedo_texture = player_texture
	player_model_mesh.mesh.surface_set_material(0, player_material)

func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		var audio_stream_player = StaticLoad.click_audio_player
		audio_stream_player.play()
		await audio_stream_player.finished
		get_tree().quit()

func _on_menu_button_1_pressed() -> void:
	StaticLoad.click_audio_player.play()
	StaticLoad.change_scene("res://Assets/Scenes/SingleMenu.tscn")
	
func _on_menu_button_2_pressed() -> void:
	StaticLoad.click_audio_player.play()
	StaticLoad.change_scene("res://Assets/Scenes/MutiMenu.tscn")

func _on_menu_button_3_pressed() -> void:
	StaticLoad.click_audio_player.play()
	StaticLoad.change_scene("res://Assets/Scenes/Options.tscn")
	
func _on_menu_button_4_pressed() -> void:
	StaticLoad.click_audio_player.play()
	StaticLoad.change_scene("res://Assets/Scenes/Language.tscn")

func _on_menu_button_5_pressed() -> void:
	StaticLoad.click_audio_player.play()
	StaticLoad.change_scene("res://Assets/Scenes/ResourcePack.tscn")

func _on_menu_button_6_pressed() -> void:
	var audio_stream_player = StaticLoad.click_audio_player
	audio_stream_player.play()
	await audio_stream_player.finished
	get_tree().quit()

func _on_menu_change_skin_button_pressed() -> void:
	StaticLoad.click_audio_player.play()
	if OS.has_feature("android"):
		OS.request_permissions()
	change_skin_file_dialog.visible = true

func _on_menu_clear_skin_button_pressed() -> void:
	StaticLoad.click_audio_player.play()
	var change_value = {
		"skin_path": "null"
	}
	StaticLoad.save_options(change_value)
	await get_tree().create_timer(0.01).timeout
	StaticLoad.update_default_skin_path()
	await get_tree().create_timer(0.01).timeout
	update_player_model_skin()

func _on_menu_help_button_pressed() -> void:
	StaticLoad.click_audio_player.play()
	StaticLoad.pop_big_notification(self, tr("HELP"), tr("HELP_TEXT"), tr("CLOSE"))
	
func _on_menu_info_button_pressed() -> void:
	StaticLoad.click_audio_player.play()
	StaticLoad.pop_big_notification(self, tr("RELEASE_NOTE"), tr("RELEASE_NOTE_TEXT"), tr("CLOSE"))

func _on_change_skin_file_dialog_file_selected(path: String) -> void:
	var change_value = {
		"skin_path": path
	}
	StaticLoad.save_options(change_value)
	await get_tree().create_timer(0.01).timeout
	update_player_model_skin()
