extends Node

@onready var resource_pack_setting_bar = $Content/ScrollContainer/VBoxContainer/ResourcePack

func _ready() -> void:
	update_resource_pack_list()

func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		AudioManager.play_static_audio("sound/ui/click")
		if StaticLoad.is_in_game:
			self.visible = false
		else:
			SceneManager.change_scene("menu")

func update_resource_pack_list():
	var config = ConfigFile.new()
	var result = config.load("user://configs.cfg")
	if result == OK:
		resource_pack_setting_bar.set_option_button_text(config.get_value("settings", "resource_pack", SettingsManager.get_default_setting("resource_pack")))

func _on_settings_save_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	var change_value = {
		"resource_pack": resource_pack_setting_bar.get_option_button_text()
	}
	SettingsManager.save_settings(change_value)
	if StaticLoad.is_in_game:
		StaticLoad.game.update_resource_pack()
	else:
		SceneManager.change_scene("menu")

func _on_settings_cancel_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	if StaticLoad.is_in_game:
		self.visible = false
	else:
		SceneManager.change_scene("menu")
