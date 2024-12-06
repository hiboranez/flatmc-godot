extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if OS.has_feature("dedicated_server"):
		return
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
		var updated = config.get_value("options", "updated", "false")
		var version = config.get_value("options", "version", "null")
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
	var audio_stream_player = StaticLoad.click_audio_player
	audio_stream_player.play()
	await audio_stream_player.finished
	get_tree().quit()

func _on_menu_help_button_pressed() -> void:
	StaticLoad.click_audio_player.play()
	StaticLoad.pop_big_notification(self, tr("HELP"), tr("HELP_TEXT"), tr("CLOSE"))
	
func _on_menu_info_button_pressed() -> void:
	StaticLoad.click_audio_player.play()
	StaticLoad.pop_big_notification(self, tr("RELEASE_NOTE"), tr("RELEASE_NOTE_TEXT"), tr("CLOSE"))
