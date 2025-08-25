extends Control

@onready var player_model = $SubViewportContainer/SubViewport/PlayerModel
@onready var player_model_mesh = $SubViewportContainer/SubViewport/PlayerModel/Root/Skeleton3D/Mesh

func update_rotation(screen_position):
	var viewport_size = get_viewport_rect().size
	var viewport_half_size = viewport_size/2.0
	var target_position = screen_position-viewport_half_size-Vector2(viewport_size[0]*0.375, 0)
	player_model.look_at(Vector3(target_position[0], -target_position[1], 3250), Vector3.UP, true)

func update_skin(skin_path: String):
	var player_texture = TextureManager.get_texture("skins/steve_"+SettingsManager.get_current_setting("resource_pack").replace("official_", ""))
	var player_material = load("res://assets/materials/player_skin.tres").duplicate(true)
	var player_texture_tmp = ImageTexture.create_from_image(Image.load_from_file(skin_path))
	if player_texture_tmp != null:
		player_texture = player_texture_tmp
	player_material.albedo_texture = player_texture
	player_model_mesh.mesh.surface_set_material(0, player_material)
