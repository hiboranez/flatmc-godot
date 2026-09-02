extends TextureRect

@onready var icon = $Icon
@onready var item_icon = $ItemIcon
@onready var amount_label = $Amount
@onready var progress_bar = $ProgressBar
@onready var selection_frame = $SelectionFrame

var hot_bar: Node = null

var index: int = -1
var item_name: String = "null"
var item_amount: int = 0

func _on_gui_input(event: InputEvent) -> void:
	if index == -1:
		return
	if event is InputEventMouseButton or event is InputEventScreenTouch or event is InputEventScreenDrag:
		select_slot()

func update_data(args: Dictionary):
	if args.has("hot_bar") and args["hot_bar"] is Node:
		hot_bar = args["hot_bar"]
	if args.has("index") and args["index"] is int:
		index = args["index"]
	if args.has("location") and args["location"] is String:
		texture = TextureManager.get_texture("ui/hot_bar_"+args["location"]+"_slot")
	if args.has("icon") and args["icon"] is String:
		icon.texture = TextureManager.get_texture(args["icon"])
		icon.visible = true
	if args.has("item_name") and args["item_name"] is String:
		item_name = args["item_name"]
	if args.has("item_amount") and args["item_amount"] is String:
		item_name = args["item_amount"]
	if args.has("refresh") and args["refresh"] is bool and args["refresh"]:
		item_icon.init_icon(item_name)
		refresh()

func refresh():
	if AttributeManager.get_is_durable_item(item_name):
		amount_label.visible = false
		amount_label.text = ""
		progress_bar.max_value = AttributeManager.get_item_max_amount(item_name)
		progress_bar.value = item_amount
		var percentage =  item_amount / float(AttributeManager.get_item_max_amount(item_name))
		var stylebox = progress_bar.get_theme_stylebox("fill")
		if percentage > 0.667:
			stylebox.bg_color = Color(0, 0.727, 0.135)
		elif percentage > 0.333 and percentage <= 0.667:
			stylebox.bg_color = Color(0.863, 0.675, 0)
		elif percentage >= 0 and percentage <= 0.333:
			stylebox.bg_color = Color(0.73, 0, 0)
		progress_bar.add_theme_stylebox_override("fill", stylebox)
		progress_bar.visible = true
	else:
		progress_bar.visible = false
		if item_amount <= 1:
			amount_label.visible = false
			amount_label.text = ""
		else:
			amount_label.text = str(item_amount)
			amount_label.visible = true

func select_slot() -> void:
	if not ClientManager.is_game_connected:
		return
	if index == 9:
		AudioManager.play_static_audio("sound/ui/click")
		InputManager.is_move_input_frozen = true
		ClientManager.local_player.stop_move()
		return
	hot_bar.clear_selection()
	if ClientManager.local_player.selected_item_grid != index:
		if ClientManager.local_player.is_eating:
			ClientManager.local_player.is_eating = false
			ClientManager.local_player.eat_timer = 0
			ClientManager.local_player.last_eat_stage = -1
	ClientManager.local_player.selected_item_grid = index
	selection_frame.visible = true
	var select_item_name = ClientManager.local_player.item_bar_names[index]
	if ClientManager.local_player.in_hand_item_name.contains("BOW"):
		if not select_item_name.contains("BOW") and ClientManager.local_player.is_pulling:
			ClientManager.local_player.is_pulling = false
			ClientManager.local_player.shoot_timer = 0
			ClientManager.local_player.last_shoot_stage = -1
			ClientManager.local_player.in_hand_item_name = select_item_name
			ClientManager.local_player.set_item_in_hand(select_item_name)
