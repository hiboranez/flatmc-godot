extends Control

@onready var server_name = $HSplitContainer/ServerName
@onready var icon = $HSplitContainer/Icon
@onready var selected_background = $SelectedBackground

signal pressed

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			pressed.emit()
	elif event is InputEventScreenTouch:
		if event.pressed:
			pressed.emit()

func update_info(args: Dictionary):
	if args.has("icon") and args["icon"] is ImageTexture:
		icon.texture = args["icon"]
	if args.has("server_name") and args["server_name"] is String:
		server_name.text = args["server_name"]

func _on_server_button_pressed() -> void:
	if has_node("/root/MultiMenu"):
		var multi_menu = get_node("/root/MultiMenu")
		multi_menu.selected_server = server_name.text
		multi_menu.clear_selected_background()
		selected_background.visible = true
		StaticLoad.is_lan_server = false
