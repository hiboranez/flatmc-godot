extends CanvasLayer

@onready var background_camera = $Background/SubViewportContainer/SubViewport/Camera3D
@onready var player_model = $MenuControl/Player/SubViewportContainer/SubViewport/PlayerModel
@onready var player_model_mesh = $MenuControl/Player/SubViewportContainer/SubViewport/PlayerModel/Root/Skeleton3D/Mesh
@onready var change_skin_file_dialog = $MenuControl/ChangeSkinFileDialog
@onready var title_video_rect = $MenuControl/TitleVideo
@onready var title_picture_rect = $MenuControl/TitlePicture
@onready var title_video_player = $MenuControl/TitleVideo/VideoStreamPlayer
@onready var menu_control = $MenuControl

var curr_mouse_pos: Vector2
var prev_mouse_pos: Vector2
var is_changing_menu: bool = false

func _ready() -> void:
	if OS.has_feature("dedicated_server"):
		return
	if OS.has_feature("android"):
		change_skin_file_dialog.current_dir = "/storage/emulated/0/"
	#if OS.has_feature("windows") or OS.has_feature("linxu"):
		#title_picture_rect.self_modulate = Color(1,1,1,0)
		#title_video_player.play()
		#if get_tree() != null:
			#await get_tree().create_timer(0.2).timeout
		#title_video_player.visible = true
	StaticLoad.select_server = null
	StaticLoad.select_world = null
	update_player_model_skin()

func _process(delta: float) -> void:
	update_background_camera_rotation()
	update_mouse_position()

func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		var audio_player = AudioStreamPlayer.new()
		audio_player.stream = AudioManager.sound_dict["sound"]["click"]
		audio_player.play()
		await audio_player.finished
		get_tree().quit()

func change_menu(path: String) -> void:
	if path != "menus/main_menu":
		is_changing_menu = true
		create_tween().tween_property(menu_control, "modulate", Color(1,1,1,0), 0.15)
		if get_tree() != null:
			await get_tree().create_timer(0.15).timeout
		menu_control.visible = false
		is_changing_menu = false
		var new_menu = SceneManager.get_scene(path).instantiate()
		add_child(new_menu)
		new_menu.menu_control.modulate = Color(1,1,1,0)
		new_menu.is_changing_menu = true
		create_tween().tween_property(new_menu.menu_control, "modulate", Color(1,1,1,1), 0.15)
		if get_tree() != null:
			await get_tree().create_timer(0.15).timeout
		new_menu.is_changing_menu = false

func update_mouse_position():
	curr_mouse_pos = get_viewport().get_mouse_position()
	if prev_mouse_pos != curr_mouse_pos:
		prev_mouse_pos = curr_mouse_pos
		update_player_model_rotation(curr_mouse_pos)

func update_background_camera_rotation():
	background_camera.rotate(Vector3.UP, -0.0001)

func update_player_model_rotation(viewport_pos):
	var viewport_size = $Background.get_viewport_rect().size
	var viewport_half_size = viewport_size/2.0
	var target_pos = viewport_pos-viewport_half_size-Vector2(viewport_size[0]*0.375, 0)
	player_model.look_at(Vector3(target_pos[0], -target_pos[1], 3250), Vector3.UP, true)

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
			
func _on_single_mode_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	SceneManager.change_scene("menus/single_menu")
	
func _on_multi_mode_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	SceneManager.change_scene("menus/multi_menu")

func _on_settings_button_pressed() -> void:
	if is_changing_menu:
		return
	AudioManager.play_static_audio("sound/ui/click")
	change_menu("menus/settings_menu")
	
func _on_language_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	SceneManager.change_scene("menus/languages_menu")

func _on_resource_pack_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	SceneManager.change_scene("menus/resource_pack_menu")

func _on_quit_game_button_pressed() -> void:
	var audio_stream_player = StaticLoad.click_audio_player
	audio_stream_player.play()
	await audio_stream_player.finished
	get_tree().quit()

func _on_change_skin_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	if OS.has_feature("android"):
		OS.request_permissions()
	change_skin_file_dialog.visible = true

func _on_clear_skin_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	var change_value = {
		"skin_path": "null"
	}
	SettingsManager.save_settings(change_value)
	await SettingsManager.settings_saved
	update_player_model_skin()

func _on_help_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	SceneManager.pop_big_notification(self, tr("HELP"), tr("HELP_TEXT"), tr("CLOSE"))
	
func _on_info_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	SceneManager.pop_big_notification(self, tr("RELEASE_NOTE"), tr("RELEASE_NOTE_TEXT"), tr("CLOSE"))

func _on_change_skin_file_dialog_file_selected(path: String) -> void:
	var change_value = {
		"skin_path": path
	}
	SettingsManager.save_settings(change_value)
	update_player_model_skin()

func _on_background_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		update_player_model_rotation(event.position)

func _on_video_stream_player_finished() -> void:
	title_picture_rect.self_modulate = Color(1,1,1,1)
	title_video_rect.visible = false
