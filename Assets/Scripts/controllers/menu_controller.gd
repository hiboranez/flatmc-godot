extends Node

class_name MenuController

var animation_time: float = 0.15
var menu_control: Node = null

func set_menu_control(got_menu_control) -> void:
	menu_control = got_menu_control

func appear() -> void:
	if menu_control == null:
		return
	var input_barrier = SceneManager.get_scene("ui/input_barrier").instantiate()
	menu_control.add_child(input_barrier)
	menu_control.modulate.a = 0
	menu_control.visible = true
	var tween = create_tween()
	tween.tween_property(menu_control, "modulate", Color(1,1,1,1), animation_time)
	await tween.finished
	input_barrier.queue_free()

func vanish() -> void:
	if menu_control == null:
		return
	var input_barrier = SceneManager.get_scene("ui/input_barrier").instantiate()
	menu_control.add_child(input_barrier)
	var tween = create_tween()
	tween.tween_property(menu_control, "modulate", Color(1,1,1,0), animation_time)
	await tween.finished
	menu_control.visible = false
	menu_control.modulate.a = 1
	input_barrier.queue_free()
