extends PointLight2D

var block_pos = Vector2i(0, 0)
var sort = 1

func init_light(new_light_name, new_block_pos, new_sort):
	block_pos = new_block_pos
	sort = new_sort
	name = new_light_name
	position = block_pos * 50
	if sort > 0:
		texture = StaticLoad.destroy_light_textures[sort]
	enabled = true
