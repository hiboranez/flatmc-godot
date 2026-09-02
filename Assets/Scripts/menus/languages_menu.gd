extends Menu


@onready var menu_control = $MenuControl
@onready var base_content_panel = $MenuControl/BaseContentPanel

func _ready() -> void:
	menu_controller = $MenuController
	menu_control.visible = false
	menu_controller.menu = self
	scale_factor = SettingsManager.get_menu_scale_factor(SettingsManager.get_current_setting("gui_scale"))
	
	base_content_panel.menu = self
	var languages_panel = SceneManager.get_scene("panels/languages_panel").instantiate()
	panel_control_dict = {
		"menu": menu_control,
		"languages_panel": languages_panel
	}
	base_content_panel.set_content(languages_panel)
	languages_panel.menu = self
	base_content_panel.title = languages_panel.title
	base_content_panel.content_top_margin = languages_panel.content_top_margin
	base_content_panel.content_bottom_margin = languages_panel.content_bottom_margin
	size_control_list = [
		base_content_panel,
		languages_panel
	]
	refresh_size()
	
	await languages_panel.update_language_list()
	menu_controller.appear("menu")

func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		AudioManager.play_static_audio("sound/ui/click")
		if StaticLoad.is_in_game:
			self.visible = false
		else:
			await menu_controller.vanish("menu")
			if has_node("/root/MainMenu"):
				get_node("/root/MainMenu").menu_controller.appear("menu")
			queue_free()
