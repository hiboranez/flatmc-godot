extends Node

@onready var create_world_ui = $CreateWorldUI
@onready var create_world_name_line_edit = $CreateWorldUI/ColorRect2/ScrollContainer/VBoxContainer/WorldName/LineEdit
@onready var edit_world_ui = $EditWorldUI
@onready var edit_world_name_line_edit = $EditWorldUI/ColorRect2/ScrollContainer/VBoxContainer/WorldName/LineEdit
@onready var notice_scene = load("res://Assets/Scenes/Notice.tscn") as PackedScene
@onready var selection_scene = load("res://Assets/Scenes/Selection.tscn") as PackedScene
@onready var world_list_vboxcontainer = $ColorRect/ScrollContainer/VBoxContainer
@onready var create_world_seed_line_edit = $CreateWorldUI/ColorRect2/ScrollContainer/VBoxContainer/Seed/LineEdit
@onready var create_world_world_type_option_button = $CreateWorldUI/ColorRect2/ScrollContainer/VBoxContainer/WorldType/OptionButton
@onready var create_world_gamemode_option_button = $CreateWorldUI/ColorRect2/ScrollContainer/VBoxContainer/Gamemode/OptionButton

func _ready() -> void:
	create_world_name_line_edit.text = tr("DEFAULT_WORLD_NAME")
	update_world_list()

func update_world_list():
	var current_worlds = world_list_vboxcontainer.get_children()
	for world in current_worlds:
		world.queue_free()
	var worlds_path = "user://worlds"
	if not DirAccess.dir_exists_absolute(worlds_path):
		DirAccess.make_dir_recursive_absolute(worlds_path)
	var world_list = DirAccess.get_directories_at(worlds_path)
	for world in world_list:
		var world_config = ConfigFile.new()
		var world_info = world_config.load_encrypted_pass(worlds_path+"/"+world+"/level.dat", StaticLoad.CONFIG_PASSWORD)
		if world_info != OK:
			continue
		var selection = selection_scene.instantiate()
		world_list_vboxcontainer.add_child(selection)
		selection.init("single_menu")
		selection.icon = ImageTexture.create_from_image(Image.load_from_file(worlds_path+"/"+world+"/icon.png"))
		selection.last_modified_label.text = tr("LAST_MODIFIED")+" : "+world_config.get_value("world", "last_modified", tr("UNKNOWN"))
		selection.version_label.text = tr("VERSION")+" : "+world_config.get_value("world", "version", tr("UNKNOWN"))
		selection.text = "   "+world

func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		StaticLoad.click_audio_player.play()
		StaticLoad.select_world = null
		StaticLoad.change_scene("res://Assets/Scenes/Menu.tscn")

func enter_world():
	StaticLoad.change_scene("res://Assets/Scenes/LoadingWorldUI.tscn")

func delete_world(world_name: String):
	var delete_path = "user://worlds/"+world_name
	if not DirAccess.dir_exists_absolute(delete_path):
		return
	OS.move_to_trash(ProjectSettings.globalize_path(delete_path))
	update_world_list()
	StaticLoad.select_world = null
	if StaticLoad.is_secondary_confirmation_poped:
		StaticLoad.is_secondary_confirmation_poped = false

func create_world(world_name: String):
	var world_path = "user://worlds/"+world_name
	var region_path = "user://worlds/"+world_name+"/regions"
	var player_path = "user://worlds/"+world_name+"/players"
	var entity_path = "user://worlds/"+world_name+"/entities"
	DirAccess.make_dir_recursive_absolute(region_path)
	DirAccess.make_dir_recursive_absolute(player_path)
	DirAccess.make_dir_recursive_absolute(entity_path)
	var image = load("res://Assets/Textures/GUI/default_icon.png").get_image()
	image.save_png(world_path+"/icon.png")
	var level = ConfigFile.new()
	var current_time = Time.get_datetime_string_from_system(false, true).replace(" ", "  ").replace("-", "/")
	level.set_value("world", "last_modified", current_time)
	level.set_value("world", "version", StaticLoad.options["version"])
	var world_seed = create_world_seed_line_edit.text
	if world_seed == "":
		var rng = RandomNumberGenerator.new()	
		world_seed = str(rng.randi())
	elif not world_seed.is_valid_int():
		var rng = RandomNumberGenerator.new()	
		world_seed = str(rng.randi())
	var world_type = StaticLoad.world_type_dictionary[create_world_world_type_option_button.selected]
	level.set_value("world", "seed", world_seed)
	level.set_value("world", "world_type", world_type)
	level.set_value("world", "gamemode", StaticLoad.gamemode_dictionary[create_world_gamemode_option_button.selected])
	level.save_encrypted_pass(world_path+"/level.dat", StaticLoad.CONFIG_PASSWORD)
	for x in range(-1,1):
		for y in range(-1,1):
			var mca = ConfigFile.new()
			var chunk = StaticLoad.generate_chunk(Vector2i(x, y), world_seed, world_type)
			mca.set_value("chunk", "blocks", chunk[0])
			mca.set_value("chunk", "no_reach_blocks", chunk[1])
			mca.set_value("chunk", "back_blocks", chunk[2])
			mca.save_encrypted_pass(region_path+"/r."+str(x)+"."+str(y)+".mca", StaticLoad.CONFIG_PASSWORD)
	StaticLoad.select_world = null

func convert_world(old_version):
	var final_old_version
	if old_version == "unknown":
		final_old_version = "0.1.0.0"
	else:
		final_old_version = old_version
	StaticLoad.convert_world(StaticLoad.select_world, final_old_version)
	StaticLoad.select_world = null
	update_world_list()
	if StaticLoad.is_secondary_confirmation_poped:
		StaticLoad.is_secondary_confirmation_poped = false

func _on_single_menu_button_1_pressed() -> void:
	StaticLoad.click_audio_player.play()
	if StaticLoad.select_world == null:
		return
	var worlds_path = "user://worlds"
	var world_config = ConfigFile.new()
	var world_info = world_config.load_encrypted_pass(worlds_path+"/"+StaticLoad.select_world+"/level.dat", StaticLoad.CONFIG_PASSWORD)
	if world_info != OK:
		return
	var version_tmp = world_config.get_value("world", "version", "unknown")
	var compare = StaticLoad.compare_version(StaticLoad.options["version"], version_tmp)
	if compare == "higher":
		if not StaticLoad.is_secondary_confirmation_poped:
			StaticLoad.pop_secondary_confirmation(self, tr("SECONDARY_CONFIRMATION_2"), Callable(self, "convert_world").bind(version_tmp))
			StaticLoad.is_secondary_confirmation_poped = true
	elif compare == "lower":
		StaticLoad.pop_notification(self, tr("WARNING"), tr("WARNING_8"))
	elif compare == "equal":
		enter_world()

func _on_single_menu_button_2_pressed() -> void:
	StaticLoad.click_audio_player.play()
	if StaticLoad.select_world == null:
		return
	edit_world_name_line_edit.text = StaticLoad.select_world
	edit_world_ui.visible = true

func _on_single_menu_button_3_pressed() -> void:
	StaticLoad.click_audio_player.play()
	StaticLoad.select_world = null
	StaticLoad.change_scene("res://Assets/Scenes/Menu.tscn")

func _on_single_menu_button_4_pressed() -> void:
	StaticLoad.click_audio_player.play()
	create_world_name_line_edit.text = tr("DEFAULT_WORLD_NAME")
	create_world_ui.visible = true;

func _on_single_menu_button_5_pressed() -> void:
	StaticLoad.click_audio_player.play()
	if StaticLoad.select_world == null:
		return
	if not StaticLoad.is_secondary_confirmation_poped:
		StaticLoad.pop_secondary_confirmation(self, StaticLoad.select_world + tr("SECONDARY_CONFIRMATION_1"), Callable(self, "delete_world").bind(StaticLoad.select_world))
		StaticLoad.is_secondary_confirmation_poped = true

func _on_create_world_button_1_pressed() -> void:
	StaticLoad.click_audio_player.play()
	var save_path = "user://worlds/"+create_world_name_line_edit.text
	if create_world_name_line_edit.text == "":
		StaticLoad.pop_notification(self, "WARNING", "WARNING_3")
		return
	if DirAccess.dir_exists_absolute(save_path):
		StaticLoad.pop_notification(self, "WARNING", "WARNING_1")
		return
	create_world(create_world_name_line_edit.text)
	update_world_list()
	create_world_ui.visible = false;

func _on_create_world_button_2_pressed() -> void:
	StaticLoad.click_audio_player.play()
	create_world_ui.visible = false;

func _on_edit_world_button_1_pressed() -> void:
	StaticLoad.click_audio_player.play()
	var world_path_tmp = "user://worlds/"
	var save_path = world_path_tmp+edit_world_name_line_edit.text
	if edit_world_name_line_edit.text == "":
		StaticLoad.pop_notification(self, "WARNING", "WARNING_3")
		return
	if edit_world_name_line_edit.text != StaticLoad.select_world and DirAccess.dir_exists_absolute(save_path):
		StaticLoad.pop_notification(self, "WARNING", "WARNING_1")
		return
	var level = ConfigFile.new()
	var current_time = Time.get_datetime_string_from_system(false, true).replace(" ", "  ").replace("-", "/")
	level.set_value("world", "last_modified", current_time)
	level.save_encrypted_pass(world_path_tmp+StaticLoad.select_world+"/level.dat", StaticLoad.CONFIG_PASSWORD)
	DirAccess.rename_absolute(world_path_tmp+StaticLoad.select_world, world_path_tmp+edit_world_name_line_edit.text)
	StaticLoad.select_world = null
	update_world_list()
	edit_world_ui.visible = false;

func _on_edit_world_button_2_pressed() -> void:
	StaticLoad.click_audio_player.play()
	edit_world_ui.visible = false;
