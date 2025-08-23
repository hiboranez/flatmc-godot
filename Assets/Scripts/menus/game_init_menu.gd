extends CanvasLayer

func _ready() -> void:
	await get_tree().process_frame
	
	ResourceLoadingMenu.update_resource([
		Manager.DataManage,
		Manager.AudioManage,
		Manager.TextureManage,
		Manager.SceneManage,
		Manager.SettingsManage
	])
	await ResourceLoadingMenu.load_finished
	SettingsManager.apply_settings()
	AttributeManager.update_attributes()
	InputManager.update_components()
	SceneManager.change_scene("menus/main_menu")
