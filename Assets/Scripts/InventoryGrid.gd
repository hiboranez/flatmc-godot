extends TextureRect

@export var slot_function: String

var item_name
var item_amount
var mouse_stay_timer = StaticLoad.INVENTORY_NAME_SHOW_STAY_TIME

func _ready() -> void:
	set_process(false)
	if slot_function == "armor_helmet":
		$BackIcon.texture = load("res://Assets/Textures/GUI/empty_slot_helmet.png")
		$BackIcon.visible = true
		$ItemIcon.visible = false
	elif slot_function == "armor_chestplate":
		$BackIcon.texture = load("res://Assets/Textures/GUI/empty_slot_chestplate.png")
		$BackIcon.visible = true
		$ItemIcon.visible = false
	elif slot_function == "armor_leggings":
		$BackIcon.texture = load("res://Assets/Textures/GUI/empty_slot_leggings.png")
		$BackIcon.visible = true
		$ItemIcon.visible = false
	elif slot_function == "armor_boots":
		$BackIcon.texture = load("res://Assets/Textures/GUI/empty_slot_boots.png")
		$BackIcon.visible = true
		$ItemIcon.visible = false
	elif slot_function == "delete":
		texture = load("res://Assets/Textures/GUI/delete_slot.png")
		$ItemIcon.visible = false

func _process(delta: float) -> void:
	if mouse_stay_timer > 0:
		mouse_stay_timer -= delta
	else:
		if StaticLoad.game.mouse_item_name_label == null and item_name != null and item_name != "AIR":
			StaticLoad.game.mouse_item_name_label = StaticLoad.mouse_item_name_label_scene.instantiate()
			StaticLoad.game.game_ui.add_child(StaticLoad.game.mouse_item_name_label)
			StaticLoad.game.mouse_item_name_label.text = tr(item_name)
			StaticLoad.game.mouse_item_name_label.start_following()
		set_process(false)

func init_inventory_grid(init_item_name, init_item_amount):
	item_name = init_item_name
	item_amount = init_item_amount
	if init_item_name == "AIR":
		$ItemIcon.visible = false
		$Amount.visible = false
		$Amount.text = ""
		update_progress_bar(init_item_name, init_item_amount)
	else:
		$ItemIcon.init_icon(init_item_name.to_lower())
		$ItemIcon.visible = true
		update_progress_bar(init_item_name, init_item_amount)
		if item_amount <= 1:
			$Amount.text = ""
		else:
			$Amount.text = str(item_amount)

func update_progress_bar(got_item_name, got_item_amount):
	if StaticLoad.get_is_durable_by_name(got_item_name):
		$ProgressBar.max_value = StaticLoad.get_max_amount_by_name(got_item_name)
		$ProgressBar.value = got_item_amount
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
	StaticLoad.game.mouse_in_inventory_grid = self
	if item_name == "AIR":
		return
	mouse_stay_timer = StaticLoad.INVENTORY_NAME_SHOW_STAY_TIME
	set_process(true)

func _on_mouse_exited() -> void:
	StaticLoad.game.mouse_in_inventory_grid = null
	set_process(false)
	mouse_stay_timer = StaticLoad.INVENTORY_NAME_SHOW_STAY_TIME
	if StaticLoad.game.mouse_item_name_label == null:
		return
	StaticLoad.game.mouse_item_name_label.stop_following()
	StaticLoad.game.mouse_item_name_label.queue_free()
	

func _on_gui_input(event: InputEvent) -> void:
	if slot_function.contains("armor") or slot_function.contains("craft"):
		return
	if not (event is InputEventMouseButton or event is InputEventScreenTouch):
		return
	if event is InputEventMouseButton:
		if not event.pressed:
			return
	var player = StaticLoad.game.player
	var mouse_item_name_tmp = StaticLoad.game.mouse_item_name
	var mouse_item_amount_tmp = StaticLoad.game.mouse_item_amount
	if name.contains("InventoryGrid"):
		if event.button_index == 1:
			if Input.is_action_pressed("shift"):
				if item_name != "AIR":
					var sort = int(name.replace("InventoryGrid", ""))
					if StaticLoad.game.inventory_back_grids.is_visible_in_tree():
						if sort < 9:
							item_amount = player.get_item([item_name, item_amount, 9, 36, false])
							if item_amount == 0:
								item_name = "AIR"
							player.item_bar_names[sort] = item_name
							player.item_bar_amounts[sort] = item_amount
							StaticLoad.game.append_process_refresh("refresh_inventory")
							update_progress_bar(item_name, item_amount)
							StaticLoad.game.refresh_item_grid(sort)
						elif sort >= 9 and sort < 36:
							item_amount = player.get_item([item_name, item_amount, 0, 9, false])
							if item_amount == 0:
								item_name = "AIR"
							player.item_bar_names[sort] = item_name
							player.item_bar_amounts[sort] = item_amount
							StaticLoad.game.append_process_refresh("refresh_inventory")
							StaticLoad.game.append_process_refresh("refresh_item_grid")
							update_progress_bar(item_name, item_amount)
					elif player.gamemode == "creative":
						player.item_bar_names[sort] = "AIR"
						player.item_bar_amounts[sort] = 0
						StaticLoad.game.refresh_item_grid(sort)
						update_progress_bar("AIR", 0)
						init_inventory_grid("AIR", 0)
			else:
				if mouse_item_name_tmp != item_name or StaticLoad.get_is_durable_by_name(item_name):
					StaticLoad.game.mouse_item_name = item_name
					StaticLoad.game.mouse_item_amount = item_amount
					init_inventory_grid(mouse_item_name_tmp, mouse_item_amount_tmp)
					var sort = int(name.replace("InventoryGrid", ""))
					player.item_bar_names[sort] = item_name
					player.item_bar_amounts[sort] = item_amount
					update_progress_bar(item_name, item_amount)
					if StaticLoad.game.mouse_item_name_label != null:
						StaticLoad.game.mouse_item_name_label.stop_following()
						StaticLoad.game.mouse_item_name_label.queue_free()
						if item_name != "AIR":
							StaticLoad.game.mouse_item_name_label = StaticLoad.mouse_item_name_label_scene.instantiate()
							StaticLoad.game.game_ui.add_child(StaticLoad.game.mouse_item_name_label)
							StaticLoad.game.mouse_item_name_label.text = tr(item_name)
							StaticLoad.game.mouse_item_name_label.start_following()
					if sort < 9:
						StaticLoad.game.refresh_item_grid(sort)
				else:
					if item_amount + mouse_item_amount_tmp <= StaticLoad.get_max_amount_by_name(item_name):
						item_amount += mouse_item_amount_tmp
						StaticLoad.game.mouse_item_name = "AIR"
						StaticLoad.game.mouse_item_amount = 0
						update_progress_bar(item_name, item_amount)
					else:
						StaticLoad.game.mouse_item_amount = mouse_item_amount_tmp+item_amount-StaticLoad.get_max_amount_by_name(item_name)
						item_amount = StaticLoad.get_max_amount_by_name(item_name)
						update_progress_bar(item_name, item_amount)
					var sort = int(name.replace("InventoryGrid", ""))
					player.item_bar_amounts[sort] = item_amount
					init_inventory_grid(item_name, item_amount)
					if sort < 9:
						StaticLoad.game.refresh_item_grid(sort)
		elif event.button_index == 2:
			if mouse_item_amount_tmp == 0 and item_amount >= 2 and not StaticLoad.get_is_durable_by_name(item_name):
				StaticLoad.game.mouse_item_name = item_name
				StaticLoad.game.mouse_item_amount = item_amount/2
				item_amount -= StaticLoad.game.mouse_item_amount
				var sort = int(name.replace("InventoryGrid", ""))
				player.item_bar_amounts[sort] = item_amount
				update_progress_bar(item_name, item_amount)
				init_inventory_grid(item_name, item_amount)
				if sort < 9:
					StaticLoad.game.refresh_item_grid(sort)
			elif mouse_item_name_tmp == item_name and not StaticLoad.get_is_durable_by_name(item_name):
				if item_amount < StaticLoad.get_max_amount_by_name(item_name):
					StaticLoad.game.mouse_item_amount -= 1
					item_amount += 1
					if StaticLoad.game.mouse_item_amount == 0:
						StaticLoad.game.mouse_item_name = "AIR"
					update_progress_bar(item_name, item_amount)
					init_inventory_grid(item_name, item_amount)
					var sort = int(name.replace("InventoryGrid", ""))
					player.item_bar_amounts[sort] = item_amount
					if sort < 9:
						StaticLoad.game.refresh_item_grid(sort)
			elif item_name == "AIR" and not StaticLoad.get_is_durable_by_name(StaticLoad.game.mouse_item_name):
				item_name = StaticLoad.game.mouse_item_name
				StaticLoad.game.mouse_item_amount -= 1
				item_amount += 1
				if StaticLoad.game.mouse_item_amount == 0:
					StaticLoad.game.mouse_item_name = "AIR"
				update_progress_bar(item_name, item_amount)
				init_inventory_grid(item_name, item_amount)
				var sort = int(name.replace("InventoryGrid", ""))
				player.item_bar_names[sort] = item_name
				player.item_bar_amounts[sort] = item_amount
				if sort < 9:
					StaticLoad.game.refresh_item_grid(sort)
			elif StaticLoad.get_is_durable_by_name(item_name):
				StaticLoad.game.mouse_item_name = item_name
				StaticLoad.game.mouse_item_amount = item_amount
				init_inventory_grid(mouse_item_name_tmp, mouse_item_amount_tmp)
				var sort = int(name.replace("InventoryGrid", ""))
				player.item_bar_names[sort] = item_name
				player.item_bar_amounts[sort] = item_amount
				update_progress_bar(item_name, item_amount)
				if StaticLoad.game.mouse_item_name_label != null:
					StaticLoad.game.mouse_item_name_label.stop_following()
					StaticLoad.game.mouse_item_name_label.queue_free()
					if item_name != "AIR":
						StaticLoad.game.mouse_item_name_label = StaticLoad.mouse_item_name_label_scene.instantiate()
						StaticLoad.game.game_ui.add_child(StaticLoad.game.mouse_item_name_label)
						StaticLoad.game.mouse_item_name_label.text = tr(item_name)
						StaticLoad.game.mouse_item_name_label.start_following()
				if sort < 9:
					StaticLoad.game.refresh_item_grid(sort)
		elif event.button_index == 3 and player.gamemode == "creative":
			if mouse_item_amount_tmp == 0 and item_name != "AIR":
				StaticLoad.game.mouse_item_name = item_name
				StaticLoad.game.mouse_item_amount = StaticLoad.get_max_amount_by_name(item_name)
	elif name.contains("InfiniteGrid") and player.gamemode == "creative":
		if event.button_index == 1:
			if Input.is_action_pressed("shift"):
				player.get_item([item_name, StaticLoad.get_max_amount_by_name(item_name), 0, 9, false])
				StaticLoad.game.append_process_refresh("refresh_inventory")
				StaticLoad.game.append_process_refresh("refresh_item_grid")
			else:
				if mouse_item_amount_tmp == 0:
					StaticLoad.game.mouse_item_name = item_name
					if StaticLoad.get_is_durable_by_name(item_name):
						StaticLoad.game.mouse_item_amount = StaticLoad.get_max_amount_by_name(item_name)
					else:
						StaticLoad.game.mouse_item_amount = 1
				elif mouse_item_name_tmp == item_name and not StaticLoad.get_is_durable_by_name(item_name):
					if StaticLoad.game.mouse_item_amount < StaticLoad.get_max_amount_by_name(item_name):
						StaticLoad.game.mouse_item_amount += 1
				elif mouse_item_name_tmp != item_name:
					StaticLoad.game.mouse_item_name = "AIR"
					StaticLoad.game.mouse_item_amount = 0
		if event.button_index == 2:
			if mouse_item_amount_tmp != 0:
				if StaticLoad.get_is_durable_by_name(mouse_item_name_tmp):
					StaticLoad.game.mouse_item_amount = 0
				else:
					StaticLoad.game.mouse_item_amount -= 1
				if StaticLoad.game.mouse_item_amount <= 0:
					StaticLoad.game.mouse_item_name = "AIR"
		elif event.button_index == 3:
			if mouse_item_amount_tmp == 0 and item_name != "AIR":
				StaticLoad.game.mouse_item_name = item_name
				StaticLoad.game.mouse_item_amount = StaticLoad.get_max_amount_by_name(item_name)
	elif slot_function == "delete":
		if Input.is_action_pressed("shift") and player.gamemode == "creative":
			for i in range(36):
				player.item_bar_amounts[i] = 0
				player.item_bar_names[i] = "AIR"
			StaticLoad.game.append_process_refresh("refresh_item_grid")
			StaticLoad.game.append_process_refresh("refresh_inventory")
		else:
			StaticLoad.game.mouse_item_name = "AIR"
			StaticLoad.game.mouse_item_amount = 0
	#var sort = player.selected_item_grid
	#player.item_bar_names[sort] = item_name
	#StaticLoad.game.refresh_item_grid(sort)
	#StaticLoad.game.sound_audio_manager.play_audio_static("gui", "select")
	#StaticLoad.game.item_grids[sort].get_node("Blink").animation = "blink"
	#StaticLoad.game.item_grids[sort].get_node("Blink").frame = 0
	#StaticLoad.game.item_grids[sort].get_node("Blink").play()
	#StaticLoad.game.item_name_label.text = player.item_bar_names[sort]
	#StaticLoad.game.item_name_timer = StaticLoad.ITEM_NAME_SHOW_TIME
