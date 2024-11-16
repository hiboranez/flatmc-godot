extends Button

var animation
var signal_control
var online_info_label
var last_modified_label
var version_label

func _ready() -> void:
	pass # Replace with function body.

func init(type: String):
	if type == "single_menu":
		animation = $Signal/Animation
		signal_control = $Signal
		online_info_label = $OnlineInfo
		last_modified_label = $LastModified
		version_label = $Version
		last_modified_label.visible = true
		version_label.visible = true
		connect("pressed", _on_selection_single_menu_pressed)
	elif type == "muti_menu":
		animation = $Signal/Animation
		signal_control = $Signal
		online_info_label = $OnlineInfo
		last_modified_label = $LastModified
		self.icon = ImageTexture.create_from_image(StaticLoad.default_icon_gray_image)
		signal_control.visible = true
		online_info_label.visible = true
		connect("pressed", _on_selection_muti_menu_pressed)

func _on_selection_single_menu_pressed() -> void:
	StaticLoad.select_world = self.text.substr(3)

func _on_selection_muti_menu_pressed() -> void:
	StaticLoad.select_server = self.text.substr(3)
	StaticLoad.is_lan_server = false

func _on_selection_language_pressed() -> void:
	if self.text == "中文（简体）":
		$"../../../..".select_language = "zh"
	elif self.text == "English (US)":
		$"../../../..".select_language = "en"
