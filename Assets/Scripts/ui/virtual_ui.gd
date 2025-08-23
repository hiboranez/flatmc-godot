extends CanvasLayer

@onready var left_ui = $LeftUI
@onready var right_ui = $RightUI
@onready var move_joystick = $LeftUI/MoveJoystick
@onready var operate_joystick = $RightUI/OperateJoystick
@onready var jump_button = $RightUI/JumpButton
@onready var sprint_button = $RightUI/SprintButton

var game

func _ready() -> void:
	game = get_node("/root/Game")

func _process(delta: float) -> void:
	updat_move_joy_stick()

func updat_move_joy_stick() -> void:
	if ClientManager.local_player != null:
		var joystick_pos = move_joystick.get_now_pos()
		if joystick_pos.x != 0:
			if joystick_pos.x > 0:
				ClientManager.local_player.face_state = 1
			elif joystick_pos.x < 0:
				ClientManager.local_player.face_state = -1
			if sprint_button.is_pressed and not ClientManager.local_player.is_sneaking and (ClientManager.local_player.hunger > 6 or ClientManager.local_player.gamemode == "creative"):
				ClientManager.local_player.move_state = "run"
			else:
				ClientManager.local_player.move_state = "walk"
		elif game.move_input_list.is_empty():
			ClientManager.local_player.move_state = "idle"
		
		if joystick_pos.y < -0.4 and not ClientManager.local_player.is_jump_pressed:
			ClientManager.local_player.is_jump_pressed = true
		
		if joystick_pos.y > 0.4 and not ClientManager.local_player.is_down_pressed:
			ClientManager.local_player.is_down_pressed = true

func set_ui_visible(is_visible: bool) -> void:
	left_ui.visible = is_visible
	right_ui.visible = is_visible

func set_jump_button_background(background_texture: Texture2D) -> void:
	jump_button.background_rect.texture = background_texture

func get_move_joystick_value() -> Vector2:
	return move_joystick.get_now_pos()

func _on_f1_button_pressed():
	if game.is_map or game.is_pause or game.is_chat or game.is_inventory or game.is_crafting or game.is_sign_edit:
		return
	AudioManager.play_static_audio("sound/ui/click")
	game.switch_ui_visibility()
	visible = game.game_ui.visible

func _on_f2_button_pressed():
	if game.is_map or game.is_pause or game.is_chat or game.is_inventory or game.is_crafting or game.is_sign_edit:
		return
	AudioManager.play_static_audio("sound/ui/click")
	game.screenshot()
	
func _on_f3_button_pressed():
	if game.is_map or game.is_pause or game.is_chat or game.is_inventory or game.is_crafting or game.is_sign_edit:
		return
	AudioManager.play_static_audio("sound/ui/click")
	game.switch_details_visibility()

func _on_menu_button_pressed():
	if game.is_map or game.is_pause or game.is_chat or game.is_inventory or game.is_crafting or game.is_sign_edit:
		return
	AudioManager.play_static_audio("sound/ui/click")
	if game.is_chat:
		game.close_chat_ui()
		await get_tree().create_timer(0.01).timeout
		if StaticLoad.is_on_mobile_platform:
			game.reset_touch(false)
	else:
		game.pause_ui.visible = !game.pause_ui.visible
		game.is_pause = game.pause_ui.visible
		if game.pause_ui.visible:
			game.is_input_frozen = true
			game.move_input_list.clear()
			game.player.stop_move()
		if StaticLoad.is_on_mobile_platform:
			game.reset_touch(true)

func _on_chat_button_pressed():
	if game.is_map or game.is_pause or game.is_chat or game.is_inventory or game.is_crafting or game.is_sign_edit:
		return
	AudioManager.play_static_audio("sound/ui/click")
	if not game.is_chat:
		game.move_input_list.clear()
		game.player.stop_move()
		game.is_input_frozen = true
		game.is_chat = true
		game.chat_message_out.visible = false
		game.chat_panel.visible = true
		await get_tree().create_timer(0.001).timeout
		game.chat_history_in.scroll_vertical = 1e9
		game.chat_line_edit.grab_focus()
		game.chat_line_edit.text = ""
		if StaticLoad.is_on_mobile_platform:
			game.reset_touch(true)
	else:
		game.close_chat_ui()
		await get_tree().create_timer(0.01).timeout
		if StaticLoad.is_on_mobile_platform:
			game.reset_touch(false)

func _on_tab_button_pressed():
	if game.is_map or game.is_pause or game.is_chat or game.is_inventory or game.is_crafting or game.is_sign_edit:
		return
	AudioManager.play_static_audio("sound/ui/click")
	if game.online_ui.visible:
		game.online_ui.visible = false
	elif StaticLoad.is_muti_mode:
		game.open_online_info_ui()

func _on_jump_button_state_changed(is_pressed: bool):
	if is_pressed:
		game.player.is_jump_pressed = true
	else:
		game.player.is_jump_pressed = false

func _on_sprint_button_pressed(is_pressed: bool) -> void:
	if game.is_map or game.is_pause or game.is_chat or game.is_inventory or game.is_crafting or game.is_sign_edit:
		return
	AudioManager.play_static_audio("sound/ui/click")
	game.is_mobile_running = is_pressed

func _on_sneak_button_pressed(is_pressed: bool) -> void:
	if game.is_map or game.is_pause or game.is_chat or game.is_inventory or game.is_crafting or game.is_sign_edit:
		return
	AudioManager.play_static_audio("sound/ui/click")
	if is_pressed and not game.player.is_sneaking:
		game.player.is_sneaking = true
		if game.player.move_state == "run":
			game.player.move_state = "walk"
	elif not is_pressed and game.player.is_sneaking:
		game.player.is_sneaking = false

func _on_switch_layer_button_pressed(is_pressed: bool) -> void:
	if game.is_map or game.is_pause or game.is_chat or game.is_inventory or game.is_crafting or game.is_sign_edit:
		return
	AudioManager.play_static_audio("sound/ui/click")
	if is_pressed and game.player.current_set_layer == "solid":
		game.player.current_set_layer = "back"
		game.tile_map_layer.modulate = Color(0.393,0.393,0.393,1)
		game.no_reach_tile_map_layer.modulate = Color(0.393,0.393,0.393,1)
		game.back_tile_map_layer.modulate = Color(1,1,1,1)
	elif not is_pressed and game.player.current_set_layer == "back":
		game.player.current_set_layer = "solid"
		game.tile_map_layer.modulate = Color(1,1,1,1)
		game.no_reach_tile_map_layer.modulate = Color(1,1,1,1)
		game.back_tile_map_layer.modulate = Color(0.393,0.393,0.393,1)
