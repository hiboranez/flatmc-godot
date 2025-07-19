extends Node

var default_data_dict: Dictionary

func _ready() -> void:
	var default_data_read_type_dict = {
		"default_item_bar_amounts" : "int",
		"item_model_types" : "int",
		"item_max_amounts" : "int"
	}
	var default_data_dict = DataManager.load_json_file("res://assets/data/default_data.json", default_data_read_type_dict)

func get_default_data(default_data):
	return default_data_dict[default_data]

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
