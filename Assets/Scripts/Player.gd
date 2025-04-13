extends CharacterBody2D

# 预加载
@onready var player_model_mesh = $SubViewportContainer/SubViewport/PlayerModel/Root/Skeleton3D/Mesh
@onready var animation_tree = $SubViewportContainer/SubViewport/AnimationTree
@onready var player_sprite = $Sprite2D
@onready var player_model = $SubViewportContainer/SubViewport/PlayerModel
@onready var camera = $Camera2D
@onready var name_label = $Sprite2D/NameLable
@onready var item_in_hand = $SubViewportContainer/SubViewport/PlayerModel/Root/Skeleton3D/Hand/Item

# 实体变量
var uuid = UUID.v4()
var entity_type = "player"
var player_name: String

# 子类变量
var move_speed: float = 200
var jump_velocity: float = -550
var walk_period: float = 0.83
var run_period: float = 0.42
var dropped_item_speed: float = 1000
var dropped_item_no_collect_time: float = 2
var render_chunk: int = 1
var player_peer_id: int
var health: int = 20
var health_recover_timer: float = 10
var gamemode: String = "survival"
var velocity_before_pause = velocity
var current_velocity = Vector2(0, 0)
var last_velocity = Vector2(0, 0)
var selected_block_pos = Vector2i(0, 0)
var destroy_timer: float = 0
var selected_item_grid: int = 0
var step_sound_timer: float = 0
var move_state = "idle"
var face_state: int = -1
var turn_state: float = -1
var is_jump_pressed = false
var last_is_jump_pressed = false
var is_down_pressed = false
var last_is_down_pressed = false
var is_other = false
var is_pause = false
var is_frozen = false
var is_dead = false
var is_in_water = false
var is_flying = false
var is_punching = false
var animation_tree_parameters = {
	"walk": 0,
	"run": 0
}
var only_server_change_state_list = [
	"health"
]
var trigger_change_state_list = [
	"is_punching", "set_block_list"
]
var state_dict = {}
var last_state_dict = {}
var changed_state_dict = {}
var only_server_change_state_dict = {}
var set_block_list = []
var success_set_block_list = []
var item_bar_names = StaticLoad.default_item_bar_names
var item_bar_amounts = StaticLoad.default_item_bar_amounts
var in_hand_item_name = "AIR"
var skin_texture_buffer

func _ready():
	freeze()
	update_state_dict()

func _process(delta: float) -> void:
	update_current_velocity()
	
	# 通过接收的数据同步更新
	move_and_slide()
	update_sound_by_data()
	update_animation_by_data()
	# 仅在服务端的本地更新
	update_local_fall_damage_by_data()
	update_local_health_recover()
	# 本地更新
	update_local_set_block()
	update_local_gravity()
	update_local_move_by_data()
	update_local_item_in_hand()
	update_local_state_dict()
	update_local_changed_state_dict()
	upload_local_player_changed_state_dict()
	
	update_last_velocity()
	
func init_local(peer_id):
	player_peer_id = peer_id
	var config = ConfigFile.new()
	var result = config.load("user://configs.cfg")
	var skin_texture = load(StaticLoad.default_skin_path) as Texture2D
	if result == OK:
		player_name = config.get_value("options", "player_name", StaticLoad.options["player_name"])
		uuid = UUID.uuid_from_username(player_name)
		name_label.text = player_name
		StaticLoad.player_peer_dict[player_peer_id] = StaticLoad.game.player
		var fov_zoom = 1+1.6*(int(config.get_value("options", "fov_zoom", StaticLoad.options["fov_zoom"]))/100.0)
		camera.zoom = Vector2(fov_zoom, fov_zoom)
		render_chunk = int(config.get_value("options", "render_chunk", StaticLoad.options["render_chunk"]))
		if render_chunk > StaticLoad.RENDER_CHUNK_MAX:
			render_chunk = StaticLoad.RENDER_CHUNK_MAX
		if render_chunk < StaticLoad.RENDER_CHUNK_MIN:
			render_chunk = StaticLoad.RENDER_CHUNK_MIN
		var skin_path = config.get_value("options", "skin_path")	
		if skin_path != "null":
			var player_texture_tmp = Image.load_from_file(skin_path)
			if player_texture_tmp != null:
				skin_texture = player_texture_tmp
				skin_texture_buffer = skin_texture.save_png_to_buffer()
				set_player_model_skin_by_texture_buffer(skin_texture_buffer)
			else:
				set_player_model_skin_by_texture(skin_texture)
				skin_texture = Image.load_from_file(StaticLoad.default_skin_path)
				skin_texture_buffer = skin_texture.save_png_to_buffer()
		else:
			set_player_model_skin_by_texture(skin_texture)
			skin_texture = Image.load_from_file(StaticLoad.default_skin_path)
			skin_texture_buffer = skin_texture.save_png_to_buffer()
	if not StaticLoad.is_muti_mode:
		gamemode = StaticLoad.game.world_info_dictionary["gamemode"]
		var player_infos = DirAccess.get_files_at(ProjectSettings.globalize_path(StaticLoad.player_path))
		for player_info in player_infos:
			var player_config = ConfigFile.new()
			var player_result = player_config.load_encrypted_pass(StaticLoad.player_path+"/"+player_name.to_lower()+".dat", StaticLoad.CONFIG_PASSWORD)
			if player_result == OK:
				position = player_config.get_value("player", "position", StaticLoad.DEFAULT_PLAYER_SPAWN_POS)
				face_state = player_config.get_value("player", "face_state", StaticLoad.DEFAULT_PLAYER_FACE_STATE)
				turn_state = face_state
				is_flying = player_config.get_value("player", "is_flying", StaticLoad.DEFAULT_PLAYER_IS_FLYING)
				gamemode = player_config.get_value("player", "gamemode", StaticLoad.DEFAULT_PLAYER_GAMEMODE)
				health = player_config.get_value("player", "health", StaticLoad.DEFAULT_PLAYER_HEALTH)
				item_bar_names = player_config.get_value("player", "item_bar_names", item_bar_names)
				item_bar_amounts = player_config.get_value("player", "item_bar_amounts", item_bar_amounts)
		if gamemode != "creative":
			is_flying = false
		if self.gamemode == "creative":
			StaticLoad.game.health_bar.visible = false
		update_player_face_rotation()
		StaticLoad.game.update_new_chunk(true)
	
	var player_icon_instance = StaticLoad.player_icon_scene.instantiate()
	var mini_map_camera_zoom = StaticLoad.game.mini_map_camera.zoom[0]
	var player_icon_scale = StaticLoad.MINI_MAP_SCALE_FACTOR/mini_map_camera_zoom
	player_icon_instance.scale = Vector2(player_icon_scale, player_icon_scale)
	player_icon_instance.name = player_name
	StaticLoad.game.player_icons[player_name] = player_icon_instance
	StaticLoad.game.mini_map_players.add_child(player_icon_instance)
	
	if is_other:
		camera.queue_free()
	unfreeze()
	StaticLoad.game.update_game_details(true)
	StaticLoad.game.init_inventory()
	for i in range(9):
		if item_bar_names[i] == "AIR":
			continue
		StaticLoad.game.item_grids[i].get_node("ItemIcon").init_icon(item_bar_names[i].to_lower())
		if item_bar_amounts[i] <= 1:
			StaticLoad.game.item_grids[i].get_node("Amount").text = ""
		else:
			StaticLoad.game.item_grids[i].get_node("Amount").text = str(item_bar_amounts[i])
	
	if not StaticLoad.is_muti_mode:
		return
	StaticLoad.rpc("create_new_peer_player", player_peer_id)

func update_sound_by_data():
	if abs(current_velocity.y) < StaticLoad.FLOAT_DELTA and last_velocity.y > 1100:
		if last_velocity.y > 1300:
			StaticLoad.game.sound_audio_manager.play_random_audio_at_position("damage", "fallbig", position, 1)
		else:
			StaticLoad.game.sound_audio_manager.play_random_audio_at_position("damage", "fallsmall", position, 1)
	if move_state != "idle":
		var block_pos = StaticLoad.game.tile_map_layer.local_to_map(position+Vector2(0, 5))
		var block_id = StaticLoad.get_block_id_by_atlas_coords(StaticLoad.game.tile_map_layer.get_cell_atlas_coords(block_pos))
		if step_sound_timer <= 0 and block_id != 0:
			if not StaticLoad.get_is_untouchable_by_id(block_id):
				if move_state == "walk":
					step_sound_timer = walk_period
					StaticLoad.game.sound_audio_manager.play_random_audio_at_position("step", StaticLoad.get_step_type_by_name(StaticLoad.get_block_name_by_id(block_id)), position, 1)
				elif move_state == "run":
					step_sound_timer = run_period
					StaticLoad.game.sound_audio_manager.play_random_audio_at_position("step", StaticLoad.get_step_type_by_name(StaticLoad.get_block_name_by_id(block_id)), position, 1)
	elif step_sound_timer > 0:
		step_sound_timer = 0
	if step_sound_timer > 0:
		step_sound_timer -= get_process_delta_time()

func update_animation_tree():
	animation_tree["parameters/Run/blend_amount"] = animation_tree_parameters["run"]
	animation_tree["parameters/Walk/blend_amount"] = animation_tree_parameters["walk"]

func update_animation_by_data():
	var delta = get_process_delta_time()
	if is_frozen:
		return
	if move_state == "run":
		animation_tree_parameters["run"] = lerpf(animation_tree_parameters["run"], 1, StaticLoad.BLEND_SPEED*delta)
		animation_tree_parameters["walk"] = lerpf(animation_tree_parameters["walk"], 0, StaticLoad.BLEND_SPEED*delta)
	elif move_state == "walk":
		animation_tree_parameters["run"] = lerpf(animation_tree_parameters["run"], 0, StaticLoad.BLEND_SPEED*delta)
		animation_tree_parameters["walk"] = lerpf(animation_tree_parameters["walk"], 1, StaticLoad.BLEND_SPEED*delta)
	elif move_state == "idle":
		animation_tree_parameters["run"] = lerpf(animation_tree_parameters["run"], 0, StaticLoad.BLEND_SPEED*delta)
		animation_tree_parameters["walk"] = lerpf(animation_tree_parameters["walk"], 0, StaticLoad.BLEND_SPEED*delta)
	
	if abs(turn_state-face_state) > 0.01:
		update_player_face_rotation()
		var turn_amplitude = delta/StaticLoad.TURN_TIME
		if turn_amplitude > 1:
			turn_amplitude = 1
		turn_state = turn_state*(1-turn_amplitude)+face_state*turn_amplitude
		if abs(turn_state-face_state)<0.01:
			turn_state = face_state
			update_player_face_rotation()
	if is_punching:
		if not animation_tree["parameters/Punch/active"]:
			animation_tree["parameters/Punch/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		if StaticLoad.is_muti_mode and StaticLoad.multiplayer.get_unique_id() == player_peer_id:
			changed_state_dict["is_punching"] = true
		is_punching = false
	update_animation_tree()

func update_local_fall_damage_by_data():
	if StaticLoad.is_muti_mode and not StaticLoad.multiplayer.get_unique_id() == 1:
		return
	#更新摔落
	if gamemode == "survival":
		if abs(current_velocity.y) < StaticLoad.FLOAT_DELTA and last_velocity.y > 1000:
			@warning_ignore("integer_division")
			var damage = (int(last_velocity.y)-1000)/50
			get_damage(damage)
			if StaticLoad.is_muti_mode:
				StaticLoad.rpc_entity_func_by_uuid(uuid, "get_damage", damage, "others", true)

func update_local_health_recover():
	if StaticLoad.is_muti_mode and not StaticLoad.multiplayer.get_unique_id() == 1:
		return
	if health >= 20:
		return
	if gamemode == "creative":
		return
	if health < 20:
		health_recover_timer -= get_process_delta_time()
	if health_recover_timer < -1.5:
		health += 1
		health_recover_timer = 0

func update_local_set_block():
	if not set_block_list.is_empty():
		for set_block_info in set_block_list.duplicate():
			var set_block_id = set_block_info[0]
			var set_block_pos = set_block_info[1]
			var set_block_layer = set_block_info[2]
			StaticLoad.game.set_block_list.append([Time.get_ticks_msec(), uuid, set_block_id, set_block_pos, set_block_layer, true])
			set_block_list.erase(set_block_info)
	if not success_set_block_list.is_empty() and StaticLoad.multiplayer.get_unique_id() != 1:
		for set_block_info in success_set_block_list.duplicate():
			if changed_state_dict.has("set_block_list") and changed_state_dict["set_block_list"] is Array:
				changed_state_dict["set_block_list"].append(set_block_info)
			else:
				changed_state_dict["set_block_list"] = [set_block_info]
			success_set_block_list.erase(set_block_info)

func update_local_gravity():
	if StaticLoad.is_muti_mode and not StaticLoad.multiplayer.get_unique_id() == player_peer_id:
		return
	if StaticLoad.is_muti_mode:
		var player_block_pos = StaticLoad.game.tile_map_layer.local_to_map(position-Vector2(0,24))
		var chunk_pos_tmp = StaticLoad.game.get_chunk_position(player_block_pos)
		if not StaticLoad.game.loaded_chunks.has(str(chunk_pos_tmp[0])+"."+str(chunk_pos_tmp[1])):
			if not is_pause:
				is_pause = true
				velocity_before_pause = velocity
				velocity = Vector2(0, -0.01)
			return
	if is_pause:
		velocity = velocity_before_pause
		is_pause = false
	if velocity.x > StaticLoad.MAX_SPEED:
		velocity.x = StaticLoad.MAX_SPEED
	if velocity.y > StaticLoad.MAX_SPEED:
		velocity.y = StaticLoad.MAX_SPEED
	if is_flying or is_frozen:
		return
	if not is_on_floor():
		velocity += get_gravity() * get_process_delta_time()

func update_local_move_by_data():
	if StaticLoad.is_muti_mode and not StaticLoad.multiplayer.get_unique_id() == player_peer_id:
		return
	if is_frozen:
		if velocity.length() > StaticLoad.FLOAT_DELTA:
			velocity = Vector2(0, 0)
		return
	if is_jump_pressed:
		if not is_flying and is_on_floor():
			velocity.y = jump_velocity
		elif is_flying:
			velocity.y = jump_velocity * 0.7
	if last_is_jump_pressed and not is_jump_pressed:
		if is_flying:
			velocity.y = 0
	last_is_jump_pressed = is_jump_pressed
	
	if is_down_pressed:
		if is_flying:
			velocity.y = -jump_velocity * 0.7
	if last_is_down_pressed and not is_down_pressed:
		if is_flying:
			velocity.y = 0
	last_is_down_pressed = is_down_pressed
	
	if move_state == "run":
		if is_in_water:
			velocity.x = face_state * move_speed
		else:
			velocity.x = face_state * move_speed * 2
	elif move_state == "walk":
		if is_in_water:
			velocity.x = face_state * move_speed * 0.5
		else:
			velocity.x = face_state * move_speed
	elif move_state == "idle":
		velocity.x = 0
	
	if velocity.length() > StaticLoad.FLOAT_DELTA:
		var player_block_pos = StaticLoad.game.tile_map_layer.local_to_map(position-Vector2(0,24))
		var block_id_down = StaticLoad.get_block_id_by_atlas_coords(StaticLoad.game.tile_map_layer.get_cell_atlas_coords(player_block_pos))
		var block_id_up = StaticLoad.get_block_id_by_atlas_coords(StaticLoad.game.tile_map_layer.get_cell_atlas_coords(player_block_pos-Vector2i(0,1)))
		if not StaticLoad.get_is_untouchable_by_id(block_id_down):
			velocity = Vector2(0, 0)
		if not StaticLoad.get_is_untouchable_by_id(block_id_up):
			velocity = Vector2(0, 0)

func set_item_in_hand(got_item_name):
	if StaticLoad.get_item_model_type_by_name(got_item_name) == 0:
		item_in_hand.get_node("Item").visible = false
		item_in_hand.get_node("Tool").visible = false
		item_in_hand.get_node("Block").visible = false
		if not StaticLoad.is_muti_mode or (StaticLoad.is_muti_mode and StaticLoad.multiplayer.get_unique_id()==player_peer_id):
			StaticLoad.game.inventory_player_model_item_in_hand.get_node("Item").visible = false
			StaticLoad.game.inventory_player_model_item_in_hand.get_node("Tool").visible = false
			StaticLoad.game.inventory_player_model_item_in_hand.get_node("Block").visible = false
	elif StaticLoad.get_item_model_type_by_name(got_item_name) == 1:
		var item_mesh = item_in_hand.get_node("Item/Mesh")
		var inventory_player_model_item_mesh = StaticLoad.game.inventory_player_model_item_in_hand.get_node("Item/Mesh")
		var item_material = load("res://Assets/Materials/ItemModel.tres").duplicate(true)
		var item_texture = load("res://Assets/ResourcePacks/"+StaticLoad.game.resource_pack+"/Items/"+got_item_name.to_lower()+".png")
		if item_texture == null:
			item_texture = load("res://Assets/ResourcePacks/"+StaticLoad.game.resource_pack+"/Items/missing_texture.png")
		item_material.albedo_texture = item_texture
		item_mesh.mesh.surface_set_material(0, item_material)
		if not StaticLoad.is_muti_mode or (StaticLoad.is_muti_mode and StaticLoad.multiplayer.get_unique_id()==player_peer_id):
			inventory_player_model_item_mesh.mesh.surface_set_material(0, item_material)
		item_in_hand.get_node("Item").visible = true
		item_in_hand.get_node("Tool").visible = false
		item_in_hand.get_node("Block").visible = false
		if not StaticLoad.is_muti_mode or (StaticLoad.is_muti_mode and StaticLoad.multiplayer.get_unique_id()==player_peer_id):
			StaticLoad.game.inventory_player_model_item_in_hand.get_node("Item").visible = true
			StaticLoad.game.inventory_player_model_item_in_hand.get_node("Tool").visible = false
			StaticLoad.game.inventory_player_model_item_in_hand.get_node("Block").visible = false
	elif StaticLoad.get_item_model_type_by_name(got_item_name) == 2:
		var tool_mesh = item_in_hand.get_node("Tool/Mesh")
		var inventory_player_model_tool_mesh = StaticLoad.game.inventory_player_model_item_in_hand.get_node("Tool/Mesh")
		var tool_material = load("res://Assets/Materials/ToolModel.tres").duplicate(true)
		var tool_texture = load("res://Assets/ResourcePacks/"+StaticLoad.game.resource_pack+"/Items/"+got_item_name.to_lower()+".png")
		if tool_texture == null:
			tool_texture = load("res://Assets/ResourcePacks/"+StaticLoad.game.resource_pack+"/Items/missing_texture.png")
		tool_material.albedo_texture = tool_texture
		tool_mesh.mesh.surface_set_material(0, tool_material)
		if not StaticLoad.is_muti_mode or (StaticLoad.is_muti_mode and StaticLoad.multiplayer.get_unique_id()==player_peer_id):
			inventory_player_model_tool_mesh.mesh.surface_set_material(0, tool_material)
		item_in_hand.get_node("Item").visible = false
		item_in_hand.get_node("Tool").visible = true
		item_in_hand.get_node("Block").visible = false
		if not StaticLoad.is_muti_mode or (StaticLoad.is_muti_mode and StaticLoad.multiplayer.get_unique_id()==player_peer_id):
			StaticLoad.game.inventory_player_model_item_in_hand.get_node("Item").visible = false
			StaticLoad.game.inventory_player_model_item_in_hand.get_node("Tool").visible = true
			StaticLoad.game.inventory_player_model_item_in_hand.get_node("Block").visible = false
	elif StaticLoad.get_item_model_type_by_name(got_item_name) == 3:
		var block_mesh = item_in_hand.get_node("Block/Mesh")
		var inventory_player_model_block_mesh = StaticLoad.game.inventory_player_model_item_in_hand.get_node("Block/Mesh")
		var block_material = load("res://Assets/Materials/BlockModel.tres").duplicate(true)
		block_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		var block_texture = load("res://Assets/ResourcePacks/"+StaticLoad.game.resource_pack+"/ModelBlocks/"+got_item_name.to_lower()+".png")
		if block_texture == null:
			block_texture = load("res://Assets/ResourcePacks/"+StaticLoad.game.resource_pack+"/ModelBlocks/missing_texture.png")
		block_material.albedo_texture = block_texture
		block_mesh.mesh.surface_set_material(0, block_material)
		if not StaticLoad.is_muti_mode or (StaticLoad.is_muti_mode and StaticLoad.multiplayer.get_unique_id()==player_peer_id):
			inventory_player_model_block_mesh.mesh.surface_set_material(0, block_material)
		item_in_hand.get_node("Item").visible = false
		item_in_hand.get_node("Tool").visible = false
		item_in_hand.get_node("Block").visible = true
		if not StaticLoad.is_muti_mode or (StaticLoad.is_muti_mode and StaticLoad.multiplayer.get_unique_id()==player_peer_id):
			StaticLoad.game.inventory_player_model_item_in_hand.get_node("Item").visible = false
			StaticLoad.game.inventory_player_model_item_in_hand.get_node("Tool").visible = false
			StaticLoad.game.inventory_player_model_item_in_hand.get_node("Block").visible = true

func update_local_item_in_hand():
	if StaticLoad.is_muti_mode and not StaticLoad.multiplayer.get_unique_id() == player_peer_id:
		return
	var last_in_hand_item_name = item_bar_names[selected_item_grid]
	if last_in_hand_item_name == in_hand_item_name:
		return
	in_hand_item_name = last_in_hand_item_name
	set_item_in_hand(in_hand_item_name)

func update_state_dict():
	state_dict["face_state"] = face_state
	state_dict["move_state"] = move_state
	state_dict["is_flying"] = is_flying
	state_dict["is_frozen"] = is_frozen
	state_dict["render_chunk"] = render_chunk
	state_dict["gamemode"] = gamemode
	state_dict["selected_block_pos"] = selected_block_pos
	state_dict["destroy_timer"] = destroy_timer
	state_dict["position"] = position
	state_dict["in_hand_item_name"] = in_hand_item_name
	state_dict["current_velocity"] = current_velocity
	state_dict["health"] = health

func update_local_state_dict():
	if not StaticLoad.is_muti_mode:
		return
	if not StaticLoad.multiplayer.get_unique_id() == 1 and not StaticLoad.multiplayer.get_unique_id() == player_peer_id:
		return
	update_state_dict()

# 由于only_server_change_state_list的限制
# 在该列表中的state是本不该由服务端更新的部分
# 但不会由客户端上传，仅会在服务端更新
func update_local_changed_state_dict():
	if not StaticLoad.is_muti_mode:
		return
	if not StaticLoad.multiplayer.get_unique_id() == 1 and not StaticLoad.multiplayer.get_unique_id() == player_peer_id:
		return
	for key in state_dict:
		if not last_state_dict.has(key) or last_state_dict[key] != state_dict[key]:
			# 客户端仅上传非only_server_change_state_list状态
			if not StaticLoad.multiplayer.get_unique_id() == 1:
				if only_server_change_state_list.has(key):
					continue
			# 服务端仅更新only_server_change_state_list状态
			if StaticLoad.multiplayer.get_unique_id() == 1 and not player_peer_id == 1:
				if not only_server_change_state_list.has(key):
					continue
			last_state_dict[key] = state_dict[key]
			if StaticLoad.multiplayer.get_unique_id() == 1 and not player_peer_id == 1:
				only_server_change_state_dict[key] = state_dict[key]
			else:
				changed_state_dict[key] = state_dict[key]

func set_changed_state_dict(new_changed_state_dict):
	for key in new_changed_state_dict:
		if changed_state_dict.has(key) and changed_state_dict[key] is Array:
			changed_state_dict[key].append_array(new_changed_state_dict[key])
		elif changed_state_dict.has(key) and changed_state_dict[key] is Dictionary:
			changed_state_dict[key].merge(new_changed_state_dict[key], true)
		else:
			changed_state_dict[key] = new_changed_state_dict[key]

func rectify_changed_state_dict():
	var is_need_resend = false
	for key in changed_state_dict:	
		if key == "render_chunk":
			var render_chunk_tmp = changed_state_dict[key]
			if render_chunk_tmp > StaticLoad.RENDER_CHUNK_MAX:
				render_chunk_tmp = StaticLoad.RENDER_CHUNK_MAX
			if render_chunk_tmp < StaticLoad.RENDER_CHUNK_MIN:
				render_chunk_tmp = StaticLoad.RENDER_CHUNK_MIN
			changed_state_dict[key] = render_chunk_tmp
			is_need_resend = true
		#elif key == "position":
			#if position.distance_to(changed_state_dict[key]) > StaticLoad.POSITION_MAX_DIFFERENCE:
				#changed_state_dict[key] = position
				#is_need_resend = true
	if is_need_resend:
		StaticLoad.rpc_entity_func_by_uuid(uuid, "apply_changed_state_dict", changed_state_dict, [player_peer_id], true)

func apply_changed_state_dict(got_changed_state_dict):
	for key in got_changed_state_dict:
		if trigger_change_state_list.has(key):
			if StaticLoad.multiplayer.get_unique_id() == player_peer_id:
				continue
		if key == "position":
			var tween = get_tree().create_tween()
			tween.tween_property(self, "position", got_changed_state_dict[key], 0.001)
		elif key == "in_hand_item_name":
			in_hand_item_name = got_changed_state_dict[key]
			set_item_in_hand(in_hand_item_name)
		elif key == "set_block_list":
			for set_block_info in got_changed_state_dict[key]:
				set_block_list.append(set_block_info)
			changed_state_dict.erase(key)
		else:
			self.set(key, got_changed_state_dict[key])

func upload_local_player_changed_state_dict():
	if not StaticLoad.is_muti_mode:
		return
	if StaticLoad.multiplayer.get_unique_id() == 1:
		return
	if not StaticLoad.multiplayer.get_unique_id() == player_peer_id:
		return
	StaticLoad.rpc_entity_func_by_uuid(uuid, "set_changed_state_dict", changed_state_dict, [], true)
	changed_state_dict.clear()

func update_last_velocity():
	last_velocity = current_velocity

func update_current_velocity():
	if StaticLoad.is_muti_mode and StaticLoad.multiplayer.get_unique_id() != player_peer_id:
		return
	if velocity.x > StaticLoad.MAX_SPEED:
		velocity.x = StaticLoad.MAX_SPEED
	if velocity.y > StaticLoad.MAX_SPEED:
		velocity.y = StaticLoad.MAX_SPEED
	current_velocity = velocity

func update_player_face_rotation():
	var current_rotation = player_model.rotation_degrees
	var looking_at = Vector3(current_rotation.x, 90+turn_state*90*StaticLoad.TURN_STATE_SCALE_FACTOR, current_rotation.z)
	player_model.rotation_degrees = looking_at

func get_damage(damage):
	if damage > 0:
		health_recover_timer = StaticLoad.HEALTH_RECOVER_TIME
	var final_damage = damage
	if final_damage > StaticLoad.DEFAULT_PLAYER_HEALTH:
		final_damage = damage
	health -= final_damage
	var tween = get_tree().create_tween()
	tween.tween_method(set_shader_blink_intensity, 0.5, 0, StaticLoad.HURT_TIME)
	if health <= 0:
		player_die()
		var tween1 = get_tree().create_tween()
		tween1.tween_method(set_name_label_modulate, Color(1,1,1,1), Color(1,1,1,0), StaticLoad.DISSOLVE_TIME)
		StaticLoad.game.sound_audio_manager.play_random_audio_at_position("player", "hurt", position, 1)
		var tween2 = get_tree().create_tween()
		tween2.tween_method(set_shader_dissolve_intensity, -0.6, 0.6, StaticLoad.DISSOLVE_TIME)
	else:
		StaticLoad.game.sound_audio_manager.play_random_audio_at_position("damage", "hit", position, 1)

func set_block(args):
	var set_block_id = args[0]
	var set_block_pos = args[1]
	var set_block_layer = args[2]
	StaticLoad.game.set_block_list.append([Time.get_ticks_msec(), uuid, set_block_id, set_block_pos, set_block_layer, false])

func fail_set_block(args):
	var set_block_id = args[0]
	var set_block_pos = args[1]
	var set_block_layer = args[2]
	item_bar_names = args[3]
	item_bar_amounts = args[4]
	StaticLoad.game.set_block_list.append([Time.get_ticks_msec(), uuid, set_block_id, set_block_pos, set_block_layer, false])

func destroy_block(block_pos: Vector2i):
	var destroy_layer = "solid"
	var tile_map_layer_tmp = StaticLoad.game.tile_map_layer
	var chunk_pos = StaticLoad.game.get_chunk_position(block_pos)
	if not StaticLoad.game.loaded_chunks.has(str(chunk_pos[0])+"."+str(chunk_pos[1])):
		return false
	var block_id = StaticLoad.get_block_id_by_atlas_coords(StaticLoad.game.tile_map_layer.get_cell_atlas_coords(block_pos))
	if block_id == 0:
		destroy_layer = "no_reach"
		tile_map_layer_tmp = StaticLoad.game.no_reach_tile_map_layer
		block_id = StaticLoad.get_block_id_by_atlas_coords(StaticLoad.game.no_reach_tile_map_layer.get_cell_atlas_coords(block_pos))
	if tile_map_layer_tmp.get_cell_source_id(block_pos) != -1 and block_id != 0:
		set_block_list.append([0, block_pos, destroy_layer])
		is_punching = true
	else:
		return false

func place_block(block_pos):
	var chunk_pos = StaticLoad.game.get_chunk_position(block_pos)
	if not StaticLoad.game.loaded_chunks.has(str(chunk_pos[0])+"."+str(chunk_pos[1])):
		return false
	var selected_item_bar_name = item_bar_names[selected_item_grid]
	if selected_item_bar_name == "AIR":
		return false
	var block_id = StaticLoad.get_block_id_by_name(selected_item_bar_name)
	if not StaticLoad.game.check_place_block_state(block_pos, block_id):
		return false
	if StaticLoad.game.tile_map_layer.get_cell_source_id(block_pos) == -1 and StaticLoad.game.no_reach_tile_map_layer.get_cell_source_id(block_pos) == -1 and StaticLoad.block_ids.has(selected_item_bar_name):
		set_block_list.append([block_id, block_pos, "solid"])
		is_punching = true
	else:
		return false

func player_die():
	is_dead = true
	stop_move()
	if is_other:
		return
	if StaticLoad.game.is_pause:
		StaticLoad.game.pause_ui.visible = false
		is_pause = false
	StaticLoad.game.death_ui.visible = true
	StaticLoad.game.is_input_frozen = true
	if StaticLoad.is_on_mobile_platform:
		Input.emulate_mouse_from_touch = false
	StaticLoad.game.move_input_list.clear()

func send_message(message: String):
	var player_name_mesage =  "<"+player_name+">  "+message
	StaticLoad.game.broadcast_to_all(player_name_mesage)
	if StaticLoad.is_dedicated_server:
		var text = "["+StaticLoad.get_time_string(false)+" INFO]: "+"<"+player_name+"> "+message
		print(text)
		StaticLoad.record_server_log(Time.get_date_string_from_system(), text)

func send_command(command: String):
	var splits = command.split(" ")
	if StaticLoad.is_dedicated_server:
		var text = "["+StaticLoad.get_time_string(false)+" INFO]: "+"<"+player_name+"> "+command
		print(text)
		StaticLoad.record_server_log(Time.get_date_string_from_system(), text)
	if splits[0] == "/help":
		StaticLoad.game.close_chat_ui()
		StaticLoad.game.broadcast_to_person(player_name, tr("COMMAND_LIST"), "gold")
		for key in StaticLoad.commands:
			StaticLoad.game.broadcast_to_person(player_name, key, "gold")
	elif splits[0] == "/tp":
		StaticLoad.game.close_chat_ui()
		if splits.size() == 3:
			var x = int(splits[1])
			var y = int(splits[2])
			if abs(x) >= 200000 or abs(y) >= 200000:
				StaticLoad.game.broadcast_to_person(player_name, tr("RANGE_LIMIT"), "pink")
			else:
				if StaticLoad.is_dedicated_server or (StaticLoad.is_muti_mode and StaticLoad.multiplayer.get_unique_id() == 1):
					position = Vector2i(x*50+25, -y*50+50)
				var tween1 = get_tree().create_tween()
				tween1.tween_method(set_shader_blink_intensity, 0.0, -1.0, StaticLoad.TELEPORT_TIME/2.0)
				var tween2 = get_tree().create_tween()
				tween2.tween_method(set_shader_transparent_intensity, 0.0, 1.0, StaticLoad.TELEPORT_TIME/2.0)
				var tween3 = get_tree().create_tween()
				tween3.tween_method(set_name_label_modulate, Color(1,1,1,1), Color(1,1,1,0), StaticLoad.TELEPORT_TIME/2.0)
				await tween3.finished
				freeze()
				position = Vector2i(x*50+25, -y*50+50)
				unfreeze()
				var tween4 = get_tree().create_tween()
				tween4.tween_method(set_shader_transparent_intensity, 1.0, 0.0, StaticLoad.TELEPORT_TIME/2.0)
				var tween5 = get_tree().create_tween()
				tween5.tween_method(set_name_label_modulate, Color(1,1,1,0), Color(1,1,1,1), StaticLoad.TELEPORT_TIME/2.0)
				var tween6 = get_tree().create_tween()
				tween6.tween_method(set_shader_blink_intensity, -1.0, 0.0, StaticLoad.TELEPORT_TIME/2.0)
				StaticLoad.game.update_new_chunk(false)
				StaticLoad.game.broadcast_to_person(player_name, tr("TELEPORT_INFO_1")+player_name+tr("TELEPORT_INFO_2")+"x="+str(x)+", y="+str(y), "chartreuse")
				await get_tree().create_timer(0.01).timeout
		else:
			StaticLoad.game.broadcast_to_person(player_name, tr("USAGE")+" : "+tr(StaticLoad.commands["/tp"]), "gold")
	elif splits[0] == "/gamemode":
		StaticLoad.game.close_chat_ui()
		if splits.size() == 2 and splits[1] != "":
			if splits[1].is_valid_int():
				var gamemode_tmp = StaticLoad.get_gamemode_from_sort(int(splits[1]))
				if gamemode_tmp == "null":
					StaticLoad.game.broadcast_to_person(player_name, splits[1]+tr("NOT_VALID_MODE_OR_NUM"), "pink")
					return
				gamemode = gamemode_tmp
				StaticLoad.game.broadcast_to_person(player_name, player_name+tr("GAMEMODE_SET_TO")+tr(gamemode.to_upper()+"_MODE"), "chartreuse")
				if not is_other:
					StaticLoad.game.update_health_bar()
			elif StaticLoad.get_is_valid_gamemode(splits[1]):
				gamemode = splits[1]
				StaticLoad.game.broadcast_to_person(player_name, player_name+tr("GAMEMODE_SET_TO")+tr(gamemode.to_upper()+"_MODE"), "chartreuse")
				if not is_other:
					StaticLoad.game.update_health_bar()
			else:
				StaticLoad.game.broadcast_to_person(player_name, splits[1]+tr("NOT_VALID_MODE_OR_NUM"), "pink")
		else:
			StaticLoad.game.broadcast_to_person(player_name, tr("USAGE")+" : "+tr(StaticLoad.commands["/gamemode"]), "gold")
	else:
		StaticLoad.game.broadcast_to_person(player_name, tr("UNKNOWN_COMMAND"), "pink")

# 清除玩家物品，返回实际清除个数
func clear_item(item_name: String, amount: int) -> int:
	var list = GameCalculator.clear_item(item_name, amount, PackedStringArray(item_bar_names), PackedInt32Array(item_bar_amounts))
	item_bar_names = list[1]
	item_bar_amounts = list[2]
	return list[0]
	#var amount_cleared = 0
	#for i in range(36):
		#if item_bar_names[i] == item_name:
			#while item_bar_amounts[i] > 0:
				#if amount_cleared >= amount:
					#break
				#amount_cleared += 1
				#item_bar_amounts[i] -= 1
			#if item_bar_amounts[i] == 0:
				#item_bar_names[i] = "AIR"
		#if amount_cleared >= amount:
			#break
	#return amount_cleared

# 玩家拾取掉落物，返回未被拾取的数量
func get_item(args):
	var item_name = args[0]
	var amount = args[1]
	var search_begin = args[2]
	var search_size = args[3]
	var sound_on = args[4]
	var list = GameCalculator.get_item(item_name, amount, search_begin, search_size, PackedStringArray(item_bar_names), PackedInt32Array(item_bar_amounts), StaticLoad.get_is_durable_by_name(name), StaticLoad.get_max_amount_by_name(name), selected_item_grid)
	item_bar_names = list[2]
	item_bar_amounts = list[3]
	#var empty_list = []
	#for i in range(9):
		#empty_list.append(item_bar_names[i] == "AIR")
	#
	#var amount_left = amount
	#if not StaticLoad.get_is_durable_by_name(item_name):
		#for i in range(search_begin, search_size):
			#if item_bar_names[i] == item_name:
				#if item_bar_amounts[i] < StaticLoad.get_max_amount_by_name(item_name):
					#if item_bar_amounts[i] + amount_left > StaticLoad.get_max_amount_by_name(item_name):
						#amount_left -= StaticLoad.get_max_amount_by_name(item_name) - item_bar_amounts[i]
						#item_bar_amounts[i] = StaticLoad.get_max_amount_by_name(item_name)
					#else:
						#item_bar_amounts[i] += amount_left
						#amount_left = 0
						#break
	#if amount_left > 0:
		#for i in range(search_begin, search_size):
			#if item_bar_names[i] == "AIR":
				#if amount_left <= StaticLoad.get_max_amount_by_name(item_name):
					#item_bar_amounts[i] = amount_left
					#item_bar_names[i] = item_name
					#amount_left = 0
					#break
				#else:
					#item_bar_amounts[i] = StaticLoad.get_max_amount_by_name(item_name)
					#item_bar_names[i] = item_name
					#amount_left -= StaticLoad.get_max_amount_by_name(item_name)
	if item_bar_amounts[selected_item_grid] == 0:
		item_bar_names[selected_item_grid] = "AIR"
	if list[0] < amount and sound_on:
		StaticLoad.game.sound_audio_manager.play_audio_static("player", "pop")
	if not StaticLoad.is_muti_mode or (StaticLoad.is_muti_mode and player_peer_id == StaticLoad.multiplayer.get_unique_id()):
		if StaticLoad.game.is_inventory:
			StaticLoad.game.refresh_to_process.append("refresh_inventory")
		if list[0] < amount and item_bar_names[selected_item_grid] != "AIR" and list[1]:
			StaticLoad.game.refresh_to_process.append("refresh_item_name_label")
		if list[0] < amount:
			StaticLoad.game.refresh_to_process.append("refresh_item_grid")
	return list[0]

# 玩家拾取掉落物，返回未被拾取的数量
func if_get_item_left(name: String, amount: int, search_begin: int, search_size: int) -> int:
	return GameCalculator.if_get_item_left(name, amount, search_begin, search_size, PackedStringArray(item_bar_names), PackedInt32Array(item_bar_amounts), StaticLoad.get_is_durable_by_name(name), StaticLoad.get_max_amount_by_name(name))
	#var amount_left = amount
	#if not StaticLoad.get_is_durable_by_name(name):
		#for i in range(search_begin, search_size):
			#if item_bar_names[i] == name:
				#if item_bar_amounts[i] < StaticLoad.get_max_amount_by_name(name):
					#if item_bar_amounts[i] + amount_left > StaticLoad.get_max_amount_by_name(name):
						#amount_left -= StaticLoad.get_max_amount_by_name(name) - item_bar_amounts[i]
					#else:
						#amount_left = 0
						#break
	#if amount_left > 0:
		#for i in range(search_begin, search_size):
			#if item_bar_names[i] == "AIR":
				#if amount_left <= StaticLoad.get_max_amount_by_name(name):
					#amount_left = 0
					#break
				#else:
					#amount_left -= StaticLoad.get_max_amount_by_name(name)
	#return amount_left

func drop_item(item_name, item_amount):
	if item_name == "AIR":
		return
	var x_velocity = face_state*dropped_item_speed
	var summon_item_args = [item_name, position-Vector2(0,55), item_amount, x_velocity, dropped_item_no_collect_time, UUID.v4()]
	if StaticLoad.is_muti_mode:
		if StaticLoad.multiplayer.get_unique_id() == 1:
			summon_item(summon_item_args)
			StaticLoad.rpc_entity_func_by_uuid(uuid, "summon_item", summon_item_args, "others", true)
		else:
			StaticLoad.rpc_entity_func_by_uuid(uuid, "summon_item", summon_item_args, [1], false)
	else:
		summon_item(summon_item_args)

func summon_item(args):
	var droppped_item_name = args[0]
	var pos = args[1]
	var amount = args[2]
	var x_velocity = args[3]
	if StaticLoad.is_muti_mode and not StaticLoad.multiplayer.get_unique_id() == 1:
		x_velocity = 0
	var no_collect_time = args[4]
	var uuid = args[5]
	var item = StaticLoad.game.item_scene.instantiate()
	StaticLoad.game.items.add_child(item)
	item.init([uuid, droppped_item_name, pos, amount, no_collect_time, x_velocity])
	StaticLoad.game.entities[item.get_uuid()] = item

func stop_move():
	last_is_down_pressed = false
	is_down_pressed = false
	last_is_jump_pressed = false
	is_jump_pressed = false
	move_state = "idle"
	velocity.x = 0
	if is_flying:
		velocity.y = 0

func respawn(is_animation = true):
	position = Vector2(0, -1)
	health = 20
	is_dead = false
	if is_animation:
		var tween1 = get_tree().create_tween()
		tween1.tween_method(set_name_label_modulate, Color(1,1,1,0), Color(1,1,1,1), StaticLoad.DISSOLVE_TIME)
		var tween2 = get_tree().create_tween()
		tween2.tween_method(set_shader_dissolve_intensity, 0.6, -0.6, StaticLoad.DISSOLVE_TIME)
	if not StaticLoad.is_muti_mode or (StaticLoad.is_muti_mode and StaticLoad.multiplayer.get_unique_id() == player_peer_id):
		if StaticLoad.is_on_mobile_platform:
			Input.emulate_mouse_from_touch = false
		StaticLoad.game.death_ui.visible = false
		StaticLoad.game.is_input_frozen = false
		StaticLoad.game.move_input_list.clear()
		stop_move()
	
func set_name_label_modulate(color):
	name_label.modulate = color

func leave_server_and_destroy():
	var tween1 = get_tree().create_tween()
	tween1.tween_method(set_shader_blink_intensity, 0.0, -1.0, StaticLoad.TELEPORT_TIME/2.0)
	var tween2 = get_tree().create_tween()
	tween2.tween_method(set_shader_transparent_intensity, 0.0, 1.0, StaticLoad.TELEPORT_TIME/2.0)
	var tween3 = get_tree().create_tween()
	tween3.tween_method(set_name_label_modulate, Color(1,1,1,1), Color(1,1,1,0), StaticLoad.TELEPORT_TIME/2.0)
	await tween3.finished
	self.queue_free()

func init_remote(got_data):
	player_peer_id = got_data[0]
	player_name = got_data[1]
	name_label.text = player_name
	apply_changed_state_dict(got_data[2])
	uuid = UUID.uuid_from_username(player_name)
	if gamemode != "creative":
		is_flying = false
	update_player_face_rotation()
	StaticLoad.game.entities[uuid] = self
	
	if player_peer_id == StaticLoad.multiplayer.get_unique_id():
		if self.gamemode == "creative":
			StaticLoad.game.health_bar.visible = false
	StaticLoad.player_peer_dict[player_peer_id] = StaticLoad.game.players.get_node(str(player_peer_id))
	StaticLoad.game.update_new_chunk(true)
	StaticLoad.game.update_game_details()
	unfreeze()
	if player_peer_id == StaticLoad.multiplayer.get_unique_id():
		return
	
	var player_icon_instance = StaticLoad.player_icon_scene.instantiate()
	var mini_map_camera_zoom = StaticLoad.game.mini_map_camera.zoom[0]
	var player_icon_scale = StaticLoad.MINI_MAP_SCALE_FACTOR/mini_map_camera_zoom
	player_icon_instance.scale = Vector2(player_icon_scale, player_icon_scale)
	player_icon_instance.name = player_name
	StaticLoad.game.player_icons[player_name] = player_icon_instance
	StaticLoad.game.mini_map_players.add_child(player_icon_instance)
	if StaticLoad.multiplayer.get_unique_id() == 1:
		return
	if not StaticLoad.game.online_ui_vbox_container.has_node(str(player_peer_id)):
		var online_info_instance = StaticLoad.online_info_scene.instantiate()
		StaticLoad.game.online_ui_vbox_container.add_child(online_info_instance)
		online_info_instance.name = str(player_peer_id)
		online_info_instance.player_name.text = self.player_name
		#var online_info = StaticLoad.game.online_ui_vbox_container.get_node(str(peer_id))
		await get_tree().create_timer(0.5).timeout
		StaticLoad.rpc_id(1, "request_for_ping", StaticLoad.multiplayer.get_unique_id(), player_peer_id)

func set_player_model_skin_by_texture_buffer(got_skin_texture_buffer):
	var player_material = load("res://Assets/Materials/PlayerSkin.tres").duplicate(true)
	var skin_texture_image = Image.new()
	skin_texture_image.load_png_from_buffer(got_skin_texture_buffer)
	player_material.albedo_texture = ImageTexture.create_from_image(skin_texture_image)
	player_model_mesh.mesh.surface_set_material(0, player_material)
	if player_peer_id == StaticLoad.multiplayer.get_unique_id():
		StaticLoad.game.inventory_player_model_mesh.mesh.surface_set_material(0, player_material)

func set_player_model_skin_by_texture(got_skin_texture):
	var player_material = load("res://Assets/Materials/PlayerSkin.tres").duplicate(true)
	player_material.albedo_texture = got_skin_texture
	player_model_mesh.mesh.surface_set_material(0, player_material)
	if player_peer_id == StaticLoad.multiplayer.get_unique_id():
		StaticLoad.game.inventory_player_model_mesh.mesh.surface_set_material(0, player_material)

func change_skin(got_skin_texture_buffer):
	if not typeof(got_skin_texture_buffer) == TYPE_PACKED_BYTE_ARRAY:
		return
	skin_texture_buffer = got_skin_texture_buffer
	set_player_model_skin_by_texture_buffer(skin_texture_buffer)

func set_shader_blink_intensity(value):
	player_sprite.material.set_shader_parameter("blink_intensity", value)

func set_shader_dissolve_intensity(value):
	player_sprite.material.set_shader_parameter("dissolve_intensity", value)

func set_shader_transparent_intensity(value):
	player_sprite.material.set_shader_parameter("transparent_intensity", value)

func freeze():
	velocity.y = 0
	is_frozen = true

func unfreeze():
	velocity.y = 0
	is_frozen = false

func get_uuid():
	return uuid

func get_entity_type():
	return entity_type

func get_entity_name():
	return player_name
