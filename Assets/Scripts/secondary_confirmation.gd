extends CanvasLayer

@onready var confirm_button = $Background/FlowContainer/ConfirmButton
@onready var cancel_button = $Background/FlowContainer/CancelButton
@onready var rich_text_label = $Background/ScrollContainer/VBoxContainer/RichTextLabel
@onready var title_label = $Background/Container/Title

func _on_secondary_confirmation_confirm_button_pressed(function: Callable):
	AudioManager.play_static_audio("sound/ui/click")
	function.call()
	queue_free()

func _on_secondary_confirmation_cancel_button_button_pressed() -> void:
	close()

func connect_secondary_confirmation_confirm_button(function: Callable):
	confirm_button.connect("pressed", _on_secondary_confirmation_confirm_button_pressed.bind(function))

func close():
	AudioManager.play_static_audio("sound/ui/click")
	StaticLoad.is_secondary_confirmation_poped = false
	queue_free()

func set_title(title):
	title_label.text = title

func set_text(text):
	rich_text_label.text = text
