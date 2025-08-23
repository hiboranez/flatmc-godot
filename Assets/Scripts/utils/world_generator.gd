class_name WorldGenerator

static func generate_chunk(chunk_coordinate: Vector2i, world_seed: String, world_type: String) -> Array:
	var seed = int(world_seed)
	var blocks = []
	var no_reach_blocks = []
	var back_blocks = []
	if world_type == "flat":
		var x = chunk_coordinate[0]
		var y = chunk_coordinate[1]
		for i in range(16):
			var row = []
			for j in range(16):
				row.append(AttributeManager.get_block_id("AIR"))
			no_reach_blocks.append(row)
		for i in range(16):
			var row = []
			for j in range(16):
				row.append(AttributeManager.get_block_id("AIR"))
			back_blocks.append(row)
		if y <= -1:
			for i in range(16):
				var row = []
				for j in range(16):
					row.append(AttributeManager.get_block_id("AIR"))
				blocks.append(row)
		elif y == 0:
			for i in range(16):
				var row = []
				for j in range(16):
					if i == 0:
						row.append(AttributeManager.get_block_id("GRASS_BLOCK"))
					elif i > 0 and i<=3:
						row.append(AttributeManager.get_block_id("DIRT"))
						back_blocks[i][j] = AttributeManager.get_block_id("DIRT")
					else:
						row.append(AttributeManager.get_block_id("STONE"))
						back_blocks[i][j] = AttributeManager.get_block_id("STONE")
				blocks.append(row)
		else:
			for i in range(16):
				var row = []
				for j in range(16):
					row.append(AttributeManager.get_block_id("STONE"))
					back_blocks[i][j] = AttributeManager.get_block_id("STONE")
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
				row.append(AttributeManager.get_block_id("AIR"))
			no_reach_blocks.append(row)
		for i in range(16):
			var row = []
			for j in range(16):
				row.append(AttributeManager.get_block_id("AIR"))
			back_blocks.append(row)
		for i in range(16):
			var row = []
			for j in range(16):
				var noise_value = noise.get_noise_2d(chunk_coordinate[0]*16+j, 0)  # 使用2D噪声
				var normalized = (noise_value) / 2  # 噪声值范围 [-1, 1] 转为 [-0.5, 0.5]
				if chunk_coordinate[1]*16+i < int(normalized*40):
					row.append(AttributeManager.get_block_id("AIR"))
				elif chunk_coordinate[1]*16+i == int(normalized*40):
					var rng = RandomNumberGenerator.new()
					rng.seed = int(str(seed%12419)+str(chunk_coordinate[0])+str(j))
					var num = rng.randf()
					if num > 0.7 and i-5 >= 0 and j-2 >=0 and j+2 <= 15:
						trees.append(Vector2i(j, i-1))
					#if num < 0.1 and i-5 >= 0 and j-2 >=0 and j+2 <= 15:
						#caves.append(Vector2i(j, i))
					row.append(AttributeManager.get_block_id("GRASS_BLOCK"))
				elif chunk_coordinate[1]*16+i > int(normalized*40):
					var noise_value2 = noise.get_noise_2d(chunk_coordinate[0]*16+j, chunk_coordinate[1]*16+i)  # 使用2D噪声
					var normalized2 = (noise_value2 + 1) / 2
					if chunk_coordinate[1]*16+i < int(normalized*40)+12*normalized2:
						row.append(AttributeManager.get_block_id("DIRT"))
						back_blocks[i][j] = AttributeManager.get_block_id("DIRT")
					else:
						var rng = RandomNumberGenerator.new()
						rng.seed = int(str(seed%12419)+str(chunk_coordinate[0])+str(chunk_coordinate[1])+str(i)+str(j))
						var num = rng.randf()
						if num > 0 and num <= 0.05:	
							row.append(AttributeManager.get_block_id("COAL_ORE"))
						elif num > 0.05 and num <= 0.08:	
							row.append(AttributeManager.get_block_id("IRON_ORE"))
						elif num > 0.08 and num <= 0.085 and chunk_coordinate[1] > 2:	
							row.append(AttributeManager.get_block_id("GOLD_ORE"))
						elif num > 0.085 and num <= 0.09 and chunk_coordinate[1] > 2:	
							row.append(AttributeManager.get_block_id("LAPIS_ORE"))
						elif num > 0.09 and num <= 0.0925 and chunk_coordinate[1] > 3:	
							row.append(AttributeManager.get_block_id("DIAMOND_ORE"))
						else:
							row.append(AttributeManager.get_block_id("STONE"))
						back_blocks[i][j] = AttributeManager.get_block_id("STONE")
			blocks.append(row)
		var cave_noise = FastNoiseLite.new()
		cave_noise.noise_type = FastNoiseLite.TYPE_PERLIN
		cave_noise.frequency = 0.005
		cave_noise.seed = seed
		for i in range(16):
			for j in range(16):
				var noise_value = cave_noise.get_noise_2d(chunk_coordinate[0]*16+j, chunk_coordinate[1]*16+i)
				if noise_value < 0 and noise_value > -0.04:
					if trees.has(Vector2i(j, i-1)):
						trees.erase(Vector2i(j, i-1))
					if blocks[i][j] != AttributeManager.get_block_id("AIR"):
						blocks[i][j] = AttributeManager.get_block_id("AIR")
		var gravel_noise = FastNoiseLite.new()
		gravel_noise.noise_type = FastNoiseLite.TYPE_PERLIN
		gravel_noise.frequency = 0.5
		gravel_noise.seed = seed
		for i in range(16):
			for j in range(16):
				var noise_value = gravel_noise.get_noise_2d(chunk_coordinate[0]*16+j, chunk_coordinate[1]*16+i)
				if noise_value < -0.15:
					#if trees.has(Vector2i(j-1, i)):
						#trees.erase(Vector2i(j-1, i))
					if blocks[i][j] == AttributeManager.get_block_id("STONE"):
						blocks[i][j] = AttributeManager.get_block_id("GRAVEL")
		var sand_noise = FastNoiseLite.new()
		sand_noise.noise_type = FastNoiseLite.TYPE_PERLIN
		sand_noise.frequency = 0.001
		sand_noise.seed = seed
		for i in range(16):
			for j in range(16):
				var noise_value = sand_noise.get_noise_2d(chunk_coordinate[0]*16+j, chunk_coordinate[1]*16+i)
				if noise_value < -0.01:
					#if trees.has(Vector2i(j-1, i)):
						#trees.erase(Vector2i(j-1, i))
					if blocks[i][j] == AttributeManager.get_block_id("GRASS_BLOCK") or blocks[i][j] == AttributeManager.get_block_id("DIRT"):
						blocks[i][j] = AttributeManager.get_block_id("SAND")
		for i in range(16):
			for j in range(15,0,-1):
				var is_planted = false
				if blocks[j][i] == AttributeManager.get_block_id("SAND") and blocks[j-1][i] == AttributeManager.get_block_id("AIR"):
					var rng = RandomNumberGenerator.new()
					rng.seed = int(str(seed%12419)+str(chunk_coordinate[0])+str(i))
					var num = rng.randf()
					if num > 0.95:
						if trees.has(Vector2i(i, j)):
							trees.erase(Vector2i(i, j))
						is_planted = true
						for k in range(3):
							if j-1-k >= 0 and blocks[j-1-k][i] == AttributeManager.get_block_id("AIR"):
								blocks[j-1-k][i] = AttributeManager.get_block_id("REEDS")
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
						#if blocks[depth][cave[0]+i-num/2] == AttributeManager.get_block_id("GRASS_BLOCK") or blocks[depth][cave[0]+i-num/2] == AttributeManager.get_block_id("DIRT"):
							#blocks[depth][cave[0]+i-num/2] = AttributeManager.get_block_id("AIR")
							#if trees.has(Vector2i(depth, cave[0]+i-num/2)):
								#trees.erase(Vector2i(depth, cave[0]+i-num/2))
					#else:
						#if blocks[depth][cave[0]+i-num/2] == AttributeManager.get_block_id("GRASS_BLOCK") or blocks[depth][cave[0]+i-num/2] == AttributeManager.get_block_id("DIRT"):
							#blocks[depth][cave[0]-i+num/2] = AttributeManager.get_block_id("AIR")
							#if trees.has(Vector2i(depth, cave[0]-i-num/2)):
								#trees.erase(Vector2i(depth, cave[0]-i-num/2))
		for tree in trees:
			for i in range(3):
				no_reach_blocks[tree[1]-i][tree[0]] = AttributeManager.get_block_id("LOG_OAK")
			for j in range(-2,3):
				if no_reach_blocks[tree[1]-3][tree[0]+j] == AttributeManager.get_block_id("LOG_OAK"):
					continue
				no_reach_blocks[tree[1]-3][tree[0]+j] = AttributeManager.get_block_id("LEAVES")
				if blocks[tree[1]-3][tree[0]+j] == AttributeManager.get_block_id("REEDS"):
					blocks[tree[1]-3][tree[0]+j] = AttributeManager.get_block_id("AIR")
			for j in range(-1,2):
				if no_reach_blocks[tree[1]-4][tree[0]+j] == AttributeManager.get_block_id("LOG_OAK"):
					continue
				no_reach_blocks[tree[1]-4][tree[0]+j] = AttributeManager.get_block_id("LEAVES")
				if blocks[tree[1]-4][tree[0]+j] == AttributeManager.get_block_id("REEDS"):
					blocks[tree[1]-4][tree[0]+j] = AttributeManager.get_block_id("AIR")
	return [blocks, no_reach_blocks, back_blocks]
