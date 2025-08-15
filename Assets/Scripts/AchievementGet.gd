extends TextureRect

@onready var item_icon = $ItemIcon
@onready var title = $Title
@onready var achievement_name_label = $AchievementNameLabel

var achievement_name = ""

func init(got_achievement_name):
	if not StaticLoad.achievement_icon_dict.has(got_achievement_name):
		queue_free()
		return
	achievement_name = got_achievement_name
	achievement_name_label.text = tr(got_achievement_name)
	item_icon.init_icon(StaticLoad.achievement_icon_dict[got_achievement_name].to_lower())
	AudioManager.play_static_audio("ui/toast")
	var tween1 = get_tree().create_tween()
	tween1.tween_property(self, "position", Vector2(0, 0), 0.3)
	await get_tree().create_timer(6).timeout
	var tween2 = get_tree().create_tween()
	tween2.tween_property(self, "position", Vector2(0, -160), 0.3)
	await get_tree().create_timer(0.5).timeout
	queue_free()
