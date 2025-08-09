extends Control

@onready var server_name_label = $HSplitContainer/HSplitContainer/ServerName
@onready var icon_rect = $HSplitContainer/Icon
@onready var selected_background_rect = $SelectedBackground
@onready var animation_sprite = $HSplitContainer/HSplitContainer/Signal/Animation
@onready var online_info_label = $HSplitContainer/HSplitContainer/Signal/OnlineInfo

signal pressed

var server_name: String = ""
var server_type: String = ""
var server_ip: String = ""
var server_port: int = -1

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 1 and not event.pressed:
			if Rect2(Vector2(), size).has_point(event.position):
				pressed.emit()
	elif event is InputEventScreenTouch:
		if not event.pressed:
			if Rect2(Vector2(), size).has_point(event.position):
				pressed.emit()

func update_data(args: Dictionary) -> void:
	if args.has("server_name") and args["server_name"] is String:
		server_name = args["server_name"]
		name = server_name
		server_name_label.text = server_name
	if args.has("online_info") and args["online_info"] is String:
		online_info_label.text = args["online_info"]
	if args.has("animation") and args["animation"] is String:
		animation_sprite.animation = args["animation"]
	if args.has("refresh") and args["refresh"] is bool and args["refresh"]:
		var server_config = ConfigFile.new()
		var server_info = server_config.load_encrypted_pass(SettingsManager.get_default_value("server_list_path")+"/"+server_name+".srv", SettingsManager.get_default_value("config_password"))
		if server_info == OK:
			server_type = server_config.get_value("server", "server_type", "third_party")
			server_ip = server_config.get_value("server", "server_ip", "")
			server_port = int(server_config.get_value("server", "server_port", "-1"))
			var icon_buffer = server_config.get_value("server", "server_icon", TextureManager.get_texture(SettingsManager.get_default_official_server_info("server_icon_path")).get_image().save_png_to_buffer())
			var icon_image = Image.new()
			icon_image.load_png_from_buffer(icon_buffer)
			icon_rect.texture = ImageTexture.create_from_image(icon_image)

func set_selected_background_visible(got_visible: bool) -> void:
	selected_background_rect.visible = got_visible

func _on_server_button_pressed() -> void:
	if has_node("/root/MultiMenu"):
		var multi_menu = get_node("/root/MultiMenu")
		multi_menu.clear_selected_background()
		selected_background_rect.visible = true
	get_node("/root/ServerManager").update_data({
		"server_name": server_name,
		"server_type": server_type, 
		"server_ip": server_ip,
		"server_port": server_port
	})
