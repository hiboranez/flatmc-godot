class_name WorldSaver

static func save_level_dat(level_dat: ConfigFile, change_value_dict: Dictionary):
	for key in SettingsManager.default_world_info_dict.keys():
		var current_value = level_dat.get_value("world", key, SettingsManager.get_default_world_info(key))
		level_dat.set_value("world", key, current_value)
	for key in change_value_dict.keys():
		level_dat.set_value("world", key, change_value_dict[key])

static func save_mca(mca: ConfigFile, value_dict: Dictionary) -> void:
	mca.set_value("chunk", "blocks", [])
	mca.set_value("chunk", "no_reach_blocks", [])
	mca.set_value("chunk", "back_blocks", [])
	mca.set_value("chunk", "entity_list", [])
	mca.set_value("chunk", "dirt_list", [])
	mca.set_value("chunk", "grass_block_list", [])
	mca.set_value("chunk", "seed_list", [])
	mca.set_value("chunk", "sapling_list", [])
	mca.set_value("chunk", "leaves_list", [])
	mca.set_value("chunk", "farm_land_list", [])
	mca.set_value("chunk", "sugar_cane_list", [])
	mca.set_value("chunk", "sign_dict", {})
	for key in value_dict:
		mca.set_value("chunk", key, value_dict[key])
