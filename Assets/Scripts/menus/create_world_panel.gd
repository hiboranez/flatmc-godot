extends Control

@onready var world_info_gridcontainer = $DragScrollContainer/CenterContainer/GridContainer

var menu: Node = null
var title: String = "CREATE_WORLD"
var content_top_margin: float = 120
var content_bottom_margin: float = 160

func _ready() -> void:
	get_viewport().size_changed.connect(refresh_size)

func refresh_size() -> void:
	var canvas_size = get_viewport().get_screen_transform().affine_inverse()*Vector2(get_viewport().size)
	scale = Vector2(menu.scale_factor, menu.scale_factor)
	set_deferred("size", Vector2(canvas_size.x/menu.scale_factor, (canvas_size.y-((content_top_margin+content_bottom_margin)*menu.scale_factor))/menu.scale_factor))

func create_world(world_name: String):
	var world_list_path = SettingsManager.get_default_value("world_list_path")
	var world_path = world_list_path+world_name
	var region_path = world_list_path+world_name+"/regions"
	var player_path = world_list_path+world_name+"/players"
	if not DirAccess.dir_exists_absolute(region_path):
		DirAccess.make_dir_recursive_absolute(region_path)
	if not DirAccess.dir_exists_absolute(player_path):
		DirAccess.make_dir_recursive_absolute(player_path)
	var image = TextureManager.get_texture("ui/default_world_icon").get_image()
	image.save_png(world_path+"/icon.png")
	var level = ConfigFile.new()
	var current_time = Time.get_datetime_string_from_system(false, true).replace(" ", "  ").replace("-", "/")
	var world_seed = ""
	if world_info_gridcontainer.has_node("Seed"):
		world_seed = world_info_gridcontainer.get_node("Seed").get_line_edit_text()
	if world_seed == "" or not world_seed.is_valid_int():
		var rng = RandomNumberGenerator.new()	
		world_seed = str(rng.randi())
	var world_type = SettingsManager.get_default_world_info("world_type")
	var gamemode = SettingsManager.get_default_world_info("gamemode")
	var allow_cheat = SettingsManager.get_default_world_info("allow_cheat")
	var achievement = SettingsManager.get_default_world_info("achievement")
	if world_info_gridcontainer.has_node("WorldType"):
		world_type = world_info_gridcontainer.get_node("WorldType").get_option_button_text()
	if world_info_gridcontainer.has_node("Gamemode"):
		gamemode = world_info_gridcontainer.get_node("Gamemode").get_option_button_text()
	if world_info_gridcontainer.has_node("AllowCheat"):
		allow_cheat = world_info_gridcontainer.get_node("AllowCheat").get_option_button_text()
	if world_info_gridcontainer.has_node("Achievement"):
		achievement = world_info_gridcontainer.get_node("Achievement").get_option_button_text()
	var level_change_value = {
		"last_modified": current_time,
		"version": SettingsManager.get_default_setting("version"),
		"seed": world_seed,
		"world_type": world_type,
		"gamemode": gamemode,
		"allow_cheat": allow_cheat,
		"achievement": achievement,
	}
	WorldSaver.save_level_dat(level, level_change_value)
	level.save_encrypted_pass(world_path+"/level.dat", SettingsManager.get_default_value("config_password"))
	for x in range(-1,1):
		for y in range(-1,1):
			var mca = ConfigFile.new()
			var chunk = WorldGenerator.generate_chunk(Vector2i(x, y), world_seed, world_type)
			var value_dict = {
				"blocks" : chunk[0],
				"no_reach_blocks" : chunk[1],
				"back_blocks" : chunk[2]
			}
			WorldSaver.save_mca(mca, value_dict)
			mca.save_encrypted_pass(region_path+"/r."+str(x)+"."+str(y)+".mca", SettingsManager.get_default_value("config_password"))

func _on_create_world_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	var world_name = ""
	if world_info_gridcontainer.has_node("WorldName"):
		world_name = world_info_gridcontainer.get_node("WorldName").get_line_edit_text() 
	var world_path = SettingsManager.get_default_value("world_list_path")+world_name
	if world_name == "":
		SceneManager.pop_notification(self, "WARNING", "WARNING_3")
		return
	if DirAccess.dir_exists_absolute(world_path):
		SceneManager.pop_notification(self, "WARNING", "WARNING_1")
		return
	create_world(world_name)
	if menu != null:
		await menu.menu_controller.vanish("create_world_panel")
		menu.panel_control_dict.erase("create_world_panel")
		get_viewport().size_changed.disconnect(refresh_size)
		var single_game_panel = menu.panel_control_dict["single_game_panel"]
		single_game_panel.selected_world_name = ""
		await single_game_panel.update_world_list()
		menu.base_content_panel.title = single_game_panel.title
		menu.base_content_panel.content_top_margin = single_game_panel.content_top_margin
		menu.base_content_panel.content_bottom_margin = single_game_panel.content_bottom_margin
		menu.base_content_panel.animated_refresh_size(single_game_panel)
		menu.menu_controller.appear("single_game_panel")
	queue_free()

func _on_cancel_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	if menu != null:
		await menu.menu_controller.vanish("create_world_panel")
		menu.panel_control_dict.erase("create_world_panel")
		get_viewport().size_changed.disconnect(refresh_size)
		var single_game_panel = menu.panel_control_dict["single_game_panel"]
		single_game_panel.selected_world_name = ""
		await single_game_panel.update_world_list()
		menu.base_content_panel.title = single_game_panel.title
		menu.base_content_panel.content_top_margin = single_game_panel.content_top_margin
		menu.base_content_panel.content_bottom_margin = single_game_panel.content_bottom_margin
		menu.base_content_panel.animated_refresh_size(single_game_panel)
		menu.menu_controller.appear("single_game_panel")
	queue_free()
