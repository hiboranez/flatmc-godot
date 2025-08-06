extends Node

@onready var language_list_vboxcontainer = $ColorRect/ScrollContainer/VBoxContainer

var select_language: String = SettingsManager.get_current_setting("language")

func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		AudioManager.play_static_audio("sound/ui/click")
		select_language = SettingsManager.get_current_setting("language")
		if StaticLoad.is_in_game:
			self.visible = false
		else:
			SceneManager.change_scene("menu")

func clear_selected_background():
	var current_languages = language_list_vboxcontainer.get_children()
	for language in current_languages:
		language.selected_background.visible = false

func _on_languages_menu_confirm_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	TranslationServer.set_locale(select_language)
	var change_value = {
		"language": str(select_language)
	}
	SettingsManager.save_settings(change_value)
	SettingsManager.set_current_setting("language", select_language)
	if StaticLoad.is_in_game:
		self.visible = false
		$"..".update_game_details(true)
		$"..".refresh_achievement_info()
	else:
		SceneManager.change_scene("menu")

func _on_languages_menu_cancel_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	select_language = SettingsManager.get_current_setting("language")
	if StaticLoad.is_in_game:
		self.visible = false
	else:
		SceneManager.change_scene("menu")
