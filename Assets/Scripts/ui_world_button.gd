extends Control

@onready var world_name = $HSplitContainer/GridContainer/WorldName
@onready var icon = $HSplitContainer/MarginContainer/Icon
@onready var selected_background = $SelectedBackground
@onready var version = $HSplitContainer/GridContainer/Version
@onready var last_modified = $HSplitContainer/GridContainer/LastModified

signal pressed

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 1 and not event.pressed:
			if Rect2(Vector2(), size).has_point(event.position):
				pressed.emit()
	elif event is InputEventScreenTouch:
		if not event.pressed:
			if Rect2(Vector2(), size).has_point(event.position):
				pressed.emit()

func update_info(args: Dictionary):
	if args.has("icon") and args["icon"] is ImageTexture:
		icon.texture = args["icon"]
	if args.has("world_name") and args["world_name"] is String:
		world_name.text = args["world_name"]
	if args.has("version") and args["version"] is String:
		version.text = args["version"]
	if args.has("last_modified") and args["last_modified"] is String:
		last_modified.text = args["last_modified"]

func set_selected_background_visible(got_visible: bool) -> void:
	selected_background.visible = got_visible

func _on_world_button_pressed() -> void:
	if has_node("/root/SingleMenu"):
		var single_menu = get_node("/root/SingleMenu")
		single_menu.selected_world_name = world_name.text
		single_menu.clear_selected_background()
		selected_background.visible = true
