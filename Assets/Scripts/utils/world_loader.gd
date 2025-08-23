class_name WorldLoader

static func load_mca(chunk_coordinate: Vector2i) -> Array:
	var region_path = "/regions"
	var chunk_config = ConfigFile.new()
	var x_chunk = chunk_coordinate[0]
	var y_chunk = chunk_coordinate[1]
	var chunk_result = chunk_config.load_encrypted_pass(region_path+"/r."+str(x_chunk)+"."+str(y_chunk)+".mca", SettingsManager.get_default_value("config_password"))
	if chunk_result != OK:
		return [false]
	var blocks = chunk_config.get_value("chunk", "blocks", [])
	var no_reach_blocks = chunk_config.get_value("chunk", "no_reach_blocks", [])
	var back_blocks = chunk_config.get_value("chunk", "back_blocks", [])
	var chunk_block_list = [blocks, no_reach_blocks, back_blocks]
	
	var chunk_dirt_list = chunk_config.get_value("chunk", "dirt_list", [])
	var chunk_grass_block_list = chunk_config.get_value("chunk", "grass_block_list", [])
	var chunk_seed_list = chunk_config.get_value("chunk", "seed_list", [])
	var chunk_sapling_list = chunk_config.get_value("chunk", "sapling_list", [])
	var chunk_leaves_list = chunk_config.get_value("chunk", "leaves_list", [])
	var chunk_farm_land_list = chunk_config.get_value("chunk", "farm_land_list", [])
	var chunk_sugar_cane_list = chunk_config.get_value("chunk", "sugar_cane_list", [])
	var chunk_sign_dict = chunk_config.get_value("chunk", "sign_dict", {})
	var chunk_info_dict = {
		"chunk_dirt_list": chunk_dirt_list,
		"chunk_grass_block_list": chunk_grass_block_list,
		"chunk_seed_list": chunk_seed_list,
		"chunk_sapling_list": chunk_sapling_list,
		"chunk_leaves_list": chunk_leaves_list,
		"chunk_farm_land_list": chunk_farm_land_list,
		"chunk_sugar_cane_list": chunk_sugar_cane_list,
		"chunk_sign_dict": chunk_sign_dict
	}
	
	if not StaticLoad.game.loaded_chunks.has(str(x_chunk)+"."+str(y_chunk)):
		StaticLoad.game.loaded_chunks[str(x_chunk)+"."+str(y_chunk)] = Chunk.new()
	StaticLoad.game.loaded_chunks[str(x_chunk)+"."+str(y_chunk)].is_to_save = false
	StaticLoad.game.loaded_chunks[str(x_chunk)+"."+str(y_chunk)].dirt_list = chunk_dirt_list
	StaticLoad.game.loaded_chunks[str(x_chunk)+"."+str(y_chunk)].grass_block_list = chunk_grass_block_list
	StaticLoad.game.loaded_chunks[str(x_chunk)+"."+str(y_chunk)].seed_list = chunk_seed_list
	StaticLoad.game.loaded_chunks[str(x_chunk)+"."+str(y_chunk)].sapling_list = chunk_sapling_list
	StaticLoad.game.loaded_chunks[str(x_chunk)+"."+str(y_chunk)].leaves_list = chunk_leaves_list
	StaticLoad.game.loaded_chunks[str(x_chunk)+"."+str(y_chunk)].farm_land_list = chunk_farm_land_list
	StaticLoad.game.loaded_chunks[str(x_chunk)+"."+str(y_chunk)].sugar_cane_list = chunk_sugar_cane_list
	StaticLoad.game.loaded_chunks[str(x_chunk)+"."+str(y_chunk)].sign_dict = chunk_sign_dict
	StaticLoad.game.loaded_chunks_timer[str(x_chunk)+"."+str(y_chunk)] = float(SettingsManager.get_default_value("chunk_dormant_time"))
	return [true, chunk_config, chunk_block_list, chunk_info_dict]
