extends GridContainer

var health_bar_heart_list: Array
var last_health = StaticLoad.DEFAULT_PLAYER_HEALTH
var flash_timer: float = 0

func _ready() -> void:
	for i in range(10):
		var health_bar_heart = SceneManager.get_scene("game_ui/health_bar_heart").instantiate()
		add_child(health_bar_heart)
		health_bar_heart_list.append(health_bar_heart)
		health_bar_heart.name = "HealthBarHeart"+str(i)
	ActionManager.register_action("health_bar", "update_visible", update_visible)

func _process(delta: float) -> void:
	update_health_bar()
	update_visible()
	update_flash()

func update_flash() -> void:
	if flash_timer < StaticLoad.FLOAT_DELTA:
		return
	flash_timer -= get_process_delta_time()
	if flash_timer < StaticLoad.FLOAT_DELTA:
		for health_bar_heart in health_bar_heart_list:
			health_bar_heart.texture = TextureManager.get_texture("ui/health_bar_heart_background")

func update_visible() -> void:
	if ClientManager.local_player == null:
		return
	if ClientManager.local_player.gamemode == "creative" and visible:
		visible = false
	elif ClientManager.local_player.gamemode != "creative" and not visible:
		visible = true

func update_health_bar() -> void:
	var current_health = StaticLoad.game.player.health
	if current_health == last_health:
		return
	
	flash_timer = StaticLoad.UI_FLASH_TIME
	for health_bar_heart in health_bar_heart_list:
		health_bar_heart.texture = TextureManager.get_texture("ui/health_bar_flash_heart_background")
	
	var full_health_amount = StaticLoad.game.player.health / 2
	if full_health_amount < 0:
		full_health_amount = 0
	if full_health_amount > 10:
		full_health_amount = 10
	
	for i in range(10):
		health_bar_heart_list[i].get_node("FullHeart").visible = false
	for i in range(full_health_amount):
		health_bar_heart_list[i].get_node("FullHeart").visible = true

	var half_health_odd = StaticLoad.game.player.health % 2
	for i in range(10):
		health_bar_heart_list[i].get_node("HalfHeart").visible = false
	if half_health_odd == 1 and full_health_amount < 10:
		health_bar_heart_list[full_health_amount].get_node("HalfHeart").visible = true
	
	last_health = current_health
