extends Node

var scene_dict: Dictionary

func _ready() -> void:
	var scene_list = DirAccess.get_files_at("res://assets/scenes")
	for scene_file_name in scene_list:
		if scene_file_name.contains(".import"):
			continue
		var splits = scene_file_name.split(".")
		var scene_name = splits[0]
		scene_dict[scene_name.to_lower()] = load("res://assets/scenes/"+scene_file_name) as PackedScene

func get_scene(scene_name) -> PackedScene:
	return scene_dict[scene_name.to_lower()]

func pop_notification(root, title: String, info: String, is_destroying = true):
	var notice = get_scene("notice").instantiate()
	root.add_child(notice)
	notice.set_title(title)
	notice.set_text(info)
	if is_destroying:
		notice.destroy_count_down()

func pop_big_notification(root, title: String, info: String, button_text: String):
	var notice = get_scene("big_notice").instantiate()
	root.add_child(notice)
	notice.set_title(title)
	notice.set_text(info)
	notice.set_button_text(button_text)

func pop_secondary_confirmation(root, info: String, function: Callable):
	var secondary_confirmation = get_scene("secondary_confirmation").instantiate()
	root.add_child(secondary_confirmation)
	secondary_confirmation.set_text(info)
	secondary_confirmation.connect_secondary_confirmation_confirm_button(function)

func change_scene(scene_name):
	get_tree().change_scene_to_packed(scene_dict[scene_name.to_lower()])

#func change_scene(path):
	#if typeof(path) == TYPE_STRING:
		#get_tree().change_scene_to_file(path)
	#else:
		#get_tree().change_scene_to_packed(path)
