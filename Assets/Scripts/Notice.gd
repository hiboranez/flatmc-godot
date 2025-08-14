extends CanvasLayer

@onready var blur_rect = $Blur
@onready var background_rect = $Background
@onready var close_button = $Background/NoticeControl/CloseButton
@onready var rich_text_label = $Background/NoticeControl/ScrollContainer/VBoxContainer/RichTextLabel
@onready var title_label = $Background/NoticeControl/Title

func destroy_count_down():
	await get_tree().create_timer(10.0).timeout
	await play_close_animation().finished
	queue_free()

func play_close_animation() -> Tween:
	var scale_factor = SettingsManager.get_menu_scale_factor(SettingsManager.get_current_setting("gui_scale"))
	var animation_time = 0.3
	if name == "Notice":
		animation_time = 0.15
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_method(set_scale_factor, scale_factor, 0.001, animation_time)
	tween.parallel().tween_method(set_blur_value, 2, 0.001, animation_time)
	return tween

func set_scale_factor(scale_factor: float) -> void:
	background_rect.scale = Vector2(scale_factor, scale_factor)

func set_blur_value(value: float):
	blur_rect.material.set_shader_parameter("lod", value)

func _on_close_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	await play_close_animation().finished
	queue_free()
