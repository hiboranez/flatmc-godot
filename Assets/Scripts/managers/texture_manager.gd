extends Node

var texture_dict: Dictionary

func get_resource_amount() -> int:
	var amount: int = 0
	var texture_type_list = DirAccess.get_directories_at("res://assets/textures")
	for texture_type in texture_type_list:
		var texture_name_list = DirAccess.get_files_at("res://assets/textures/"+texture_type)
		for texture_file_name in texture_name_list:
			if OS.is_debug_build() and texture_file_name.contains(".import"):
				continue
			amount += 1
	return amount

func update_resource() -> void:
	var texture_type_list = []
	var textures_dir = DirAccess.open("res://assets/textures")
	if textures_dir:
		texture_type_list = textures_dir.get_directories()
	for texture_type in texture_type_list:
		var texture_dict_tmp = {}
		var texture_name_list = []
		var texture_sub_dir = DirAccess.open("res://assets/textures/"+texture_type)
		if texture_sub_dir:
			texture_name_list = texture_sub_dir.get_files()
		for texture_file_name in texture_name_list:
			if OS.is_debug_build() and texture_file_name.contains(".import"):
				continue
			texture_file_name = texture_file_name.replace(".import", "")
			var splits = texture_file_name.split(".")
			var texture_name = splits[0]
			ResourceLoadingMenu.call_deferred("set_loading_info", "res://assets/textures/"+texture_type+"/"+texture_file_name)
			texture_dict_tmp[texture_name] = load("res://assets/textures/"+texture_type+"/"+texture_file_name) as Texture2D
			ResourceLoadingMenu.call_deferred("add_loaded_amount")
		texture_dict[texture_type.to_lower()] = texture_dict_tmp


func get_texture(path: String) -> Texture2D:
	if not path.contains("/"):
		return
	var splits = path.split("/")
	return texture_dict[splits[0]][splits[1]]
