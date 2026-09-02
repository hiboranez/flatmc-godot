extends Node2D

@onready var description = $NinePatchRect/ScrollContainer/VBoxContainer/Description

func init(got_text, got_block_pos):
	if not got_text is String:
		return
	description.text = got_text
	position = StaticLoad.game.tile_map_layer.map_to_local(got_block_pos)+Vector2(0, 25)
