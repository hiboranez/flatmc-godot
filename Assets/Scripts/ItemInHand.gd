extends Node3D

func set_item_in_hand(got_item_name, is_update_player_inventory):
	if StaticLoad.get_item_model_type_by_name(got_item_name) == 0:
		get_node("Item").visible = false
		get_node("ItemTop").visible = false
		get_node("Tool").visible = false
		get_node("Bow").visible = false
		get_node("Block").visible = false
		if is_update_player_inventory:
			ActionManager.execute_action("inventory_creative_ui", "update_handheld_item_visible", {
				"Item": false,
				"ItemTop": false,
				"Tool": false,
				"Bow": false,
				"Block": false
			})
	elif StaticLoad.get_item_model_type_by_name(got_item_name) == 1:
		if got_item_name.contains("SPAWN_EGG"):
			var item_mesh = get_node("Item/Mesh")
			var item_material = load("res://assets/materials/ItemModel.tres").duplicate(true)
			var item_texture = load("res://assets/ResourcePacks/"+SettingsManager.get_current_setting("resource_pack")+"/Items/spawn_egg.png")
			item_material.albedo_texture = item_texture
			item_mesh.mesh.surface_set_material(0, item_material)
			if is_update_player_inventory:
				ActionManager.execute_action("inventory_creative_ui", "set_mesh_surface_material", {
					"mesh": "item",
					"surface_material": item_material
				})
			var item_top_mesh = get_node("ItemTop/Mesh")
			var item_top_material = load("res://assets/materials/ItemModel.tres").duplicate(true)
			var item_top_texture = load("res://assets/ResourcePacks/"+SettingsManager.get_current_setting("resource_pack")+"/Items/spawn_egg_overlay.png")
			item_top_material.albedo_texture = item_top_texture
			item_top_mesh.mesh.surface_set_material(0, item_top_material)
			if is_update_player_inventory:
				ActionManager.execute_action("inventory_creative_ui", "set_mesh_surface_material", {
					"mesh": "item_top",
					"surface_material": item_top_material
				})
			if StaticLoad.spawn_egg_colors.has(got_item_name):
				var color_info = StaticLoad.spawn_egg_colors[got_item_name]
				item_material.albedo_color = Color.html(color_info[0])
				item_top_material.albedo_color = Color.html(color_info[1])
			get_node("Item").visible = true
			get_node("ItemTop").visible = true
			get_node("Tool").visible = false
			get_node("Bow").visible = false
			get_node("Block").visible = false
			if is_update_player_inventory:
				ActionManager.execute_action("inventory_creative_ui", "update_handheld_item_visible", {
					"Item": true,
					"ItemTop": true,
					"Tool": false,
					"Bow": false,
					"Block": false
				})
		else:
			var item_mesh = get_node("Item/Mesh")
			var item_material = load("res://assets/materials/ItemModel.tres").duplicate(true)
			var item_texture = load("res://assets/ResourcePacks/"+SettingsManager.get_current_setting("resource_pack")+"/Items/"+got_item_name.to_lower()+".png")
			if item_texture == null:
				item_texture = load("res://assets/ResourcePacks/"+SettingsManager.get_current_setting("resource_pack")+"/Items/missing_texture.png")
			item_material.albedo_texture = item_texture
			item_mesh.mesh.surface_set_material(0, item_material)
			if is_update_player_inventory:
				ActionManager.execute_action("inventory_creative_ui", "set_mesh_surface_material", {
					"mesh": "item",
					"surface_material": item_material
				})
			get_node("Item").visible = true
			get_node("ItemTop").visible = false
			get_node("Tool").visible = false
			get_node("Bow").visible = false
			get_node("Block").visible = false
			if is_update_player_inventory:
				ActionManager.execute_action("inventory_creative_ui", "update_handheld_item_visible", {
				"Item": true,
				"ItemTop": false,
				"Tool": false,
				"Bow": false,
				"Block": false
			})
	elif StaticLoad.get_item_model_type_by_name(got_item_name) == 2:
		var tool_mesh = get_node("Tool/Mesh")
		if got_item_name.contains("BOW"):
			tool_mesh = get_node("Bow/Mesh")
		var tool_material = load("res://assets/materials/ToolModel.tres").duplicate(true)
		var tool_texture = load("res://assets/ResourcePacks/"+SettingsManager.get_current_setting("resource_pack")+"/Items/"+got_item_name.to_lower()+".png")
		if tool_texture == null:
			tool_texture = load("res://assets/ResourcePacks/"+SettingsManager.get_current_setting("resource_pack")+"/Items/missing_texture.png")
		tool_material.albedo_texture = tool_texture
		tool_mesh.mesh.surface_set_material(0, tool_material)
		if is_update_player_inventory:
			ActionManager.execute_action("inventory_creative_ui", "set_mesh_surface_material", {
				"mesh": "tool",
				"surface_material": tool_material
			})
		get_node("Item").visible = false
		get_node("ItemTop").visible = false
		if got_item_name.contains("BOW"):
			get_node("Bow").visible = true
			get_node("Tool").visible = false
		else:
			get_node("Bow").visible = false
			get_node("Tool").visible = true
		get_node("Block").visible = false
		if is_update_player_inventory:
			ActionManager.execute_action("inventory_creative_ui", "update_handheld_item_visible", {
				"Item": false,
				"ItemTop": false,
			})
			if got_item_name.contains("BOW"):
				ActionManager.execute_action("inventory_creative_ui", "update_handheld_item_visible", {
					"Bow": true,
					"Tool": false
				})
			else:
				ActionManager.execute_action("inventory_creative_ui", "update_handheld_item_visible", {
					"Bow": false,
					"Tool": true,
				})
			ActionManager.execute_action("inventory_creative_ui", "update_handheld_item_visible", {
				"Block": false
			})
	elif StaticLoad.get_item_model_type_by_name(got_item_name) == 3:
		var block_mesh = get_node("Block/Mesh")
		var block_material = load("res://assets/materials/BlockModel.tres").duplicate(true)
		block_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		var block_texture = load("res://assets/ResourcePacks/"+SettingsManager.get_current_setting("resource_pack")+"/ModelBlocks/"+got_item_name.to_lower()+".png")
		if block_texture == null:
			block_texture = load("res://assets/ResourcePacks/"+SettingsManager.get_current_setting("resource_pack")+"/ModelBlocks/missing_texture.png")
		block_material.albedo_texture = block_texture
		block_mesh.mesh.surface_set_material(0, block_material)
		if is_update_player_inventory:
			ActionManager.execute_action("inventory_creative_ui", "set_mesh_surface_material", {
					"mesh": "block",
					"surface_material": block_material
				})
		get_node("Item").visible = false
		get_node("ItemTop").visible = false
		get_node("Tool").visible = false
		get_node("Bow").visible = false
		get_node("Block").visible = true
		if is_update_player_inventory:
			ActionManager.execute_action("inventory_creative_ui", "update_handheld_item_visible", {
				"Item": false,
				"ItemTop": false,
				"Tool": false,
				"Bow": false,
				"Block": true
			})
