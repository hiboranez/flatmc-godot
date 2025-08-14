extends Node

var scene_dict: Dictionary

var is_secondary_confirmation_popped: bool = false

func get_resource_amount() -> int:
	var amount: int = 0
	var scene_type_list = DirAccess.get_directories_at("res://assets/scenes")
	for scene_type in scene_type_list:
		var scene_name_list = DirAccess.get_files_at("res://assets/scenes/"+scene_type)
		for scene_file_name in scene_name_list:
			if OS.is_debug_build() and scene_file_name.contains(".import"):
				continue
			amount += 1
	return amount

func update_resource() -> void:
	var scene_type_list = []
	var scene_dir = DirAccess.open("res://assets/scenes")
	if scene_dir:
		scene_type_list = scene_dir.get_directories()
	for scene_type in scene_type_list:
		var scene_dict_tmp = {}
		var scene_name_list = []
		var scene_sub_dir = DirAccess.open("res://assets/scenes/"+scene_type)
		if scene_sub_dir:
			scene_name_list = scene_sub_dir.get_files()
		for scene_file_name in scene_name_list:
			if OS.is_debug_build() and scene_file_name.contains(".import"):
				continue
			scene_file_name = scene_file_name.replace(".import", "")
			var splits = scene_file_name.split(".")
			var scene_name = splits[0]
			ResourceLoadingMenu.call_deferred("set_loading_info", "res://assets/scenes/"+scene_type+"/"+scene_file_name)
			scene_dict_tmp[scene_name] = load("res://assets/scenes/"+scene_type+"/"+scene_file_name) as PackedScene
			ResourceLoadingMenu.call_deferred("add_loaded_amount")
		scene_dict[scene_type.to_lower()] = scene_dict_tmp

func change_scene(path):
	var scene = get_scene(path)
	if scene == null:
		return
	get_tree().change_scene_to_packed(scene)

func get_scene(path):
	if not path.contains("/"):
		return
	var splits = path.split("/")
	return scene_dict[splits[0]][splits[1]]

func pop_notification(root, title: String, info: String, is_destroying = true):
	var notice = get_scene("ui/notice").instantiate()
	root.add_child(notice)
	var scale_factor = SettingsManager.get_menu_scale_factor(SettingsManager.get_current_setting("gui_scale"))
	notice.set_scale_factor(0.001)
	notice.title_label.text = title
	notice.rich_text_label.text = info
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_method(notice.set_scale_factor, 0.001, scale_factor, 0.15)
	tween.parallel().tween_method(notice.set_blur_value, 0.001, 2, 0.15)
	if is_destroying:
		notice.destroy_count_down()

func pop_big_notification(root, title: String, info: String, button_text: String):
	var notice = get_scene("ui/big_notice").instantiate()
	root.add_child(notice)
	var scale_factor = SettingsManager.get_menu_scale_factor(SettingsManager.get_current_setting("gui_scale"))
	notice.set_scale_factor(0.001)
	notice.title_label.text = title
	notice.rich_text_label.text = info
	notice.close_button.text = button_text
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_method(notice.set_scale_factor, 0.001, scale_factor, 0.3)
	tween.parallel().tween_method(notice.set_blur_value, 0.001, 2, 0.3)

func pop_secondary_confirmation(root, info: String, function: Callable):
	if is_secondary_confirmation_popped:
		return
	var secondary_confirmation = get_scene("ui/secondary_confirmation").instantiate()
	root.add_child(secondary_confirmation)
	var scale_factor = SettingsManager.get_menu_scale_factor(SettingsManager.get_current_setting("gui_scale"))
	secondary_confirmation.connect_secondary_confirmation_confirm_button(function)
	secondary_confirmation.set_scale_factor(0.001)
	secondary_confirmation.rich_text_label.text = info
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_method(secondary_confirmation.set_scale_factor, 0.001, scale_factor, 0.15)
	tween.parallel().tween_method(secondary_confirmation.set_blur_value, 0.001, 2, 0.15)

#func change_scene(path):
	#if typeof(path) == TYPE_STRING:
		#get_tree().change_scene_to_file(path)
	#else:
		#get_tree().change_scene_to_packed(path)
