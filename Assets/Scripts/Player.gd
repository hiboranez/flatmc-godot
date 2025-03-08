extends CharacterBody2D

const MOVE_SPEED = 200.0
const JUMP_VELOCITY = -550.0
const WALK_PERIOD = 0.83
const RUN_PERIOD = 0.42

@onready var player_model_mesh = $SubViewportContainer/SubViewport/PlayerModel/Root/Skeleton3D/Mesh

var uuid
var entity_type = "player"
var selected_block_pos = Vector2i(0, 0)
var destroy_timer: float = 0
var gamemode: String = "survival"
var health: int = StaticLoad.DEFAULT_PLAYER_HEALTH
var health_recover_timer = StaticLoad.HEALTH_RECOVER_TIME
var render_chunk: int = 1
var player_peer_id: int
var player_name: String
var is_jump_pressed: bool = false
var last_is_jump_pressed: bool = false
var is_down_pressed: bool = false
var last_is_down_pressed: bool = false
var is_other: bool = false
var is_pause: bool = false
var is_frozen: bool = false
var is_dead: bool = false
var is_in_water: bool = false
var is_flying: bool = false
var move_state: String = "idle"
var face_state: int = -1
var selected_item_grid: int = 0
var item_bar_names = []
var item_bar_amounts = []
var current_velocity = Vector2(0, 0)
var last_velocity = Vector2(0, 0)
var step_sound_timer = 0.0
var turn_state: float = -1
var velocity_before_pause
var skin_texture_buffer
var player_state = {
	"face_state": StaticLoad.DEFAULT_PLAYER_FACE_STATE,
	"move_state": "idle",
	"is_jump_pressed": false,
	"is_down_pressed": false,
	"is_flying": false,
	"render_chunk": 1,
	"gamemode": "survival",
	"selected_block_pos": Vector2i(0, 0),
	"destroy_timer": 0,
	"selected_item_grid": 0
	}
var animation_tree_parameters = {
	"walk": 0,
	"run": 0
}

@onready var animation_tree = $SubViewportContainer/SubViewport/AnimationTree
@onready var player_sprite = $Sprite2D
@onready var player_model = $SubViewportContainer/SubViewport/PlayerModel
@onready var camera = $Camera2D
@onready var name_label = $Sprite2D/NameLable
@onready var item_in_hand = $SubViewportContainer/SubViewport/PlayerModel/Root/Skeleton3D/Hand/Item

func _ready():
	freeze_player()
	velocity_before_pause = velocity
	item_bar_names = StaticLoad.default_item_bar_names
	item_bar_amounts = StaticLoad.default_item_bar_amounts

func _process(delta: float) -> void:
	move_and_slide()
	update_player_speed_related(delta)
	update_animation_by_player_state(delta)
	update_tree()
	if StaticLoad.is_muti_mode and StaticLoad.multiplayer.get_unique_id()!=1 and is_other:
		return
	update_health_recover(delta)
	update_gravity(delta)
	update_move_by_player_state()

func init(peer_id):
	player_peer_id = peer_id
	var config = ConfigFile.new()
	var result = config.load("user://configs.cfg")
	var player_texture = load(StaticLoad.default_skin_path) as Texture2D
	if result == OK:
		player_name = config.get_value("options", "player_name", StaticLoad.options["player_name"])
		uuid = UUID.uuid_from_username(player_name)
		name_label.text = player_name
		StaticLoad.online_peer_ids[player_peer_id] = StaticLoad.game.player
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
				player_texture = player_texture_tmp
				skin_texture_buffer = player_texture.save_png_to_buffer()
				refresh_player_model_skin(skin_texture_buffer)
			else:
				refresh_player_model_skin_by_texture(player_texture)
				player_texture = Image.load_from_file(StaticLoad.default_skin_path)
				skin_texture_buffer = player_texture.save_png_to_buffer()
		else:
			refresh_player_model_skin_by_texture(player_texture)
			player_texture = Image.load_from_file(StaticLoad.default_skin_path)
			skin_texture_buffer = player_texture.save_png_to_buffer()
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
	unfreeze_player()
	StaticLoad.game.update_details(true)
	StaticLoad.game.init_inventory()
	for i in range(9):
		if item_bar_names[i] == "AIR":
			continue
		StaticLoad.game.item_grids[i].get_node("ItemIcon").init_icon(item_bar_names[i].to_lower())
		if item_bar_amounts[i] <= 1:
			StaticLoad.game.item_grids[i].get_node("Amount").text = ""
		else:
			StaticLoad.game.item_grids[i].get_node("Amount").text = str(item_bar_amounts[i])
	switch_item_in_hand()
	
	if not StaticLoad.is_muti_mode:
		return
	StaticLoad.rpc("new_peer_broadcast", player_peer_id)

func update_health_recover(delta):
	if health >= StaticLoad.DEFAULT_PLAYER_HEALTH:
		return
	if gamemode == "creative":
		return
	if health < StaticLoad.DEFAULT_PLAYER_HEALTH:
		health_recover_timer -= delta
	if health_recover_timer < -1.5:
		health += 1
		health_recover_timer = 0
		if StaticLoad.is_muti_mode and StaticLoad.multiplayer.get_unique_id() == 1:
			remote_update_player_health(health)

func get_uuid():
	return uuid

func freeze_player():
	velocity.y = 0
	is_frozen = true
	$CollisionShape2D.disabled = true
	self.visible = false

func unfreeze_player():
	velocity.y = 0
	is_frozen = false
	$CollisionShape2D.disabled = false
	self.visible = true

func update_player_state():
	player_state["face_state"] = face_state
	player_state["move_state"] = move_state
	player_state["is_jump_pressed"] = is_jump_pressed
	player_state["is_down_pressed"] = is_down_pressed
	player_state["is_flying"] = is_flying
	player_state["render_chunk"] = render_chunk
	player_state["gamemode"] = gamemode
	player_state["selected_block_pos"] = selected_block_pos
	player_state["destroy_timer"] = destroy_timer
	player_state["selected_item_grid"] = selected_item_grid

func broadcast_player_state_to_all():
	if not StaticLoad.online_peer_ids.has(1):
		rpc_id(1, "remote_update_player_state", player_state)
	for peer_id in StaticLoad.online_peer_ids:
		if peer_id != StaticLoad.multiplayer_peer.get_unique_id():
			rpc_id(peer_id, "remote_update_player_state", player_state)

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

func set_shader_blink_intensity(value):
	player_sprite.material.set_shader_parameter("blink_intensity", value)

func set_shader_dissolve_intensity(value):
	player_sprite.material.set_shader_parameter("dissolve_intensity", value)

func set_shader_transparent_intensity(value):
	player_sprite.material.set_shader_parameter("transparent_intensity", value)

func player_die():
	is_dead = true
	stop_player_move()
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
	if StaticLoad.is_muti_mode:
		rpc("remote_stop_player_move")
	
func update_player_speed_related(delta):
	if not is_other:
		current_velocity = velocity
	if StaticLoad.is_muti_mode and StaticLoad.multiplayer.get_unique_id()==1:
		current_velocity = velocity
	#更新声音
	if abs(current_velocity.y) < StaticLoad.FLOAT_DELTA and last_velocity.y > 1100:
		if last_velocity.y > 1300:
			StaticLoad.game.sound_audio_manager.play_random_audio_at_position("damage", "fallbig", position, 1)
		else:
			StaticLoad.game.sound_audio_manager.play_random_audio_at_position("damage", "fallsmall", position, 1)
	#更新摔落
	if gamemode == "survival":
		if not StaticLoad.is_muti_mode:
			if abs(current_velocity.y) < StaticLoad.FLOAT_DELTA and last_velocity.y > 1000:
				@warning_ignore("integer_division")
				var damage = (int(last_velocity.y)-1000)/50
				get_damage(damage)
		elif StaticLoad.multiplayer.get_unique_id() == 1:
			if abs(current_velocity.y) < StaticLoad.FLOAT_DELTA and last_velocity.y > 1000:
				@warning_ignore("integer_division")
				var damage = (int(last_velocity.y)-1000)/50
				get_damage(damage)
				rpc("remote_damage_player", damage)
				for peer_id in StaticLoad.online_peer_ids:
					if peer_id == 1 or peer_id == player_peer_id:
						continue
					rpc_id(peer_id, "reply_for_update_player_velocity", velocity)
	
	#插入在这里，如果速度归零再发一遍更新位置
	if StaticLoad.is_muti_mode and StaticLoad.multiplayer.get_unique_id() != 1 and StaticLoad.multiplayer.get_unique_id() == player_peer_id:
		if abs(current_velocity.y) < StaticLoad.FLOAT_DELTA and abs(last_velocity.y) > StaticLoad.FLOAT_DELTA:
			rpc_id(1, "request_for_set_self_player_position", player_peer_id, position)
	elif StaticLoad.is_muti_mode and StaticLoad.multiplayer.get_unique_id() == 1 and StaticLoad.multiplayer.get_unique_id() == player_peer_id:
		if abs(current_velocity.y) < StaticLoad.FLOAT_DELTA and abs(last_velocity.y) > StaticLoad.FLOAT_DELTA:
			rpc("reply_for_set_self_player_position", position)
	last_velocity = current_velocity
	
	if move_state != "idle":
		var block_pos = StaticLoad.game.tile_map_layer.local_to_map(position+Vector2(0, 5))
		var block_id = StaticLoad.get_block_id_by_atlas_coords(StaticLoad.game.tile_map_layer.get_cell_atlas_coords(block_pos))
		if step_sound_timer <= 0 and block_id != 0:
			if not StaticLoad.get_is_untouchable_by_id(block_id):
				if move_state == "walk":
					step_sound_timer = WALK_PERIOD
					StaticLoad.game.sound_audio_manager.play_random_audio_at_position("step", StaticLoad.get_step_type_by_name(StaticLoad.get_block_name_by_id(block_id)), position, 1)
				elif move_state == "run":
					step_sound_timer = RUN_PERIOD
					StaticLoad.game.sound_audio_manager.play_random_audio_at_position("step", StaticLoad.get_step_type_by_name(StaticLoad.get_block_name_by_id(block_id)), position, 1)
	elif step_sound_timer > 0:
		step_sound_timer = 0
	if step_sound_timer > 0:
		step_sound_timer -= delta

func update_gravity(delta):
	if StaticLoad.is_muti_mode:
		var player_block_pos = StaticLoad.game.tile_map_layer.local_to_map(position-Vector2(0,24))
		var chunk_pos_tmp = StaticLoad.game.get_chunk_position(player_block_pos)
		if not StaticLoad.game.loaded_chunks.has(str(chunk_pos_tmp[0])+"."+str(chunk_pos_tmp[1])):
			if not is_pause:
				is_pause = true
				velocity_before_pause = velocity
				velocity = Vector2(0, -0.01)
				#if StaticLoad.multiplayer.get_unique_id() == 1:
					#rpc_id(player_peer_id, "refresh_player", position, velocity, face_state, move_state, is_flying)
			return
	if is_pause:
		velocity = velocity_before_pause
		#if StaticLoad.multiplayer.get_unique_id() == 1:
			#rpc_id(player_peer_id, "refresh_player", position, velocity, face_state, move_state, is_flying)
		is_pause = false
	if velocity.x > StaticLoad.MAX_SPEED:
		velocity.x = StaticLoad.MAX_SPEED
	if velocity.y > StaticLoad.MAX_SPEED:
		velocity.y = StaticLoad.MAX_SPEED
	if is_flying or is_frozen:
		return
	if not is_on_floor():
		velocity += get_gravity() * delta

func update_tree():
	animation_tree["parameters/Run/blend_amount"] = animation_tree_parameters["run"]
	animation_tree["parameters/Walk/blend_amount"] = animation_tree_parameters["walk"]

func update_animation_by_player_state(delta):
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

func update_move_by_player_state():
	if is_frozen:
		if velocity.length() > StaticLoad.FLOAT_DELTA:
			velocity = Vector2(0, 0)
		return
	if is_jump_pressed:
		if not is_flying and is_on_floor():
			velocity.y = JUMP_VELOCITY
		elif is_flying:
			velocity.y = JUMP_VELOCITY * 0.7
	if last_is_jump_pressed and not is_jump_pressed:
		if is_flying:
			velocity.y = 0
	last_is_jump_pressed = is_jump_pressed
	
	if is_down_pressed:
		if is_flying:
			velocity.y = -JUMP_VELOCITY * 0.7
	if last_is_down_pressed and not is_down_pressed:
		if is_flying:
			velocity.y = 0
	last_is_down_pressed = is_down_pressed
	
	if move_state == "run":
		if is_in_water:
			velocity.x = face_state * MOVE_SPEED
		else:
			velocity.x = face_state * MOVE_SPEED * 2
	elif move_state == "walk":
		if is_in_water:
			velocity.x = face_state * MOVE_SPEED * 0.5
		else:
			velocity.x = face_state * MOVE_SPEED
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
		
func update_player_face_rotation():
	var current_rotation = player_model.rotation_degrees
	var looking_at = Vector3(current_rotation.x, 90+turn_state*90*StaticLoad.TURN_STATE_SCALE_FACTOR, current_rotation.z)
	player_model.rotation_degrees = looking_at

func punch():
	if not animation_tree["parameters/Punch/active"]:
		animation_tree["parameters/Punch/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		if StaticLoad.is_muti_mode:
			rpc("remote_punch")

func refresh_player_model_skin_by_texture(skin_texture):
	var player_material = load("res://Assets/Materials/PlayerSkin.tres").duplicate(true)
	player_material.albedo_texture = skin_texture
	player_model_mesh.mesh.surface_set_material(0, player_material)
	if player_peer_id == StaticLoad.multiplayer.get_unique_id():
		StaticLoad.game.inventory_player_model_mesh.mesh.surface_set_material(0, player_material)

func refresh_player_model_skin(skin_texture_buffer):
	var player_material = load("res://Assets/Materials/PlayerSkin.tres").duplicate(true)
	var skin_texture_image = Image.new()
	skin_texture_image.load_png_from_buffer(skin_texture_buffer)
	player_material.albedo_texture = ImageTexture.create_from_image(skin_texture_image)
	player_model_mesh.mesh.surface_set_material(0, player_material)
	if player_peer_id == StaticLoad.multiplayer.get_unique_id():
		StaticLoad.game.inventory_player_model_mesh.mesh.surface_set_material(0, player_material)

func send_message(message: String):
	var player_name_mesage =  "<"+player_name+">  "+message
	StaticLoad.game.broadcast_to_all(player_name_mesage)
	if StaticLoad.is_dedicated_server:
		var text = "["+StaticLoad.get_time_string(false)+" INFO]: "+"<"+player_name+"> "+message
		print(text)
		StaticLoad.record_log(Time.get_date_string_from_system(), text)

func send_command(command: String):
	var splits = command.split(" ")
	if StaticLoad.is_dedicated_server:
		var text = "["+StaticLoad.get_time_string(false)+" INFO]: "+"<"+player_name+"> "+command
		print(text)
		StaticLoad.record_log(Time.get_date_string_from_system(), text)
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
				freeze_player()
				if StaticLoad.is_muti_mode:
					rpc("remote_freeze_player")
				position = Vector2i(x*50+25, -y*50+50)
				unfreeze_player()
				if StaticLoad.is_muti_mode:
					rpc("remote_unfreeze_player")	
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
				change_gamemode()
				if StaticLoad.is_muti_mode:
					rpc("remote_change_gamemode", gamemode)
			elif StaticLoad.get_is_valid_gamemode(splits[1]):
				gamemode = splits[1]
				StaticLoad.game.broadcast_to_person(player_name, player_name+tr("GAMEMODE_SET_TO")+tr(gamemode.to_upper()+"_MODE"), "chartreuse")
				change_gamemode()
				if StaticLoad.is_muti_mode:
					rpc("remote_change_gamemode", gamemode)
			else:
				StaticLoad.game.broadcast_to_person(player_name, splits[1]+tr("NOT_VALID_MODE_OR_NUM"), "pink")
		else:
			StaticLoad.game.broadcast_to_person(player_name, tr("USAGE")+" : "+tr(StaticLoad.commands["/gamemode"]), "gold")
	else:
		StaticLoad.game.broadcast_to_person(player_name, tr("UNKNOWN_COMMAND"), "pink")

func change_gamemode():
	if gamemode == "creative":
		if not is_other:
			StaticLoad.game.health_bar.visible = false
	elif gamemode == "survival":
		if not is_other:
			StaticLoad.game.health_bar.visible = true
		if is_flying:
			is_flying = false

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
func get_item(name: String, amount: int, search_begin: int, search_size: int, sound_on: bool) -> int:
	var list = GameCalculator.get_item(name, amount, search_begin, search_size, PackedStringArray(item_bar_names), PackedInt32Array(item_bar_amounts), StaticLoad.get_is_durable_by_name(name), StaticLoad.get_max_amount_by_name(name), selected_item_grid)
	item_bar_names = list[2]
	item_bar_amounts = list[3]
	#var empty_list = []
	#for i in range(9):
		#empty_list.append(item_bar_names[i] == "AIR")
	#
	#var amount_left = amount
	#if not StaticLoad.get_is_durable_by_name(name):
		#for i in range(search_begin, search_size):
			#if item_bar_names[i] == name:
				#if item_bar_amounts[i] < StaticLoad.get_max_amount_by_name(name):
					#if item_bar_amounts[i] + amount_left > StaticLoad.get_max_amount_by_name(name):
						#amount_left -= StaticLoad.get_max_amount_by_name(name) - item_bar_amounts[i]
						#item_bar_amounts[i] = StaticLoad.get_max_amount_by_name(name)
					#else:
						#item_bar_amounts[i] += amount_left
						#amount_left = 0
						#break
	#if amount_left > 0:
		#for i in range(search_begin, search_size):
			#if item_bar_names[i] == "AIR":
				#if amount_left <= StaticLoad.get_max_amount_by_name(name):
					#item_bar_amounts[i] = amount_left
					#item_bar_names[i] = name
					#amount_left = 0
					#break
				#else:
					#item_bar_amounts[i] = StaticLoad.get_max_amount_by_name(name)
					#item_bar_names[i] = name
					#amount_left -= StaticLoad.get_max_amount_by_name(name)
	if list[0] < amount and sound_on:
		StaticLoad.game.sound_audio_manager.play_audio_static("player", "pop")
		StaticLoad.game.refresh_to_process.append("refresh_item_grid")
		if item_bar_names[selected_item_grid] != "AIR" and list[1]:
			StaticLoad.game.refresh_to_process.append("refresh_item_name_label")
	if item_bar_amounts[selected_item_grid] == 0:
		item_bar_names[selected_item_grid] = "AIR"
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
	if StaticLoad.is_muti_mode:
		var x_velocity = face_state*StaticLoad.DROPPED_ITEM_SPEED
		if StaticLoad.multiplayer.get_unique_id() == 1:
			var item = StaticLoad.game.item_scene.instantiate()
			StaticLoad.game.items.add_child(item)
			item.velocity.x = x_velocity
			item.init(item_name, position-Vector2(0,55), item_amount, StaticLoad.DEFAULT_NO_COLLECT_TIME)
			StaticLoad.game.entities[item.get_uuid()] = item
			StaticLoad.rpc("reply_for_summon_item", item.uuid, item_name, position-Vector2(0,55), item_amount, StaticLoad.DEFAULT_NO_COLLECT_TIME)
		else:
			StaticLoad.rpc_id(1, "request_for_summon_item", item_name, position-Vector2(0,55), item_amount, x_velocity, StaticLoad.DEFAULT_NO_COLLECT_TIME)
	else:
		summon_drop_item(item_name, item_amount)

func summon_drop_item(item_name, item_amount):
	var item = StaticLoad.game.item_scene.instantiate()
	StaticLoad.game.items.add_child(item)
	var x_velocity = face_state*StaticLoad.DROPPED_ITEM_SPEED
	item.velocity.x = x_velocity
	item.init(item_name, position-Vector2(0,55), item_amount, StaticLoad.DEFAULT_NO_COLLECT_TIME)
	StaticLoad.game.entities[item.get_uuid()] = item

func stop_player_move():
	last_is_down_pressed = false
	is_down_pressed = false
	last_is_jump_pressed = false
	is_jump_pressed = false
	move_state = "idle"
	velocity.x = 0
	if is_flying:
		velocity.y = 0

func respawn_player(is_animation = true):
	position = Vector2(0, -1)
	health = StaticLoad.DEFAULT_PLAYER_HEALTH
	is_dead = false
	
	if not is_animation:
		return
	
	var tween1 = get_tree().create_tween()
	tween1.tween_method(set_name_label_modulate, Color(1,1,1,0), Color(1,1,1,1), StaticLoad.DISSOLVE_TIME)
	var tween2 = get_tree().create_tween()
	tween2.tween_method(set_shader_dissolve_intensity, 0.6, -0.6, StaticLoad.DISSOLVE_TIME)
	
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

func update_item_in_hand(item_name):
	if StaticLoad.get_item_model_type_by_name(item_name) == 0:
		item_in_hand.get_node("Item").visible = false
		item_in_hand.get_node("Tool").visible = false
		item_in_hand.get_node("Block").visible = false
		if not StaticLoad.is_muti_mode or (StaticLoad.is_muti_mode and StaticLoad.multiplayer.get_unique_id()==player_peer_id):
			StaticLoad.game.inventory_player_model_item_in_hand.get_node("Item").visible = false
			StaticLoad.game.inventory_player_model_item_in_hand.get_node("Tool").visible = false
			StaticLoad.game.inventory_player_model_item_in_hand.get_node("Block").visible = false
	elif StaticLoad.get_item_model_type_by_name(item_name) == 1:
		var item_mesh = item_in_hand.get_node("Item/Mesh")
		var inventory_player_model_item_mesh = StaticLoad.game.inventory_player_model_item_in_hand.get_node("Item/Mesh")
		var item_material = load("res://Assets/Materials/ItemModel.tres").duplicate(true)
		var item_texture = load("res://Assets/ResourcePacks/"+StaticLoad.game.resource_pack+"/Items/"+item_name.to_lower()+".png")
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
	elif StaticLoad.get_item_model_type_by_name(item_name) == 2:
		var tool_mesh = item_in_hand.get_node("Tool/Mesh")
		var inventory_player_model_tool_mesh = StaticLoad.game.inventory_player_model_item_in_hand.get_node("Tool/Mesh")
		var tool_material = load("res://Assets/Materials/ToolModel.tres").duplicate(true)
		var tool_texture = load("res://Assets/ResourcePacks/"+StaticLoad.game.resource_pack+"/Items/"+item_name.to_lower()+".png")
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
	elif StaticLoad.get_item_model_type_by_name(item_name) == 3:
		var block_mesh = item_in_hand.get_node("Block/Mesh")
		var inventory_player_model_block_mesh = StaticLoad.game.inventory_player_model_item_in_hand.get_node("Block/Mesh")
		var block_material = load("res://Assets/Materials/BlockModel.tres").duplicate(true)
		block_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		var block_texture = load("res://Assets/ResourcePacks/"+StaticLoad.game.resource_pack+"/ModelBlocks/"+item_name.to_lower()+".png")
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

func switch_item_in_hand():
	var item_name = item_bar_names[selected_item_grid]
	if StaticLoad.is_muti_mode:
		update_item_in_hand(item_name)
		rpc("remote_update_item_in_hand", item_name)
	else:
		update_item_in_hand(item_name)

@rpc("any_peer", "call_local", "reliable", 1)
@warning_ignore("shadowed_variable")
func broadcast_join_game(player_name):
	StaticLoad.game.broadcast_to_all(player_name+tr("JOINED_GAME"), "gold")
	if StaticLoad.is_dedicated_server:
		var text = "["+StaticLoad.get_time_string(false)+" INFO]: "+player_name+" joined the game"
		print(text)
		StaticLoad.record_log(Time.get_date_string_from_system(), text)

@rpc("any_peer", "call_local", "reliable", 1)
@warning_ignore("shadowed_variable")
func init_player(peer_id, player_name, pos, face_state, is_flying, gamemode, item_in_hand):
	self.player_peer_id = peer_id
	self.player_name = player_name
	self.name_label.text = player_name
	self.position = pos
	self.face_state = face_state
	self.is_flying = is_flying
	self.gamemode = gamemode
	self.uuid = UUID.uuid_from_username(player_name)
	if self.gamemode != "creative":
		self.is_flying = false
	update_player_face_rotation()
	update_item_in_hand(item_in_hand)
	
	if peer_id == StaticLoad.multiplayer.get_unique_id():
		if self.gamemode == "creative":
			StaticLoad.game.health_bar.visible = false
	StaticLoad.online_peer_ids[peer_id] = StaticLoad.game.players.get_node(str(peer_id))
	StaticLoad.game.update_new_chunk(true)
	StaticLoad.game.update_details()

	if peer_id == StaticLoad.multiplayer.get_unique_id():
		return
	
	unfreeze_player()
	var player_icon_instance = StaticLoad.player_icon_scene.instantiate()
	var mini_map_camera_zoom = StaticLoad.game.mini_map_camera.zoom[0]
	var player_icon_scale = StaticLoad.MINI_MAP_SCALE_FACTOR/mini_map_camera_zoom
	player_icon_instance.scale = Vector2(player_icon_scale, player_icon_scale)
	player_icon_instance.name = player_name
	StaticLoad.game.player_icons[player_name] = player_icon_instance
	StaticLoad.game.mini_map_players.add_child(player_icon_instance)
	
	if StaticLoad.multiplayer.get_unique_id() == 1:
		return
	if not StaticLoad.game.online_ui_vbox_container.has_node(str(peer_id)):
		var online_info_instance = StaticLoad.online_info_scene.instantiate()
		StaticLoad.game.online_ui_vbox_container.add_child(online_info_instance)
		online_info_instance.name = str(peer_id)
		online_info_instance.player_name.text = self.player_name
		#var online_info = StaticLoad.game.online_ui_vbox_container.get_node(str(peer_id))
		await get_tree().create_timer(0.5).timeout
		StaticLoad.rpc_id(1, "request_for_ping", StaticLoad.multiplayer.get_unique_id(), peer_id)

@rpc("authority", "call_remote", "reliable", 1)
@warning_ignore("shadowed_variable")
func refresh_player(pos, velo, face_state, move_state, is_flying):
	self.position = pos
	self.velocity = velo
	self.face_state = face_state
	self.move_state = move_state
	self.is_flying = is_flying

@rpc("any_peer", "call_remote", "reliable", 1)
func request_for_set_self_player_position(client_peer_id, pos):
	if position.distance_to(pos) <= StaticLoad.POSITION_MAX_DIFFERENCE:
		var tween = get_tree().create_tween()
		tween.tween_property(self, "position", pos, StaticLoad.REFRESH_DELTA_TIME)
		for peer_id in StaticLoad.online_peer_ids:
			if peer_id == client_peer_id or peer_id == 1:
				continue
			rpc_id(peer_id, "reply_for_set_self_player_position", pos)
	else:
		rpc_id(client_peer_id, "reply_for_set_self_player_position", position)

@rpc("authority", "call_remote", "reliable", 1)
func reply_for_set_self_player_position(pos):
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", pos, StaticLoad.REFRESH_DELTA_TIME)

@rpc("any_peer", "call_remote", "reliable", 1)
func request_for_drop_item(item_name, item_amount):
	rpc("reply_for_drop_item", item_name, item_amount)

@rpc("authority", "call_local", "reliable", 1)
func reply_for_drop_item(item_name, item_amount):
	summon_drop_item(item_name, item_amount)

@rpc("any_peer", "call_remote", "reliable", 1)
func request_for_respawn_player(is_animation):
	position = Vector2(0, -1)
	rpc("reply_for_respawn_player", is_animation)

@rpc("authority", "call_local", "reliable", 1)
func reply_for_respawn_player(is_animation):
	respawn_player(is_animation)
	if StaticLoad.multiplayer.get_unique_id() == player_peer_id:
		if StaticLoad.is_on_mobile_platform:
			Input.emulate_mouse_from_touch = false
		StaticLoad.game.death_ui.visible = false
		StaticLoad.game.is_input_frozen = false
		StaticLoad.game.move_input_list.clear()
		stop_player_move()
		if StaticLoad.is_muti_mode:
			rpc("remote_stop_player_move")

@rpc("any_peer", "call_remote", "reliable", 1)
func request_for_update_player_velocity(velo):
	if velocity.distance_to(velo) < StaticLoad.VELOCITY_MAX_DIFFERENCE:
		velocity = velo
		for peer_id in StaticLoad.online_peer_ids:
			if peer_id == 1 or peer_id == player_peer_id:
				continue
			rpc_id(peer_id, "reply_for_update_player_velocity", velo)

@rpc("authority", "call_local", "reliable", 1)
func reply_for_update_player_velocity(velo):
	current_velocity = velo

@rpc("authority", "call_remote", "reliable", 1)
func remote_update_player_health(new_health):
	health = new_health

@rpc("authority", "call_remote", "reliable", 1)
func remote_damage_player(damage):
	get_damage(damage)

@rpc("authority", "call_remote", "unreliable", 1)
func remote_check_player_position(pos):
	if position.distance_to(pos) >= StaticLoad.POSITION_MAX_DIFFERENCE:
		#if abs(velocity.x) > 1000 or abs(velocity.y) > 1000:
			#return
		var tween = get_tree().create_tween()
		tween.tween_property(self, "position", pos, StaticLoad.REFRESH_DELTA_TIME_LONG)

@rpc("any_peer", "call_remote", "reliable", 1)
func remote_freeze_player():
	self.freeze_player()
	#if StaticLoad.multiplayer.get_unique_id() == 1:
		#rpc_id(player_peer_id, "remote_check_player_position", position)

@rpc("any_peer", "call_remote", "reliable", 1)
func remote_unfreeze_player():
	self.unfreeze_player()
	#if StaticLoad.multiplayer.get_unique_id() == 1:
		#rpc_id(player_peer_id, "remote_check_player_position", position)

@rpc("any_peer", "call_remote", "reliable", 1)
func remote_stop_player_move():
	stop_player_move()
	if StaticLoad.multiplayer.get_unique_id() == 1:
		rpc_id(player_peer_id, "remote_check_player_position", position)

@rpc("any_peer", "call_remote", "unreliable", 1)
@warning_ignore("shadowed_variable")
func remote_update_player_state(player_state):
	self.face_state = player_state["face_state"]
	self.move_state = player_state["move_state"]
	self.is_jump_pressed = player_state["is_jump_pressed"]
	self.is_down_pressed = player_state["is_down_pressed"]
	self.is_flying = player_state["is_flying"]
	var render_chunk_tmp = player_state["render_chunk"]
	if render_chunk_tmp > StaticLoad.RENDER_CHUNK_MAX:
		render_chunk_tmp = StaticLoad.RENDER_CHUNK_MAX
	if render_chunk_tmp < StaticLoad.RENDER_CHUNK_MIN:
		render_chunk_tmp = StaticLoad.RENDER_CHUNK_MIN
	self.render_chunk = render_chunk_tmp
	self.gamemode = player_state["gamemode"]
	self.selected_block_pos = player_state["selected_block_pos"]
	self.destroy_timer = player_state["destroy_timer"]
	self.selected_item_grid = player_state["selected_item_grid"]
	#if StaticLoad.multiplayer.get_unique_id() == 1:
		#rpc_id(player_peer_id, "remote_check_player_position", position)

@rpc("any_peer", "call_remote", "reliable", 1)
func remote_punch():
	if animation_tree["parameters/Punch/request"] != AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE:
		animation_tree["parameters/Punch/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE

@rpc("any_peer", "call_remote", "reliable", 1)
func remote_change_gamemode(new_gamemode):
	gamemode = new_gamemode
	change_gamemode()

@rpc("any_peer", "call_remote", "reliable", 1)
func remote_update_message(peer_id, message):
	if StaticLoad.online_peer_ids.has(peer_id):
		StaticLoad.online_peer_ids[peer_id].send_message(message)

@rpc("any_peer", "call_remote", "reliable", 1)
func remote_update_command(peer_id, command):
	if StaticLoad.online_peer_ids.has(peer_id):
		StaticLoad.online_peer_ids[peer_id].send_command(command)

@rpc("authority", "call_remote", "reliable", 1)
func remote_get_item(item_name: String, amount: int, search_begin: int, search_size: int, sound_on: bool):
	get_item(item_name, amount, search_begin, search_size, sound_on)
	if player_peer_id == StaticLoad.multiplayer.get_unique_id():
		StaticLoad.game.refresh_item_grid(selected_item_grid)
		StaticLoad.game.refresh_inventory()
		
@rpc("any_peer", "call_remote", "reliable", 1)
func remote_update_item_in_hand(item_name):
	update_item_in_hand(item_name)

@rpc("any_peer", "call_remote", "reliable", 1)
func request_for_change_skin(skin_texture_buffer: PackedByteArray):
	if StaticLoad.multiplayer.get_unique_id() != 1:
		return
	self.skin_texture_buffer = skin_texture_buffer
	refresh_player_model_skin(skin_texture_buffer)
	for peer_id in StaticLoad.online_peer_ids:
		if peer_id == 1:
			continue
		rpc_id(peer_id, "reply_for_change_skin", skin_texture_buffer)

@rpc("authority", "call_remote", "reliable", 1)
func reply_for_change_skin(skin_texture_buffer: PackedByteArray):
	refresh_player_model_skin(skin_texture_buffer)
