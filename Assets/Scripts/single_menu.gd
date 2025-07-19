extends Node

@onready var world_list_vboxcontainer = $Content/ScrollContainer/VBoxContainer

var selected_world: String = ""

func _ready() -> void:
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
		var world_info = world_config.load_encrypted_pass(worlds_path+"/"+world+"/level.dat", SettingsManager.get_default_value("config_password"))
		if world_info != OK:
			continue
		var selection_button = SceneManager.get_scene("selection_button").instantiate()
		world_list_vboxcontainer.add_child(selection_button)
		selection_button.init("single_menu")
		selection_button.icon = ImageTexture.create_from_image(Image.load_from_file(worlds_path+"/"+world+"/icon.png"))
		selection_button.last_modified_label.text = tr("LAST_MODIFIED")+" : "+tr(world_config.get_value("world", "last_modified", "UNKNOWN"))
		selection_button.version_label.text = tr("VERSION")+" : "+tr(world_config.get_value("world", "version", "UNKNOWN"))
		selection_button.text = "   "+world

func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		AudioManager.play_static_audio("sound/ui/click")
		SceneManager.change_scene("menu")

func enter_world():
	#AudioManager.bgm_audio_player.set_process(false)
	AudioManager.bgm_audio_player.stop()
	SceneManager.change_scene("loading_world_menu")

func delete_world(world_name: String):
	var delete_path = "user://worlds/"+world_name
	if not DirAccess.dir_exists_absolute(delete_path):
		return
	OS.move_to_trash(ProjectSettings.globalize_path(delete_path))
	update_world_list()
	selected_world = ""
	if StaticLoad.is_secondary_confirmation_poped:
		StaticLoad.is_secondary_confirmation_poped = false

func convert_world_version(old_version):
	var final_old_version
	if old_version == "unknown":
		final_old_version = "0.1.0.0"
	else:
		final_old_version = old_version
	StaticLoad.convert_world_version(selected_world, final_old_version)
	selected_world = ""
	update_world_list()
	if StaticLoad.is_secondary_confirmation_poped:
		StaticLoad.is_secondary_confirmation_poped = false

func _on_single_menu_enter_world_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	if selected_world == "":
		return
	var worlds_path = "user://worlds"
	var world_config = ConfigFile.new()
	var world_info = world_config.load_encrypted_pass(worlds_path+"/"+selected_world+"/level.dat", SettingsManager.get_default_value("config_password"))
	if world_info != OK:
		return
	var version_tmp = world_config.get_value("world", "version", "unknown")
	var compare = StaticLoad.compare_version(SettingsManager.default_setting_dict["version"], version_tmp)
	if compare == "higher":
		if not StaticLoad.is_secondary_confirmation_poped:
			SceneManager.pop_secondary_confirmation(self, tr("SECONDARY_CONFIRMATION_2"), Callable(self, "convert_world_version").bind(version_tmp))
			StaticLoad.is_secondary_confirmation_poped = true
	elif compare == "lower":
		SceneManager.pop_notification(self, tr("WARNING"), tr("WARNING_8"))
	elif compare == "equal":
		enter_world()

func _on_single_menu_edit_world_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	if selected_world == "":
		return
	var edit_world_menu = SceneManager.get_scene("edit_world_menu").instantiate()
	add_child(edit_world_menu)
	edit_world_menu.init(selected_world)

func _on_single_menu_back_to_menu_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	selected_world = ""
	SceneManager.change_scene("menu")

func _on_single_menu_create_world_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	var create_world_menu = SceneManager.get_scene("create_world_menu").instantiate()
	add_child(create_world_menu)

func _on_single_menu_delete_world_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	if selected_world == "":
		return
	if not StaticLoad.is_secondary_confirmation_poped:
		SceneManager.pop_secondary_confirmation(self, selected_world + tr("SECONDARY_CONFIRMATION_1"), Callable(self, "delete_world").bind(selected_world))
		StaticLoad.is_secondary_confirmation_poped = true
