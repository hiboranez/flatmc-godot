extends GridContainer

var empty_hearts
var last_health = StaticLoad.DEFAULT_PLAYER_HEALTH
var flash_timer: float = 0

func _ready() -> void:
	set_process(false)
	await get_tree().create_timer(0.5).timeout
	empty_hearts = get_node("/root/Game").health_bar.get_children()
	set_process(true)

func _process(delta: float) -> void:
	update_health_bar()
	update_flash(delta)

func update_flash(delta):
	if flash_timer < StaticLoad.FLOAT_DELTA:
		return
	flash_timer -= delta
	if flash_timer < StaticLoad.FLOAT_DELTA:
		for empty_heart in empty_hearts:
			empty_heart.texture = TextureManager.get_texture("ui/empty_heart")
		

func update_health_bar():
	var current_health = StaticLoad.game.player.health
	if current_health == last_health:
		return
	
	flash_timer = StaticLoad.UI_FLASH_TIME
	for empty_heart in empty_hearts:
		empty_heart.texture = TextureManager.get_texture("ui/flash_heart")
	
	var full_health_amount = StaticLoad.game.player.health / 2
	if full_health_amount < 0:
		full_health_amount = 0
	if full_health_amount > 10:
		full_health_amount = 10
	
	for i in range(10):
		empty_hearts[i].get_node("FullHeart").visible = false
	for i in range(full_health_amount):
		empty_hearts[i].get_node("FullHeart").visible = true

	var half_health_odd = StaticLoad.game.player.health % 2
	for i in range(10):
		empty_hearts[i].get_node("HalfHeart").visible = false
	if half_health_odd == 1 and full_health_amount < 10:
		empty_hearts[full_health_amount].get_node("HalfHeart").visible = true
	
	last_health = current_health
