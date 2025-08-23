extends GridContainer

var hunger_bar_hunger_list: Array
var last_hunger = StaticLoad.DEFAULT_PLAYER_HEALTH
var flash_timer: float = 0
var current_is_hungry = false

func _ready() -> void:
	for i in range(10, 0, -1):
		var hunger_bar_hunger = SceneManager.get_scene("game_ui/hunger_bar_hunger").instantiate()
		add_child(hunger_bar_hunger)
		hunger_bar_hunger_list.append(hunger_bar_hunger)
		hunger_bar_hunger.name = "HungerBarHunger"+str(i-1)
	ActionManager.register_action("health_bar", "update_visible", update_visible)

func _process(delta: float) -> void:
	update_hunger_bar()
	update_visible()
	update_flash()

func update_flash() -> void:
	if flash_timer < StaticLoad.FLOAT_DELTA:
		return
	flash_timer -= get_process_delta_time()
	if flash_timer < StaticLoad.FLOAT_DELTA:
		for hunger_bar_hunger in hunger_bar_hunger_list:
			if current_is_hungry:
				hunger_bar_hunger.texture = TextureManager.get_texture("ui/hunger_bar_hungry_hunger_background")
			else:
				hunger_bar_hunger.texture = TextureManager.get_texture("ui/hunger_bar_hunger_background")

func update_visible() -> void:
	if ClientManager.local_player == null:
		return
	if ClientManager.local_player.gamemode == "creative" and visible:
		visible = false
	elif ClientManager.local_player.gamemode != "creative" and not visible:
		visible = true

func update_hunger_bar() -> void:
	var current_hunger = StaticLoad.game.player.hunger
	if not current_is_hungry and StaticLoad.game.player.effect_dict["hungry"] > 0:
		for hunger_bar_hunger in hunger_bar_hunger_list:
			hunger_bar_hunger.texture = TextureManager.get_texture("ui/hunger_bar_hungry_hunger_background")
			hunger_bar_hunger.get_node("HalfHunger").texture = TextureManager.get_texture("ui/hunger_bar_hungry_half_hunger")
			hunger_bar_hunger.get_node("FullHunger").texture = TextureManager.get_texture("ui/hunger_bar_hungry_full_hunger")
			current_is_hungry = (StaticLoad.game.player.effect_dict["hungry"] > 0)
	elif current_is_hungry and StaticLoad.game.player.effect_dict["hungry"] <= 0:
		for hunger_bar_hunger in hunger_bar_hunger_list:
			hunger_bar_hunger.texture = TextureManager.get_texture("ui/hunger_bar_hunger_background")
			hunger_bar_hunger.get_node("HalfHunger").texture = TextureManager.get_texture("ui/hunger_bar_half_hunger")
			hunger_bar_hunger.get_node("FullHunger").texture = TextureManager.get_texture("ui/hunger_bar_full_hunger")
			current_is_hungry = (StaticLoad.game.player.effect_dict["hungry"] > 0)
	if current_hunger == last_hunger:
		return
	if current_hunger > last_hunger:
		flash_timer = StaticLoad.UI_FLASH_TIME
		for hunger_bar_hunger in hunger_bar_hunger_list:
			hunger_bar_hunger.texture = TextureManager.get_texture("ui/hunger_bar_flash_hunger_background")
	
	var full_hunger_amount = StaticLoad.game.player.hunger / 2
	if full_hunger_amount < 0:
		full_hunger_amount = 0
	if full_hunger_amount > 10:
		full_hunger_amount = 10
	
	for i in range(10):
		hunger_bar_hunger_list[i].get_node("FullHunger").visible = false
	for i in range(full_hunger_amount):
		hunger_bar_hunger_list[i].get_node("FullHunger").visible = true

	var half_hunger_odd = StaticLoad.game.player.hunger % 2
	for i in range(10):
		hunger_bar_hunger_list[i].get_node("HalfHunger").visible = false
	if half_hunger_odd == 1 and full_hunger_amount < 10:
		hunger_bar_hunger_list[full_hunger_amount].get_node("HalfHunger").visible = true
	
	last_hunger = current_hunger
