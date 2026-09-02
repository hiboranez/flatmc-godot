extends Control

@onready var background_rect = $Background
@onready var progress_rect = $Progress

func _process(delta: float) -> void:
	if not ClientManager.is_game_connected:
		return
	if ClientManager.local_player.attack_timer <= 0:
		if visible:
			visible = false
		return
	if not visible:
		visible = true
	if ClientManager.local_player.in_hand_item_name.contains("GOLD"):
		progress_rect.material.set_shader_parameter("progress", max((0.5-ClientManager.local_player.attack_timer)*2, 0))
	else:
		progress_rect.material.set_shader_parameter("progress", 1-ClientManager.local_player.attack_timer)
