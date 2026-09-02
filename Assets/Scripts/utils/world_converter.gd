class_name WorldConverter

static func convert_world_version(world_name: String, old_version: String) -> void:
	var old_block_id_dict = DataManager.default_block_id_dict["initial"]
	var old_version_splits = old_version.split(".")
	old_block_id_dict = DataManager.default_block_id_dict[old_version_splits[0]+"."+old_version_splits[1]+".x"]
	if old_version_splits[0] == "0":
		if old_version_splits[1] == "1":
			if int(old_version_splits[2]) >= 1:
				old_block_id_dict = DataManager.default_block_id_dict["0.1.x"]
	var region_path_tmp = "user://worlds/"+world_name+"/regions"
	var regions = DirAccess.get_files_at(ProjectSettings.globalize_path(region_path_tmp))
	if regions.is_empty():
		return
	for region in regions:
		var splits = region.split(".")
		var chunk_config = ConfigFile.new()
		var chunk_result = chunk_config.load_encrypted_pass(region_path_tmp+"/"+region, SettingsManager.get_default_value("config_password"))
		if chunk_result != OK:
			return
		var blocks = "null"
		var no_reach_blocks = "null"
		var back_blocks = "null"
		if old_version_splits[0] == "0" and old_version_splits[1] == "1":
			blocks = chunk_config.get_value("chunck", "blocks", "null")
			no_reach_blocks = chunk_config.get_value("chunck", "no_reach_blocks", "null")
			back_blocks = chunk_config.get_value("chunck", "back_blocks", "null")
			if blocks == "null":
				blocks = chunk_config.get_value("chunk", "blocks", "null")
				no_reach_blocks = chunk_config.get_value("chunk", "no_reach_blocks", "null")
				back_blocks = chunk_config.get_value("chunk", "back_blocks", "null")
		else:
			blocks = chunk_config.get_value("chunk", "blocks", "null")
			no_reach_blocks = chunk_config.get_value("chunk", "no_reach_blocks", "null")
			back_blocks = chunk_config.get_value("chunk", "back_blocks", "null")
		if not no_reach_blocks is Array:
			no_reach_blocks = []
			for i in range(16):
				var row = []
				for j in range(16):
					row.append(AttributeManager.get_block_id("AIR"))
				no_reach_blocks.append(row)
		if not back_blocks is Array:
			back_blocks = []
			for i in range(16):
				var row = []
				for j in range(16):
					row.append(AttributeManager.get_block_id("AIR"))
				back_blocks.append(row)
		blocks = convert_blocks_version(blocks, old_block_id_dict)
		no_reach_blocks = convert_blocks_version(no_reach_blocks, old_block_id_dict)
		back_blocks = convert_blocks_version(back_blocks, old_block_id_dict)
		var mca = ConfigFile.new()
		mca.set_value("chunk", "blocks", blocks)
		mca.set_value("chunk", "no_reach_blocks", no_reach_blocks)
		mca.set_value("chunk", "back_blocks", back_blocks)
		mca.save_encrypted_pass(region_path_tmp+"/r."+splits[1]+"."+splits[2]+".mca", SettingsManager.get_default_value("config_password"))
	var world_path_tmp = "user://worlds/"+world_name
	var level = ConfigFile.new()
	var current_time = Time.get_datetime_string_from_system(false, true).replace(" ", "  ").replace("-", "/")
	var level_change_value = {
		"last_modified": current_time,
		"version": SettingsManager.get_current_setting("version")
	}
	WorldSaver.save_level_dat(level, level_change_value)
	level.save_encrypted_pass(world_path_tmp+"/level.dat", SettingsManager.get_default_value("config_password"))

static func convert_blocks_version(blocks: Array, old_version: String) -> Array:
	var old_block_id_dict = DataManager.default_block_id_dict["initial"]
	var old_version_splits = old_version.split(".")
	old_block_id_dict = DataManager.default_block_id_dict[old_version_splits[0]+"."+old_version_splits[1]+".x"]
	var block_name_alternatives = DataManager.get_default_data_dict("block_name_alternatives")
	for i in range(16):
		for j in range(16):
			var old_id = blocks[i][j]
			var new_id = blocks[i][j]
			if old_block_id_dict.find_key(old_id) != null:
				var block_name_tmp = old_block_id_dict.find_key(old_id)
				if AttributeManager.block_id_dict.has(block_name_tmp):
					new_id = AttributeManager.get_block_id(block_name_tmp)
				else:
					var is_alternative_found = false
					for alternative in block_name_alternatives:
						if alternative.has(block_name_tmp):
							block_name_tmp = alternative[0]
							is_alternative_found = true
							break
					if is_alternative_found:
						new_id = AttributeManager.get_block_id(block_name_tmp)
			blocks[i][j] = new_id
	return blocks
