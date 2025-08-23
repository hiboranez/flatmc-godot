extends Label

var hot_bar_text_display_time: float = 2
var hot_bar_text_disappear_time: float = 0.2
var item_name_timer: float = 0

func _ready() -> void:
	hot_bar_text_display_time = float(SettingsManager.get_default_value("hot_bar_text_display_time"))
	hot_bar_text_disappear_time = float(SettingsManager.get_default_value("hot_bar_text_disappear_time"))
	ActionManager.register_action("hot_bar_text", "refresh", refresh)

func _process(delta: float) -> void:
	if item_name_timer < 0:
		return
	var alpha: float = 1
	if item_name_timer <= hot_bar_text_disappear_time:
		alpha = item_name_timer/hot_bar_text_disappear_time
	self_modulate = Color(1,1,1,alpha)
	item_name_timer -= get_process_delta_time()
	if item_name_timer < 0:
		self_modulate = Color(1,1,1,0)

func refresh() -> void:
	if ClientManager.local_player == null:
		return
	var display_name = ClientManager.local_player.item_bar_names[ClientManager.local_player.selected_item_grid]
	if display_name != "AIR":
		text = display_name
		item_name_timer = hot_bar_text_display_time
