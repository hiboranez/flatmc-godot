extends Menu

@onready var menu_control = $MenuControl
@onready var base_content_panel = $MenuControl/BaseContentPanel

func _ready() -> void:
	menu_controller = $MenuController
	menu_controller.menu = self
	scale_factor = SettingsManager.get_menu_scale_factor(SettingsManager.get_current_setting("gui_scale"))
	
	base_content_panel.menu = self
	var loading_world_panel = SceneManager.get_scene("panels/loading_world_panel").instantiate()
	panel_control_dict = {
		"menu": menu_control,
		"loading_world_panel": loading_world_panel
	}
	base_content_panel.set_content(loading_world_panel)
	loading_world_panel.menu = self
	base_content_panel.title = loading_world_panel.title
	base_content_panel.content_top_margin = loading_world_panel.content_top_margin
	base_content_panel.content_bottom_margin = loading_world_panel.content_bottom_margin
	size_control_list = [
		base_content_panel,
		loading_world_panel
	]
	refresh_size()
	loading_world_panel.load_game()
