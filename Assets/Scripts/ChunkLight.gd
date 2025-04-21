extends PointLight2D

var old_chunk_light = null
var chunk_pos: Vector2i
#var block_r_data: PackedByteArray
#var block_g_data: PackedByteArray
#var block_b_data: PackedByteArray
var block_a_data: PackedByteArray
#var r_data: PackedByteArray
#var g_data: PackedByteArray
#var b_data: PackedByteArray
#var a_data: PackedByteArray
var light_data: PackedByteArray

func init(update_neighbour_state):
	position = Vector2i(chunk_pos[0]*800, chunk_pos[1]*800)
	update_light_data()
	update_texture(update_neighbour_state)
	StaticLoad.game.chunk_lights[str(chunk_pos[0])+"."+str(chunk_pos[1])] = self
	if old_chunk_light != null:
		old_chunk_light.enabled = false
		old_chunk_light.queue_free()
	StaticLoad.game.chunk_light_updated_signal.emit()

func update_texture_from_image(light_image):
	position = Vector2i(chunk_pos[0]*800, chunk_pos[1]*800)
	texture = ImageTexture.create_from_image(light_image)
	enabled = true

func destroy():
	var chunk_name = str(chunk_pos[0])+"."+str(chunk_pos[1])
	if StaticLoad.game.chunk_lights.has(chunk_name):
		StaticLoad.game.chunk_lights.erase(chunk_name)
		StaticLoad.game.chunk_light_datas.erase(chunk_name)
	queue_free()

func refresh():
	var chunk_light_name = str(chunk_pos[0])+"."+str(chunk_pos[1])
	if not StaticLoad.game.chunk_lights.has(chunk_light_name):
		return
	update_game_chunk_light_data_without_influence(false)
	if StaticLoad.game.chunk_lights.has(str(chunk_pos[0])+"."+str(chunk_pos[1]-1)):
		StaticLoad.game.chunk_lights[str(chunk_pos[0])+"."+str(chunk_pos[1]-1)].update_game_chunk_light_data_without_influence(true)
	if StaticLoad.game.chunk_lights.has(str(chunk_pos[0])+"."+str(chunk_pos[1]+1)):
		StaticLoad.game.chunk_lights[str(chunk_pos[0])+"."+str(chunk_pos[1]+1)].update_game_chunk_light_data_without_influence(true)
	if StaticLoad.game.chunk_lights.has(str(chunk_pos[0]-1)+"."+str(chunk_pos[1])):
		StaticLoad.game.chunk_lights[str(chunk_pos[0]-1)+"."+str(chunk_pos[1])].update_game_chunk_light_data_without_influence(true)
	if StaticLoad.game.chunk_lights.has(str(chunk_pos[0]+1)+"."+str(chunk_pos[1])):
		StaticLoad.game.chunk_lights[str(chunk_pos[0]+1)+"."+str(chunk_pos[1])].update_game_chunk_light_data_without_influence(true)

func update_game_chunk_light_data_without_influence(is_update_sky_light):
	var block_a_data_tmp: PackedByteArray
	block_a_data_tmp.resize(16*16)
	block_a_data_tmp.fill(0)
	var chunk_light_name = str(chunk_pos[0])+"."+str(chunk_pos[1])
	if StaticLoad.game.loaded_chunk_packed_byte_arrays.has(chunk_light_name) and StaticLoad.game.chunk_sky_light_datas.has(chunk_light_name):
		if is_update_sky_light:
			block_a_data_tmp = GameCalculator.spread_sky_light(block_a_data_tmp, StaticLoad.game.loaded_chunk_packed_byte_arrays[chunk_light_name], StaticLoad.game.chunk_sky_light_datas[chunk_light_name], StaticLoad.transparent_block_ids)
	for y in range(16):
		for x in range(16):
			var block_id = StaticLoad.get_block_id_by_atlas_coords(StaticLoad.game.tile_map_layer.get_cell_atlas_coords(Vector2i(chunk_pos[0]*16+x, chunk_pos[1]*16+y)))
			var color_info = StaticLoad.get_light_color_by_id(block_id)
			if color_info[0]:
				#block_r_data.set(y*16+x, color_info[1].r8)
				#block_g_data.set(y*16+x, color_info[1].g8)
				#block_b_data.set(y*16+x, color_info[1].b8)
				block_a_data_tmp.set(y*16+x, 255)
	#if without_whom is Vector2i:
		## 更新上部临近区块
		#if not str(chunk_pos[0])+"."+str(chunk_pos[1]-1) == str(without_whom[0])+"."+str(without_whom[1]):
			#if StaticLoad.game.chunk_lights.has(str(chunk_pos[0])+"."+str(chunk_pos[1]-1)):
				#var neighbour_light_data: PackedByteArray
				#var neighbour_chunk_light = StaticLoad.game.chunk_light_datas[str(chunk_pos[0])+"."+str(chunk_pos[1]-1)]
				#for i in range(16):
					#neighbour_light_data.append(neighbour_chunk_light[240+i])
				#for i in range(16):
					#if neighbour_light_data[i] > 0:
						#var block_id = StaticLoad.get_block_id_by_atlas_coords(StaticLoad.game.tile_map_layer.get_cell_atlas_coords(Vector2i(chunk_pos[0]*16+i, chunk_pos[1]*16)))
						#if block_id != 0:
							#var new_light = neighbour_light_data[i]-48
							#if new_light < 0:
								#new_light = 0
							#if block_a_data_tmp[i] < new_light:
								#block_a_data_tmp.set(i, new_light)
						#else:
							#var new_light = neighbour_light_data[i]-16
							#if new_light < 0:
								#new_light = 0
							#if block_a_data_tmp[i] < new_light:
								#block_a_data_tmp.set(i, new_light)
		## 更新下部临近区块
		#if not str(chunk_pos[0])+"."+str(chunk_pos[1]+1) == str(without_whom[0])+"."+str(without_whom[1]):
			#if StaticLoad.game.chunk_lights.has(str(chunk_pos[0])+"."+str(chunk_pos[1]+1)):
				#var neighbour_light_data: PackedByteArray
				#var neighbour_chunk_light = StaticLoad.game.chunk_light_datas[str(chunk_pos[0])+"."+str(chunk_pos[1]+1)]
				#for i in range(16):
					#neighbour_light_data.append(neighbour_chunk_light[i])
				#for i in range(16):
					#if neighbour_light_data[i] > 0:
						#var block_id = StaticLoad.get_block_id_by_atlas_coords(StaticLoad.game.tile_map_layer.get_cell_atlas_coords(Vector2i(chunk_pos[0]*16+i, chunk_pos[1]*16+15)))
						#if block_id != 0:
							#var new_light = neighbour_light_data[i]-48
							#if new_light < 0:
								#new_light = 0
							#if block_a_data_tmp[240+i] < new_light:
								#block_a_data_tmp.set(240+i, new_light)
						#else:
							#var new_light = neighbour_light_data[i]-16
							#if new_light < 0:
								#new_light = 0
							#if block_a_data_tmp[240+i] < new_light:
								#block_a_data_tmp.set(240+i, new_light)
		## 更新左部临近区块
		#if not str(chunk_pos[0]-1)+"."+str(chunk_pos[1]) == str(without_whom[0])+"."+str(without_whom[1]):
			#if StaticLoad.game.chunk_lights.has(str(chunk_pos[0]-1)+"."+str(chunk_pos[1])):
				#var neighbour_light_data: PackedByteArray
				#var neighbour_chunk_light = StaticLoad.game.chunk_light_datas[str(chunk_pos[0]-1)+"."+str(chunk_pos[1])]
				#for i in range(16):
					#neighbour_light_data.append(neighbour_chunk_light[i*16+15])
				#for i in range(16):
					#if neighbour_light_data[i] > 0:
						#var block_id = StaticLoad.get_block_id_by_atlas_coords(StaticLoad.game.tile_map_layer.get_cell_atlas_coords(Vector2i(chunk_pos[0]*16, chunk_pos[1]*16+i)))
						#if block_id != 0:
							#var new_light = neighbour_light_data[i]-48
							#if new_light < 0:
								#new_light = 0
							#if block_a_data_tmp[i*16] < new_light:
								#block_a_data_tmp.set(i*16, new_light)
						#else:
							#var new_light = neighbour_light_data[i]-16
							#if new_light < 0:
								#new_light = 0
							#if block_a_data_tmp[i*16] < new_light:
								#block_a_data_tmp.set(i*16, new_light)
		## 更新右部临近区块
		#if not str(chunk_pos[0]+1)+"."+str(chunk_pos[1]) == str(without_whom[0])+"."+str(without_whom[1]):
			#if StaticLoad.game.chunk_lights.has(str(chunk_pos[0]+1)+"."+str(chunk_pos[1])):
				#var neighbour_light_data: PackedByteArray
				#var neighbour_chunk_light = StaticLoad.game.chunk_light_datas[str(chunk_pos[0]+1)+"."+str(chunk_pos[1])]
				#for i in range(16):
					#neighbour_light_data.append(neighbour_chunk_light[i*16])
				#for i in range(16):
					#if neighbour_light_data[i] > 0:
						#var block_id = StaticLoad.get_block_id_by_atlas_coords(StaticLoad.game.tile_map_layer.get_cell_atlas_coords(Vector2i(chunk_pos[0]*16+15, chunk_pos[1]*16+i)))
						#if block_id != 0:
							#var new_light = neighbour_light_data[i]-48
							#if new_light < 0:
								#new_light = 0
							#if block_a_data_tmp[i*16+15] < new_light:
								#block_a_data_tmp.set(i*16+15, new_light)
						#else:
							#var new_light = neighbour_light_data[i]-16
							#if new_light < 0:
								#new_light = 0
							#if block_a_data_tmp[i*16+15] < new_light:
								#block_a_data_tmp.set(i*16+15, new_light)
	if not StaticLoad.game.chunk_lights.has(chunk_light_name):
		return
	if not StaticLoad.game.loaded_chunk_packed_byte_arrays.has(chunk_light_name):
		var chunk_packed_byte_array: PackedByteArray
		chunk_packed_byte_array.resize(256)
		chunk_packed_byte_array.fill(0)
		StaticLoad.game.loaded_chunk_packed_byte_arrays[chunk_light_name] = chunk_packed_byte_array
	block_a_data_tmp = GameCalculator.spread_normal_light(block_a_data_tmp, StaticLoad.game.loaded_chunk_packed_byte_arrays[str(chunk_pos[0])+"."+str(chunk_pos[1])], StaticLoad.transparent_block_ids)
	block_a_data_tmp = GameCalculator.spread_normal_light(block_a_data_tmp, StaticLoad.game.loaded_chunk_packed_byte_arrays[str(chunk_pos[0])+"."+str(chunk_pos[1])], StaticLoad.transparent_block_ids)
	StaticLoad.game.chunk_light_datas[str(chunk_pos[0])+"."+str(chunk_pos[1])] = block_a_data_tmp

func update_chunk_light(chunk_pos_tmp, update_neighbour_state):
	var chunk_light_name = str(chunk_pos_tmp[0])+"."+str(chunk_pos_tmp[1])
	if not StaticLoad.game.chunk_lights.has(chunk_light_name):
		return
	if update_neighbour_state.contains("update"):
		StaticLoad.game.chunk_lights[chunk_light_name].refresh()
	await get_tree().process_frame
	var chunk_light = StaticLoad.game.chunk_light_scene.instantiate()
	if StaticLoad.game.chunk_lights.has(chunk_light_name):
		chunk_light.old_chunk_light = StaticLoad.game.chunk_lights[chunk_light_name]
	chunk_light.chunk_pos = Vector2i(chunk_pos_tmp[0], chunk_pos_tmp[1])
	StaticLoad.game.lights.add_child(chunk_light)
	chunk_light.name = chunk_light_name.replace(".", "_")
	chunk_light.init(update_neighbour_state)

func update_light_data():
	#block_r_data.resize(16*16)
	#block_r_data.fill(255)
	#block_g_data.resize(16*16)
	#block_g_data.fill(255)
	#block_b_data.resize(16*16)
	#block_b_data.fill(255)
	block_a_data.resize(16*16)
	block_a_data.fill(0)
	var chunk_light_name = str(chunk_pos[0])+"."+str(chunk_pos[1])
	if StaticLoad.game.loaded_chunk_packed_byte_arrays.has(chunk_light_name) and StaticLoad.game.chunk_sky_light_datas.has(chunk_light_name):
		block_a_data = GameCalculator.spread_sky_light(block_a_data, StaticLoad.game.loaded_chunk_packed_byte_arrays[chunk_light_name], StaticLoad.game.chunk_sky_light_datas[chunk_light_name], StaticLoad.transparent_block_ids)
	for y in range(16):
		for x in range(16):
			var block_id = StaticLoad.get_block_id_by_atlas_coords(StaticLoad.game.tile_map_layer.get_cell_atlas_coords(Vector2i(chunk_pos[0]*16+x, chunk_pos[1]*16+y)))
			var color_info = StaticLoad.get_light_color_by_id(block_id)
			if color_info[0]:
				#block_r_data.set(y*16+x, color_info[1].r8)
				#block_g_data.set(y*16+x, color_info[1].g8)
				#block_b_data.set(y*16+x, color_info[1].b8)
				block_a_data.set(y*16+x, 255)
	# 更新上部临近区块
	if StaticLoad.game.chunk_lights.has(str(chunk_pos[0])+"."+str(chunk_pos[1]-1)):
		var neighbour_light_data: PackedByteArray
		var neighbour_chunk_light = StaticLoad.game.chunk_light_datas[str(chunk_pos[0])+"."+str(chunk_pos[1]-1)]
		for i in range(16):
			neighbour_light_data.append(neighbour_chunk_light[240+i])
		for i in range(16):
			if neighbour_light_data[i] > 0:
				var block_id = StaticLoad.get_block_id_by_atlas_coords(StaticLoad.game.tile_map_layer.get_cell_atlas_coords(Vector2i(chunk_pos[0]*16+i, chunk_pos[1]*16)))
				if block_id != 0:
					var new_light = neighbour_light_data[i]-48
					if new_light < 0:
						new_light = 0
					if block_a_data[i] < new_light:
						block_a_data.set(i, new_light)
				else:
					var new_light = neighbour_light_data[i]-16
					if new_light < 0:
						new_light = 0
					if block_a_data[i] < new_light:
						block_a_data.set(i, new_light)
	# 更新下部临近区块
	if StaticLoad.game.chunk_lights.has(str(chunk_pos[0])+"."+str(chunk_pos[1]+1)):
		var neighbour_light_data: PackedByteArray
		var neighbour_chunk_light = StaticLoad.game.chunk_light_datas[str(chunk_pos[0])+"."+str(chunk_pos[1]+1)]
		for i in range(16):
			neighbour_light_data.append(neighbour_chunk_light[i])
		for i in range(16):
			if neighbour_light_data[i] > 0:
				var block_id = StaticLoad.get_block_id_by_atlas_coords(StaticLoad.game.tile_map_layer.get_cell_atlas_coords(Vector2i(chunk_pos[0]*16+i, chunk_pos[1]*16+15)))
				if block_id != 0:
					var new_light = neighbour_light_data[i]-48
					if new_light < 0:
						new_light = 0
					if block_a_data[240+i] < new_light:
						block_a_data.set(240+i, new_light)
				else:
					var new_light = neighbour_light_data[i]-16
					if new_light < 0:
						new_light = 0
					if block_a_data[240+i] < new_light:
						block_a_data.set(240+i, new_light)
	# 更新左部临近区块
	if StaticLoad.game.chunk_lights.has(str(chunk_pos[0]-1)+"."+str(chunk_pos[1])):
		var neighbour_light_data: PackedByteArray
		var neighbour_chunk_light = StaticLoad.game.chunk_light_datas[str(chunk_pos[0]-1)+"."+str(chunk_pos[1])]
		for i in range(16):
			neighbour_light_data.append(neighbour_chunk_light[i*16+15])
		for i in range(16):
			if neighbour_light_data[i] > 0:
				var block_id = StaticLoad.get_block_id_by_atlas_coords(StaticLoad.game.tile_map_layer.get_cell_atlas_coords(Vector2i(chunk_pos[0]*16, chunk_pos[1]*16+i)))
				if block_id != 0:
					var new_light = neighbour_light_data[i]-48
					if new_light < 0:
						new_light = 0
					if block_a_data[i*16] < new_light:
						block_a_data.set(i*16, new_light)
				else:
					var new_light = neighbour_light_data[i]-16
					if new_light < 0:
						new_light = 0
					if block_a_data[i*16] < new_light:
						block_a_data.set(i*16, new_light)
	# 更新右部临近区块
	if StaticLoad.game.chunk_lights.has(str(chunk_pos[0]+1)+"."+str(chunk_pos[1])):
		var neighbour_light_data: PackedByteArray
		var neighbour_chunk_light = StaticLoad.game.chunk_light_datas[str(chunk_pos[0]+1)+"."+str(chunk_pos[1])]
		for i in range(16):
			neighbour_light_data.append(neighbour_chunk_light[i*16])
		for i in range(16):
			if neighbour_light_data[i] > 0:
				var block_id = StaticLoad.get_block_id_by_atlas_coords(StaticLoad.game.tile_map_layer.get_cell_atlas_coords(Vector2i(chunk_pos[0]*16+15, chunk_pos[1]*16+i)))
				if block_id != 0:
					var new_light = neighbour_light_data[i]-48
					if new_light < 0:
						new_light = 0
					if block_a_data[i*16+15] < new_light:
						block_a_data.set(i*16+15, new_light)
				else:
					var new_light = neighbour_light_data[i]-16
					if new_light < 0:
						new_light = 0
					if block_a_data[i*16+15] < new_light:
						block_a_data.set(i*16+15, new_light)
	if StaticLoad.game.loaded_chunk_packed_byte_arrays.has(chunk_light_name):
		block_a_data = GameCalculator.spread_normal_light(block_a_data, StaticLoad.game.loaded_chunk_packed_byte_arrays[chunk_light_name], StaticLoad.transparent_block_ids)
		block_a_data = GameCalculator.spread_normal_light(block_a_data, StaticLoad.game.loaded_chunk_packed_byte_arrays[chunk_light_name], StaticLoad.transparent_block_ids)
	#print(chunk_pos)
	#for y in range(16):
		#print(block_a_data.slice(y*16, y*16+16))
	#print()
	#r_data.resize(800*800)
	#r_data.fill(255)
	#g_data.resize(800*800)
	#g_data.fill(255)
	#b_data.resize(800*800)
	#b_data.fill(255)
	#a_data.resize(800*800)
	#a_data.fill(0)
	#for y in range(800):
		#for x in range(800):
			#r_data.set(y*800+x, block_r_data[((y-1)/50)*16+(x-1)/50])
			#g_data.set(y*800+x, block_g_data[((y-1)/50)*16+(x-1)/50])
			#b_data.set(y*800+x, block_b_data[((y-1)/50)*16+(x-1)/50])
			#a_data.set(y*800+x, block_a_data[((y-1)/50)*16+(x-1)/50])

func update_texture(update_neighbour_state):
	light_data = block_a_data.duplicate()
	#light_data.resize(0)
	#for i in range(800):
		#for j in range(800):
			#light_data.append(r_data[i*800+j])
			#light_data.append(g_data[i*800+j])
			#light_data.append(b_data[i*800+j])
			#light_data.append(a_data[i*800+j])
	var light_image = Image.create_from_data(16, 16, false, Image.FORMAT_L8, light_data)
	texture = ImageTexture.create_from_image(light_image)
	enabled = true
	StaticLoad.game.update_mini_map_chunk_light(chunk_pos, light_image)
	var chunk_light_name = str(chunk_pos[0])+"."+str(chunk_pos[1])
	if StaticLoad.game.loaded_chunk_packed_byte_arrays.has(chunk_light_name):
		var next_chunk_sky_light_datas = GameCalculator.get_final_sky_light_data(StaticLoad.game.loaded_chunk_packed_byte_arrays[chunk_light_name], StaticLoad.game.chunk_sky_light_datas[chunk_light_name], StaticLoad.transparent_block_ids)
		var is_should_update_next_chunk_light = false
		if StaticLoad.game.chunk_sky_light_datas.has(str(chunk_pos[0])+"."+str(chunk_pos[1]+1)):
			var old_next_chunk_sky_light_data = StaticLoad.game.chunk_sky_light_datas[str(chunk_pos[0])+"."+str(chunk_pos[1]+1)]
			for i in range(16):
				if old_next_chunk_sky_light_data[i] != next_chunk_sky_light_datas[i]:
					is_should_update_next_chunk_light = true
					break
		StaticLoad.game.chunk_sky_light_datas[str(chunk_pos[0])+"."+str(chunk_pos[1]+1)] = next_chunk_sky_light_datas
		if is_should_update_next_chunk_light:
			update_chunk_light(Vector2i(chunk_pos[0], chunk_pos[1]+1), "null")
	
	if update_neighbour_state.contains("update"):
		if StaticLoad.game.chunk_lights.has(str(chunk_pos[0])+"."+str(chunk_pos[1]-1)):
			update_chunk_light(Vector2i(chunk_pos[0], chunk_pos[1]-1), "null")
		if StaticLoad.game.chunk_lights.has(str(chunk_pos[0])+"."+str(chunk_pos[1]+1)):
			update_chunk_light(Vector2i(chunk_pos[0], chunk_pos[1]+1), "null")
		if StaticLoad.game.chunk_lights.has(str(chunk_pos[0]-1)+"."+str(chunk_pos[1])):
			update_chunk_light(Vector2i(chunk_pos[0]-1, chunk_pos[1]), "null")
		if StaticLoad.game.chunk_lights.has(str(chunk_pos[0]+1)+"."+str(chunk_pos[1])):
			update_chunk_light(Vector2i(chunk_pos[0]+1, chunk_pos[1]), "null")
		#var wait_timer = 0
		#while wait_timer < 0.01:
			#wait_timer += get_process_delta_time()
		if StaticLoad.game.chunk_lights.has(str(chunk_pos[0]+1)+"."+str(chunk_pos[1]+1)):
			update_chunk_light(Vector2i(chunk_pos[0]+1, chunk_pos[1]+1), "null")
		if StaticLoad.game.chunk_lights.has(str(chunk_pos[0]+1)+"."+str(chunk_pos[1]-1)):
			update_chunk_light(Vector2i(chunk_pos[0]+1, chunk_pos[1]-1), "null")
		if StaticLoad.game.chunk_lights.has(str(chunk_pos[0]-1)+"."+str(chunk_pos[1]+1)):
			update_chunk_light(Vector2i(chunk_pos[0]-1, chunk_pos[1]+1), "null")
		if StaticLoad.game.chunk_lights.has(str(chunk_pos[0]-1)+"."+str(chunk_pos[1]-1)):
			update_chunk_light(Vector2i(chunk_pos[0]-1, chunk_pos[1]-1), "null")
		
	StaticLoad.game.chunk_light_datas[str(chunk_pos[0])+"."+str(chunk_pos[1])] = light_data.duplicate()

func spread_vertical_light(block_a_data_tmp):
	var light_pos_list = []
	for y in range(16):
		for x in range(16):
			if block_a_data_tmp[y*16+x] > 0:
				light_pos_list.append(Vector2i(x, y))
	for light_pos in light_pos_list:
		# 向上传播
		for i in range(light_pos[1]):
			var y_tmp = light_pos[1]-i-1
			var block_id = StaticLoad.get_block_id_by_atlas_coords(StaticLoad.game.tile_map_layer.get_cell_atlas_coords(Vector2i(chunk_pos[0]*16+light_pos[0], chunk_pos[1]*16+y_tmp)))
			if block_id != 0:
				var new_light = block_a_data_tmp[(y_tmp+1)*16+light_pos[0]]-48
				if new_light < 0:
					new_light = 0
				if block_a_data_tmp[y_tmp*16+light_pos[0]] < new_light:
					block_a_data_tmp.set(y_tmp*16+light_pos[0], new_light)
			else:
				var new_light = block_a_data_tmp[(y_tmp+1)*16+light_pos[0]]-16
				if new_light < 0:
					new_light = 0
				if block_a_data_tmp[y_tmp*16+light_pos[0]] < new_light:
					block_a_data_tmp.set(y_tmp*16+light_pos[0], new_light)
			#var color_last_pos = Color(block_r_data[(y_tmp+1)*16+light_pos[0]]/255.0, block_g_data[(y_tmp+1)*16+light_pos[0]]/255.0, block_b_data[(y_tmp+1)*16+light_pos[0]]/255.0)
			#var color_current_pos = Color(block_r_data[y_tmp*16+light_pos[0]]/255.0, block_g_data[y_tmp*16+light_pos[0]]/255.0, block_b_data[y_tmp*16+light_pos[0]]/255.0)
			#var blended_color = color_current_pos.blend(color_last_pos)
			#block_r_data[y_tmp*16+light_pos[0]] = blended_color.r8
			#block_g_data[y_tmp*16+light_pos[0]] = blended_color.g8
			#block_b_data[y_tmp*16+light_pos[0]] = blended_color.b8
		# 向下传播
		for i in range(light_pos[1]+1, 16):
			var y_tmp = i
			var block_id = StaticLoad.get_block_id_by_atlas_coords(StaticLoad.game.tile_map_layer.get_cell_atlas_coords(Vector2i(chunk_pos[0]*16+light_pos[0], chunk_pos[1]*16+y_tmp)))
			if block_id != 0:
				var new_light = block_a_data_tmp[(y_tmp-1)*16+light_pos[0]]-48
				if new_light < 0:
					new_light = 0
				if block_a_data_tmp[y_tmp*16+light_pos[0]] < new_light:
					block_a_data_tmp.set(y_tmp*16+light_pos[0], new_light)
			else:
				var new_light = block_a_data_tmp[(y_tmp-1)*16+light_pos[0]]-16
				if new_light < 0:
					new_light = 0
				if block_a_data_tmp[y_tmp*16+light_pos[0]] < new_light:
					block_a_data_tmp.set(y_tmp*16+light_pos[0], new_light)
			#var color_last_pos = Color(block_r_data[(y_tmp-1)*16+light_pos[0]]/255.0, block_g_data[(y_tmp-1)*16+light_pos[0]]/255.0, block_b_data[(y_tmp-1)*16+light_pos[0]]/255.0)
			#var color_current_pos = Color(block_r_data[y_tmp*16+light_pos[0]]/255.0, block_g_data[y_tmp*16+light_pos[0]]/255.0, block_b_data[y_tmp*16+light_pos[0]]/255.0)
			#var blended_color = color_current_pos.blend(color_last_pos)
			#block_r_data[y_tmp*16+light_pos[0]] = blended_color.r8
			#block_g_data[y_tmp*16+light_pos[0]] = blended_color.g8
			#block_b_data[y_tmp*16+light_pos[0]] = blended_color.b8
				
func spread_horizontal_light(block_a_data_tmp):
	var light_pos_list = []
	for y in range(16):
		for x in range(16):
			if block_a_data_tmp[y*16+x] > 0:
				light_pos_list.append(Vector2i(x, y))
	for light_pos in light_pos_list:
		# 向左传播
		for i in range(light_pos[0]):
			var x_tmp = light_pos[0]-i-1
			var block_id = StaticLoad.get_block_id_by_atlas_coords(StaticLoad.game.tile_map_layer.get_cell_atlas_coords(Vector2i(chunk_pos[0]*16+x_tmp, chunk_pos[1]*16+light_pos[1])))
			if block_id != 0:
				var new_light = block_a_data_tmp[light_pos[1]*16+(x_tmp+1)]-48
				if new_light < 0:
					new_light = 0
				if block_a_data_tmp[light_pos[1]*16+x_tmp] < new_light:
					block_a_data_tmp.set(light_pos[1]*16+x_tmp, new_light)
			else:
				var new_light = block_a_data_tmp[light_pos[1]*16+(x_tmp+1)]-16
				if new_light < 0:
					new_light = 0
				if block_a_data_tmp[light_pos[1]*16+x_tmp] < new_light:
					block_a_data_tmp.set(light_pos[1]*16+x_tmp, new_light)
			#var color_last_pos = Color(block_r_data[light_pos[1]*16+(x_tmp+1)]/255.0, block_g_data[light_pos[1]*16+(x_tmp+1)]/255.0, block_b_data[light_pos[1]*16+(x_tmp+1)]/255.0)
			#var color_current_pos = Color(block_r_data[light_pos[1]*16+x_tmp]/255.0, block_g_data[light_pos[1]*16+x_tmp]/255.0, block_b_data[light_pos[1]*16+x_tmp]/255.0)
			#var blended_color = color_current_pos.blend(color_last_pos)
			#block_r_data[light_pos[1]*16+x_tmp] = blended_color.r8
			#block_g_data[light_pos[1]*16+x_tmp] = blended_color.g8
			#block_b_data[light_pos[1]*16+x_tmp] = blended_color.b8
		# 向右传播
		for i in range(light_pos[0]+1, 16):
			var x_tmp = i
			var block_id = StaticLoad.get_block_id_by_atlas_coords(StaticLoad.game.tile_map_layer.get_cell_atlas_coords(Vector2i(chunk_pos[0]*16+x_tmp, chunk_pos[1]*16+light_pos[1])))
			if block_id != 0:
				var new_light = block_a_data_tmp[light_pos[1]*16+(x_tmp-1)]-48
				if new_light < 0:
					new_light = 0
				if block_a_data_tmp[light_pos[1]*16+x_tmp] < new_light:
					block_a_data_tmp.set(light_pos[1]*16+x_tmp, new_light)
			else:
				var new_light = block_a_data_tmp[light_pos[1]*16+(x_tmp-1)]-16
				if new_light < 0:
					new_light = 0
				if block_a_data_tmp[light_pos[1]*16+x_tmp] < new_light:
					block_a_data_tmp.set(light_pos[1]*16+x_tmp, new_light)
			#var color_last_pos = Color(block_r_data[light_pos[1]*16+(x_tmp-1)]/255.0, block_g_data[light_pos[1]*16+(x_tmp-1)]/255.0, block_b_data[light_pos[1]*16+(x_tmp-1)]/255.0)
			#var color_current_pos = Color(block_r_data[light_pos[1]*16+x_tmp]/255.0, block_g_data[light_pos[1]*16+x_tmp]/255.0, block_b_data[light_pos[1]*16+x_tmp]/255.0)
			#var blended_color = color_current_pos.blend(color_last_pos)
			#block_r_data[light_pos[1]*16+x_tmp] = blended_color.r8
			#block_g_data[light_pos[1]*16+x_tmp] = blended_color.g8
			#block_b_data[light_pos[1]*16+x_tmp] = blended_color.b8
