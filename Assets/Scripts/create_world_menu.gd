extends CanvasLayer

@onready var create_world_name_line_edit = $Content/ScrollContainer/VBoxContainer/WorldName/LineEdit
@onready var create_world_seed_line_edit = $Content/ScrollContainer/VBoxContainer/Seed/LineEdit
@onready var create_world_world_type_setting_button = $Content/ScrollContainer/VBoxContainer/WorldType/OptionButton
@onready var create_world_gamemode_setting_button = $Content/ScrollContainer/VBoxContainer/Gamemode/OptionButton
@onready var create_world_allow_cheat_setting_button = $Content/ScrollContainer/VBoxContainer/AllowCheat/OptionButton
@onready var create_world_achievement_setting_button = $Content/ScrollContainer/VBoxContainer/Achievement/OptionButton

func _ready() -> void:
	create_world_name_line_edit.text = tr("DEFAULT_WORLD_NAME")
	_on_create_world_allow_cheat_setting_button_item_selected(0)

func create_world(world_name: String):
	var world_list_path = SettingsManager.get_default_value("world_list_path")
	var world_path = world_list_path+"/"+world_name
	var region_path = world_list_path+"/"+world_name+"/regions"
	var player_path = world_list_path+"/"+world_name+"/players"
	if not DirAccess.dir_exists_absolute(region_path):
		DirAccess.make_dir_recursive_absolute(region_path)
	if not DirAccess.dir_exists_absolute(player_path):
		DirAccess.make_dir_recursive_absolute(player_path)
	var image = TextureManager.get_texture("ui/default_world_icon").get_image()
	image.save_png(world_path+"/icon.png")
	var level = ConfigFile.new()
	var current_time = Time.get_datetime_string_from_system(false, true).replace(" ", "  ").replace("-", "/")
	var world_seed = create_world_seed_line_edit.text
	if world_seed == "":
		var rng = RandomNumberGenerator.new()	
		world_seed = str(rng.randi())
	elif not world_seed.is_valid_int():
		var rng = RandomNumberGenerator.new()	
		world_seed = str(rng.randi())
	var world_type = StaticLoad.world_type_dictionary[create_world_world_type_setting_button.selected]
	var allow_cheat = StaticLoad.get_on_or_off_by_selection(create_world_allow_cheat_setting_button.selected)
	var achievement_on = StaticLoad.get_on_or_off_by_selection(create_world_achievement_setting_button.selected)
	#if allow_cheat == "on":
		#achievement_on = "off"
	var level_change_value = {
		"last_modified": current_time,
		"version": SettingsManager.get_default_setting("version"),
		"seed": world_seed,
		"world_type": world_type,
		"gamemode": GameMode.get_name(create_world_gamemode_setting_button.selected),
		"allow_cheat": allow_cheat,
		"achievement": achievement_on,
	}
	StaticLoad.save_level_dat(level, level_change_value)
	level.save_encrypted_pass(world_path+"/level.dat", SettingsManager.get_default_value("config_password"))
	for x in range(-1,1):
		for y in range(-1,1):
			var mca = ConfigFile.new()
			var chunk = StaticLoad.generate_chunk(Vector2i(x, y), world_seed, world_type)
			var value_dict = {
				"blocks" : chunk[0],
				"no_reach_blocks" : chunk[1],
				"back_blocks" : chunk[2]
			}
			StaticLoad.set_mca_value(mca, value_dict)
			mca.save_encrypted_pass(region_path+"/r."+str(x)+"."+str(y)+".mca", SettingsManager.get_default_value("config_password"))
	if has_node("/root/single_menu"):
		var single_menu = get_node("/root/single_menu")
		single_menu.selected_world = ""

func _on_create_world_allow_cheat_setting_button_item_selected(index: int) -> void:
	pass
	#var allow_cheat_on = StaticLoad.get_on_or_off_by_selection(create_world_allow_cheat_setting_button.selected)
	#if allow_cheat_on == "on":
		#if StaticLoad.get_on_or_off_by_selection(create_world_achievement_setting_button.selected) == "on":
			#create_world_achievement_setting_button.selected = SettingsManager.get_selection_by_on_or_off("off")
		#create_world_achievement_setting_button.disabled = true
	#elif allow_cheat_on == "off" and create_world_achievement_setting_button.disabled:
		#create_world_achievement_setting_button.disabled = false

func _on_create_world_menu_create_world_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	var save_path = "user://worlds/"+create_world_name_line_edit.text
	if create_world_name_line_edit.text == "":
		SceneManager.pop_notification(self, "WARNING", "WARNING_3")
		return
	if DirAccess.dir_exists_absolute(save_path):
		SceneManager.pop_notification(self, "WARNING", "WARNING_1")
		return
	create_world(create_world_name_line_edit.text)
	if has_node("/root/single_menu"):
		var single_menu = get_node("/root/single_menu")
		single_menu.update_world_list()
	if get_tree().get_root() != self:
		queue_free()

func _on_create_world_menu_canecl_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	if get_tree().get_root() != self:
		queue_free()
