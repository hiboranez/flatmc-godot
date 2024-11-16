extends Node

@onready var player_name_line_edit = $ColorRect/ScrollContainer/VBoxContainer/PlayerName/LineEdit
@onready var render_chunk_label = $ColorRect/ScrollContainer/VBoxContainer/RenderChunk/HScrollBar/Label
@onready var render_chunk_scroll_bar = $ColorRect/ScrollContainer/VBoxContainer/RenderChunk/HScrollBar
@onready var notice_scene = load("res://Assets/Scenes/Notice.tscn") as PackedScene
@onready var fov_zoom_label = $ColorRect/ScrollContainer/VBoxContainer/FovZoom/HScrollBar/Label
@onready var fov_zoom_scroll_bar = $ColorRect/ScrollContainer/VBoxContainer/FovZoom/HScrollBar
@onready var bgm_volume_label = $ColorRect/ScrollContainer/VBoxContainer/BgmVolume/HScrollBar/Label
@onready var bgm_volume_scroll_bar = $ColorRect/ScrollContainer/VBoxContainer/BgmVolume/HScrollBar
@onready var sound_volume_label = $ColorRect/ScrollContainer/VBoxContainer/SoundVolume/HScrollBar/Label
@onready var sound_volume_scroll_bar = $ColorRect/ScrollContainer/VBoxContainer/SoundVolume/HScrollBar
@onready var block_selection_box_option_bar = $ColorRect/ScrollContainer/VBoxContainer/BlockSelectionBox/OptionButton

func _ready() -> void:
	load_options()

func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		StaticLoad.click_audio_player.play()
		if StaticLoad.is_in_game:
			self.visible = false
		else:
			StaticLoad.change_scene("res://Assets/Scenes/Menu.tscn")

func _on_options_button_1_pressed() -> void:
	StaticLoad.click_audio_player.play()
	if player_name_line_edit.text == "":
		StaticLoad.pop_notification(self, "WARNING", "WARNING_2")
		return
	
	var change_value = {
		"player_name": str(player_name_line_edit.text),
		"render_chunk": str(render_chunk_scroll_bar.value),
		"fov_zoom": str(fov_zoom_scroll_bar.value),
		"bgm_volume": str(bgm_volume_scroll_bar.value),
		"sound_volume": str(sound_volume_scroll_bar.value),
		"block_selection_box": StaticLoad.get_block_selection_box_by_selected(block_selection_box_option_bar.selected)
	}
	StaticLoad.save_options(change_value)
	StaticLoad.click_audio_player.volume_db = linear_to_db(int(change_value["sound_volume"])/50.0)
	if StaticLoad.is_in_game:
		var game = $".."
		game.render_chunk = int(change_value["render_chunk"])
		var fov_zoom = 1+1.6*(int(change_value["fov_zoom"])/100.0)
		game.player.camera.zoom = Vector2(fov_zoom, fov_zoom)
		game.bgm_audio_player.volume_db = linear_to_db(int(change_value["bgm_volume"])/50.0)
		game.sound_audio_manager.volume_db = linear_to_db(int(change_value["sound_volume"])/50.0)
		game.block_selection_box = StaticLoad.get_block_selection_box_by_selected(block_selection_box_option_bar.selected)
		self.visible = false
		game.update_new_chunk(true)
	else:
		StaticLoad.change_scene("res://Assets/Scenes/Menu.tscn")

func _on_options_button_2_pressed() -> void:
	StaticLoad.click_audio_player.play()
	if StaticLoad.is_in_game:
		self.visible = false
	else:
		StaticLoad.change_scene("res://Assets/Scenes/Menu.tscn")

func _on_options_render_chunk_scroll_bar_scrolling() -> void:
	render_chunk_label.text = str(render_chunk_scroll_bar.value)

func _on_options_fov_zoom_scroll_bar_scrolling() -> void:
	fov_zoom_label.text = str(fov_zoom_scroll_bar.value)+"%"

func _on_options_bgm_volume_scroll_bar_scrolling() -> void:
	bgm_volume_label.text = str(bgm_volume_scroll_bar.value)+"%"

func _on_options_sound_volume_scroll_bar_scrolling() -> void:
	sound_volume_label.text = str(sound_volume_scroll_bar.value)+"%"

func load_options():
	var config = ConfigFile.new()
	var result = config.load("user://configs.cfg")
	if result == OK:
		player_name_line_edit.text = config.get_value("options", "player_name")	
		render_chunk_label.text = config.get_value("options", "render_chunk")
		render_chunk_scroll_bar.value = int(config.get_value("options", "render_chunk"))
		fov_zoom_label.text = config.get_value("options", "fov_zoom")+"%"
		fov_zoom_scroll_bar.value = int(config.get_value("options", "fov_zoom"))
		bgm_volume_label.text = config.get_value("options", "bgm_volume")+"%"
		bgm_volume_scroll_bar.value = int(config.get_value("options", "bgm_volume"))
		sound_volume_label.text = config.get_value("options", "sound_volume")+"%"
		sound_volume_scroll_bar.value = int(config.get_value("options", "sound_volume"))
		block_selection_box_option_bar.selected = StaticLoad.get_selected_by_block_selection_box(config.get_value("options", "block_selection_box"))
	#else:
		#var default_config = ConfigFile.new()
		#default_config.set_value("Options", "player_name", player_name_line_edit.text)
		#default_config.save("user://configs.cfg")
