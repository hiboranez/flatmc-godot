extends PanelContainer

@onready var achievement_name = $MarginContainer/HSplitContainer/MarginContainer/VSplitContainer/AchievementName
@onready var achievement_description = $MarginContainer/HSplitContainer/MarginContainer/VSplitContainer/Description
@onready var item_icon = $MarginContainer/HSplitContainer/ItemIcon
@onready var dark_mask = $DarkMask

var is_achieved = false

func init(got_achievement_name, got_is_achieved):
	if not StaticLoad.achievement_icon_dict.has(got_achievement_name):
		queue_free()
		return
	achievement_name.text = "  "+tr(got_achievement_name)
	achievement_description.text = tr(got_achievement_name+"_DESCRIPTION")
	item_icon.init_icon(StaticLoad.achievement_icon_dict[got_achievement_name].to_lower())
	update_achieved(got_is_achieved)

func update_achieved(got_is_achieved):
	if is_achieved and not got_is_achieved:
		dark_mask.visible = true
		is_achieved = false
		achievement_name.set("theme_override_colors/font_color", Color(1, 0.041, 0.022))
	elif not is_achieved and got_is_achieved:
		dark_mask.visible = false
		is_achieved = true
		achievement_name.set("theme_override_colors/font_color", Color(0.393, 0.907, 0.362))
