extends CanvasLayer

@onready var left_ui = $LeftUI
@onready var right_ui = $RightUI
@onready var move_joystick = $LeftUI/MoveJoystick
@onready var operate_joystick = $RightUI/OperateJoystick
@onready var jump_button = $RightUI/JumpButton

var game

func _ready() -> void:
	game = get_node("/root/Game")

func set_ui_visible(is_visible: bool) -> void:
	left_ui.visible = is_visible
	right_ui.visible = is_visible

func set_jump_button_background(background_texture: Texture2D) -> void:
	jump_button.background_rect.texture = background_texture

func get_move_joystick_value() -> Vector2:
	return move_joystick.get_now_pos()

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
