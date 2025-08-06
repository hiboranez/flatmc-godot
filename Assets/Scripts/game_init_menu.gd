extends CanvasLayer

func _ready() -> void:
	await get_tree().process_frame
	var init_resource_list = [
		Manager.DataManage, Manager.AudioManage, Manager.TextureManage,
		Manager.SceneManage, Manager.SettingsManage
	]
	GameLoader.update_resource(init_resource_list)
	await GameLoader.load_finished
	SettingsManager.init_settings()
	SceneManager.change_scene("menu")
