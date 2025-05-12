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
			$ProgressBar.visible = false
			$Amount.visible = false
			$Amount.text = ""
		#await get_tree().create_timer(0.01).timeout
		return
	elif not $ItemIcon.visible:
		$ItemIcon.init_icon(StaticLoad.game.mouse_item_name.to_lower())
		mouse_item_name_now = StaticLoad.game.mouse_item_name
		$ItemIcon.visible = true
	if StaticLoad.game.mouse_item_amount <= 1:
		$Amount.text = ""
		$Amount.visible = false
	else:
		$Amount.text = str(StaticLoad.game.mouse_item_amount)
		$Amount.visible = true
	update_progress_bar(StaticLoad.game.mouse_item_name, StaticLoad.game.mouse_item_amount)
	position = get_global_mouse_position()-Vector2(50, 50)
	if mouse_item_name_now == null:
		return
	if mouse_item_name_now != StaticLoad.game.mouse_item_name:
		$ItemIcon.init_icon(StaticLoad.game.mouse_item_name.to_lower())
	mouse_item_name_now = StaticLoad.game.mouse_item_name

func update_progress_bar(got_item_name, got_item_amount):
	if StaticLoad.get_is_durable_by_name(got_item_name):
		$ProgressBar.max_value = StaticLoad.get_max_amount_by_name(got_item_name)
		$ProgressBar.value = got_item_amount
		var percentage =  got_item_amount / float(StaticLoad.get_max_amount_by_name(got_item_name))
		var stylebox = $ProgressBar.get_theme_stylebox("fill")
		if percentage > 0.667:
			stylebox.bg_color = Color(0, 0.727, 0.135)
		elif percentage > 0.333 and percentage <= 0.667:
			stylebox.bg_color = Color(0.863, 0.675, 0)
		elif percentage >= 0 and percentage <= 0.333:
			stylebox.bg_color = Color(0.73, 0, 0)
		$ProgressBar.add_theme_stylebox_override("fill", stylebox)
		$Amount.visible = false
		$ProgressBar.visible = true
	else:
		$Amount.visible = true
		$ProgressBar.visible = false
