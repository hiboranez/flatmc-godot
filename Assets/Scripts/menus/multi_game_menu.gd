extends Menu

@onready var menu_control = $MenuControl
@onready var base_content_panel = $MenuControl/BaseContentPanel

func _ready() -> void:
	menu_controller = $MenuController
	menu_control.visible = false
	menu_controller.menu = self
	scale_factor = SettingsManager.get_menu_scale_factor(SettingsManager.get_current_setting("gui_scale"))
	
	base_content_panel.menu = self
	var multi_game_panel = SceneManager.get_scene("panels/multi_game_panel").instantiate()
	panel_control_dict = {
		"menu": menu_control,
		"multi_game_panel": multi_game_panel
	}
	base_content_panel.set_content(multi_game_panel)
	multi_game_panel.menu = self
	base_content_panel.title = multi_game_panel.title
	base_content_panel.content_top_margin = multi_game_panel.content_top_margin
	base_content_panel.content_bottom_margin = multi_game_panel.content_bottom_margin
	size_control_list = [
		base_content_panel,
		multi_game_panel
	]
	refresh_size()
	
	await multi_game_panel.update_server_list()
	if get_tree() != null:
		await get_tree().process_frame
	await multi_game_panel.rectify_official_server()
	if get_tree() != null:
		await get_tree().process_frame
	await multi_game_panel.detect_all_server()
	if get_tree() != null:
		await get_tree().process_frame
	menu_controller.appear("menu")

func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		AudioManager.play_static_audio("sound/ui/click")
		await menu_controller.vanish("menu")
		if has_node("/root/MainMenu"):
			get_node("/root/MainMenu").menu_controller.appear("menu")
		queue_free()
