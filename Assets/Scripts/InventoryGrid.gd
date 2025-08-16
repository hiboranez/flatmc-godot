extends TextureRect

@export var slot_function: String

@onready var white_color_rect = $WhiteColorRect

var item_name = "AIR"
var item_amount = 0
var mouse_stay_timer = StaticLoad.INVENTORY_NAME_SHOW_STAY_TIME

func _ready() -> void:
	set_process(false)
	if slot_function == "armor_helmet":
		$BackIcon.texture = TextureManager.get_texture("ui/inventory_helmet_icon")
		$BackIcon.visible = true
		$ItemIcon.visible = false
	elif slot_function == "armor_chestplate":
		$BackIcon.texture = TextureManager.get_texture("ui/inventory_chestplate_icon")
		$BackIcon.visible = true
		$ItemIcon.visible = false
	elif slot_function == "armor_leggings":
		$BackIcon.texture = TextureManager.get_texture("ui/inventory_leggings_icon")
		$BackIcon.visible = true
		$ItemIcon.visible = false
	elif slot_function == "armor_boots":
		$BackIcon.texture = TextureManager.get_texture("ui/inventory_boots_icon")
		$BackIcon.visible = true
		$ItemIcon.visible = false
	elif slot_function == "delete":
		texture = TextureManager.get_texture("ui/inventory_delete_slot")
		$ItemIcon.visible = false

func _process(delta: float) -> void:
	if mouse_stay_timer > 0:
		mouse_stay_timer -= delta
	else:
		if StaticLoad.game.mouse_item_name_label == null and item_name != null and item_name != "AIR":
			StaticLoad.game.mouse_item_name_label = SceneManager.get_scene("others/mouse_item_name_label").instantiate()
			StaticLoad.game.game_ui.add_child(StaticLoad.game.mouse_item_name_label)
			StaticLoad.game.mouse_item_name_label.text = tr(item_name)
			StaticLoad.game.mouse_item_name_label.start_following()
		set_process(false)

func init_inventory_grid(init_item_name, init_item_amount, is_force=true):
	if not is_force:
		item_amount = init_item_amount
		if item_amount <= 1:
			$Amount.text = ""
		else:
			$Amount.text = str(item_amount)
		if item_name != init_item_name:
			item_name = init_item_name
			if item_name == "AIR":
				$ItemIcon.visible = false
				$Amount.visible = false
				$Amount.text = ""
				update_progress_bar(item_name, item_amount)
			else:
				$ItemIcon.init_icon(item_name.to_lower())
				$ItemIcon.visible = true
				update_progress_bar(item_name, item_amount)
	else:
		item_name = init_item_name
		item_amount = init_item_amount
		if item_amount <= 0:
			item_name = "AIR"
			item_amount = 0
		if item_name == "AIR":
			$ItemIcon.visible = false
			$Amount.visible = false
			$Amount.text = ""
			update_progress_bar(item_name, item_amount)
		else:
			$ItemIcon.init_icon(item_name.to_lower())
			$ItemIcon.visible = true
			update_progress_bar(item_name, item_amount)
			if item_amount <= 1:
				$Amount.text = ""
			else:
				$Amount.text = str(item_amount)

func update_progress_bar(got_item_name, got_item_amount):
	if StaticLoad.get_is_durable_by_name(got_item_name):
		$ProgressBar.max_value = StaticLoad.get_max_amount_by_name(got_item_name)
		$ProgressBar.value = got_item_amount
		var percentage =  got_item_amount / float(StaticLoad.get_max_amount_by_name(got_item_name))
		var stylebox = $ProgressBar.get_theme_stylebox("fill")
		if percentage > 0.667:
			stylebox.bg_color = Color(0, 0.727, 0.135)
		elif percentage > 0.333 and percentage <= 0.667:
			stylebox.bg_color = Color(0.863, 0.675, 0)
		elif percentage >= 0 and percentage <= 0.333:
			stylebox.bg_color = Color(0.73, 0, 0)
		$ProgressBar.add_theme_stylebox_override("fill", stylebox)
		$Amount.visible = false
		if name.contains("InfiniteGrid"):
			$ProgressBar.value = StaticLoad.get_max_amount_by_name(got_item_name)
			$ProgressBar.visible = false
		else:
			$ProgressBar.visible = true
	else:
		$Amount.visible = true
		$ProgressBar.visible = false


func _on_mouse_entered() -> void:
	if name.contains("InventoryGrid") or (slot_function.contains("craft") and not slot_function.contains("craft_result")):
		if item_name == "AIR":
			if StaticLoad.game.drag_inventory_grid_item_name != "null":
				if not StaticLoad.game.drag_inventory_grid_dict.has(name):
					StaticLoad.game.drag_inventory_grid_dict[name] = self
					StaticLoad.game.drag_inventory_last_grid_name = name
					StaticLoad.game.update_drag_inventory_grid("null")
		elif item_name == StaticLoad.game.drag_inventory_grid_item_name:
			if StaticLoad.game.drag_inventory_grid_dict.has(name):
				# 截断处理，暂不启用
				#var index = StaticLoad.game.drag_inventory_grid_dict.find_key(name)
				#StaticLoad.game.update_drag_inventory_grid(index)
				pass
			else:
				if not StaticLoad.game.drag_inventory_grid_dict.has(name):
					StaticLoad.game.drag_inventory_grid_dict[name] = self
					StaticLoad.game.drag_inventory_last_grid_name = name
					StaticLoad.game.update_drag_inventory_grid("null")
	if StaticLoad.game.drag_inventory_grid_state == "null" and not StaticLoad.game.drag_inventory_grid_dict.is_empty():
		StaticLoad.game.drag_inventory_grid_dict.clear()
	if StaticLoad.game.mouse_in_inventory_grid != self:
		white_color_rect.visible = true
	StaticLoad.game.mouse_in_inventory_grid = self
	if item_name == "AIR":
		return
	mouse_stay_timer = StaticLoad.INVENTORY_NAME_SHOW_STAY_TIME
	set_process(true)

func _on_mouse_exited() -> void:
	if name.contains("InventoryGrid") or (slot_function.contains("craft") and not slot_function.contains("craft_result")):
		if StaticLoad.game.drag_inventory_grid_state != "null" and StaticLoad.game.drag_inventory_grid_item_name == "null":
			if not StaticLoad.get_is_durable_by_name(StaticLoad.game.player.mouse_item_name) or StaticLoad.game.drag_inventory_grid_state == "middle":
				StaticLoad.game.drag_inventory_grid_item_name = StaticLoad.game.player.mouse_item_name
				StaticLoad.game.dragging_total_amount = StaticLoad.game.player.mouse_item_amount
				StaticLoad.game.drag_inventory_grid_amount_dict.clear()
				StaticLoad.game.drag_inventory_grid_dict.clear()
				StaticLoad.game.drag_inventory_grid_dict[name] = self
				StaticLoad.game.drag_inventory_last_grid_name = name
				StaticLoad.game.update_drag_inventory_grid("null")
				white_color_rect.visible = true
	if StaticLoad.game.drag_inventory_grid_state == "null" or not StaticLoad.game.drag_inventory_grid_dict.has(name):
		if StaticLoad.game.mouse_in_inventory_grid == self:
			white_color_rect.visible = false
	StaticLoad.game.mouse_in_inventory_grid = null
	set_process(false)
	mouse_stay_timer = StaticLoad.INVENTORY_NAME_SHOW_STAY_TIME
	if StaticLoad.game.mouse_item_name_label == null:
		return
	StaticLoad.game.mouse_item_name_label.stop_following()
	StaticLoad.game.mouse_item_name_label.queue_free()

func update_achievement():
	if item_name == "CRAFTING_TABLE":
		var change_dict = {
			"make_crafting_table" : true
		}
		StaticLoad.game.player.process_achievement_progress(change_dict)
	elif item_name == "BREAD":
		var change_dict = {
			"make_bread" : true
		}
		StaticLoad.game.player.process_achievement_progress(change_dict)
	elif item_name.contains("PICKAXE"):
		var change_dict = {
			"make_pickaxe" : true
		}
		StaticLoad.game.player.process_achievement_progress(change_dict)
	elif item_name.contains("HOE"):
		var change_dict = {
			"make_hoe" : true
		}
		StaticLoad.game.player.process_achievement_progress(change_dict)
	elif item_name.contains("SWORD"):
		var change_dict = {
			"make_sword" : true
		}
		StaticLoad.game.player.process_achievement_progress(change_dict)

func _on_gui_input(event: InputEvent) -> void:
	if slot_function.contains("armor"):
		return
	if not (event is InputEventMouseButton or event is InputEventScreenTouch):
		return
	var is_event_double_click = false
	var event_index = 1
	if event is InputEventMouseButton:
		is_event_double_click = event.double_click
		event_index = event.button_index
	var player = StaticLoad.game.player
	var mouse_item_name_tmp = player.mouse_item_name
	var mouse_item_amount_tmp = player.mouse_item_amount
	if event is InputEventMouseButton:
		if is_event_double_click and event_index == 1:
			var assemble_item_name = mouse_item_name_tmp
			var current_item_amount = mouse_item_amount_tmp
			#if assemble_item_name == "AIR":
				#assemble_item_name = item_name
				#current_item_amount = item_amount
			var max_item_amount = StaticLoad.get_max_amount_by_name(assemble_item_name)
			if assemble_item_name != "AIR" and current_item_amount < max_item_amount and not StaticLoad.get_is_durable_by_name(assemble_item_name):
				var assemble_item_amount = max_item_amount-current_item_amount
				if StaticLoad.game.is_inventory:
					var is_update_craft_result = false
					for index in ["0", "1", "3", "4"]:
						var craft_grid = StaticLoad.game.inventory_craft_grid.get_node("Craft"+index)
						if craft_grid.item_name == assemble_item_name:
							is_update_craft_result = true
							if craft_grid.item_amount <= assemble_item_amount:
								current_item_amount += craft_grid.item_amount
								assemble_item_amount -= craft_grid.item_amount
								craft_grid.init_inventory_grid("AIR", 0)
							else:
								current_item_amount = max_item_amount
								assemble_item_amount = 0
								craft_grid.init_inventory_grid(craft_grid.item_name, craft_grid.item_amount-assemble_item_amount)
					if is_update_craft_result:
						StaticLoad.game.refresh_inventory_crafting_result()
				elif StaticLoad.game.is_crafting:
					var is_update_craft_result = false
					for index in range(9):
						var craft_grid = StaticLoad.game.table_craft_grid.get_node("Craft"+str(index))
						if craft_grid.item_name == assemble_item_name:
							is_update_craft_result = true
							if craft_grid.item_amount <= assemble_item_amount:
								current_item_amount += craft_grid.item_amount
								assemble_item_amount -= craft_grid.item_amount
								craft_grid.init_inventory_grid("AIR", 0)
							else:
								current_item_amount = max_item_amount
								assemble_item_amount = 0
								craft_grid.init_inventory_grid(craft_grid.item_name, craft_grid.item_amount-assemble_item_amount)
					if is_update_craft_result:
						StaticLoad.game.refresh_table_crafting_result()
				if assemble_item_amount > 0:
					assemble_item_amount = player.if_clear_item_amount(assemble_item_name, assemble_item_amount)
					if assemble_item_amount > 0:
						player.clear_item(assemble_item_name, assemble_item_amount)
						current_item_amount += assemble_item_amount
				if current_item_amount > mouse_item_amount_tmp:
					player.mouse_item_amount = current_item_amount
					StaticLoad.game.append_process_refresh("refresh_item_grid")
					if StaticLoad.game.is_inventory:
						StaticLoad.game.append_process_refresh("refresh_inventory")
					elif StaticLoad.game.is_crafting:
						StaticLoad.game.append_process_refresh("refresh_crafting_inventory")
		if event.pressed:
			if name.contains("InfiniteGrid"):
				return
			if name.contains("InventoryGrid") or (slot_function.contains("craft") and not slot_function.contains("craft_result")):
				if event_index == 1 and Input.is_action_pressed("shift"):
					pass
				else:
					var player_mouse_item_name = StaticLoad.game.player.mouse_item_name
					if player_mouse_item_name != "AIR" and StaticLoad.game.drag_inventory_grid_state == "null" and (item_name == "AIR" or item_name == player_mouse_item_name):
						if event_index == 1:
							StaticLoad.game.drag_inventory_grid_state = "left"
						elif event_index == 2:
							StaticLoad.game.drag_inventory_grid_state = "right"
						elif StaticLoad.game.player.gamemode == "creative" and event_index == 3:
							StaticLoad.game.drag_inventory_grid_state = "middle"
					return
		else:
			if StaticLoad.game.ui_freeze_timer > 0:
				return
			if StaticLoad.game.drag_inventory_grid_dict.has(name):
				StaticLoad.game.drag_inventory_grid_dict.clear()
				return
		if StaticLoad.game.mouse_in_inventory_grid != self:
			return
		if event_index == 4 or event_index == 5:
			return
	var is_operated = false
	
	if name.contains("InventoryGrid"):
		if event_index == 1:
			if Input.is_action_pressed("shift"):
				if item_name != "AIR":
					var sort = int(name.replace("InventoryGrid", ""))
					if StaticLoad.game.inventory_back_grids.is_visible_in_tree() or StaticLoad.game.crafting_inventory_back_grids.is_visible_in_tree():
						if sort < 9:
							item_amount = player.get_item([item_name, item_amount, 9, 36, false])
							if item_amount == 0:
								item_name = "AIR"
							player.item_bar_names[sort] = item_name
							player.item_bar_amounts[sort] = item_amount
							StaticLoad.game.append_process_refresh("refresh_inventory")
							update_progress_bar(item_name, item_amount)
							init_inventory_grid(item_name, item_amount)
							StaticLoad.game.refresh_item_grid(sort)
							if not (player.mouse_item_name == "AIR" and item_name == "AIR"):
								is_operated = true
						elif sort >= 9 and sort < 36:
							item_amount = player.get_item([item_name, item_amount, 0, 9, false])
							if item_amount == 0:
								item_name = "AIR"
							player.item_bar_names[sort] = item_name
							player.item_bar_amounts[sort] = item_amount
							StaticLoad.game.append_process_refresh("refresh_inventory")
							StaticLoad.game.append_process_refresh("refresh_item_grid")
							update_progress_bar(item_name, item_amount)
							init_inventory_grid(item_name, item_amount)
							is_operated = true
					elif player.gamemode == "creative":
						player.item_bar_names[sort] = "AIR"
						player.item_bar_amounts[sort] = 0
						StaticLoad.game.refresh_item_grid(sort)
						update_progress_bar("AIR", 0)
						init_inventory_grid("AIR", 0)
						if not (player.mouse_item_name == "AIR" and item_name == "AIR"):
							is_operated = true
			else:
				if mouse_item_name_tmp != item_name or StaticLoad.get_is_durable_by_name(item_name):
					player.mouse_item_name = item_name
					player.mouse_item_amount = item_amount
					init_inventory_grid(mouse_item_name_tmp, mouse_item_amount_tmp)
					var sort = int(name.replace("InventoryGrid", ""))
					player.item_bar_names[sort] = item_name
					player.item_bar_amounts[sort] = item_amount
					update_progress_bar(item_name, item_amount)
					if StaticLoad.game.mouse_item_name_label != null:
						StaticLoad.game.mouse_item_name_label.stop_following()
						StaticLoad.game.mouse_item_name_label.queue_free()
						if item_name != "AIR":
							StaticLoad.game.mouse_item_name_label = SceneManager.get_scene("others/mouse_item_name_label").instantiate()
							StaticLoad.game.game_ui.add_child(StaticLoad.game.mouse_item_name_label)
							StaticLoad.game.mouse_item_name_label.text = tr(item_name)
							StaticLoad.game.mouse_item_name_label.start_following()
					if sort < 9:
						StaticLoad.game.refresh_item_grid(sort)
					if not (player.mouse_item_name == "AIR" and item_name == "AIR"):
						is_operated = true
				else:
					if item_amount + mouse_item_amount_tmp <= StaticLoad.get_max_amount_by_name(item_name):
						item_amount += mouse_item_amount_tmp
						player.mouse_item_name = "AIR"
						player.mouse_item_amount = 0
						update_progress_bar(item_name, item_amount)
					else:
						player.mouse_item_amount = mouse_item_amount_tmp+item_amount-StaticLoad.get_max_amount_by_name(item_name)
						item_amount = StaticLoad.get_max_amount_by_name(item_name)
						update_progress_bar(item_name, item_amount)
					var sort = int(name.replace("InventoryGrid", ""))
					player.item_bar_amounts[sort] = item_amount
					init_inventory_grid(item_name, item_amount)
					if sort < 9:
						StaticLoad.game.refresh_item_grid(sort)
					if not (player.mouse_item_name == "AIR" and item_name == "AIR"):
						is_operated = true
		elif event_index == 2:
			if mouse_item_amount_tmp == 0 and item_amount >= 2 and not StaticLoad.get_is_durable_by_name(item_name):
				player.mouse_item_name = item_name
				player.mouse_item_amount = item_amount/2
				item_amount -= player.mouse_item_amount
				var sort = int(name.replace("InventoryGrid", ""))
				player.item_bar_amounts[sort] = item_amount
				update_progress_bar(item_name, item_amount)
				init_inventory_grid(item_name, item_amount)
				if sort < 9:
					StaticLoad.game.refresh_item_grid(sort)
				if not (player.mouse_item_name == "AIR" and item_name == "AIR"):
					is_operated = true
			elif mouse_item_name_tmp == item_name and not StaticLoad.get_is_durable_by_name(item_name):
				if item_amount < StaticLoad.get_max_amount_by_name(item_name):
					player.mouse_item_amount -= 1
					item_amount += 1
					if player.mouse_item_amount == 0:
						player.mouse_item_name = "AIR"
					update_progress_bar(item_name, item_amount)
					init_inventory_grid(item_name, item_amount)
					var sort = int(name.replace("InventoryGrid", ""))
					player.item_bar_amounts[sort] = item_amount
					if sort < 9:
						StaticLoad.game.refresh_item_grid(sort)
					if not (player.mouse_item_name == "AIR" and item_name == "AIR"):
						is_operated = true
			elif item_name == "AIR" and not StaticLoad.get_is_durable_by_name(player.mouse_item_name):
				item_name = player.mouse_item_name
				player.mouse_item_amount -= 1
				item_amount += 1
				if player.mouse_item_amount == 0:
					player.mouse_item_name = "AIR"
				update_progress_bar(item_name, item_amount)
				init_inventory_grid(item_name, item_amount)
				var sort = int(name.replace("InventoryGrid", ""))
				player.item_bar_names[sort] = item_name
				player.item_bar_amounts[sort] = item_amount
				if sort < 9:
					StaticLoad.game.refresh_item_grid(sort)
				if not (player.mouse_item_name == "AIR" and item_name == "AIR"):
					is_operated = true
			elif StaticLoad.get_is_durable_by_name(item_name):
				player.mouse_item_name = item_name
				player.mouse_item_amount = item_amount
				init_inventory_grid(mouse_item_name_tmp, mouse_item_amount_tmp)
				var sort = int(name.replace("InventoryGrid", ""))
				player.item_bar_names[sort] = item_name
				player.item_bar_amounts[sort] = item_amount
				update_progress_bar(item_name, item_amount)
				if StaticLoad.game.mouse_item_name_label != null:
					StaticLoad.game.mouse_item_name_label.stop_following()
					StaticLoad.game.mouse_item_name_label.queue_free()
					if item_name != "AIR":
						StaticLoad.game.mouse_item_name_label = SceneManager.get_scene("others/mouse_item_name_label").instantiate()
						StaticLoad.game.game_ui.add_child(StaticLoad.game.mouse_item_name_label)
						StaticLoad.game.mouse_item_name_label.text = tr(item_name)
						StaticLoad.game.mouse_item_name_label.start_following()
				if sort < 9:
					StaticLoad.game.refresh_item_grid(sort)
				if not (player.mouse_item_name == "AIR" and item_name == "AIR"):
					is_operated = true
		elif event_index == 3 and player.gamemode == "creative":
			if mouse_item_amount_tmp == 0 and item_name != "AIR":
				if StaticLoad.get_is_durable_by_name(item_name):
					player.mouse_item_name = item_name
					player.mouse_item_amount = item_amount
					if not (player.mouse_item_name == "AIR" and item_name == "AIR"):
						is_operated = true
				else:
					player.mouse_item_name = item_name
					player.mouse_item_amount = StaticLoad.get_max_amount_by_name(item_name)
					if not (player.mouse_item_name == "AIR" and item_name == "AIR"):
						is_operated = true
	elif slot_function.contains("craft") and not slot_function.contains("craft_result"):
		if event_index == 1:
			if Input.is_action_pressed("shift"):
				if item_name != "AIR":
					if item_amount > player.if_get_item_left(item_name, item_amount, 0, 9):
						item_amount = player.get_item([item_name, item_amount, 0, 36, false])
					else:
						item_amount = player.get_item([item_name, item_amount, 9, 36, false])
						if item_amount > 0:
							item_amount = player.get_item([item_name, item_amount, 0, 9, false])
					if item_amount == 0:
						item_name = "AIR"
					update_progress_bar(item_name, item_amount)
					init_inventory_grid(item_name, item_amount)
					StaticLoad.game.append_process_refresh("refresh_item_grid")
					if slot_function.contains("inventory"):
						StaticLoad.game.append_process_refresh("refresh_inventory")
						StaticLoad.game.refresh_inventory_crafting_result()
					elif slot_function.contains("table"):
						StaticLoad.game.append_process_refresh("refresh_crafting_inventory")
						StaticLoad.game.refresh_table_crafting_result()
			else:
				if mouse_item_name_tmp != item_name or StaticLoad.get_is_durable_by_name(item_name):
					player.mouse_item_name = item_name
					player.mouse_item_amount = item_amount
					init_inventory_grid(mouse_item_name_tmp, mouse_item_amount_tmp)
					update_progress_bar(item_name, item_amount)
					if slot_function.contains("inventory"):
						StaticLoad.game.refresh_inventory_crafting_result()
					elif slot_function.contains("table"):
						StaticLoad.game.refresh_table_crafting_result()
					if StaticLoad.game.mouse_item_name_label != null:
						StaticLoad.game.mouse_item_name_label.stop_following()
						StaticLoad.game.mouse_item_name_label.queue_free()
						if item_name != "AIR":
							StaticLoad.game.mouse_item_name_label = SceneManager.get_scene("others/mouse_item_name_label").instantiate()
							StaticLoad.game.game_ui.add_child(StaticLoad.game.mouse_item_name_label)
							StaticLoad.game.mouse_item_name_label.text = tr(item_name)
							StaticLoad.game.mouse_item_name_label.start_following()
				else:
					if item_amount + mouse_item_amount_tmp <= StaticLoad.get_max_amount_by_name(item_name):
						item_amount += mouse_item_amount_tmp
						player.mouse_item_name = "AIR"
						player.mouse_item_amount = 0
						update_progress_bar(item_name, item_amount)
					else:
						player.mouse_item_amount = mouse_item_amount_tmp+item_amount-StaticLoad.get_max_amount_by_name(item_name)
						item_amount = StaticLoad.get_max_amount_by_name(item_name)
						update_progress_bar(item_name, item_amount)
					init_inventory_grid(item_name, item_amount)
					if slot_function.contains("inventory"):
						StaticLoad.game.refresh_inventory_crafting_result()
					elif slot_function.contains("table"):
						StaticLoad.game.refresh_table_crafting_result()
		elif event_index == 2:
			if mouse_item_amount_tmp == 0 and item_amount >= 2 and not StaticLoad.get_is_durable_by_name(item_name):
				player.mouse_item_name = item_name
				player.mouse_item_amount = item_amount/2
				item_amount -= player.mouse_item_amount
				update_progress_bar(item_name, item_amount)
				init_inventory_grid(item_name, item_amount)
				if slot_function.contains("inventory"):
					StaticLoad.game.refresh_inventory_crafting_result()
				elif slot_function.contains("table"):
					StaticLoad.game.refresh_table_crafting_result()
			elif mouse_item_name_tmp == item_name and not StaticLoad.get_is_durable_by_name(item_name):
				if item_amount < StaticLoad.get_max_amount_by_name(item_name):
					player.mouse_item_amount -= 1
					item_amount += 1
					if player.mouse_item_amount == 0:
						player.mouse_item_name = "AIR"
					update_progress_bar(item_name, item_amount)
					init_inventory_grid(item_name, item_amount)
					if slot_function.contains("inventory"):
						StaticLoad.game.refresh_inventory_crafting_result()
					elif slot_function.contains("table"):
						StaticLoad.game.refresh_table_crafting_result()
			elif item_name == "AIR" and not StaticLoad.get_is_durable_by_name(player.mouse_item_name):
				item_name = player.mouse_item_name
				player.mouse_item_amount -= 1
				item_amount += 1
				if player.mouse_item_amount == 0:
					player.mouse_item_name = "AIR"
				update_progress_bar(item_name, item_amount)
				init_inventory_grid(item_name, item_amount)
				if slot_function.contains("inventory"):
					StaticLoad.game.refresh_inventory_crafting_result()
				elif slot_function.contains("table"):
					StaticLoad.game.refresh_table_crafting_result()
			elif StaticLoad.get_is_durable_by_name(item_name):
				player.mouse_item_name = item_name
				player.mouse_item_amount = item_amount
				init_inventory_grid(mouse_item_name_tmp, mouse_item_amount_tmp)
				update_progress_bar(item_name, item_amount)
				if slot_function.contains("inventory"):
					StaticLoad.game.refresh_inventory_crafting_result()
				elif slot_function.contains("table"):
					StaticLoad.game.refresh_table_crafting_result()
				if StaticLoad.game.mouse_item_name_label != null:
					StaticLoad.game.mouse_item_name_label.stop_following()
					StaticLoad.game.mouse_item_name_label.queue_free()
					if item_name != "AIR":
						StaticLoad.game.mouse_item_name_label = SceneManager.get_scene("others/mouse_item_name_label").instantiate()
						StaticLoad.game.game_ui.add_child(StaticLoad.game.mouse_item_name_label)
						StaticLoad.game.mouse_item_name_label.text = tr(item_name)
						StaticLoad.game.mouse_item_name_label.start_following()
		elif event_index == 3 and player.gamemode == "creative":
			if mouse_item_amount_tmp == 0 and item_name != "AIR":
				if StaticLoad.get_is_durable_by_name(item_name):
					player.mouse_item_name = item_name
					player.mouse_item_amount = item_amount
				else:
					player.mouse_item_name = item_name
					player.mouse_item_amount = StaticLoad.get_max_amount_by_name(item_name)
	elif slot_function.contains("craft_result"):
		if event_index == 1 and event.pressed:
			if Input.is_action_pressed("shift"):
				if item_name != "AIR":
					var min_amount = 0
					if slot_function.contains("inventory"):
						min_amount = StaticLoad.game.get_max_craft_amount("inventory")
					elif slot_function.contains("table"):
						min_amount = StaticLoad.game.get_max_craft_amount("table")
					if min_amount > 0:
						var can_accept_amount = 0
						for i in range(min_amount, 0, -1):
							if player.if_get_item_left(item_name, item_amount*i, 0, 36) == 0:
								can_accept_amount = i
								break
						if can_accept_amount > 0:
							update_achievement()
							var final_amount = item_amount * can_accept_amount
							item_amount = player.get_item([item_name, final_amount, 9, 36, false])
							if item_amount > 0:
								item_amount = player.get_item([item_name, item_amount, 0, 9, false])
							if item_amount == 0:
								item_name = "AIR"
							StaticLoad.game.append_process_refresh("refresh_item_grid")
							if slot_function.contains("inventory"):
								StaticLoad.game.decline_inventory_crafting_material(can_accept_amount)
								StaticLoad.game.refresh_inventory_crafting_result()
								StaticLoad.game.append_process_refresh("refresh_inventory")
							elif slot_function.contains("table"):
								StaticLoad.game.decline_table_crafting_material(can_accept_amount)
								StaticLoad.game.refresh_table_crafting_result()
								StaticLoad.game.append_process_refresh("refresh_crafting_inventory")
			else:
				if mouse_item_name_tmp != item_name or StaticLoad.get_is_durable_by_name(item_name):
					if player.mouse_item_name == "AIR":
						player.mouse_item_name = item_name
						player.mouse_item_amount = item_amount
						if slot_function.contains("inventory"):
							StaticLoad.game.decline_inventory_crafting_material(1)
							StaticLoad.game.refresh_inventory_crafting_result()
						elif slot_function.contains("table"):
							StaticLoad.game.decline_table_crafting_material(1)
							StaticLoad.game.refresh_table_crafting_result()
						update_achievement()
						if StaticLoad.game.mouse_item_name_label != null:
							StaticLoad.game.mouse_item_name_label.stop_following()
							StaticLoad.game.mouse_item_name_label.queue_free()
							if item_name != "AIR":
								StaticLoad.game.mouse_item_name_label = SceneManager.get_scene("others/mouse_item_name_label").instantiate()
								StaticLoad.game.game_ui.add_child(StaticLoad.game.mouse_item_name_label)
								StaticLoad.game.mouse_item_name_label.text = tr(item_name)
								StaticLoad.game.mouse_item_name_label.start_following()
				else:
					if item_amount + mouse_item_amount_tmp <= StaticLoad.get_max_amount_by_name(item_name):
						var max_amount = 0
						if slot_function.contains("inventory"):
							max_amount = StaticLoad.game.get_max_craft_amount("inventory")
						elif slot_function.contains("table"):
							max_amount = StaticLoad.game.get_max_craft_amount("table")
						if max_amount > 0:
							player.mouse_item_amount += item_amount
						update_achievement()
						if slot_function.contains("inventory"):
							StaticLoad.game.decline_inventory_crafting_material(1)
							StaticLoad.game.refresh_inventory_crafting_result()
						elif slot_function.contains("table"):
							StaticLoad.game.decline_table_crafting_material(1)
							StaticLoad.game.refresh_table_crafting_result()
		elif (event_index == 2 or event_index == 3) and event.pressed:
			if Input.is_action_pressed("shift"):
				if item_name != "AIR":
					if player.if_get_item_left(item_name, item_amount, 0, 36) == 0:
						item_amount = player.get_item([item_name, item_amount, 9, 36, false])
						if item_amount > 0:
							item_amount = player.get_item([item_name, item_amount, 0, 9, false])
						if item_amount == 0:
							item_name = "AIR"
						StaticLoad.game.append_process_refresh("refresh_item_grid")
						update_achievement()
						if slot_function.contains("inventory"):
							StaticLoad.game.decline_inventory_crafting_material(1)
							StaticLoad.game.refresh_inventory_crafting_result()
							StaticLoad.game.append_process_refresh("refresh_inventory")
						elif slot_function.contains("table"):
							StaticLoad.game.decline_table_crafting_material(1)
							StaticLoad.game.refresh_table_crafting_result()
							StaticLoad.game.append_process_refresh("refresh_crafting_inventory")
			else:
				if mouse_item_name_tmp != item_name or StaticLoad.get_is_durable_by_name(item_name):
					if player.mouse_item_name == "AIR":
						player.mouse_item_name = item_name
						player.mouse_item_amount = item_amount
						update_achievement()
						if slot_function.contains("inventory"):
							StaticLoad.game.decline_inventory_crafting_material(1)
							StaticLoad.game.refresh_inventory_crafting_result()
						elif slot_function.contains("table"):
							StaticLoad.game.decline_table_crafting_material(1)
							StaticLoad.game.refresh_table_crafting_result()
						if StaticLoad.game.mouse_item_name_label != null:
							StaticLoad.game.mouse_item_name_label.stop_following()
							StaticLoad.game.mouse_item_name_label.queue_free()
							if item_name != "AIR":
								StaticLoad.game.mouse_item_name_label = SceneManager.get_scene("others/mouse_item_name_label").instantiate()
								StaticLoad.game.game_ui.add_child(StaticLoad.game.mouse_item_name_label)
								StaticLoad.game.mouse_item_name_label.text = tr(item_name)
								StaticLoad.game.mouse_item_name_label.start_following()
				else:
					if item_amount + mouse_item_amount_tmp <= StaticLoad.get_max_amount_by_name(item_name):
						var max_amount = 0
						if slot_function.contains("inventory"):
							max_amount = StaticLoad.game.get_max_craft_amount("inventory")
						elif slot_function.contains("table"):
							max_amount = StaticLoad.game.get_max_craft_amount("table")
						if max_amount > 0:
							player.mouse_item_amount += item_amount
						update_achievement()
						if slot_function.contains("inventory"):
							StaticLoad.game.decline_inventory_crafting_material(1)
							StaticLoad.game.refresh_inventory_crafting_result()
						elif slot_function.contains("table"):
							StaticLoad.game.decline_table_crafting_material(1)
							StaticLoad.game.refresh_table_crafting_result()
	elif name.contains("InfiniteGrid") and player.gamemode == "creative":
		if event_index == 1:
			if Input.is_action_pressed("shift"):
				player.get_item([item_name, StaticLoad.get_max_amount_by_name(item_name), 0, 9, false])
				StaticLoad.game.append_process_refresh("refresh_inventory")
				StaticLoad.game.append_process_refresh("refresh_item_grid")
				if not (player.mouse_item_name == "AIR" and item_name == "AIR"):
					is_operated = true
			else:
				if mouse_item_amount_tmp == 0:
					player.mouse_item_name = item_name
					if StaticLoad.get_is_durable_by_name(item_name):
						player.mouse_item_amount = StaticLoad.get_max_amount_by_name(item_name)
						if not (player.mouse_item_name == "AIR" and item_name == "AIR"):
							is_operated = true
					else:
						player.mouse_item_amount = 1
						if not (player.mouse_item_name == "AIR" and item_name == "AIR"):
							is_operated = true
				elif mouse_item_name_tmp == item_name and not StaticLoad.get_is_durable_by_name(item_name):
					if player.mouse_item_amount < StaticLoad.get_max_amount_by_name(item_name):
						player.mouse_item_amount += 1
						if not (player.mouse_item_name == "AIR" and item_name == "AIR"):
							is_operated = true
				elif mouse_item_name_tmp != item_name:
					player.mouse_item_name = "AIR"
					player.mouse_item_amount = 0
					if not (player.mouse_item_name == "AIR" and item_name == "AIR"):
						is_operated = true
		if event_index == 2:
			if mouse_item_amount_tmp != 0:
				if StaticLoad.get_is_durable_by_name(mouse_item_name_tmp):
					player.mouse_item_amount = 0
					if not (player.mouse_item_name == "AIR" and item_name == "AIR"):
						is_operated = true
				else:
					player.mouse_item_amount -= 1
					if not (player.mouse_item_name == "AIR" and item_name == "AIR"):
						is_operated = true
				if player.mouse_item_amount <= 0:
					player.mouse_item_name = "AIR"
					if not (player.mouse_item_name == "AIR" and item_name == "AIR"):
						is_operated = true
		elif event_index == 3:
			if mouse_item_amount_tmp == 0 and item_name != "AIR":
				player.mouse_item_name = item_name
				player.mouse_item_amount = StaticLoad.get_max_amount_by_name(item_name)
				if not (player.mouse_item_name == "AIR" and item_name == "AIR"):
					is_operated = true
	elif slot_function == "delete":
		if Input.is_action_pressed("shift") and player.gamemode == "creative":
			for i in range(36):
				player.item_bar_amounts[i] = 0
				player.item_bar_names[i] = "AIR"
			StaticLoad.game.append_process_refresh("refresh_item_grid")
			StaticLoad.game.append_process_refresh("refresh_inventory")
			is_operated = true
		else:
			player.mouse_item_name = "AIR"
			player.mouse_item_amount = 0
			is_operated = true
	if StaticLoad.is_muti_mode and multiplayer.get_unique_id() != 1 and is_operated:
		player.changed_state_dict["inventory"] = [player.item_bar_names, player.item_bar_amounts, player.mouse_item_name, player.mouse_item_amount]
