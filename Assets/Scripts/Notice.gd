extends CanvasLayer

@onready var close_button = $TextureRect/Button1
@onready var rich_text_label = $TextureRect/ScrollContainer/VBoxContainer/RichTextLabel
@onready var title_label = $TextureRect/Container/Title
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	close_button.connect("button_up", close)

func destroy_count_down():
	await get_tree().create_timer(10.0).timeout
	queue_free()

func close():
	StaticLoad.click_audio_player.play()
	queue_free()

func set_title(title):
	title_label.text = title

func set_text(text):
	rich_text_label.text = text

func set_button_text(text):
	close_button.text = text	
