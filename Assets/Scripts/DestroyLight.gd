extends PointLight2D

var block_pos = Vector2i(0, 0)
var sort = 1

func init_light(new_light_name, new_block_pos, new_sort):
	block_pos = new_block_pos
	sort = new_sort
	name = new_light_name
	position = block_pos * 50
	if sort > 0:
		texture = TextureManager.get_block_crack_texture(sort)
	enabled = true

func update_block_pos(got_block_pos):
	block_pos = got_block_pos
	position = block_pos * 50
