extends Control

var mouse_item_name_now = null

func _process(delta: float) -> void:
	if StaticLoad.game.mouse_item_name == "AIR":
		if $Icon.visible:
			$Icon.visible = false
			$Amount.text = ""
		#await get_tree().create_timer(0.01).timeout
		return
	elif not $Icon.visible:
		$Icon.texture = load("res://Assets//Textures//Items//"+StaticLoad.game.mouse_item_name.to_lower()+".png") as Texture2D
		mouse_item_name_now = StaticLoad.game.mouse_item_name
		if StaticLoad.game.mouse_item_amount <= 1:
			$Amount.text = ""
		else:
			$Amount.text = str(StaticLoad.game.mouse_item_amount)
		$Icon.visible = true
	position = get_global_mouse_position()-Vector2(50, 50)
	if mouse_item_name_now == null:
		return
	if mouse_item_name_now != StaticLoad.game.mouse_item_name:
		$Icon.texture = load("res://Assets//Textures//Items//"+StaticLoad.game.mouse_item_name.to_lower()+".png") as Texture2D
	mouse_item_name_now = StaticLoad.game.mouse_item_name
