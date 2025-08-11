extends Menu

@onready var menu_control = $MenuControl
@onready var base_content_panel = $MenuControl/BaseContentPanel

var single_game_panel: Node = null

func _ready() -> void:
	menu_controller = $MenuController
	menu_control.visible = false
	menu_controller.set_menu_control(menu_control)
	single_game_panel = SceneManager.get_scene("panels/single_game_panel").instantiate()
	base_content_panel.set_content(single_game_panel)
	single_game_panel.menu = self
	await single_game_panel.update_world_list()
	menu_controller.appear()

func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		AudioManager.play_static_audio("sound/ui/click")
		await menu_controller.vanish()
		if has_node("/root/MainMenu"):
			get_node("/root/MainMenu").menu_controller.appear()
		queue_free()

func init():
	single_game_panel.update_world_list()
