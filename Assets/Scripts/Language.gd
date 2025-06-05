extends Node

var select_language: String = StaticLoad.language

func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		StaticLoad.click_audio_player.play()
		select_language = StaticLoad.language
		if StaticLoad.is_in_game:
			self.visible = false
		else:
			StaticLoad.change_scene("res://Assets/Scenes/Menu.tscn")

func _on_language_button_1_pressed() -> void:
	StaticLoad.click_audio_player.play()
	TranslationServer.set_locale(select_language)
	var change_value = {
		"language": str(select_language)
	}
	StaticLoad.save_options(change_value)
	StaticLoad.language = select_language
	if StaticLoad.is_in_game:
		self.visible = false
		$"..".update_game_details(true)
		$"..".refresh_achievement_info()
	else:
		StaticLoad.change_scene("res://Assets/Scenes/Menu.tscn")

func _on_language_button_2_pressed() -> void:
	StaticLoad.click_audio_player.play()
	select_language = StaticLoad.language
	if StaticLoad.is_in_game:
		self.visible = false
	else:
		StaticLoad.change_scene("res://Assets/Scenes/Menu.tscn")
