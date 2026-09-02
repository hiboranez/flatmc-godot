extends Control

@onready var item_icon = $ItemIcon
@onready var amount_label = $Amount
@onready var progress_bar = $ProgressBar

var item_name: String = ""

func _ready() -> void:
	set_process(false)
	await get_tree().create_timer(0.5).timeout
	set_process(true)

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if not ClientManager.is_game_connected:
		return
	if ClientManager.local_player.mouse_item_name == "AIR":
		if item_icon.visible:
			item_icon.visible = false
			progress_bar.visible = false
			amount_label.visible = false
			amount_label.text = ""
		return
	elif not item_icon.visible:
		item_icon.init_icon(ClientManager.local_player.mouse_item_name.to_lower())
		item_name = ClientManager.local_player.mouse_item_name
		item_icon.visible = true
	if ClientManager.local_player.mouse_item_amount <= 1:
		amount_label.text = ""
		amount_label.visible = false
	else:
		amount_label.text = str(ClientManager.local_player.mouse_item_amount)
		amount_label.visible = true
	update_progress_bar(ClientManager.local_player.mouse_item_name, ClientManager.local_player.mouse_item_amount)
	position = get_global_mouse_position()-Vector2(50, 50)
	if item_name == "":
		return
	if item_name != ClientManager.local_player.mouse_item_name:
		item_icon.init_icon(ClientManager.local_player.mouse_item_name.to_lower())
	item_name = ClientManager.local_player.mouse_item_name

func update_progress_bar(got_item_name, got_item_amount):
	if StaticLoad.get_is_durable_by_name(got_item_name):
		progress_bar.max_value = StaticLoad.get_max_amount_by_name(got_item_name)
		progress_bar.value = got_item_amount
		var percentage =  got_item_amount / float(StaticLoad.get_max_amount_by_name(got_item_name))
		var stylebox = progress_bar.get_theme_stylebox("fill")
		if percentage > 0.667:
			stylebox.bg_color = Color(0, 0.727, 0.135)
		elif percentage > 0.333 and percentage <= 0.667:
			stylebox.bg_color = Color(0.863, 0.675, 0)
		elif percentage >= 0 and percentage <= 0.333:
			stylebox.bg_color = Color(0.73, 0, 0)
		progress_bar.add_theme_stylebox_override("fill", stylebox)
		amount_label.visible = false
		progress_bar.visible = true
	else:
		amount_label.visible = true
		progress_bar.visible = false
