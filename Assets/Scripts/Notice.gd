extends CanvasLayer

@onready var close_button = $Background/CloseButton
@onready var rich_text_label = $Background/ScrollContainer/VBoxContainer/RichTextLabel
@onready var title_label = $Background/Title
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	close_button.connect("pressed", close)

func destroy_count_down():
	await get_tree().create_timer(10.0).timeout
	queue_free()

func close():
	AudioManager.play_static_audio("sound/ui/click")
	queue_free()

func set_title(title):
	title_label.text = title

func set_text(text):
	rich_text_label.text = text

func set_button_text(text):
	close_button.text = text	
