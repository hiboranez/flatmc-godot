extends Node

func save_level_dat(world_config, change_value: Dictionary):
	for key in SettingsManager.default_world_info_dict.keys():
		var current_value = world_config.get_value("world", key, SettingsManager.get_default_world_info(key))
		world_config.set_value("world", key, current_value)
	for key in change_value.keys():
		world_config.set_value("world", key, change_value[key])

func set_mca_value(got_mca, got_value_dict):
	got_mca.set_value("chunk", "blocks", [])
	got_mca.set_value("chunk", "no_reach_blocks", [])
	got_mca.set_value("chunk", "back_blocks", [])
	got_mca.set_value("chunk", "entity_list", [])
	got_mca.set_value("chunk", "dirt_list", [])
	got_mca.set_value("chunk", "grass_block_list", [])
	got_mca.set_value("chunk", "seed_list", [])
	got_mca.set_value("chunk", "sapling_list", [])
	got_mca.set_value("chunk", "leaves_list", [])
	got_mca.set_value("chunk", "farm_land_list", [])
	got_mca.set_value("chunk", "sugar_cane_list", [])
	got_mca.set_value("chunk", "sign_dict", {})
	for key in got_value_dict:
		got_mca.set_value("chunk", key, got_value_dict[key])

func generate_chunk(pos: Vector2i, got_seed, world_type):
	var seed = int(got_seed)
	var blocks = []
	var no_reach_blocks = []
	var back_blocks = []
	if world_type == "flat":
		var x = pos[0]
		var y = pos[1]
		for i in range(16):
			var row = []
			for j in range(16):
				row.append(DataManager.get_block_id("AIR"))
			no_reach_blocks.append(row)
		for i in range(16):
			var row = []
			for j in range(16):
				row.append(DataManager.get_block_id("AIR"))
			back_blocks.append(row)
		if y <= -1:
			for i in range(16):
				var row = []
				for j in range(16):
					row.append(DataManager.get_block_id("AIR"))
				blocks.append(row)
		elif y == 0:
			for i in range(16):
				var row = []
				for j in range(16):
					if i == 0:
						row.append(DataManager.get_block_id("GRASS_BLOCK"))
					elif i > 0 and i<=3:
						row.append(DataManager.get_block_id("DIRT"))
						back_blocks[i][j] = DataManager.get_block_id("DIRT")
					else:
						row.append(DataManager.get_block_id("STONE"))
						back_blocks[i][j] = DataManager.get_block_id("STONE")
				blocks.append(row)
		else:
			for i in range(16):
				var row = []
				for j in range(16):
					row.append(DataManager.get_block_id("STONE"))
					back_blocks[i][j] = DataManager.get_block_id("STONE")
				blocks.append(row)
	else:
		var noise = FastNoiseLite.new()
		noise.noise_type = FastNoiseLite.TYPE_PERLIN
		noise.frequency = 0.005
		noise.seed = seed  # 随机种子
		var trees = []
		#var caves = []
		for i in range(16):
			var row = []
			for j in range(16):
				row.append(DataManager.get_block_id("AIR"))
			no_reach_blocks.append(row)
		for i in range(16):
			var row = []
			for j in range(16):
				row.append(DataManager.get_block_id("AIR"))
			back_blocks.append(row)
		for i in range(16):
			var row = []
			for j in range(16):
				var noise_value = noise.get_noise_2d(pos[0]*16+j, 0)  # 使用2D噪声
				var normalized = (noise_value) / 2  # 噪声值范围 [-1, 1] 转为 [-0.5, 0.5]
				if pos[1]*16+i < int(normalized*40):
					row.append(DataManager.get_block_id("AIR"))
				elif pos[1]*16+i == int(normalized*40):
					var rng = RandomNumberGenerator.new()
					rng.seed = int(str(seed%12419)+str(pos[0])+str(j))
					var num = rng.randf()
					if num > 0.7 and i-5 >= 0 and j-2 >=0 and j+2 <= 15:
						trees.append(Vector2i(j, i-1))
					#if num < 0.1 and i-5 >= 0 and j-2 >=0 and j+2 <= 15:
						#caves.append(Vector2i(j, i))
					row.append(DataManager.get_block_id("GRASS_BLOCK"))
				elif pos[1]*16+i > int(normalized*40):
					var noise_value2 = noise.get_noise_2d(pos[0]*16+j, pos[1]*16+i)  # 使用2D噪声
					var normalized2 = (noise_value2 + 1) / 2
					if pos[1]*16+i < int(normalized*40)+12*normalized2:
						row.append(DataManager.get_block_id("DIRT"))
						back_blocks[i][j] = DataManager.get_block_id("DIRT")
					else:
						var rng = RandomNumberGenerator.new()
						rng.seed = int(str(seed%12419)+str(pos[0])+str(pos[1])+str(i)+str(j))
						var num = rng.randf()
						if num > 0 and num <= 0.05:	
							row.append(DataManager.get_block_id("COAL_ORE"))
						elif num > 0.05 and num <= 0.08:	
							row.append(DataManager.get_block_id("IRON_ORE"))
						elif num > 0.08 and num <= 0.085 and pos[1] > 2:	
							row.append(DataManager.get_block_id("GOLD_ORE"))
						elif num > 0.085 and num <= 0.09 and pos[1] > 2:	
							row.append(DataManager.get_block_id("LAPIS_ORE"))
						elif num > 0.09 and num <= 0.0925 and pos[1] > 3:	
							row.append(DataManager.get_block_id("DIAMOND_ORE"))
						else:
							row.append(DataManager.get_block_id("STONE"))
						back_blocks[i][j] = DataManager.get_block_id("STONE")
			blocks.append(row)
		var cave_noise = FastNoiseLite.new()
		cave_noise.noise_type = FastNoiseLite.TYPE_PERLIN
		cave_noise.frequency = 0.005
		cave_noise.seed = seed
		for i in range(16):
			for j in range(16):
				var noise_value = cave_noise.get_noise_2d(pos[0]*16+j, pos[1]*16+i)
				if noise_value < 0 and noise_value > -0.04:
					if trees.has(Vector2i(j, i-1)):
						trees.erase(Vector2i(j, i-1))
					if blocks[i][j] != DataManager.get_block_id("AIR"):
						blocks[i][j] = DataManager.get_block_id("AIR")
		var gravel_noise = FastNoiseLite.new()
		gravel_noise.noise_type = FastNoiseLite.TYPE_PERLIN
		gravel_noise.frequency = 0.5
		gravel_noise.seed = seed
		for i in range(16):
			for j in range(16):
				var noise_value = gravel_noise.get_noise_2d(pos[0]*16+j, pos[1]*16+i)
				if noise_value < -0.15:
					#if trees.has(Vector2i(j-1, i)):
						#trees.erase(Vector2i(j-1, i))
					if blocks[i][j] == DataManager.get_block_id("STONE"):
						blocks[i][j] = DataManager.get_block_id("GRAVEL")
		var sand_noise = FastNoiseLite.new()
		sand_noise.noise_type = FastNoiseLite.TYPE_PERLIN
		sand_noise.frequency = 0.001
		sand_noise.seed = seed
		for i in range(16):
			for j in range(16):
				var noise_value = sand_noise.get_noise_2d(pos[0]*16+j, pos[1]*16+i)
				if noise_value < -0.01:
					#if trees.has(Vector2i(j-1, i)):
						#trees.erase(Vector2i(j-1, i))
					if blocks[i][j] == DataManager.get_block_id("GRASS_BLOCK") or blocks[i][j] == DataManager.get_block_id("DIRT"):
						blocks[i][j] = DataManager.get_block_id("SAND")
		for i in range(16):
			for j in range(15,0,-1):
				var is_planted = false
				if blocks[j][i] == DataManager.get_block_id("SAND") and blocks[j-1][i] == DataManager.get_block_id("AIR"):
					var rng = RandomNumberGenerator.new()
					rng.seed = int(str(seed%12419)+str(pos[0])+str(i))
					var num = rng.randf()
					if num > 0.95:
						if trees.has(Vector2i(i, j)):
							trees.erase(Vector2i(i, j))
						is_planted = true
						for k in range(3):
							if j-1-k >= 0 and blocks[j-1-k][i] == DataManager.get_block_id("AIR"):
								blocks[j-1-k][i] = DataManager.get_block_id("REEDS")
								if trees.has(Vector2i(i, j-1-k)):
									trees.erase(Vector2i(i, j-1-k))
				if is_planted:
					break
		#for cave in caves:
			#for depth in range(cave[1], 16):
				#var rng = RandomNumberGenerator.new()
				#rng.seed = int(str(seed%12419)+str(cave[0])+str(cave[1])+str(depth))
				#var num = int(rng.randf()*6)
				#for i in range(num):
					#if cave[1]%2==0:
						#if blocks[depth][cave[0]+i-num/2] == DataManager.get_block_id("GRASS_BLOCK") or blocks[depth][cave[0]+i-num/2] == DataManager.get_block_id("DIRT"):
							#blocks[depth][cave[0]+i-num/2] = DataManager.get_block_id("AIR")
							#if trees.has(Vector2i(depth, cave[0]+i-num/2)):
								#trees.erase(Vector2i(depth, cave[0]+i-num/2))
					#else:
						#if blocks[depth][cave[0]+i-num/2] == DataManager.get_block_id("GRASS_BLOCK") or blocks[depth][cave[0]+i-num/2] == DataManager.get_block_id("DIRT"):
							#blocks[depth][cave[0]-i+num/2] = DataManager.get_block_id("AIR")
							#if trees.has(Vector2i(depth, cave[0]-i-num/2)):
								#trees.erase(Vector2i(depth, cave[0]-i-num/2))
		for tree in trees:
			for i in range(3):
				no_reach_blocks[tree[1]-i][tree[0]] = DataManager.get_block_id("LOG_OAK")
			for j in range(-2,3):
				if no_reach_blocks[tree[1]-3][tree[0]+j] == DataManager.get_block_id("LOG_OAK"):
					continue
				no_reach_blocks[tree[1]-3][tree[0]+j] = DataManager.get_block_id("LEAVES")
				if blocks[tree[1]-3][tree[0]+j] == DataManager.get_block_id("REEDS"):
					blocks[tree[1]-3][tree[0]+j] = DataManager.get_block_id("AIR")
			for j in range(-1,2):
				if no_reach_blocks[tree[1]-4][tree[0]+j] == DataManager.get_block_id("LOG_OAK"):
					continue
				no_reach_blocks[tree[1]-4][tree[0]+j] = DataManager.get_block_id("LEAVES")
				if blocks[tree[1]-4][tree[0]+j] == DataManager.get_block_id("REEDS"):
					blocks[tree[1]-4][tree[0]+j] = DataManager.get_block_id("AIR")
	return [blocks, no_reach_blocks, back_blocks]
	
func convert_world_version(world_name, old_version):
	var block_ids_old = DataManager.default_block_id_dict["initial"]
	var old_version_splits = old_version.split(".")
	block_ids_old = DataManager.default_block_id_dict[old_version_splits[0]+"."+old_version_splits[1]+".x"]
	if old_version_splits[0] == "0":
		if old_version_splits[1] == "1":
			if int(old_version_splits[2]) >= 1:
				block_ids_old = DataManager.default_block_id_dict["0.1.x"]
	var region_path_tmp = "user://worlds/"+world_name+"/regions"
	var regions = DirAccess.get_files_at(ProjectSettings.globalize_path(region_path_tmp))
	if regions.is_empty():
		return
	for region in regions:
		var splits = region.split(".")
		var chunk_config = ConfigFile.new()
		var chunk_result = chunk_config.load_encrypted_pass(region_path_tmp+"/"+region, StaticLoad.SettingsManager.get_default_value("config_password"))
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
		if no_reach_blocks == "null":
			no_reach_blocks = []
			for i in range(16):
				var row = []
				for j in range(16):
					row.append(DataManager.get_block_id("AIR"))
				no_reach_blocks.append(row)
		if back_blocks == "null":
			back_blocks = []
			for i in range(16):
				var row = []
				for j in range(16):
					row.append(DataManager.get_block_id("AIR"))
				back_blocks.append(row)
		blocks = convert_blocks_version(blocks, block_ids_old)
		no_reach_blocks = convert_blocks_version(no_reach_blocks, block_ids_old)
		back_blocks = convert_blocks_version(back_blocks, block_ids_old)
		var mca = ConfigFile.new()
		mca.set_value("chunk", "blocks", blocks)
		mca.set_value("chunk", "no_reach_blocks", no_reach_blocks)
		mca.set_value("chunk", "back_blocks", back_blocks)
		mca.save_encrypted_pass(region_path_tmp+"/r."+splits[1]+"."+splits[2]+".mca", StaticLoad.SettingsManager.get_default_value("config_password"))
	var world_path_tmp = "user://worlds/"+world_name
	var level = ConfigFile.new()
	var current_time = Time.get_datetime_string_from_system(false, true).replace(" ", "  ").replace("-", "/")
	var level_change_value = {
		"last_modified": current_time,
		"version": StaticLoad.settings["version"]
	}
	get_node("/root/WorldManager").save_level_dat(level, level_change_value)
	level.save_encrypted_pass(world_path_tmp+"/level.dat", StaticLoad.SettingsManager.get_default_value("config_password"))

func convert_blocks_version(blocks, block_ids_old):
	var block_name_alternatives = DataManager.get_default_data("block_name_alternatives")
	for i in range(16):
		for j in range(16):
			var old_id = blocks[i][j]
			var new_id = blocks[i][j]
			if block_ids_old.find_key(old_id) != null:
				var block_name_tmp = block_ids_old.find_key(old_id)
				if DataManager.block_id_dict.has(block_name_tmp):
					new_id = DataManager.get_block_id(block_name_tmp)
				else:
					var is_alternative_found = false
					for alternative in block_name_alternatives:
						if alternative.has(block_name_tmp):
							block_name_tmp = alternative[0]
							is_alternative_found = true
							break
					if is_alternative_found:
						new_id = DataManager.get_block_id(block_name_tmp)
			blocks[i][j] = new_id
	return blocks
