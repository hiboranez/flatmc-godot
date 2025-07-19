extends Node

@onready var resource_pack_setting_bar = $Content/ScrollContainer/VBoxContainer/ResourcePack/OptionButton

func _ready() -> void:
	load_resource_packs()

func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		AudioManager.play_static_audio("sound/ui/click")
		if StaticLoad.is_in_game:
			self.visible = false
		else:
			SceneManager.change_scene("menu")

func load_resource_packs():
	var config = ConfigFile.new()
	var result = config.load("user://configs.cfg")
	if result == OK:
		resource_pack_setting_bar.selected = StaticLoad.resource_pack_dictionary.find_key(config.get_value("settings", "resource_pack"))

func _on_settings_save_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	var change_value = {
		"resource_pack": StaticLoad.resource_pack_dictionary[resource_pack_setting_bar.selected]
	}
	SettingsManager.save_settings(change_value)
	await get_tree().create_timer(0.01).timeout
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
