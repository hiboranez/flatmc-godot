class_name MenuController extends Node

var menu: Menu = null
var animation_time: float = 0.15

func _ready() -> void:
	menu = get_parent()

func appear(control_name) -> void:
	var control = null
	control = menu.panel_control_dict[control_name]
	if control == null:
		return
	var input_barrier = SceneManager.get_scene("ui/input_barrier").instantiate()
	menu.panel_control_dict["menu"].add_child(input_barrier)
	control.modulate.a = 0
	control.visible = true
	var tween = create_tween()
	tween.tween_property(control, "modulate", Color(1,1,1,1), animation_time)
	await tween.finished
	input_barrier.queue_free()

func vanish(control_name) -> void:
	var control = null
	control = menu.panel_control_dict[control_name]
	if control == null:
		return
	var input_barrier = SceneManager.get_scene("ui/input_barrier").instantiate()
	menu.panel_control_dict["menu"].add_child(input_barrier)
	var tween = create_tween()
	tween.tween_property(control, "modulate", Color(1,1,1,0), animation_time)
	await tween.finished
	control.visible = false
	control.modulate.a = 1
	input_barrier.queue_free()
