extends Node

@onready var touch_time_counters = $TouchTimeCounters

var mouse_dict: Dictionary
var touch_dict: Dictionary
var game

func _ready() -> void:
	game = get_node("/root/Game")

func _process(delta: float) -> void:
	execute_mouse_pressing_actions()
	execute_touch_pressing_actions()

func _on_screen_input_receiver_gui_input(event: InputEvent) -> void:
	if not ClientManager.check_connections():
		return
	if event is InputEventMouseButton:
		if event.pressed:
			mouse_dict[event.button_index] = event
			mouse_pressed(event)
		else:
			mouse_released(event)
			mouse_dict.erase(event.button_index)
	
	if event is InputEventMouseMotion:
		mouse_moved(event)
	
	if event is InputEventScreenTouch:
		if event.pressed:
			touch_dict[event.index] = event
			var time_counter_instance = SceneManager.get_scene("others/time_counter").instantiate()
			touch_time_counters.add_child(time_counter_instance)
			time_counter_instance.name = str(event.index)
			time_counter_instance.start_counting()
			touch_pressed(event)
		else:
			touch_released(event)
			touch_dict.erase(event.index)
			var time_counter = touch_time_counters.get_node(str(event.index))
			time_counter.stop_counting()
			time_counter.queue_free()	
	
	if event is InputEventScreenDrag:
		if touch_dict.has(event.index):
			touch_dict[event.index].position = event.position

func touch_pressed(event: InputEvent) -> void:
	ActionManager.execute_action("block_selection_frame", "set_frame_restricted_position", event.position)
	ActionManager.execute_action("block_selection_frame", "refresh_visible_timer")

func touch_released(event: InputEvent) -> void:
	var pressed_time = touch_time_counters.get_node(str(event.index)).timer
	var selected_block_layer = BlockLayer.get_index(ClientManager.local_player.current_set_layer)
	var handheld_item_name = ClientManager.local_player.get_handheld_name()
	var touch_world_position = WorldTransformer.screen_position_to_world_position(ClientManager.local_player.camera, event.position)
	var touch_block_coordinate = WorldTransformer.get_block_coordinate(touch_world_position)
	var final_touch_block_coordinate = touch_block_coordinate
	var touch_block_id = WorldTransformer.block_coordinate_to_id(final_touch_block_coordinate, selected_block_layer)
	if ClientManager.local_player.gamemode != "creative":
		final_touch_block_coordinate = WorldTransformer.get_restricted_block_selection_position(touch_block_coordinate)
	if pressed_time < StaticLoad.LONG_TOUCH_TIME:
		var is_punched = false
		if AttributeManager.get_block_name(touch_block_id) == "CRAFTING_TABLE":
			game.refresh_crafting_inventory()
			game.ui_freeze_timer = 0.3
			game.crafting_ui.visible = true
			InputManager.is_input_frozen = true
		elif ClientManager.local_player.in_hand_item_name.contains("SPAWN_EGG"):
			var is_can_spawn = true
			if ClientManager.local_player.gamemode != "creative" and not ClientManager.local_player.check_attached_block(final_touch_block_coordinate, selected_block_layer):
				is_can_spawn = false
			elif touch_block_id != 0 and not StaticLoad.get_is_transparent_by_id(touch_block_id):
				is_can_spawn = false
			if is_can_spawn:
				var splits = ClientManager.local_player.in_hand_item_name.split("_")
				var entity_type = splits[0].to_lower()
				var uuid = UUID.v4()
				var summon_entity_args = [entity_type, uuid, str(uuid), touch_world_position, "default"]
				if StaticLoad.is_muti_mode:
					if multiplayer.get_unique_id() == 1:
						ClientManager.local_player.create_entity(summon_entity_args)
						StaticLoad.rpc_entity_func_by_uuid(ClientManager.local_player.get_uuid(), "create_entity", summon_entity_args, "others", true)
					else:
						StaticLoad.rpc_entity_func_by_uuid(ClientManager.local_player.get_uuid(), "create_entity", summon_entity_args, [1, multiplayer.get_unique_id()], false)
				else:
					ClientManager.local_player.create_entity(summon_entity_args)
				ClientManager.local_player.is_punching = true
				if ClientManager.local_player.face_state < 0 and WorldTransformer.get_block_coordinate(ClientManager.local_player.position).x < final_touch_block_coordinate.x:
					ClientManager.local_player.face_state = 1
				elif ClientManager.local_player.face_state > 0 and WorldTransformer.get_block_coordinate(ClientManager.local_player.position).x > final_touch_block_coordinate.x:
					ClientManager.local_player.face_state = -1
				if ClientManager.local_player.gamemode != "creative":
					var select_sort = ClientManager.local_player.selected_item_grid
					ClientManager.local_player.item_bar_amounts[select_sort] -= 1
					if ClientManager.local_player.item_bar_amounts[select_sort] <= 0:
						ClientManager.local_player.item_bar_names[select_sort] = "AIR"
					game.refresh_item_grid(select_sort)
		elif ClientManager.local_player.sword_breaking_timer > 0:
			pass
		elif touch_block_id == 0 and ClientManager.local_player.current_set_layer == "solid":
			if ClientManager.local_player.punch_timer <= 0 and touch_block_id == 0 and not ClientManager.local_player.animation_tree["parameters/Punch/active"]:
				var touch_chunk_coordinate = WorldTransformer.get_chunk_coordinate(final_touch_block_coordinate)
				var touch_chunk_name = str(touch_chunk_coordinate[0])+"."+str(touch_chunk_coordinate[1])
				if game.loaded_chunks.has(touch_chunk_name) and game.loaded_chunks[touch_chunk_name].is_loaded:
					for player_tmp in ClientManager.players.get_children():
						if player_tmp == ClientManager.local_player:
							continue
						var entity_block_coordinate = WorldTransformer.get_block_coordinate(player_tmp.position)
						if entity_block_coordinate == final_touch_block_coordinate or entity_block_coordinate-Vector2i(0,1) == final_touch_block_coordinate:
							if not StaticLoad.is_muti_mode or (StaticLoad.is_muti_mode and multiplayer.get_unique_id() == 1):
								ClientManager.local_player.punch(["player", player_tmp.player_peer_id])
							elif StaticLoad.is_muti_mode and multiplayer.get_unique_id() != 1:
								StaticLoad.rpc_entity_func_by_uuid(ClientManager.local_player.get_uuid(), "punch", ["player", player_tmp.player_peer_id], [1], true)
							ClientManager.local_player.is_punching = true
							ClientManager.local_player.punch_timer = 1
							if StaticLoad.is_muti_mode:
								ClientManager.local_player.changed_state_dict["is_punching"] = true
							is_punched = true
							break
					if not is_punched:
						for entity in ClientManager.mobs.get_children():
							if entity == null:
								continue
							if ["arrow", "item"].has(entity.get_entity_type()):
								continue
							var entity_block_coordinate = WorldTransformer.get_block_coordinate(entity.position)
							if entity_block_coordinate == final_touch_block_coordinate:
								if not StaticLoad.is_muti_mode or (StaticLoad.is_muti_mode and multiplayer.get_unique_id() == 1):
									ClientManager.local_player.punch(["entity", entity.get_uuid()])
								elif StaticLoad.is_muti_mode and multiplayer.get_unique_id() != 1:
									StaticLoad.rpc_entity_func_by_uuid(ClientManager.local_player.get_uuid(), "punch", ["entity", entity.get_uuid()], [1], true)
								ClientManager.local_player.is_punching = true
								ClientManager.local_player.punch_timer = 1
								if StaticLoad.is_muti_mode:
									ClientManager.local_player.changed_state_dict["is_punching"] = true
								is_punched = true
								break
					if not is_punched:
						for entity in ClientManager.undead_mobs.get_children():
							if entity == null:
								continue
							if ["arrow", "item"].has(entity.get_entity_type()):
								continue
							var entity_block_coordinate = WorldTransformer.get_block_coordinate(entity.position)
							if entity_block_coordinate == final_touch_block_coordinate or entity_block_coordinate-Vector2i(0,1) == final_touch_block_coordinate:
								if not StaticLoad.is_muti_mode or (StaticLoad.is_muti_mode and multiplayer.get_unique_id() == 1):
									ClientManager.local_player.punch(["entity", entity.get_uuid()])
								elif StaticLoad.is_muti_mode and multiplayer.get_unique_id() != 1:
									StaticLoad.rpc_entity_func_by_uuid(ClientManager.local_player.get_uuid(), "punch", ["entity", entity.get_uuid()], [1], true)
								ClientManager.local_player.is_punching = true
								ClientManager.local_player.punch_timer = 1
								if StaticLoad.is_muti_mode:
									ClientManager.local_player.changed_state_dict["is_punching"] = true
								is_punched = true
								break
		if not is_punched:
			if ClientManager.local_player.gamemode == "creative":
				ClientManager.local_player.place_block(final_touch_block_coordinate)
			else:
				ClientManager.local_player.place_block(final_touch_block_coordinate)
	elif not Input.is_mouse_button_pressed(1) and not Input.is_mouse_button_pressed(2):
			if ClientManager.local_player.is_eating:
				ClientManager.local_player.is_eating = false
				ClientManager.local_player.last_eat_stage = -1
				ClientManager.local_player.eat_timer = 0


func touch_dragged(event: InputEvent) -> void:
	ActionManager.execute_action("block_selection_frame", "set_frame_restricted_position", event.position)
	ActionManager.execute_action("block_selection_frame", "refresh_visible_timer")
	if ClientManager.local_player.gamemode != "creative":
		var mouse_position = InputManager.get_mouse_position()
		var final_mouse_coordinate = WorldTransformer.get_block_coordinate(WorldTransformer.get_restricted_block_selection_position(mouse_position))
		if WorldTransformer.get_block_coordinate(InputManager.prev_mouse_position) != final_mouse_coordinate:
			ClientManager.local_player.destroy_timer = 0
			if ClientManager.game.destroy_light_names.has(ClientManager.local_player.player_peer_id):
				ClientManager.game.destroy_light_names[ClientManager.local_player.player_peer_id].set_texture(null)
		InputManager.prev_mouse_position = mouse_position

func mouse_pressed(event: InputEvent) -> void:
	if event.button_index == 1:
		if ClientManager.local_player.gamemode != "creative":
			ActionManager.execute_action("block_selection_frame", "set_frame_restricted_position", event.position)
		else:
			ActionManager.execute_action("block_selection_frame", "set_frame_restricted_position", event.position)
		ActionManager.execute_action("block_selection_frame", "refresh_visible_timer")
	if event.button_index == 4:
		if Input.is_action_pressed("ctrl"):
			ActionManager.execute_action("mini_map", "zoom_in")
		else:
			if ClientManager.local_player.selected_item_grid >= 1:
				ActionManager.execute_action("hot_bar", "select_slot", ClientManager.local_player.selected_item_grid-1)
			else:
				ActionManager.execute_action("hot_bar", "select_slot", ClientManager.local_player.selected_item_grid-8)
			ActionManager.execute_action("block_selection_frame", "update_visible", ClientManager.local_player.item_bar_names[ClientManager.local_player.selected_item_grid])
			ActionManager.execute_action("hot_bar_text", "refresh")
	if event.button_index == 5:
		if Input.is_action_pressed("ctrl"):
			ActionManager.execute_action("mini_map", "zoom_out")
		else:
			if ClientManager.local_player.selected_item_grid <= 7:
				ActionManager.execute_action("hot_bar", "select_slot", ClientManager.local_player.selected_item_grid+1)
			else:
				ActionManager.execute_action("hot_bar", "select_slot", 0)
			ActionManager.execute_action("block_selection_frame", "update_visible", ClientManager.local_player.item_bar_names[ClientManager.local_player.selected_item_grid])
			ActionManager.execute_action("hot_bar_text", "refresh")

func mouse_released(event: InputEvent) -> void:
	if event.button_index == 1:
		ClientManager.local_player.destroy_timer = 0
		if ClientManager.game.destroy_light_names.has(ClientManager.local_player.player_peer_id):
			ClientManager.game.destroy_light_names[ClientManager.local_player.player_peer_id].set_texture(null)
	if event.button_index == 2:
		if ClientManager.local_player.is_pulling:
			ClientManager.local_player.is_pulling = false
			if ClientManager.local_player.shoot_timer > 0:
				ClientManager.local_player.in_hand_item_name = "BOW"
				ClientManager.local_player.set_item_in_hand("BOW")
				ClientManager.local_player.shoot_arrow()
				ClientManager.local_player.shoot_timer = 0
				ClientManager.local_player.last_shoot_stage = -1
		elif ClientManager.local_player.is_eating:
			ClientManager.local_player.is_eating = false
			ClientManager.local_player.last_eat_stage = -1
			ClientManager.local_player.eat_timer = 0

func mouse_moved(event: InputEvent) -> void:
	ActionManager.execute_action("block_selection_frame", "set_frame_restricted_position", event.position)
	ActionManager.execute_action("block_selection_frame", "refresh_visible_timer")
	if ClientManager.local_player.gamemode != "creative":
		var mouse_position = InputManager.get_mouse_position()
		var final_mouse_coordinate = WorldTransformer.get_block_coordinate(WorldTransformer.get_restricted_block_selection_position(mouse_position))
		if WorldTransformer.get_block_coordinate(InputManager.prev_mouse_position) != final_mouse_coordinate:
			ClientManager.local_player.destroy_timer = 0
			if ClientManager.game.destroy_light_names.has(ClientManager.local_player.player_peer_id):
				ClientManager.game.destroy_light_names[ClientManager.local_player.player_peer_id].set_texture(null)
		InputManager.prev_mouse_position = mouse_position

func execute_mouse_pressing_actions():
	if ClientManager.local_player.is_dead:
		return
	var mouse_position = InputManager.get_mouse_position()
	var mouse_coordinate = WorldTransformer.get_block_coordinate(mouse_position)
	var chunk_coordinate = WorldTransformer.get_chunk_coordinate(mouse_coordinate)
	var chunk_name = str(chunk_coordinate[0])+"."+str(chunk_coordinate[1])
	var final_mouse_coordinate = mouse_coordinate
	if ClientManager.local_player.gamemode != "creative":
		final_mouse_coordinate = WorldTransformer.get_block_coordinate(WorldTransformer.get_restricted_block_selection_position(mouse_position))
	var selected_block_layer = BlockLayer.get_index(ClientManager.local_player.current_set_layer)
	var block_id = WorldTransformer.block_coordinate_to_id(final_mouse_coordinate, selected_block_layer)
	var handheld_item_name = ClientManager.local_player.get_handheld_name()
	# 长按左键
	if mouse_dict.has(1) and not mouse_dict.has(2):
		if AttributeManager.get_tool_type(handheld_item_name) == "sword":
			if ClientManager.local_player.attack_timer <= 0:
				ClientManager.local_player.is_punching = true
		elif ClientManager.local_player.sword_breaking_timer > 0:
			pass
		elif block_id == 0 and selected_block_layer == BlockLayer.MIDDLE:
			if ClientManager.local_player.punch_timer <= 0 and block_id == 0 and not ClientManager.local_player.animation_tree["parameters/Punch/active"]:
				if StaticLoad.game.loaded_chunks.has(chunk_name) and StaticLoad.game.loaded_chunks[chunk_name].is_loaded:
					var is_punched = false
					for player_tmp in ClientManager.players.get_children():
						if player_tmp == ClientManager.local_player:
							continue
						var entity_block_coordinate = WorldTransformer.get_block_coordinate(player_tmp.position)
						if entity_block_coordinate == final_mouse_coordinate or entity_block_coordinate-Vector2i(0,1) == final_mouse_coordinate:
							if not StaticLoad.is_muti_mode or (StaticLoad.is_muti_mode and multiplayer.get_unique_id() == 1):
								ClientManager.local_player.punch(["player", player_tmp.player_peer_id])
							elif StaticLoad.is_muti_mode and multiplayer.get_unique_id() != 1:
								StaticLoad.rpc_entity_func_by_uuid(ClientManager.local_player.get_uuid(), "punch", ["player", player_tmp.player_peer_id], [1], true)
							ClientManager.local_player.is_punching = true
							ClientManager.local_player.punch_timer = 1
							if StaticLoad.is_muti_mode:
								ClientManager.local_player.changed_state_dict["is_punching"] = true
							is_punched = true
							break
					if not is_punched:
						for entity in ClientManager.mobs.get_children():
							if entity == null:
								continue
							if ["arrow", "item"].has(entity.get_entity_type()):
								continue
							var entity_block_coordinate = WorldTransformer.get_block_coordinate(entity.position)
							if entity_block_coordinate == final_mouse_coordinate:
								if not StaticLoad.is_muti_mode or (StaticLoad.is_muti_mode and multiplayer.get_unique_id() == 1):
									ClientManager.local_player.punch(["entity", entity.get_uuid()])
								elif StaticLoad.is_muti_mode and multiplayer.get_unique_id() != 1:
									StaticLoad.rpc_entity_func_by_uuid(ClientManager.local_player.get_uuid(), "punch", ["entity", entity.get_uuid()], [1], true)
								ClientManager.local_player.is_punching = true
								ClientManager.local_player.punch_timer = 1
								if StaticLoad.is_muti_mode:
									ClientManager.local_player.changed_state_dict["is_punching"] = true
								is_punched = true
								break
					if not is_punched:
						for entity in ClientManager.undead_mobs.get_children():
							if entity == null:
								continue
							if ["arrow", "item"].has(entity.get_entity_type()):
								continue
							var entity_block_coordinate = WorldTransformer.get_block_coordinate(entity.position)
							if entity_block_coordinate == final_mouse_coordinate or entity_block_coordinate-Vector2i(0,1) == final_mouse_coordinate:
								if not StaticLoad.is_muti_mode or (StaticLoad.is_muti_mode and multiplayer.get_unique_id() == 1):
									ClientManager.local_player.punch(["entity", entity.get_uuid()])
								elif StaticLoad.is_muti_mode and multiplayer.get_unique_id() != 1:
									StaticLoad.rpc_entity_func_by_uuid(ClientManager.local_player.get_uuid(), "punch", ["entity", entity.get_uuid()], [1], true)
								ClientManager.local_player.is_punching = true
								ClientManager.local_player.punch_timer = 1
								if StaticLoad.is_muti_mode:
									ClientManager.local_player.changed_state_dict["is_punching"] = true
								is_punched = true
								break
		elif ClientManager.local_player.gamemode == "creative":
			ClientManager.local_player.destroy_block(mouse_coordinate)
		else:
			ClientManager.local_player.destroy_timer += get_process_delta_time()
	elif Input.is_mouse_button_pressed(2) and not Input.is_mouse_button_pressed(1):
		if ClientManager.local_player.in_hand_item_name.contains("SPAWN_EGG"):
			pass
		elif ClientManager.local_player.sword_breaking_timer > 0:
			pass
		elif StaticLoad.food_dict.has(ClientManager.local_player.in_hand_item_name):
			if not ClientManager.local_player.is_eating and ClientManager.local_player.gamemode != "creative" and ClientManager.local_player.hunger < 20:
				ClientManager.local_player.is_eating = true
		elif ClientManager.local_player.in_hand_item_name.contains("BOW"):
			if ClientManager.local_player.gamemode != "creative" and not ClientManager.local_player.item_bar_names.has("ARROW"):
				pass
			elif ClientManager.local_player.item_bar_names[ClientManager.local_player.selected_item_grid].contains("BOW"):
				ClientManager.local_player.is_pulling = true
		else:
			ClientManager.local_player.place_block(final_mouse_coordinate)

func execute_touch_pressing_actions():
	var selected_block_layer = BlockLayer.get_index(ClientManager.local_player.current_set_layer)
	var handheld_item_name = ClientManager.local_player.get_handheld_name()
	for index in touch_dict:
		var event = touch_dict[index]
		var pressed_time = touch_time_counters.get_node(str(index)).timer
		var touch_world_position = WorldTransformer.screen_position_to_world_position(ClientManager.local_player.camera, event.position)
		var touch_block_coordinate = WorldTransformer.get_block_coordinate(touch_world_position)
		var final_touch_block_coordinate = touch_block_coordinate
		var block_id = WorldTransformer.block_coordinate_to_id(final_touch_block_coordinate, selected_block_layer)
		if ClientManager.local_player.gamemode != "creative":
			final_touch_block_coordinate = WorldTransformer.get_restricted_block_selection_position(touch_block_coordinate)
		if event.double_tap:
			if ClientManager.local_player.gamemode == "creative":
				game.grab_item(final_touch_block_coordinate)
			ClientManager.local_player.place_block(final_touch_block_coordinate)
		elif pressed_time >= StaticLoad.LONG_TOUCH_TIME:		
			if AttributeManager.get_tool_type(handheld_item_name) == "sword":
				if ClientManager.local_player.attack_timer <= 0:
					ClientManager.local_player.is_punching = true
			elif ClientManager.local_player.sword_breaking_timer > 0:
				pass
			elif StaticLoad.food_dict.has(ClientManager.local_player.in_hand_item_name):
				if not ClientManager.local_player.is_eating and ClientManager.local_player.gamemode != "creative" and ClientManager.local_player.hunger < 20:
					ClientManager.local_player.is_eating = true
			elif ClientManager.local_player.in_hand_item_name.contains("BOW"):
				if ClientManager.local_player.gamemode != "creative" and not ClientManager.local_player.item_bar_names.has("ARROW"):
					pass
				elif ClientManager.local_player.item_bar_names[ClientManager.local_player.selected_item_grid].contains("BOW"):
					ClientManager.local_player.is_pulling = true
			elif ClientManager.local_player.gamemode == "creative":
				ClientManager.local_player.destroy_block(final_touch_block_coordinate)
			else:
				ClientManager.local_player.destroy_timer += get_process_delta_time()
