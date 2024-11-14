extends Label

var is_disappearing: bool = false

func detect_and_disappear():
	if is_disappearing:
		await get_tree().create_timer(StaticLoad.MESSAGE_TIME).timeout
		var tween = get_tree().create_tween()
		tween.tween_property(self, "modulate", Color(1, 1, 1, 0), StaticLoad.MESSAGE_DISAPPEAR_TIME)	
		await tween.finished
		queue_free()
