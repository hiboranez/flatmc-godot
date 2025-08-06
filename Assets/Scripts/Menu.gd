extends CanvasLayer

@onready var player_model = $Player/SubViewportContainer/SubViewport/PlayerModel
@onready var player_model_mesh = $Player/SubViewportContainer/SubViewport/PlayerModel/Root/Skeleton3D/Mesh
@onready var change_skin_file_dialog = $ChangeSkinFileDialog
@onready var background_camera = $Background/SubViewportContainer/SubViewport/Camera3D

func _process(delta: float) -> void:
	update_player_model()
	update_background_camera()

enum Test{
		SURVIVAL = 0,
		CREATIVE = 1
	}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if OS.has_feature("dedicated_server"):
		return
	if OS.has_feature("android"):
		change_skin_file_dialog.current_dir = "/storage/emulated/0/"
	StaticLoad.select_server = null
	StaticLoad.select_world = null
	update_player_model_skin()

func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		var audio_player = AudioStreamPlayer.new()
		audio_player.stream = AudioManager.sound_dict["sound"]["click"]
		audio_player.play()
		await audio_player.finished
		get_tree().quit()

func update_player_model():
	var mouse_pos = get_viewport().get_mouse_position()
	var viewport_size = $Background.get_viewport_rect().size
	var viewport_half_size = viewport_size/2.0
	var target_pos = mouse_pos-viewport_half_size-Vector2(viewport_size[0]*0.375, 0)
	player_model.look_at(Vector3(target_pos[0], -target_pos[1], 3250), Vector3.UP, true)

func update_background_camera():
	background_camera.rotate(Vector3.UP, -0.0001)

func update_player_model_skin():
	var player_texture = TextureManager.get_texture("skins/steve_"+SettingsManager.get_current_setting("resource_pack").replace("official_", ""))
	var player_material = load("res://assets/materials/player_skin.tres").duplicate(true)
	var config = ConfigFile.new()
	var result = config.load("user://configs.cfg")
	if result == OK:
		var skin_path = config.get_value("settings", "skin_path", "null")
		if skin_path != "null":	
			var player_texture_tmp = ImageTexture.create_from_image(Image.load_from_file(skin_path))
			if player_texture_tmp != null:
				player_texture = player_texture_tmp
	player_material.albedo_texture = player_texture
	player_model_mesh.mesh.surface_set_material(0, player_material)

func _on_menu_single_mode_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	SceneManager.change_scene("single_menu")
	
func _on_menu_multi_mode_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	SceneManager.change_scene("multi_menu")

func _on_menu_settings_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	SceneManager.change_scene("settings_menu")
	
func _on_menu_language_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	SceneManager.change_scene("languages_menu")

func _on_menu_resource_pack_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	SceneManager.change_scene("resource_pack_menu")

func _on_menu_quit_game_button_pressed() -> void:
	var audio_stream_player = StaticLoad.click_audio_player
	audio_stream_player.play()
	await audio_stream_player.finished
	get_tree().quit()

func _on_menu_change_skin_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	if OS.has_feature("android"):
		OS.request_permissions()
	change_skin_file_dialog.visible = true

func _on_menu_clear_skin_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	var change_value = {
		"skin_path": "null"
	}
	SettingsManager.save_settings(change_value)
	await get_tree().create_timer(0.01).timeout
	update_player_model_skin()

func _on_menu_help_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	SceneManager.pop_big_notification(self, tr("HELP"), tr("HELP_TEXT"), tr("CLOSE"))
	
func _on_menu_info_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	SceneManager.pop_big_notification(self, tr("RELEASE_NOTE"), tr("RELEASE_NOTE_TEXT"), tr("CLOSE"))

func _on_change_skin_file_dialog_file_selected(path: String) -> void:
	var change_value = {
		"skin_path": path
	}
	SettingsManager.save_settings(change_value)
	update_player_model_skin()
