extends Control

var mouse_item_name_now = null

func _ready() -> void:
	set_process(false)
	await get_tree().create_timer(0.5).timeout
	set_process(true)

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if StaticLoad.game.mouse_item_name == "AIR":
		if $ItemIcon.visible:
			$ItemIcon.visible = false
			$Amount.text = ""
		#await get_tree().create_timer(0.01).timeout
		return
	elif not $ItemIcon.visible:
		$ItemIcon.init_icon(StaticLoad.game.mouse_item_name.to_lower())
		mouse_item_name_now = StaticLoad.game.mouse_item_name
		$ItemIcon.visible = true
	if StaticLoad.game.mouse_item_amount <= 1:
		$Amount.text = ""
	else:
		$Amount.text = str(StaticLoad.game.mouse_item_amount)
	position = get_global_mouse_position()-Vector2(50, 50)
	if mouse_item_name_now == null:
		return
	if mouse_item_name_now != StaticLoad.game.mouse_item_name:
		$ItemIcon.init_icon(StaticLoad.game.mouse_item_name.to_lower())
	mouse_item_name_now = StaticLoad.game.mouse_item_name
