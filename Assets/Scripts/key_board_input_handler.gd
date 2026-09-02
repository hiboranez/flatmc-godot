extends Node

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("select_item_grid_0"):
		ActionManager.execute_action("hot_bar", "select_slot", 0)
	if Input.is_action_just_pressed("select_item_grid_1"):
		ActionManager.execute_action("hot_bar", "select_slot", 1)
	if Input.is_action_just_pressed("select_item_grid_2"):
		ActionManager.execute_action("hot_bar", "select_slot", 2)
	if Input.is_action_just_pressed("select_item_grid_3"):
		ActionManager.execute_action("hot_bar", "select_slot", 3)
	if Input.is_action_just_pressed("select_item_grid_4"):
		ActionManager.execute_action("hot_bar", "select_slot", 4)
	if Input.is_action_just_pressed("select_item_grid_5"):
		ActionManager.execute_action("hot_bar", "select_slot", 5)
	if Input.is_action_just_pressed("select_item_grid_6"):
		ActionManager.execute_action("hot_bar", "select_slot", 6)
	if Input.is_action_just_pressed("select_item_grid_7"):
		ActionManager.execute_action("hot_bar", "select_slot", 7)
	if Input.is_action_just_pressed("select_item_grid_8"):
		ActionManager.execute_action("hot_bar", "select_slot", 8)
