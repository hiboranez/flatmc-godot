extends CanvasLayer

@onready var achievement_info_vbox_container = $StoneWall/DragScrollContainer/VBoxContainer

func _ready() -> void:
	ActionManager.register_action("achievement_ui", "refresh", refresh)

func refresh() -> void:
	for achievement_info in achievement_info_vbox_container.get_children():
		achievement_info.name = "null"
		achievement_info.queue_free()
	var achieved_achievement_list_tmp = []
	if ClientManager.local_player != null:
		achieved_achievement_list_tmp = ClientManager.local_player.achieved_achievement_list
	for achievement in StaticLoad.achievement_icon_dict:
		var is_achieved = false
		var achievement_info = SceneManager.get_scene("others/achievement_info").instantiate()
		achievement_info_vbox_container.add_child(achievement_info)	
		if achieved_achievement_list_tmp.has(achievement):
			is_achieved = true
		achievement_info.init(achievement, is_achieved)
