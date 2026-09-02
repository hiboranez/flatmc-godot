extends Node

var default_data_dict: Dictionary
var default_block_id_dict: Dictionary

func get_resource_amount() -> int:
	return 1

func update_resource() -> void:
	var default_data_read_type_dict = {
		"default_item_bar_amounts" : "int",
		"item_model_types" : "int",
		"item_max_amounts" : "int"
	}
	ResourceLoadingMenu.call_deferred("set_loading_info", "res://assets/data/default_data.json")
	default_data_dict = ResourceManager.load_json_file("res://assets/data/default_data.json", default_data_read_type_dict)
	default_block_id_dict = ResourceManager.load_json_file("res://assets/data/block_ids.json", {"all" : "int"})
	ResourceLoadingMenu.add_loaded_amount()

func get_default_data_dict(default_data):
	return default_data_dict[default_data]
