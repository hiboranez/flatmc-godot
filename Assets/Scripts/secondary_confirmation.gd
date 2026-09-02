extends CanvasLayer

@onready var blur_rect = $Blur
@onready var background_rect = $Background
@onready var confirm_button = $Background/FlowContainer/ConfirmButton
@onready var cancel_button = $Background/FlowContainer/CancelButton
@onready var rich_text_label = $Background/ScrollContainer/VBoxContainer/RichTextLabel
@onready var title_label = $Background/Title
	
func play_close_animation() -> Tween:
	SceneManager.is_secondary_confirmation_popped = false
	var scale_factor = SettingsManager.get_menu_scale_factor(SettingsManager.get_current_setting("gui_scale"))
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_method(set_scale_factor, scale_factor, 0.001, 0.15)
	tween.parallel().tween_method(set_blur_value, 2.0, 0.001, 0.15)
	tween.parallel().tween_method(set_modulate_alpha, 1.0, 0.0, 0.15)
	return tween

func connect_secondary_confirmation_confirm_button(function: Callable) -> void:
	confirm_button.connect("pressed", _on_secondary_confirmation_confirm_button_pressed.bind(function))

func set_modulate_alpha(alpha: float) -> void:
	background_rect.modulate.a = alpha

func set_scale_factor(scale_factor: float) -> void:
	background_rect.scale = Vector2(scale_factor, scale_factor)

func set_blur_value(value: float):
	blur_rect.material.set_shader_parameter("lod", value)

func _on_secondary_confirmation_confirm_button_pressed(function: Callable) -> void:
	AudioManager.play_static_audio("sound/ui/click")
	SceneManager.is_secondary_confirmation_popped = false
	await function.call()
	await play_close_animation().finished
	queue_free()

func _on_secondary_confirmation_cancel_button_button_pressed() -> void:
	AudioManager.play_static_audio("sound/ui/click")
	await play_close_animation().finished
	queue_free()
