extends CanvasLayer

@onready var progress_bar = $ProgressBar
@onready var title = $Title
@onready var game_path = "res://Assets/Scenes/Game.tscn"
@onready var tip_label = $ProgressBar/Tip

var scene_load_progress = []
var scene_load_status = 0
var is_loaded_terrain: bool = false

func _ready() -> void:
	progress_bar.max_value = 100
	update_tip()
	if not StaticLoad.is_in_game:
		StaticLoad.update_select_world_path()
		var world_icon_image = Image.load_from_file(SettingsManager.get_default_value("world_list_path")+"icon.png")
		world_icon_image.resize(256, 256)
		StaticLoad.world_icon_buffer = world_icon_image.save_png_to_buffer()

# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if not StaticLoad.is_in_game:
		load_scene()
	else:
		load_terrain()
		if not is_loaded_terrain:
			return
		if StaticLoad.game.player == null or StaticLoad.game.player.is_frozen:
			return
		title.text = tr("COMPLETED")
		await get_tree().create_timer(1).timeout
		load_finished()

func update_tip():
	if StaticLoad.is_dedicated_server:
		return
	var rng = RandomNumberGenerator.new()
	var num = rng.randi_range(0,1)
	tip_label.text = tr("TIP_"+str(num))

func load_scene():
	title.text = tr("LOADING_SCENE")
	StaticLoad.is_in_game = true
	SceneManager.change_scene("menus/game")
		
func load_terrain():
	title.text = tr("LOADING_TERRAIN")
	progress_bar.value = int(((StaticLoad.game.loaded_chunk_num * 2.0) / StaticLoad.game.total_chunk_num) * 100)
	if progress_bar.value == 100:
		is_loaded_terrain = true

func load_finished():
	StaticLoad.game.unfreeze_game()
	self.visible = false
	set_process(false)
