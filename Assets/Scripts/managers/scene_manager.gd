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
	notice.set_title(title)
	notice.set_text(info)
	if is_destroying:
		notice.destroy_count_down()

func pop_big_notification(root, title: String, info: String, button_text: String):
	var notice = get_scene("ui/big_notice").instantiate()
	root.add_child(notice)
	notice.set_title(title)
	notice.set_text(info)
	notice.set_button_text(button_text)

func pop_secondary_confirmation(root, info: String, function: Callable):
	if is_secondary_confirmation_popped:
		return
	var secondary_confirmation = get_scene("secondary_confirmation").instantiate()
	root.add_child(secondary_confirmation)
	secondary_confirmation.set_text(info)
	secondary_confirmation.connect_secondary_confirmation_confirm_button(function)

#func change_scene(path):
	#if typeof(path) == TYPE_STRING:
		#get_tree().change_scene_to_file(path)
	#else:
		#get_tree().change_scene_to_packed(path)
