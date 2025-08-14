extends Control

@onready var world_list_container = $DragScrollContainer/VBoxContainer/CenterContainer/GridContainer

var menu: Node = null
var title: String = "SINGLE_MODE"
var content_top_margin: float = 120
var content_bottom_margin: float = 250

var selected_world_name: String = ""

func _ready() -> void:
	get_viewport().size_changed.connect(refresh_size)

func refresh_size() -> void:
	var canvas_size = get_viewport().get_screen_transform().affine_inverse()*Vector2(get_viewport().size)
	scale = Vector2(menu.scale_factor, menu.scale_factor)
	set_deferred("size", Vector2(canvas_size.x/menu.scale_factor, (canvas_size.y-((content_top_margin+content_bottom_margin)*menu.scale_factor))/menu.scale_factor))

func update_world_list():
	var current_worlds = world_list_container.get_children()
	for world in current_worlds:
		world.queue_free()
	var world_list_path = SettingsManager.get_default_value("world_list_path")
	if not DirAccess.dir_exists_absolute(world_list_path):
		DirAccess.make_dir_recursive_absolute(world_list_path)
	var world_list = DirAccess.get_directories_at(world_list_path)
	for world in world_list:
		var world_config = ConfigFile.new()
		var world_info = world_config.load_encrypted_pass(world_list_path+world+"/level.dat", SettingsManager.get_default_value("config_password"))
		if world_info != OK:
			continue
		var world_button = SceneManager.get_scene("ui/ui_world_button").instantiate()
		world_list_container.add_child(world_button)
		var icon = ImageTexture.create_from_image(Image.load_from_file(world_list_path+world+"/icon.png"))
		var update_dict = {
			"world_name" : world,
			"last_modified" : tr("LAST_MODIFIED")+" : "+tr(world_config.get_value("world", "last_modified", "UNKNOWN")),
			"version" : tr("VERSION")+" : "+tr(world_config.get_value("world", "version", "UNKNOWN")),
			"panel": self
		}
		if icon is ImageTexture:
			update_dict["icon"] = icon
		world_button.update_info(update_dict)
		if get_tree() != null:
			await get_tree().process_frame

func clear_selected_background():
	var current_worlds = world_list_container.get_children()
	for world in current_worlds:
		if world.has_method("set_selected_background_visible"):
			world.set_selected_background_visible(false)

func enter_world():
	AudioManager.bgm_audio_player.stop()
	SceneManager.change_scene("menus/loading_world_menu")

func delete_world(world_name: String):
	var delete_path = "user://worlds/"+world_name
	if not DirAccess.dir_exists_absolute(delete_path):
		return
	OS.move_to_trash(ProjectSettings.globalize_path(delete_path))
	await update_world_list()
	selected_world_name = ""

func convert_world_version(old_version):
	var final_old_version
	if old_version == "unknown":
		final_old_version = "0.1.0.0"
	else:
		final_old_version = old_version
	WorldManager.convert_world_version(selected_world_name, final_old_version)
	update_world_list()
	selected_world_name = ""

func _on_enter_world_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	if selected_world_name == "":
		return
	var worlds_path = "user://worlds"
	var world_config = ConfigFile.new()
	var world_info = world_config.load_encrypted_pass(worlds_path+"/"+selected_world_name+"/level.dat", SettingsManager.get_default_value("config_password"))
	if world_info != OK:
		return
	var version_tmp = world_config.get_value("world", "version", "unknown")
	var compare = SettingsManager.compare_version(SettingsManager.default_setting_dict["version"], version_tmp)
	if compare == "higher":
		SceneManager.pop_secondary_confirmation(self, tr("SECONDARY_CONFIRMATION_2"), Callable(self, "convert_world_version").bind(version_tmp))
	elif compare == "lower":
		SceneManager.pop_notification(self, tr("WARNING"), tr("WARNING_8"))
	elif compare == "equal":
		enter_world()

func _on_edit_world_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	if selected_world_name == "":
		return
	if menu == null:
		return
	await menu.menu_controller.vanish("single_game_panel")
	var edit_world_panel = SceneManager.get_scene("panels/edit_world_panel").instantiate()
	menu.panel_control_dict["edit_world_panel"] = edit_world_panel
	menu.base_content_panel.set_content(edit_world_panel)
	edit_world_panel.menu = menu
	await edit_world_panel.load_world_info()
	menu.base_content_panel.title = edit_world_panel.title
	menu.base_content_panel.content_top_margin = edit_world_panel.content_top_margin
	menu.base_content_panel.content_bottom_margin = edit_world_panel.content_bottom_margin
	menu.base_content_panel.animated_refresh_size(edit_world_panel)
	menu.menu_controller.appear("edit_world_panel")

func _on_back_to_menu_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	if menu != null:
		await menu.menu_controller.vanish("menu")
	if has_node("/root/MainMenu"):
		get_node("/root/MainMenu").menu_controller.appear("menu")
	if menu != null:
		menu.queue_free()

func _on_create_world_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	if menu == null:
		return
	await menu.menu_controller.vanish("single_game_panel")
	var create_world_panel = SceneManager.get_scene("panels/create_world_panel").instantiate()
	menu.panel_control_dict["create_world_panel"] = create_world_panel
	menu.base_content_panel.set_content(create_world_panel)
	create_world_panel.menu = menu
	menu.base_content_panel.title = create_world_panel.title
	menu.base_content_panel.content_top_margin = create_world_panel.content_top_margin
	menu.base_content_panel.content_bottom_margin = create_world_panel.content_bottom_margin
	menu.base_content_panel.animated_refresh_size(create_world_panel)
	menu.menu_controller.appear("create_world_panel")
	
func _on_delete_world_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	if selected_world_name == "":
		return
	SceneManager.pop_secondary_confirmation(self, selected_world_name + tr("SECONDARY_CONFIRMATION_1"), Callable(self, "delete_world").bind(selected_world_name))
