extends CanvasLayer

@onready var button_1 = $TextureRect/FlowContainer/Button1
@onready var button_2 = $TextureRect/FlowContainer/Button2
@onready var rich_text_label = $TextureRect/ScrollContainer/VBoxContainer/RichTextLabel
@onready var title_label = $TextureRect/Container/Title

func _ready() -> void:
	destroy_count_down()

func destroy_count_down():
	await get_tree().create_timer(10.0).timeout
	queue_free()

func _on_secondary_confirmation_button_1_button_pressed(function: Callable):
	StaticLoad.click_audio_player.play()
	function.call()
	queue_free()

func _on_secondary_confirmation_button_2_button_pressed() -> void:
	close()

func connect_secondary_confirmation_button_1(function: Callable):
	button_1.connect("pressed", _on_secondary_confirmation_button_1_button_pressed.bind(function))

func close():
	StaticLoad.click_audio_player.play()
	queue_free()

func set_title(title):
	title_label.text = title

func set_text(text):
	rich_text_label.text = text
