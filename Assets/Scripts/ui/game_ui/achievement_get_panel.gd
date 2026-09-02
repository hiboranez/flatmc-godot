extends Control

func _ready() -> void:
	ActionManager.register_action("achievement_get_panel", "refresh", refresh)

func refresh():
	if get_child_count() > 0:
		for achievement_get in get_children():
			achievement_get.title.text = tr("ACHIEVEMENT_GET")
			achievement_get.achievement_name_label.text = tr(achievement_get.achievement_name)
