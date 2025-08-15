extends Node

var default_data_dict: Dictionary
var default_block_id_dict: Dictionary

var block_id_dict: Dictionary
var moon_phase_dict: Dictionary

func get_resource_amount() -> int:
	return 1

func update_resource() -> void:
	var default_data_read_type_dict = {
		"default_item_bar_amounts" : "int",
		"item_model_types" : "int",
		"item_max_amounts" : "int"
	}
	ResourceLoadingMenu.call_deferred("set_loading_info", "res://assets/data/default_data.json")
	default_data_dict = load_json_file("res://assets/data/default_data.json", default_data_read_type_dict)
	default_block_id_dict = load_json_file("res://assets/data/block_ids.json", {"all" : "int"})
	for key in default_data_dict["moon_phase_dict"]:
		var splits = default_data_dict["moon_phase_dict"][key].split("-")
		moon_phase_dict[int(key)] = Vector3(12+32*int(splits[0]), 12+32*int(splits[1]), float(splits[2]))
	ResourceLoadingMenu.add_loaded_amount()

func update_block_id_dict() -> void:
	var version = SettingsManager.get_default_setting("version")
	var splits = version.split(".")
	var version_range = splits[0]+"."+splits[1]+".x"
	block_id_dict = default_block_id_dict[version_range]

func get_default_data_dict(default_data):
	return default_data_dict[default_data]

func get_moon_phase_info(phase_state: int) -> Vector3:
	return moon_phase_dict[phase_state]

func get_block_id(block_name: String) -> int:
	if not block_id_dict.has(block_name):
		return -1
	return block_id_dict[block_name]

func get_block_name(block_id: int) -> String:
	var found_name = block_id_dict.find_key(block_id)
	if found_name == null:
		return "NULL"
	return found_name

func load_json_file(file_path, data_type_dict) -> Dictionary:
	if FileAccess.file_exists(file_path):
		var data_file = FileAccess.open(file_path, FileAccess.READ)
		var parsed_result = JSON.parse_string(data_file.get_as_text())
		if parsed_result is Dictionary:
			if data_type_dict.has("all"):
				data_type_dict = {}
				for data in parsed_result:
					data_type_dict[data] = "int"
			for data in parsed_result:
				for key in parsed_result[data]:
					if key is float:
						key = int(key)
				if data_type_dict.has(data):
					if data_type_dict[data] == "int":
						if parsed_result[data] is Dictionary:
							for key in parsed_result[data]:
								parsed_result[data][key] = int(parsed_result[data][key])
						elif parsed_result[data] is Array:
							for i in range(parsed_result[data].size()):
								parsed_result[data][i] = int(parsed_result[data][i])
			return parsed_result
		else:
			print("读取出错")
			return {}
	else:
		print("文件未找到")
		return {}
