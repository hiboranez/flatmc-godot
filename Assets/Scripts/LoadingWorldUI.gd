extends CanvasLayer

@onready var progress_bar = $ProgressBar
@onready var title = $Title
@onready var game_path = "res://Assets/Scenes/Game.tscn"

var scene_load_progress = []
var scene_load_status = 0
var is_loaded_terrain: bool = false

func _ready() -> void:
	progress_bar.max_value = 100
	if not StaticLoad.is_in_game:
		ResourceLoader.load_threaded_request(game_path)
		StaticLoad.update_select_world_path()
		var world_icon_image = Image.load_from_file(StaticLoad.world_path+"/icon.png")
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

func load_scene():
	title.text = tr("LOADING_SCENE")
	scene_load_status = ResourceLoader.load_threaded_get_status(game_path, scene_load_progress)
	progress_bar.value = scene_load_progress[0] * 100
	if scene_load_status == ResourceLoader.THREAD_LOAD_LOADED:
		set_process(false)
		StaticLoad.is_in_game = true
		StaticLoad.change_scene(ResourceLoader.load_threaded_get(game_path))
		
func load_terrain():
	title.text = tr("LOADING_TERRAIN")
	progress_bar.value = int(((StaticLoad.game.loaded_chunk_num * 1.0) / StaticLoad.game.total_chunk_num) * 100)
	if progress_bar.value == 100:
		is_loaded_terrain = true

func load_finished():
	StaticLoad.game.unfreeze_game()
	self.visible = false
	set_process(false)
