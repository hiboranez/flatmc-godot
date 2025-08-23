class_name WorldTransformer

static func block_position_to_id(block_position: Vector2, block_layer: int) -> int:
	if not ClientManager.check_connections():
		return 0
	return get_block_id(get_atlas_coordinate(get_block_coordinate(block_position), block_layer))

static func block_coordinate_to_id(block_coordinate: Vector2, block_layer: int) -> int:
	if not ClientManager.check_connections():
		return 0
	return get_block_id(get_atlas_coordinate(block_coordinate, block_layer))

static func screen_position_to_world_position(camera: Camera2D, screen_position: Vector2):
	var inv_canv_tfm: Transform2D = camera.get_canvas_transform().affine_inverse()
	var half_screen: Transform2D = Transform2D().translated(screen_position)
	var actual_screen_center_pos: Vector2 = inv_canv_tfm * half_screen * Vector2(0, 0)
	return actual_screen_center_pos

static func get_restricted_block_selection_position(target_position: Vector2) -> Vector2:
	if not ClientManager.check_connections():
		return Vector2(0, 0)
	var mouse_in_world_position = target_position
	var player_head_position = ClientManager.local_player.position - Vector2(0, 60)
	var player_center_position = ClientManager.local_player.position - Vector2(0, 24)
	var relative_to_player_position = mouse_in_world_position - player_head_position
	#local_player.sight_line.set_point_position(1, relative_to_player_position)
	var stride = 5
	var length = relative_to_player_position.length()
	var freq = stride / length
	var cycle_num = int(1 / freq)
	var orthogonal_relative_to_player_position = relative_to_player_position.orthogonal().normalized()*5
	for i in range(cycle_num):
		var pos_tmp1 = player_head_position.lerp(mouse_in_world_position, i*freq)
		var pos_tmp2 = pos_tmp1+orthogonal_relative_to_player_position
		var pos_tmp3 = pos_tmp1-orthogonal_relative_to_player_position
		for pos_tmp in [pos_tmp1, pos_tmp2, pos_tmp3]:
			var block_id = block_position_to_id(pos_tmp, BlockLayer.SUBSTANTIAL)
			if block_id != 0 and not StaticLoad.get_is_untouchable_by_id(block_id):
				return pos_tmp
			if player_center_position.distance_to(pos_tmp) > 250:
				return pos_tmp
	return mouse_in_world_position

static func get_block_coordinate(block_position: Vector2) -> Vector2i:
	if not ClientManager.check_connections():
		return Vector2i(0, 0)
	return ClientManager.substantial_layer.local_to_map(block_position)

static func get_chunk_coordinate(block_coordinate: Vector2i) -> Vector2i:
	var block_coordinate_tmp = Vector2i(block_coordinate)
	if block_coordinate[0] < 0:
		block_coordinate_tmp[0] += 1
	if block_coordinate[1] < 0:
		block_coordinate_tmp[1] += 1
	@warning_ignore("integer_division")
	var x_chunk = block_coordinate_tmp[0]/16
	@warning_ignore("integer_division")
	var y_chunk = block_coordinate_tmp[1]/16
	if block_coordinate[0] < 0:
		x_chunk -= 1
	if block_coordinate[1] < 0:
		y_chunk -= 1
	return Vector2i(x_chunk, y_chunk)

static func get_atlas_coordinate(block_coordinate: Vector2i, block_layer: int) -> Vector2i:
	if not ClientManager.check_connections():
		return Vector2i(-1, -1)
	var atlas_coordinate = Vector2i(-1, -1)
	if block_layer == BlockLayer.MIDDLE:
		atlas_coordinate = ClientManager.substantial_layer.get_cell_atlas_coords(block_coordinate)
		if get_block_id(atlas_coordinate) == 0:
			atlas_coordinate = ClientManager.insubstantial_layer.get_cell_atlas_coords(block_coordinate)
	elif block_layer == BlockLayer.BACK:
		atlas_coordinate = ClientManager.background_layer.get_cell_atlas_coords(block_coordinate)
	elif block_layer == BlockLayer.SUBSTANTIAL:
		atlas_coordinate = ClientManager.substantial_layer.get_cell_atlas_coords(block_coordinate)
	elif block_layer == BlockLayer.INSUBSTANTIAL:
		atlas_coordinate = ClientManager.insubstantial_layer.get_cell_atlas_coords(block_coordinate)
	return atlas_coordinate

static func get_block_id(atlas_coordinate: Vector2i):
	if atlas_coordinate[0] == -1:
		return 0
	return atlas_coordinate[1]*10+atlas_coordinate[0]+1
