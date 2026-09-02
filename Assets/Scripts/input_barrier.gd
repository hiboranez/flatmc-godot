extends Control

func free_in_seconds(time: float):
	if get_tree() != null:
		await get_tree().create_timer(time)
	queue_free()
