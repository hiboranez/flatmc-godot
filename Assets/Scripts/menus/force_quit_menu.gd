extends CanvasLayer

@onready var title = $Title

func _ready() -> void:
	if StaticLoad.force_quit_reason == "server_closed":
		title.text = tr("SERVER_CLOSED")
	elif StaticLoad.force_quit_reason == "connection_interrupted":
		title.text = tr("CONNECTION_INTERRUPTED")
	elif StaticLoad.force_quit_reason == "connection_timeout":
		title.text = tr("CONNECTION_TIMEOUT")
	title.set("theme_override_colors/font_color", StaticLoad.colors["pink"])
	StaticLoad.force_quit_reason = "null"
	if StaticLoad.is_on_mobile_platform:
		Input.emulate_mouse_from_touch = true
	AudioManager.refresh_bgm()

func _on_force_quit_back_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	SceneManager.change_scene("menus/main_menu")
