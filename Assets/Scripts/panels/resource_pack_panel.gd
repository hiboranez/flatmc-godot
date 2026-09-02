extends Control

@onready var resource_pack_switch_button = $DragScrollContainer/VBoxContainer/CenterContainer/GridContainer/ResourcePack

var menu: Node = null
var title: String = "RESOURCE_PACK"
var content_top_margin: float = 120
var content_bottom_margin: float = 160

func _ready() -> void:
	get_viewport().size_changed.connect(refresh_size)

func refresh_size() -> void:
	var canvas_size = get_viewport().get_screen_transform().affine_inverse()*Vector2(get_viewport().size)
	scale = Vector2(menu.scale_factor, menu.scale_factor)
	set_deferred("size", Vector2(canvas_size.x/menu.scale_factor, (canvas_size.y-((content_top_margin+content_bottom_margin)*menu.scale_factor))/menu.scale_factor))

func update_resource_pack_list():
	var config = ConfigFile.new()
	var result = config.load("user://configs.cfg")
	if result == OK:
		resource_pack_switch_button.load_setting(config)
		#resource_pack_switch_button.set_option_button_text(config.get_value("settings", "resource_pack", SettingsManager.get_default_setting("resource_pack")))

func _on_save_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	var change_value = {
		"resource_pack": resource_pack_switch_button.get_option_button_text()
	}
	SettingsManager.save_settings(change_value)
	if StaticLoad.is_in_game:
		StaticLoad.game.update_resource_pack()
	else:
		if menu != null:
			await menu.menu_controller.vanish("menu")
		if has_node("/root/MainMenu"):
			var main_menu = get_node("/root/MainMenu")
			main_menu.refresh_size()
			main_menu.update_player_model_skin()
			main_menu.menu_controller.appear("menu")
		if menu != null:
			get_viewport().size_changed.disconnect(refresh_size)
			menu.queue_free()

func _on_cancel_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	if StaticLoad.is_in_game:
		self.visible = false
	else:
		if menu != null:
			await menu.menu_controller.vanish("menu")
		if has_node("/root/MainMenu"):
			var main_menu = get_node("/root/MainMenu")
			main_menu.refresh_size()
			main_menu.menu_controller.appear("menu")
		if menu != null:
			get_viewport().size_changed.disconnect(refresh_size)
			menu.queue_free()
