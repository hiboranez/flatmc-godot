extends Node

@onready var resource_pack_option_bar = $ColorRect/ScrollContainer/VBoxContainer/ResourcePack/OptionButton

func _ready() -> void:
	load_options()

func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		StaticLoad.click_audio_player.play()
		if StaticLoad.is_in_game:
			self.visible = false
		else:
			StaticLoad.change_scene("res://Assets/Scenes/Menu.tscn")

func _on_options_button_1_pressed() -> void:
	StaticLoad.click_audio_player.play()
	var change_value = {
		"resource_pack": StaticLoad.resource_pack_dictionary[resource_pack_option_bar.selected]
	}
	StaticLoad.save_options(change_value)
	await get_tree().create_timer(0.01).timeout
	StaticLoad.refresh_default_skin_path()
	await get_tree().create_timer(0.01).timeout
	if StaticLoad.is_in_game:
		StaticLoad.game.refresh_resource_pack()
	else:
		StaticLoad.change_scene("res://Assets/Scenes/Menu.tscn")

func _on_options_button_2_pressed() -> void:
	StaticLoad.click_audio_player.play()
	if StaticLoad.is_in_game:
		self.visible = false
	else:
		StaticLoad.change_scene("res://Assets/Scenes/Menu.tscn")

func load_options():
	var config = ConfigFile.new()
	var result = config.load("user://configs.cfg")
	if result == OK:
		resource_pack_option_bar.selected = StaticLoad.resource_pack_dictionary.find_key(config.get_value("options", "resource_pack"))
