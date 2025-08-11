extends Control

@onready var selected_background = $SelectedBackground
@onready var icon_rect = $GridContainer/IconMarginContainer/Icon
@onready var world_name_label = $GridContainer/GridContainer/WorldName
@onready var version_label = $GridContainer/GridContainer/Version
@onready var last_modified_label = $GridContainer/GridContainer/LastModified

var panel: Node = null

signal pressed

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 1 and not event.pressed:
			if Rect2(Vector2(), size).has_point(event.position):
				grab_focus()
				pressed.emit()
	elif event is InputEventScreenTouch:
		if not event.pressed:
			if Rect2(Vector2(), size).has_point(event.position):
				grab_focus()
				pressed.emit()

func update_info(args: Dictionary):
	if args.has("icon") and args["icon"] is ImageTexture:
		icon_rect.texture = args["icon"]
	if args.has("world_name") and args["world_name"] is String:
		world_name_label.text = args["world_name"]
	if args.has("version") and args["version"] is String:
		version_label.text = args["version"]
	if args.has("last_modified") and args["last_modified"] is String:
		last_modified_label.text = args["last_modified"]
	if args.has("panel") and args["panel"] is Node:
		panel = args["panel"]

func set_selected_background_visible(got_visible: bool) -> void:
	selected_background.visible = got_visible

func _on_world_button_pressed() -> void:
	if panel != null:
		panel.selected_world_name = world_name_label.text
		panel.clear_selected_background()
		selected_background.visible = true
