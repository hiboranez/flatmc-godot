extends Control

@onready var directional_light = $SubViewportContainer/SubViewport/DirectionalLight3D
@onready var item = $SubViewportContainer/SubViewport/Item
@onready var item_mesh = $SubViewportContainer/SubViewport/Item/Mesh

func init_icon(block_name):
	if StaticLoad.get_item_model_type_by_name(block_name.to_upper()) == 1 or StaticLoad.get_item_model_type_by_name(block_name.to_upper()) == 2:
		var item_texture = load("res://Assets/ResourcePacks/"+StaticLoad.game.resource_pack+"/Items/"+block_name.to_lower()+".png") as Texture2D
		if item_texture != null:
			$Icon.texture = item_texture
		$Icon.visible = true
		$SubViewportContainer.visible = false
	elif StaticLoad.get_item_model_type_by_name(block_name.to_upper()) == 3:
		item_mesh.mesh = load("res://Assets/Meshs/BlockMesh.tres").duplicate(true)
		var block_material = load("res://Assets/Materials/BlockModel.tres").duplicate(true)
		var block_texture = load("res://Assets/ResourcePacks/"+StaticLoad.game.resource_pack+"/ModelBlocks/"+block_name.to_lower()+".png")
		if block_texture != null:
			block_material.albedo_texture = block_texture
			item_mesh.mesh.surface_set_material(0, block_material)
		$Icon.visible = false
		$SubViewportContainer.visible = true
	
