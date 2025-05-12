extends Control

@onready var directional_light = $SubViewportContainer/SubViewport/DirectionalLight3D
@onready var item = $SubViewportContainer/SubViewport/Item
@onready var item_mesh = $SubViewportContainer/SubViewport/Item/Mesh

func init_icon(block_name):
	$Icon.modulate = Color.WHITE
	$IconTop.modulate = Color.WHITE
	if StaticLoad.get_item_model_type_by_name(block_name.to_upper()) == 1 or StaticLoad.get_item_model_type_by_name(block_name.to_upper()) == 2:
		if block_name.to_upper().contains("SPAWN_EGG"):
			var item_texture = load("res://Assets/ResourcePacks/"+StaticLoad.game.resource_pack+"/Items/spawn_egg.png") as Texture2D
			var item_texture_top = load("res://Assets/ResourcePacks/"+StaticLoad.game.resource_pack+"/Items/spawn_egg_overlay.png") as Texture2D
			$Icon.texture = item_texture
			$IconTop.texture = item_texture_top
			if StaticLoad.spawn_egg_colors.has(block_name.to_upper()):
				var color_info = StaticLoad.spawn_egg_colors[block_name.to_upper()]
				$Icon.modulate = Color.html(color_info[0])
				$IconTop.modulate = Color.html(color_info[1])
			$Icon.visible = true
			$IconTop.visible = true
			$SubViewportContainer.visible = false
		else:
			var item_texture = load("res://Assets/ResourcePacks/"+StaticLoad.game.resource_pack+"/Items/"+block_name.to_lower()+".png") as Texture2D
			if item_texture != null:
				$Icon.texture = item_texture
			$Icon.visible = true
			$IconTop.visible = false
			$SubViewportContainer.visible = false
	elif StaticLoad.get_item_model_type_by_name(block_name.to_upper()) == 3:
		item_mesh.mesh = load("res://Assets/Meshs/BlockMesh.tres").duplicate(true)
		var block_material = load("res://Assets/Materials/BlockModel.tres").duplicate(true)
		var block_texture = load("res://Assets/ResourcePacks/"+StaticLoad.game.resource_pack+"/ModelBlocks/"+block_name.to_lower()+".png")
		if block_texture != null:
			block_material.albedo_texture = block_texture
			item_mesh.mesh.surface_set_material(0, block_material)
		$Icon.visible = false
		$IconTop.visible = false
		$SubViewportContainer.visible = true
	
