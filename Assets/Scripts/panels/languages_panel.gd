extends Control

@onready var language_list_gridcontainer = $DragScrollContainer/VBoxContainer/CenterContainer/GridContainer

var menu: Node = null
var title: String = "LANGUAGES"
var content_top_margin: float = 120
var content_bottom_margin: float = 160

var select_language: String = SettingsManager.get_current_setting("language")

func _ready() -> void:
	select_language = SettingsManager.get_current_setting("language")
	get_viewport().size_changed.connect(refresh_size)

func refresh_size() -> void:
	var canvas_size = get_viewport().get_screen_transform().affine_inverse()*Vector2(get_viewport().size)
	scale = Vector2(menu.scale_factor, menu.scale_factor)
	set_deferred("size", Vector2(canvas_size.x/menu.scale_factor, (canvas_size.y-((content_top_margin+content_bottom_margin)*menu.scale_factor))/menu.scale_factor))

func update_language_list():
	for language_abbr in SettingsManager.default_language_dict.keys():
		var ui_language_button = SceneManager.get_scene("ui/ui_language_button").instantiate()
		language_list_gridcontainer.add_child(ui_language_button)
		ui_language_button.update_data({
			"language_abbr": language_abbr,
			"display_language_name": SettingsManager.get_default_language_name(language_abbr),
			"panel": self
		})
		if get_tree() != null:
			await get_tree().process_frame

func clear_selected_background():
	var current_languages = language_list_gridcontainer.get_children()
	for language in current_languages:
		language.selected_background_rect.visible = false

func _on_confirm_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	TranslationServer.set_locale(select_language)
	var change_value = {
		"language": str(select_language)
	}
	SettingsManager.save_settings(change_value)
	SettingsManager.set_current_setting("language", select_language)
	if StaticLoad.is_in_game:
		menu.visible = false
		StaticLoad.game.pause_ui.visible = true
		StaticLoad.game.update_game_details(true)
		StaticLoad.game.refresh_achievement_info()
	else:
		if menu != null:
			await menu.menu_controller.vanish("menu")
		if has_node("/root/MainMenu"):
			get_node("/root/MainMenu").menu_controller.appear("menu")
		if menu != null:
			menu.queue_free()

func _on_cancel_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	if StaticLoad.is_in_game:
		menu.visible = false
		StaticLoad.game.pause_ui.visible = true
	else:
		if menu != null:
			await menu.menu_controller.vanish("menu")
		if has_node("/root/MainMenu"):
			get_node("/root/MainMenu").menu_controller.appear("menu")
		if menu != null:
			menu.queue_free()
