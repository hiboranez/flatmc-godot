extends TextureRect

@onready var item_icon = $ItemIcon
@onready var dark_mask = $DarkMask

var panel

func init_tab_panel(icon_name, panel_name, tab_panels):
	item_icon.init_icon(icon_name)
	panel = tab_panels

func switch_tab():
	for tab in StaticLoad.game.inventory_tabs.get_children():
		tab.dark_mask.visible = true
		tab.panel.visible = false
		tab.z_index = 0
	dark_mask.visible = false
	panel.visible = true
	z_index = 1

func _on_dark_mask_gui_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	AudioManager.play_static_audio("sound/ui/click")
	switch_tab()
		
