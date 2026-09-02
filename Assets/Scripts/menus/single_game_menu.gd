extends Menu

@onready var menu_control = $MenuControl
@onready var base_content_panel = $MenuControl/BaseContentPanel

func _ready() -> void:
	menu_controller = $MenuController
	menu_control.visible = false
	menu_controller.menu = self
	scale_factor = SettingsManager.get_menu_scale_factor(SettingsManager.get_current_setting("gui_scale"))
	
	base_content_panel.menu = self
	var single_game_panel = SceneManager.get_scene("panels/single_game_panel").instantiate()
	panel_control_dict = {
		"menu": menu_control,
		"single_game_panel": single_game_panel
	}
	base_content_panel.set_content(single_game_panel)
	single_game_panel.menu = self
	base_content_panel.title = single_game_panel.title
	base_content_panel.content_top_margin = single_game_panel.content_top_margin
	base_content_panel.content_bottom_margin = single_game_panel.content_bottom_margin
	size_control_list = [
		base_content_panel,
		single_game_panel
	]
	refresh_size()
	
	await single_game_panel.update_world_list()
	menu_controller.appear("menu")

func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		AudioManager.play_static_audio("sound/ui/click")
		await menu_controller.vanish("menu")
		if has_node("/root/MainMenu"):
			get_node("/root/MainMenu").menu_controller.appear("menu")
		queue_free()
