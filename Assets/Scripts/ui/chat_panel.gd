extends Control

@onready var outside_history = $OutsideHistory
@onready var outside_history_vbox_container = $OutsideHistory/VBoxContainer
@onready var inside_panel = $InsidePanel
@onready var inside_history = $InsidePanel/InsideHistory
@onready var inside_history_vbox_container = $InsidePanel/InsideHistory/VoxContainer
@onready var line_edit = $InsidePanel/LineEdit

func _on_line_edit_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if not event.pressed and Rect2(Vector2(), size).has_point(event.position):
			if line_edit.has_focus():
				line_edit.release_focus()
			else:
				line_edit.grab_focus()
				line_edit.select_all()

func open_chat(is_command_mode: bool) -> void:
	if ClientManager.local_ClientManager.local_player.is_dead:
		return
	ClientManager.local_ClientManager.local_player.stop_move()
	InputManager.is_move_input_frozen = true
	outside_history_vbox_container.visible = false
	inside_panel.visible = true
	if get_tree() != null:
		await get_tree().process_frame
	inside_history.scroll_vertical = 1e9
	line_edit.grab_focus()
	line_edit.text = ""
	if is_command_mode:
		line_edit.insert_text_at_caret("/")

func close_chat() -> void:
	line_edit.release_focus()
	InputManager.is_move_input_frozen = false
	inside_panel.visible = false
	outside_history_vbox_container.visible = true
	if get_tree() != null:
		await get_tree().process_frame
	inside_history.scroll_vertical = 1e9
	outside_history.scroll_vertical = 1e9
	line_edit.text = ""
	
func add_message(text:String, color="white"):
	var messgae_in_instance = SceneManager.get_scene("ui/chat_message").instantiate()
	messgae_in_instance.text = text
	var messgae_out_instance = SceneManager.get_scene("ui/chat_message").instantiate()
	messgae_out_instance.text = text
	if color != "white":
		messgae_in_instance.set("theme_override_colors/font_color", StaticLoad.colors[color])
		messgae_out_instance.set("theme_override_colors/font_color", StaticLoad.colors[color])
	inside_history_vbox_container.add_child(messgae_in_instance)
	outside_history_vbox_container.add_child(messgae_out_instance)
	if inside_panel.visible:
		outside_history_vbox_container.visible = false
	if get_tree() != null:
		await get_tree().process_frame
	inside_history_vbox_container.scroll_vertical = 1e9
	messgae_out_instance.is_disappearing = true
	messgae_out_instance.detect_and_disappear()

func _on_line_edit_text_submitted(new_text: String) -> void:
	if line_edit.text == "":
		return
	var text: String = line_edit.text
	if StaticLoad.is_muti_mode:
		if text[0] != "/":
			ClientManager.local_player.send_message(text)
			if multiplayer.get_unique_id() == 1:
				StaticLoad.rpc_entity_func_by_uuid(ClientManager.local_player.get_uuid(), "send_message", text, "others", true)
			else:
				StaticLoad.rpc_entity_func_by_uuid(ClientManager.local_player.get_uuid(), "send_message", text, [ClientManager.local_player.player_peer_id], false)
		else:
			ClientManager.local_player.send_command(text)
			#if multiClientManager.local_player.get_unique_id() == 1:
				#StaticLoad.rpc_entity_func_by_uuid(ClientManager.local_player.get_uuid(), "send_command", text, "others", true)
			#else:
				#StaticLoad.rpc_entity_func_by_uuid(ClientManager.local_player.get_uuid(), "send_command", text, [ClientManager.local_player.player_peer_id], false)
	else:
		if text[0] != "/":
			ClientManager.local_player.send_message(text)
		else:
			ClientManager.local_player.send_command(text)
	if inside_panel.visible:
		outside_history_vbox_container.visible = false
	line_edit.text = ""
	if get_tree() != null:
		await get_tree().process_frame
	inside_history_vbox_container.scroll_vertical = 1e9
	outside_history_vbox_container.scroll_vertical = 1e9
	if StaticLoad.is_on_mobile_platform:
		close_chat()
		if get_tree() != null:
			await get_tree().process_frame
		ClientManager.local_player.stop_move()
		InputManager.is_move_input_frozen = true
		if get_tree() != null:
			await get_tree().process_frame
		InputManager.is_move_input_frozen = false

func _on_outside_history_pre_sort_children() -> void:
	outside_history.scroll_vertical = 1e9
