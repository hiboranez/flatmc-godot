extends Node

@onready var player_name_line_edit = $Content/ScrollContainer/VBoxContainer/PlayerName/LineEdit
@onready var render_chunk_label = $Content/ScrollContainer/VBoxContainer/RenderChunk/HScrollBar/Label
@onready var render_chunk_scroll_bar = $Content/ScrollContainer/VBoxContainer/RenderChunk/HScrollBar
@onready var notice_scene = load("res://Assets/Scenes/Notice.tscn") as PackedScene
@onready var fov_zoom_label = $Content/ScrollContainer/VBoxContainer/FovZoom/HScrollBar/Label
@onready var fov_zoom_scroll_bar = $Content/ScrollContainer/VBoxContainer/FovZoom/HScrollBar
@onready var bgm_volume_label = $Content/ScrollContainer/VBoxContainer/BgmVolume/HScrollBar/Label
@onready var bgm_volume_scroll_bar = $Content/ScrollContainer/VBoxContainer/BgmVolume/HScrollBar
@onready var sound_volume_label = $Content/ScrollContainer/VBoxContainer/SoundVolume/HScrollBar/Label
@onready var sound_volume_scroll_bar = $Content/ScrollContainer/VBoxContainer/SoundVolume/HScrollBar
@onready var block_selection_box_setting_bar = $Content/ScrollContainer/VBoxContainer/BlockSelectionBox/OptionButton
@onready var mini_map_setting_bar = $Content/ScrollContainer/VBoxContainer/MiniMap/OptionButton
@onready var mini_map_zoom_label = $Content/ScrollContainer/VBoxContainer/MiniMapZoom/HScrollBar/Label
@onready var mini_map_zoom_scroll_bar = $Content/ScrollContainer/VBoxContainer/MiniMapZoom/HScrollBar
@onready var auto_jump_setting_bar = $Content/ScrollContainer/VBoxContainer/AutoJump/OptionButton
@onready var new_music_setting_bar = $Content/ScrollContainer/VBoxContainer/NewMusic/OptionButton
@onready var smooth_lighting_setting_bar = $Content/ScrollContainer/VBoxContainer/SmoothLighting/OptionButton
@onready var particle_effect_setting_bar = $Content/ScrollContainer/VBoxContainer/ParticleEffect/OptionButton
@onready var v_sync_setting_bar = $Content/ScrollContainer/VBoxContainer/VSync/OptionButton
@onready var full_screen_setting_bar = $Content/ScrollContainer/VBoxContainer/FullScreen/OptionButton

func _ready() -> void:
	load_settings()

func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		AudioManager.play_static_audio("sound/ui/click")
		if StaticLoad.is_in_game:
			self.visible = false
		else:
			SceneManager.change_scene("menu")

func load_settings():
	var config = ConfigFile.new()
	var result = config.load("user://configs.cfg")
	if result == OK:
		player_name_line_edit.text = config.get_value("settings", "player_name")	
		render_chunk_label.text = config.get_value("settings", "render_chunk")
		render_chunk_scroll_bar.value = int(config.get_value("settings", "render_chunk"))
		fov_zoom_label.text = config.get_value("settings", "fov_zoom")+"%"
		fov_zoom_scroll_bar.value = int(config.get_value("settings", "fov_zoom"))
		bgm_volume_label.text = config.get_value("settings", "bgm_volume")+"%"
		bgm_volume_scroll_bar.value = int(config.get_value("settings", "bgm_volume"))
		sound_volume_label.text = config.get_value("settings", "sound_volume")+"%"
		sound_volume_scroll_bar.value = int(config.get_value("settings", "sound_volume"))
		block_selection_box_setting_bar.selected = StaticLoad.block_selection_box_dictionary.find_key(config.get_value("settings", "block_selection_box"))
		mini_map_setting_bar.selected = SettingsManager.get_selection_by_on_or_off(config.get_value("settings", "mini_map"), SettingsManager.get_default_setting("mini_map"))
		auto_jump_setting_bar.selected = SettingsManager.get_selection_by_on_or_off(config.get_value("settings", "auto_jump"), SettingsManager.get_default_setting("auto_jump"))
		new_music_setting_bar.selected = SettingsManager.get_selection_by_on_or_off(config.get_value("settings", "new_music"), SettingsManager.get_default_setting("new_music"))
		smooth_lighting_setting_bar.selected = SettingsManager.get_selection_by_on_or_off(config.get_value("settings", "smooth_lighting"), SettingsManager.get_default_setting("smooth_lighting"))
		particle_effect_setting_bar.selected = SettingsManager.get_selection_by_on_or_off(config.get_value("settings", "particle_effect"), SettingsManager.get_default_setting("particle_effect"))
		v_sync_setting_bar.selected = SettingsManager.get_selection_by_on_or_off(config.get_value("settings", "v_sync"), SettingsManager.get_default_setting("v_sync"))
		full_screen_setting_bar.selected = SettingsManager.get_selection_by_on_or_off(config.get_value("settings", "full_screen"), SettingsManager.get_default_setting("full_screen"))
		mini_map_zoom_label.text = config.get_value("settings", "mini_map_zoom")+"%"
		mini_map_zoom_scroll_bar.value = int(config.get_value("settings", "mini_map_zoom"))

func load_in_game_settings():
	if not StaticLoad.is_in_game:
		return
	var game = $".."
	var mini_map_zoom_tmp = int(game.mini_map_camera.zoom[0]*100)
	mini_map_zoom_label.text = str(mini_map_zoom_tmp)+"%"
	mini_map_zoom_scroll_bar.value = mini_map_zoom_tmp

func _on_settings_menu_save_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	if player_name_line_edit.text == "":
		SceneManager.pop_notification(self, "WARNING", "WARNING_2")
		return
	if player_name_line_edit.text.length() > StaticLoad.MAX_NAME_LENGTH:
		SceneManager.pop_notification(self, "WARNING", "WARNING_9")
		return
	if player_name_line_edit.text.contains(" "):
		SceneManager.pop_notification(self, "WARNING", "WARNING_10")
		return
	var stored_full_screen = SettingsManager.get_default_setting("full_screen")
	var stored_v_sync = SettingsManager.get_default_setting("v_sync")
	var config = ConfigFile.new()
	var result = config.load("user://configs.cfg")
	if result == OK:
		stored_full_screen = config.get_value("settings", "full_screen", SettingsManager.get_default_setting("full_screen"))
		stored_v_sync = config.get_value("settings", "v_sync", SettingsManager.get_default_setting("v_sync"))
	var change_value = {
		"player_name": str(player_name_line_edit.text),
		"render_chunk": str(render_chunk_scroll_bar.value),
		"fov_zoom": str(fov_zoom_scroll_bar.value),
		"bgm_volume": str(bgm_volume_scroll_bar.value),
		"sound_volume": str(sound_volume_scroll_bar.value),
		"block_selection_box": StaticLoad.block_selection_box_dictionary[block_selection_box_setting_bar.selected],
		"mini_map": StaticLoad.get_on_or_off_by_selection(mini_map_setting_bar.selected, SettingsManager.get_default_setting("mini_map")),
		"auto_jump": StaticLoad.get_on_or_off_by_selection(auto_jump_setting_bar.selected, SettingsManager.get_default_setting("auto_jump")),
		"new_music": StaticLoad.get_on_or_off_by_selection(new_music_setting_bar.selected, SettingsManager.get_default_setting("new_music")),
		"smooth_lighting": StaticLoad.get_on_or_off_by_selection(smooth_lighting_setting_bar.selected, SettingsManager.get_default_setting("smooth_lighting")),
		"particle_effect": StaticLoad.get_on_or_off_by_selection(particle_effect_setting_bar.selected, SettingsManager.get_default_setting("particle_effect")),
		"v_sync": StaticLoad.get_on_or_off_by_selection(v_sync_setting_bar.selected, SettingsManager.get_default_setting("v_sync")),
		"full_screen": StaticLoad.get_on_or_off_by_selection(full_screen_setting_bar.selected, SettingsManager.get_default_setting("full_screen")),
		"mini_map_zoom": str(mini_map_zoom_scroll_bar.value)
	}
	if db_to_linear(AudioManager.bgm_audio_player.volume_db) > 0 and int(change_value["bgm_volume"]) <= 0:
		AudioManager.stop()
	elif db_to_linear(AudioManager.bgm_audio_player.volume_db) <= 0 and int(change_value["bgm_volume"]) > 0:
		AudioManager.refresh_bgm()
	SettingsManager.save_settings(change_value)
	StaticLoad.click_audio_player.volume_db = linear_to_db(int(change_value["sound_volume"])/50.0)
	if stored_full_screen != change_value["full_screen"]:
		if change_value["full_screen"] == "on":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	if stored_v_sync != change_value["v_sync"]:
		if change_value["v_sync"] == "on":
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		else:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	if change_value["new_music"] == "off" and StaticLoad.is_new_music_on:
		StaticLoad.is_new_music_on = false
		AudioManager.refresh_bgm()
	elif change_value["new_music"] == "on" and not StaticLoad.is_new_music_on:
		StaticLoad.is_new_music_on = true
		AudioManager.refresh_bgm()
	AudioManager.bgm_audio_player.volume_db = linear_to_db(int(change_value["bgm_volume"])/50.0)
	if StaticLoad.is_in_game:
		var game = $".."
		game.player.render_chunk = int(change_value["render_chunk"])
		var fov_zoom = 1+1.6*(int(change_value["fov_zoom"])/100.0)
		game.player.camera.zoom = Vector2(fov_zoom, fov_zoom)
		game.sound_audio_manager.volume_db = linear_to_db(int(change_value["sound_volume"])/50.0)
		game.block_selection_box = StaticLoad.block_selection_box_dictionary[block_selection_box_setting_bar.selected]
		game.mini_map_on = StaticLoad.get_on_or_off_by_selection(mini_map_setting_bar.selected, SettingsManager.get_default_setting("mini_map"))
		var auto_jump_on = StaticLoad.get_on_or_off_by_selection(auto_jump_setting_bar.selected, SettingsManager.get_default_setting("auto_jump"))
		if auto_jump_on == "on":
			game.player.is_auto_jump = true
		elif auto_jump_on == "off":
			game.player.is_auto_jump = false
		var smooth_lighting_on = StaticLoad.get_on_or_off_by_selection(smooth_lighting_setting_bar.selected, SettingsManager.get_default_setting("smooth_lighting"))
		if smooth_lighting_on == "on" and not game.is_smooth_light:
			game.is_smooth_light = true
			game.refresh_all_light()
		elif smooth_lighting_on == "off" and game.is_smooth_light:
			game.is_smooth_light = false
			game.refresh_all_light()
		var particle_effect_on = StaticLoad.get_on_or_off_by_selection(particle_effect_setting_bar.selected, SettingsManager.get_default_setting("particle_effect"))
		if particle_effect_on == "on":
			game.is_particle_effect_on = true
		elif particle_effect_on == "off":
			game.is_particle_effect_on = false
			game.clear_particles()
		game.mini_map_zoom = str(mini_map_zoom_scroll_bar.value)
		var mini_map_zoom_tmp = game.mini_map_zoom/100
		game.mini_map_camera.zoom = Vector2(mini_map_zoom_tmp, mini_map_zoom_tmp)
		var icon_scale = StaticLoad.MINI_MAP_SCALE_FACTOR/game.mini_map_camera.zoom[0]
		for player_icon in game.mini_map_players.get_children():
			player_icon.scale = Vector2(icon_scale, icon_scale)
		if game.mini_map_on == "off":
			game.mini_map.visible = false
		elif game.mini_map_on == "on":
			game.mini_map.visible = true
		self.visible = false
		game.player.update_state_dict()
		game.update_new_chunk(true)
	else:
		SceneManager.change_scene("menu")

func _on_settings_menu_cancel_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	if StaticLoad.is_in_game:
		self.visible = false
	else:
		SceneManager.change_scene("menu")

func _on_settings_menu_render_chunk_scroll_bar_scrolling() -> void:
	render_chunk_label.text = str(render_chunk_scroll_bar.value)

func _on_settings_menu_fov_zoom_scroll_bar_scrolling() -> void:
	fov_zoom_label.text = str(fov_zoom_scroll_bar.value)+"%"

func _on_settings_menu_bgm_volume_scroll_bar_scrolling() -> void:
	if bgm_volume_scroll_bar.value > 0:
		bgm_volume_label.text = str(bgm_volume_scroll_bar.value)+"%"
	else:
		bgm_volume_label.text = tr("OFF")

func _on_settings_menu_sound_volume_scroll_bar_scrolling() -> void:
	if sound_volume_scroll_bar.value > 0:
		sound_volume_label.text = str(sound_volume_scroll_bar.value)+"%"
	else:
		sound_volume_label.text = tr("OFF")

func _on_settings_menu_mini_map_zoom_scroll_bar_scrolling() -> void:
	mini_map_zoom_label.text = str(mini_map_zoom_scroll_bar.value)+"%"
