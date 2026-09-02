extends Control

@onready var substantial_layer = $SubViewportContainer/SubViewport/TileMapLayer
@onready var insubstantial_layer = $SubViewportContainer/SubViewport/NoReachTileMapLayer
@onready var background_layer = $SubViewportContainer/SubViewport/BackTileMapLayer
@onready var sky_background = $SkyBackground
@onready var star_background = $SubViewportContainer/SubViewport/StaticBackground/ParallaxLayer/StarBackground
@onready var camera = $SubViewportContainer/SubViewport/Camera2D
@onready var player_icons = $SubViewportContainer/SubViewport/PlayerIcons
@onready var lights = $SubViewportContainer/SubViewport/Lights

var mini_map_scale_factor: float = 0.07*48
var mini_map_icon_size: int = 8

func _ready() -> void:
	mini_map_scale_factor = float(SettingsManager.get_default_value("mini_map_scale_factor"))
	mini_map_icon_size = int(SettingsManager.get_default_value("mini_map_icon_size"))
	ActionManager.register_action("mini_map", "set_tile_set", set_tile_set)
	ActionManager.register_action("mini_map", "set_block", set_block)
	ActionManager.register_action("mini_map", "save_zoom_setting", save_zoom_setting)
	ActionManager.register_action("mini_map", "update_chunk_light", update_chunk_light)
	ActionManager.register_action("mini_map", "update_background", update_background)
	ActionManager.register_action("mini_map", "refresh", refresh)
	ActionManager.register_action("mini_map", "zoom_in", zoom_in)
	ActionManager.register_action("mini_map", "zoom_out", zoom_out)

func _process(delta: float) -> void:
	if not ClientManager.is_game_connected:
		return
	camera.position = ClientManager.local_player.camera.get_screen_center_position()
	var icon_scale = mini_map_scale_factor/camera.zoom[0]
	var half_icon_size = StaticLoad.MINI_MAP_ICON_SIZE*icon_scale*0.5
	for player_icon in player_icons.get_children():
		if StaticLoad.game.player_icons.has(player_icon.player_name):
			StaticLoad.game.player_icons[player_icon.player_name].position = player_icon.position-Vector2(0, half_icon_size)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		AudioManager.play_static_audio("sound/ui/click")
		if event.pressed:
			open_map()
		else:
			close_map()

func refresh() -> void:
	var mini_map_zoom = float(SettingsManager.get_current_setting("mini_map_zoom"))/100
	camera.zoom = Vector2(mini_map_zoom, mini_map_zoom)
	var icon_scale = mini_map_scale_factor/camera.zoom[0]
	for player_icon in player_icons.get_children():
		player_icon.scale = Vector2(icon_scale, icon_scale)
	if SettingsManager.get_current_setting("mini_map") == "off":
		visible = false
	else:
		visible = true

func save_zoom_setting() -> void:
	var change_value = {
		"mini_map_zoom": str(int(camera.zoom[0]*100))
	}
	SettingsManager.save_settings(change_value)

func set_tile_set(tile_set: TileSet) -> void:
	substantial_layer.tile_set = tile_set
	insubstantial_layer.tile_set = tile_set
	background_layer.tile_set = tile_set

func set_block(args: Dictionary) -> void:
	var block_layer = BlockLayer.get_index(args["block_layer"])
	var block_coordinate = args["block_coordinate"]
	var block_id = args["block_id"]
	var layer = substantial_layer
	if block_layer == BlockLayer.INSUBSTANTIAL:
		layer = insubstantial_layer
	elif block_layer == BlockLayer.BACK:
		layer = background_layer
	if block_id == 0:
		layer.set_cell(block_coordinate)
	else:
		var atlas_coodinate = WorldTransformer.get_atlas_coordinate(block_coordinate, block_layer)
		layer.set_cell(block_coordinate, 9999, atlas_coodinate)

func add_player(args: Dictionary) -> void:
	var skin_texture = args["skin_texture"]
	var player_name = args["player_name"]
	var player_icon_instance = SceneManager.get_scene("others/player_icon").instantiate()
	player_icon_instance.get_node("UpSkin").texture.atlas = skin_texture
	StaticLoad.game.player_icons[player_name] = player_icon_instance
	player_icons.add_child(player_icon_instance)
	var player_icon_scale = mini_map_scale_factor/camera.zoom[0]
	player_icon_instance.scale = Vector2(player_icon_scale, player_icon_scale)
	player_icon_instance.name = player_name

func update_chunk_light(args: Dictionary):
	var chunk_coordinate = args["chunk_coordinate"]
	var light_image = args["light_image"]
	var chunk_name = str(chunk_coordinate[0])+"."+str(chunk_coordinate[1])
	if not StaticLoad.game.mini_map_chunk_lights.has(chunk_name):
		var chunk_light = SceneManager.get_scene("others/chunk_light").instantiate()
		lights.add_child(chunk_light)
		chunk_light.name = chunk_name.replace(".", "_")
		chunk_light.chunk_pos = chunk_coordinate
		chunk_light.update_texture_from_image(light_image)
		StaticLoad.game.mini_map_chunk_lights[chunk_name] = chunk_light
	StaticLoad.game.mini_map_chunk_lights[chunk_name].update_texture_from_image(light_image)

func update_background(night_ratio: float) -> void:
	sky_background.color = lerp(Color(0.443, 0.698, 1),Color(0, 0.008, 0.137),night_ratio)
	star_background.modulate = Color(1, 1, 1, night_ratio)

func zoom_in() -> void:
	if camera.zoom[0] >= 0.2:
		camera.zoom -= Vector2(0.1, 0.1)
	if camera.zoom[0] < 0.1:
		camera.zoom = Vector2(0.1, 0.1)
	var icon_scale = mini_map_scale_factor/camera.zoom[0]
	for player_icon in player_icons.get_children():
		player_icon.scale = Vector2(icon_scale, icon_scale)

func zoom_out() -> void:
	if camera.zoom[0] <= 0.9:
		camera.zoom += Vector2(0.1, 0.1)
	if camera.zoom[0] > 1:
		camera.zoom = Vector2(1, 1)
	var icon_scale = mini_map_scale_factor/camera.zoom[0]
	for player_icon in player_icons.get_children():
		player_icon.scale = Vector2(icon_scale, icon_scale)

func open_map():
	set_anchors_preset(Control.PRESET_FULL_RECT)
	size = get_viewport_rect().size
	position = Vector2(0, 0)
	ClientManager.local_player.stop_move()
	InputManager.is_move_input_frozen = true
	await get_tree().create_timer(0.01)

func close_map():
	set_anchors_preset(Control.PRESET_TOP_RIGHT)
	size = Vector2(270, 270)
	position = Vector2(get_viewport_rect().size[0]-270, 0)
	ClientManager.local_player.stop_move()
	InputManager.is_move_input_frozen = false
	await get_tree().create_timer(0.01)
