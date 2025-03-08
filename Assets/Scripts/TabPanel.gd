extends TextureRect

@onready var item_icon = $ItemIcon
@onready var dark_mask = $DarkMask

var panel

func init_tab_panel(icon_name, panel_name):
	item_icon.init_icon(icon_name)
	panel = StaticLoad.game.inventory_ui.get_node("Panel").get_node(panel_name+"Panel")

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
	StaticLoad.click_audio_player.play()
	switch_tab()
		
