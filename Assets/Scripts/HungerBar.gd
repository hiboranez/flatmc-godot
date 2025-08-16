extends GridContainer

var empty_hungers
var last_hunger = StaticLoad.DEFAULT_PLAYER_HEALTH
var flash_timer: float = 0
var current_is_hungry = false

func _ready() -> void:
	set_process(false)
	await get_tree().create_timer(0.5).timeout
	empty_hungers = get_node("/root/Game").hunger_bar.get_children()
	set_process(true)

func _process(delta: float) -> void:
	update_hunger_bar()
	update_flash(delta)

func update_flash(delta):
	if flash_timer < StaticLoad.FLOAT_DELTA:
		return
	flash_timer -= delta
	if flash_timer < StaticLoad.FLOAT_DELTA:
		for empty_hunger in empty_hungers:
			if current_is_hungry:
				empty_hunger.texture = TextureManager.get_texture("ui/hungerbar_hungry_hunger_background")
			else:
				empty_hunger.texture = TextureManager.get_texture("ui/hungerbar_hunger_background")
		

func update_hunger_bar():
	var current_hunger = StaticLoad.game.player.hunger
	if not current_is_hungry and StaticLoad.game.player.effect_dict["hungry"] > 0:
		for empty_hunger in empty_hungers:
			empty_hunger.texture = TextureManager.get_texture("ui/hungerbar_hungry_hunger_background")
			empty_hunger.get_node("HalfHunger").texture = TextureManager.get_texture("ui/hungerbar_hungry_half_hunger")
			empty_hunger.get_node("FullHunger").texture = TextureManager.get_texture("ui/hungerbar_hungry_full_hunger")
			current_is_hungry = (StaticLoad.game.player.effect_dict["hungry"] > 0)
	elif current_is_hungry and StaticLoad.game.player.effect_dict["hungry"] <= 0:
		for empty_hunger in empty_hungers:
			empty_hunger.texture = TextureManager.get_texture("ui/hungerbar_hunger_background")
			empty_hunger.get_node("HalfHunger").texture = TextureManager.get_texture("ui/hungerbar_half_hunger")
			empty_hunger.get_node("FullHunger").texture = TextureManager.get_texture("ui/hungerbar_full_hunger")
			current_is_hungry = (StaticLoad.game.player.effect_dict["hungry"] > 0)
	if current_hunger == last_hunger:
		return
	if current_hunger > last_hunger:
		flash_timer = StaticLoad.UI_FLASH_TIME
		for empty_hunger in empty_hungers:
			empty_hunger.texture = TextureManager.get_texture("ui/hungerbar_flash_hunger_background")
	
	var full_hunger_amount = StaticLoad.game.player.hunger / 2
	if full_hunger_amount < 0:
		full_hunger_amount = 0
	if full_hunger_amount > 10:
		full_hunger_amount = 10
	
	for i in range(10):
		empty_hungers[i].get_node("FullHunger").visible = false
	for i in range(full_hunger_amount):
		empty_hungers[i].get_node("FullHunger").visible = true

	var half_hunger_odd = StaticLoad.game.player.hunger % 2
	for i in range(10):
		empty_hungers[i].get_node("HalfHunger").visible = false
	if half_hunger_odd == 1 and full_hunger_amount < 10:
		empty_hungers[full_hunger_amount].get_node("HalfHunger").visible = true
	
	last_hunger = current_hunger
