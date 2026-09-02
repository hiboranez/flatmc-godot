extends Sprite2D

var block_selection_display_time: float = 3
var block_selection_disappear_time: float = 0.2
var visible_timer: float = 0

func _ready() -> void:
	block_selection_display_time = float(SettingsManager.get_default_value("block_selection_display_time"))
	block_selection_disappear_time = float(SettingsManager.get_default_value("block_selection_disappear_time"))
	ActionManager.register_action("block_selection_frame", "update_visible", update_visible)
	ActionManager.register_action("block_selection_frame", "set_frame_restricted_location", set_frame_restricted_location)
	ActionManager.register_action("block_selection_frame", "refresh_visible_timer", refresh_visible_timer)
	ActionManager.register_action("block_selection_frame", "set_frame_location", set_frame_location)
	ActionManager.register_action("block_selection_frame", "set_frame_position", set_frame_position)
	ActionManager.register_action("block_selection_frame", "set_frame_coordinate", set_frame_coordinate)

func _process(delta: float) -> void:
	if SettingsManager.get_current_setting("block_selection_box") == "show_when_changing":
		if InputManager.is_move_input_frozen:
			visible_timer = 0
		if visible_timer > 0 and visible_timer <= block_selection_disappear_time:
			var alpha = visible_timer/block_selection_disappear_time
			self_modulate = Color(1,1,1,alpha)
		elif visible_timer > block_selection_disappear_time:
			self_modulate = Color(1,1,1,1)
		else:
			self_modulate = Color(1,1,1,0)
		if visible_timer > 0:
			visible_timer -= get_process_delta_time()
	elif SettingsManager.get_current_setting("block_selection_box") == "always_show":
		self_modulate = Color(1,1,1,1)
	elif SettingsManager.get_current_setting("block_selection_box") == "never_show":
		self_modulate = Color(1,1,1,0)

func update_visible(handheld_item_name: String) -> void:
	if AttributeManager.tool_type_dict.has(handheld_item_name) and AttributeManager.tool_type_dict[handheld_item_name].has("sword"):
		visible = false
	else:
		visible = true

func refresh_visible_timer() -> void:
	visible_timer = block_selection_display_time

func set_frame_restricted_location(screen_location: Vector2) -> void:
	if not ClientManager.is_game_connected:
		return
	if ClientManager.local_player.gamemode == "creative":
		set_frame_position(WorldTransformer.screen_position_to_world_position(ClientManager.local_player.camera, screen_location))
	else:
		var restricted_block_selection_position = WorldTransformer.get_restricted_block_selection_position(WorldTransformer.screen_position_to_world_position(ClientManager.local_player.camera, screen_location))
		set_frame_position(restricted_block_selection_position)

func set_frame_location(screen_location: Vector2) -> void:
	if not ClientManager.is_game_connected:
		return
	set_frame_position(WorldTransformer.screen_position_to_world_position(ClientManager.local_player.camera, screen_location))

func set_frame_position(world_position: Vector2) -> void:
	if not ClientManager.is_game_connected:
		return
	var x_offset = 25
	var y_offset = -25
	if world_position.x < 0:
		x_offset = -25
	if world_position.y > 0:
		y_offset = 25
	@warning_ignore("integer_division")
	position = Vector2((int(world_position.x)/50)*50+x_offset, (int(world_position.y)/50)*50+y_offset)
	var block_x_offset = -1
	var block_y_offset = -1
	if world_position.x > 0:
		block_x_offset = 0
	if world_position.y > 0:
		block_y_offset = 0
	@warning_ignore("integer_division")
	var block_pos = Vector2i(int(world_position.x)/50+block_x_offset, int(world_position.y)/50+block_y_offset)
	ClientManager.local_player.selected_block_pos = block_pos

func set_frame_coordinate(block_coordinate: Vector2i) -> void:
	if not ClientManager.is_game_connected:
		return
	var x_offset = 25
	var y_offset = 25
	#if block_coordinate.x < 0:
		#x_offset = -25
	#if block_coordinate.y > 0:
		#y_offset = 25
	position = Vector2((block_coordinate.x)*50+x_offset, (block_coordinate.y)*50+y_offset)
	ClientManager.local_player.selected_block_pos = block_coordinate
