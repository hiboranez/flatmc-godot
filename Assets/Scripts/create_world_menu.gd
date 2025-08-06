extends CanvasLayer

@onready var settings_vboxcontainer = $Content/ScrollContainer/VBoxContainer

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
	if settings_vboxcontainer.has_node("Seed"):
		world_seed = settings_vboxcontainer.get_node("Seed").get_line_edit_text()
	if world_seed == "" or not world_seed.is_valid_int():
		var rng = RandomNumberGenerator.new()	
		world_seed = str(rng.randi())
	var world_type = SettingsManager.get_default_world_info("world_type")
	var gamemode = SettingsManager.get_default_world_info("gamemode")
	var allow_cheat = SettingsManager.get_default_world_info("allow_cheat")
	var achievement = SettingsManager.get_default_world_info("achievement")
	if settings_vboxcontainer.has_node("WorldType"):
		world_type = settings_vboxcontainer.get_node("WorldType").get_option_button_text()
	if settings_vboxcontainer.has_node("Gamemode"):
		gamemode = settings_vboxcontainer.get_node("Gamemode").get_option_button_text()
	if settings_vboxcontainer.has_node("AllowCheat"):
		allow_cheat = settings_vboxcontainer.get_node("AllowCheat").get_option_button_text()
	if settings_vboxcontainer.has_node("Achievement"):
		achievement = settings_vboxcontainer.get_node("Achievement").get_option_button_text()
	var level_change_value = {
		"last_modified": current_time,
		"version": SettingsManager.get_default_setting("version"),
		"seed": world_seed,
		"world_type": world_type,
		"gamemode": gamemode,
		"allow_cheat": allow_cheat,
		"achievement": achievement,
	}
	WorldManager.save_level_dat(level, level_change_value)
	level.save_encrypted_pass(world_path+"/level.dat", SettingsManager.get_default_value("config_password"))
	for x in range(-1,1):
		for y in range(-1,1):
			var mca = ConfigFile.new()
			var chunk = WorldManager.generate_chunk(Vector2i(x, y), world_seed, world_type)
			var value_dict = {
				"blocks" : chunk[0],
				"no_reach_blocks" : chunk[1],
				"back_blocks" : chunk[2]
			}
			WorldManager.set_mca_value(mca, value_dict)
			mca.save_encrypted_pass(region_path+"/r."+str(x)+"."+str(y)+".mca", SettingsManager.get_default_value("config_password"))

func _on_create_world_menu_create_world_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	var world_name = ""
	if settings_vboxcontainer.has_node("WorldName"):
		world_name = settings_vboxcontainer.get_node("WorldName").get_line_edit_text() 
	var world_list_path = SettingsManager.get_default_value("world_list_path")+world_name
	var world_path = world_list_path+world_name
	if world_name == "":
		SceneManager.pop_notification(self, "WARNING", "WARNING_3")
		return
	if DirAccess.dir_exists_absolute(world_path):
		SceneManager.pop_notification(self, "WARNING", "WARNING_1")
		return
	create_world(world_name)
	if has_node("/root/SingleMenu"):
		var single_menu = get_node("/root/SingleMenu")
		single_menu.selected_world = ""
		single_menu.update_world_list()
	if get_tree().get_root() != self:
		queue_free()

func _on_create_world_menu_canecl_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	if get_tree().get_root() != self:
		queue_free()
