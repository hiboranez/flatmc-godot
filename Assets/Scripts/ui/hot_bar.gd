extends Control

@onready var grid_container = $GridContainer

var hot_bar_slot_list: Array

func _ready() -> void:
	ActionManager.register_action("hot_bar", "update_slot_data", update_slot_data)
	ActionManager.register_action("hot_bar", "select_slot", select_slot)
	for i in range(9):
		var hot_bar_slot = SceneManager.get_scene("game_ui/hot_bar_slot").instantiate()
		grid_container.add_child(hot_bar_slot)
		hot_bar_slot_list.append(hot_bar_slot)
		hot_bar_slot.name = "HotBarSlot"+str(i)
		if i == 0:
			hot_bar_slot.update_data({
				"hot_bar": self,
				"index": i,
				"location": "left"
			})
		else:
			hot_bar_slot.update_data({
				"hot_bar": self,
				"index": i,
				"location": "middle"
			})
	var hot_bar_ellipsis_slot = SceneManager.get_scene("game_ui/hot_bar_slot").instantiate()
	grid_container.add_child(hot_bar_ellipsis_slot)
	hot_bar_ellipsis_slot.update_data({
		"hot_bar": self,
		"index": 9,
		"location": "right",
		"icon": "ui/hot_bar_ellipsis_icon"
	})

func update_slot_data(args: Dictionary) -> void:
	var index = args["index"]
	args.erase("index")
	hot_bar_slot_list[index].update_data(args)

func select_slot(index: int):
	hot_bar_slot_list[index].select_slot()

func clear_selection_frame() -> void:
	for hot_bar_slot in hot_bar_slot_list:
		hot_bar_slot.selection_frame.visible = false
