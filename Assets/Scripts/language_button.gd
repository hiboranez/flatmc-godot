extends Control

@onready var language_name = $LanguageName
@onready var selected_background = $SelectedBackground

@export var display_language: String = ""
@export var language: String = ""

signal pressed

func _ready() -> void:
	language_name.text = display_language

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			pressed.emit()
	elif event is InputEventScreenTouch:
		if event.pressed:
			pressed.emit()

func _on_language_button_pressed() -> void:
	if has_node("/root/LanguagesMenu"):
		var language_menu = get_node("/root/LanguagesMenu")
		language_menu.select_language = language
		language_menu.clear_selected_background()
		selected_background.visible = true
		StaticLoad.is_lan_server = false
