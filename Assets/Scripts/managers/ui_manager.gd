extends Node

var ui_dict: Dictionary

func add_ui(ui_name: String, ui):
	ui_dict[ui_name] = ui

func get_ui(ui_name: String):
	if ui_dict.has(ui_name):
		return ui_dict[ui_name]
	return null

func set_ui_visible(ui_name: String, is_visible: bool):
	if not ui_dict.has(ui_name):
		return
	ui_dict[ui_name].visible = is_visible
