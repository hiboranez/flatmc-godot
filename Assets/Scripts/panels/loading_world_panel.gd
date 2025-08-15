extends Control

@onready var progress_bar = $ProgressBar
@onready var title_label = $Title
@onready var tip_label = $ProgressBar/Tip

var menu: Node = null
var title: String = ""
var content_top_margin: float = 0
var content_bottom_margin: float = 0

var is_loaded_terrain: bool = false

func _ready() -> void:
	set_process(false)
	get_viewport().size_changed.connect(refresh_size)

func _process(delta: float) -> void:
	load_terrain()
	if not is_loaded_terrain:
		return
	if StaticLoad.game.player == null or StaticLoad.game.player.is_frozen:
		return
	title_label.text = tr("COMPLETED")
	await get_tree().create_timer(1).timeout
	load_finished()

func refresh_size() -> void:
	var canvas_size = get_viewport().get_screen_transform().affine_inverse()*Vector2(get_viewport().size)
	scale = Vector2(menu.scale_factor, menu.scale_factor)
	set_deferred("size", Vector2(canvas_size.x/menu.scale_factor, (canvas_size.y-((content_top_margin+content_bottom_margin)*menu.scale_factor))/menu.scale_factor))

func update_tip():
	if StaticLoad.is_dedicated_server:
		return
	var rng = RandomNumberGenerator.new()
	var num = rng.randi_range(0,1)
	tip_label.text = tr("TIP_"+str(num))

func load_icon():
	var world_icon_image = Image.load_from_file(SettingsManager.get_default_value("world_list_path")+StaticLoad.select_world+"/icon.png")
	world_icon_image.resize(256, 256)
	StaticLoad.world_icon_buffer = world_icon_image.save_png_to_buffer()

func load_game():
	update_tip()
	StaticLoad.update_select_world_path()
	set_process(true)

func load_terrain():
	title_label.text = tr("LOADING_TERRAIN")
	progress_bar.value = int(((StaticLoad.game.loaded_chunk_num * 2.0) / StaticLoad.game.total_chunk_num) * 100)
	if progress_bar.value == 100:
		is_loaded_terrain = true

func load_finished():
	StaticLoad.game.unfreeze_game()
	self.visible = false
	set_process(false)
