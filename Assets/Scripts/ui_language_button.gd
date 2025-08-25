extends Control

@onready var language_name_label = $LanguageName
@onready var selected_background_rect = $SelectedBackground

var display_language_name: String = ""
var language_abbr: String = ""

var panel: Node = null

signal pressed

func update_data(args: Dictionary) -> void:
	if args.has("display_language_name") and args["display_language_name"] is String:
		display_language_name = args["display_language_name"]
		language_name_label.text = display_language_name
	if args.has("language_abbr") and args["language_abbr"] is String:
		language_abbr = args["language_abbr"]
	if args.has("panel") and args["panel"] is Node:
		panel = args["panel"]

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 1 and not event.pressed:
			if Rect2(Vector2(), size).has_point(event.position):
				pressed.emit()
	elif event is InputEventScreenTouch:
		if not event.pressed:
			if Rect2(Vector2(), size).has_point(event.position):
				pressed.emit()

func _on_language_button_pressed() -> void:
	if panel != null:
		panel.select_language = language_abbr
		panel.clear_selection()
		selected_background_rect.visible = true
		StaticLoad.is_lan_server = false
