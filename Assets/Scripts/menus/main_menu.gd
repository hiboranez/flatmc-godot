extends Menu

@onready var menu_control = $MenuControl
@onready var base_panel = $MenuControl/BasePanel
@onready var background_camera = $MenuControl/Background/SubViewportContainer/SubViewport/Camera3D
@onready var change_skin_file_dialog = $MenuControl/BasePanel/ChangeSkinFileDialog
@onready var title_video_rect = $MenuControl/BasePanel/TitleVideo
@onready var title_picture_rect = $MenuControl/BasePanel/TitlePicture
@onready var title_video_player = $MenuControl/BasePanel/TitleVideo/VideoStreamPlayer
@onready var copyright_label = $MenuControl/BasePanel/Copyright
@onready var main_buttons = $MenuControl/BasePanel/MainButtons
@onready var corner_buttons = $MenuControl/BasePanel/CornerButtons
@onready var right_panel = $MenuControl/BasePanel/RightPanel
@onready var oriented_player = $MenuControl/BasePanel/RightPanel/OrientedPlayer

var curr_mouse_pos: Vector2
var prev_mouse_pos: Vector2

var menu_scroll_speed: float = 0.5

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
	size_control_list = [
		title_picture_rect,
		copyright_label,
		main_buttons,
		corner_buttons,
		right_panel,
	]
	menu_controller = $MenuController
	menu_controller.menu = self
	StaticLoad.select_server = null
	StaticLoad.select_world = null
	panel_control_dict = {
		"menu": base_panel
	}
	menu_scroll_speed = float(SettingsManager.get_current_setting("menu_scroll"))/100.0
	refresh_size()
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

func refresh_size():
	var scale_factor = SettingsManager.get_menu_scale_factor(SettingsManager.get_current_setting("gui_scale"))
	for control in size_control_list:
		control.scale = Vector2(scale_factor, scale_factor)

func update_mouse_position():
	curr_mouse_pos = get_viewport().get_mouse_position()
	if prev_mouse_pos != curr_mouse_pos:
		prev_mouse_pos = curr_mouse_pos
		oriented_player.update_rotation(curr_mouse_pos)

func update_background_camera_rotation():
	background_camera.rotate(Vector3.UP, -0.0833*get_process_delta_time()*menu_scroll_speed)

func update_player_model_skin():
	var config = ConfigFile.new()
	var result = config.load("user://configs.cfg")
	if result == OK:
		var skin_path = config.get_value("settings", "skin_path", "")
		if skin_path != "":	
			oriented_player.update_skin(skin_path)
			
func _on_single_mode_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	await menu_controller.vanish("menu")
	var single_game_menu = SceneManager.get_scene("menus/single_game_menu").instantiate()
	add_child(single_game_menu)
	
func _on_multi_mode_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	await menu_controller.vanish("menu")
	var multi_game_menu = SceneManager.get_scene("menus/multi_game_menu").instantiate()
	add_child(multi_game_menu)

func _on_settings_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	await menu_controller.vanish("menu")
	var settings_menu = SceneManager.get_scene("menus/settings_menu").instantiate()
	add_child(settings_menu)
	
func _on_language_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	await menu_controller.vanish("menu")
	var languages_menu = SceneManager.get_scene("menus/languages_menu").instantiate()
	add_child(languages_menu)

func _on_resource_pack_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	await menu_controller.vanish("menu")
	var resource_pack_menu = SceneManager.get_scene("menus/resource_pack_menu").instantiate()
	add_child(resource_pack_menu)

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
	await SettingsManager.save_settings({
		"skin_path": "null",
	})
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

func _on_menu_control_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		oriented_player.update_rotation(event.position)

func _on_video_stream_player_finished() -> void:
	title_picture_rect.self_modulate = Color(1,1,1,1)
	title_video_rect.visible = false
