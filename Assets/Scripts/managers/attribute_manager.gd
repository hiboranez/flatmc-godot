extends Node

var block_id_dict: Dictionary
var item_max_amount_dict: Dictionary
var tool_type_dict: Dictionary
var moon_phase_dict: Dictionary
var no_collide_block_list: Array

func update_attributes():
	# 更新方块id信息
	var version = SettingsManager.get_default_setting("version")
	var version_splits = version.split(".")
	var version_range = version_splits[0]+"."+version_splits[1]+".x"
	block_id_dict = DataManager.default_block_id_dict[version_range]
	# 更新物品最大堆叠数
	item_max_amount_dict = DataManager.get_default_data_dict("item_max_amounts")
	# 更新耐用型物品信息
	tool_type_dict = DataManager.get_default_data_dict("tools_type")
	# 更新月相信息
	for key in DataManager.get_default_data_dict("moon_phase_dict"):
		var moon_phase_splits = DataManager.get_default_data_dict("moon_phase_dict")[key].split("-")
		moon_phase_dict[int(key)] = Vector3(12+32*int(moon_phase_splits[0]), 12+32*int(moon_phase_splits[1]), float(moon_phase_splits[2]))
	# 更新无碰撞方块
	no_collide_block_list = DataManager.get_default_data_dict("untouchable_blocks")

func get_block_id(block_name: String) -> int:
	if not block_id_dict.has(block_name):
		return -1
	return block_id_dict[block_name]

func get_block_name(block_id: int) -> String:
	var found_name = block_id_dict.find_key(block_id)
	if found_name == null:
		return "NULL"
	return found_name

func get_item_max_amount(item_name):
	var value = 64
	if item_max_amount_dict.has(item_name):
		value = item_max_amount_dict[item_name]
	return value

func get_is_durable_item(item_name: String) -> bool:
	return tool_type_dict.has(item_name)

func get_tool_type(tool_name: String) -> String:
	if tool_type_dict.has(tool_name):
		return tool_type_dict[tool_name]
	return "null"

func get_moon_phase_info(phase_state: int) -> Vector3:
	return moon_phase_dict[phase_state]
