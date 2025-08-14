extends CanvasLayer

class_name Menu

var menu_controller: MenuController
var scale_factor: float = 1
var size_control_list: Array
var panel_control_dict: Dictionary

func refresh_size():
	for control in size_control_list:
		control.refresh_size()	
