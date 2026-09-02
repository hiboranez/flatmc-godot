class_name WorldInspector

static func check_has_nearby_block(block_coordinate: Vector2i, block_layer: int) -> bool:
	var is_attached_block = false
	for i in [1, -1]:
		var nearby_block_coordinate = block_coordinate + Vector2i(i, 0)
		var nearby_chunk_coordinate = WorldTransformer.get_chunk_coordinate(block_coordinate)
		if StaticLoad.game.loaded_chunks.has(str(nearby_chunk_coordinate[0])+"."+str(nearby_chunk_coordinate[1])):
			if WorldTransformer.block_coordinate_to_id(nearby_block_coordinate, block_layer) != 0:
				is_attached_block = true
	for i in [1, -1]:
		var nearby_block_coordinate = block_coordinate + Vector2i(0, i)
		var nearby_chunk_coordinate = WorldTransformer.get_chunk_coordinate(block_coordinate)
		if StaticLoad.game.loaded_chunks.has(str(nearby_chunk_coordinate[0])+"."+str(nearby_chunk_coordinate[1])):
			if WorldTransformer.block_coordinate_to_id(nearby_block_coordinate, block_layer) != 0:
				is_attached_block = true
	return is_attached_block
