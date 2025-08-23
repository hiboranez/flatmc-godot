extends Node

var action_dict: Dictionary

func register_action(object_name: String, action_name: String, callable: Callable) -> void:
	if not action_dict.has(object_name):
		action_dict[object_name] = {}
	action_dict[object_name][action_name] = callable

func execute_action(object_name: String, action_name: String, args = null) -> void:
	if not action_dict.has(object_name):
		return
	if not action_dict[object_name].has(action_name):
		return
	if args == null:
		action_dict[object_name][action_name].call()
	else:
		action_dict[object_name][action_name].call(args)
