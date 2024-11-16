extends TextureRect

var item_name
var mouse_stay_timer = StaticLoad.INVENTORY_NAME_SHOW_STAY_TIME

func _ready() -> void:
	set_process(false)

func _process(delta: float) -> void:
	if mouse_stay_timer > 0:
		mouse_stay_timer -= delta
	else:
		StaticLoad.game.mouse_item_name_label = StaticLoad.mouse_item_name_label_scene.instantiate()
		StaticLoad.game.game_ui.add_child(StaticLoad.game.mouse_item_name_label)
		StaticLoad.game.mouse_item_name_label.text = tr(item_name)
		StaticLoad.game.mouse_item_name_label.start_following()
		set_process(false)

func init_inventory_grid(init_item_name):
	item_name = init_item_name
	$Icon.texture = load("res://Assets//Textures//Items//"+init_item_name.to_lower()+".png") as Texture2D

func _on_mouse_entered() -> void:
	mouse_stay_timer = StaticLoad.INVENTORY_NAME_SHOW_STAY_TIME
	set_process(true)

func _on_mouse_exited() -> void:
	set_process(false)
	mouse_stay_timer = StaticLoad.INVENTORY_NAME_SHOW_STAY_TIME
	if StaticLoad.game.mouse_item_name_label == null:
		return
	StaticLoad.game.mouse_item_name_label.stop_following()
	StaticLoad.game.mouse_item_name_label.queue_free()

func _on_gui_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton or event is InputEventScreenTouch):
		return
	if event is InputEventMouseButton:
		if event.button_index != 1 or not event.pressed:
			return
	var player = StaticLoad.game.player
	var sort = player.selected_item_grid
	player.item_bar_names[sort] = item_name
	StaticLoad.game.refresh_item_grid(sort)
	StaticLoad.game.sound_audio_manager.play_audio_static("gui", "select")
	StaticLoad.game.item_grids[sort].get_node("Blink").animation = "blink"
	StaticLoad.game.item_grids[sort].get_node("Blink").frame = 0
	StaticLoad.game.item_grids[sort].get_node("Blink").play()
	StaticLoad.game.item_name_label.text = player.item_bar_names[sort]
	StaticLoad.game.item_name_timer = StaticLoad.ITEM_NAME_SHOW_TIME
