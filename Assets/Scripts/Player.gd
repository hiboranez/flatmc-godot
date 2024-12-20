extends CharacterBody2D

const MOVE_SPEED = 200.0
const JUMP_VELOCITY = -550.0
const WALK_PERIOD = 0.83
const RUN_PERIOD = 0.42

var gamemode: String = "survival"
var health: int = StaticLoad.DEFAULT_PLAYER_HEALTH
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
var current_velocity = Vector2(0, 0)
var last_velocity = Vector2(0, 0)
var step_sound_timer = 0.0
var turn_state: float = -1
var velocity_before_pause
var player_state = {
	"face_state": StaticLoad.DEFAULT_PLAYER_FACE_STATE,
	"move_state": "idle",
	"is_jump_pressed": false,
	"is_down_pressed": false,
	"is_flying": false,
	"render_chunk": 1,
	"gamemode": "survival"
	}

@onready var player_animation = $SubViewportContainer/SubViewport/AnimationPlayer
@onready var player_sprite = $Sprite2D
@onready var player_model = $SubViewportContainer/SubViewport/PlayerModel
@onready var camera = $Camera2D
@onready var name_label = $Sprite2D/NameLable

func _ready():
	freeze_player()
	velocity_before_pause = velocity
	var count:int = 0
	for key in StaticLoad.block_ids:
		if count < 13:
			count += 1
			continue
		item_bar_names.push_back(key)
		count += 1
		if count >= 22:
			break

func _process(delta: float) -> void:
	move_and_slide()
	update_player_speed_related(delta)
	update_animation_by_player_state(delta)
	if StaticLoad.is_muti_mode and StaticLoad.multiplayer.get_unique_id()!=1 and is_other:
		return
	update_gravity(delta)
	update_move_by_player_state()

func init(peer_id):
	player_peer_id = peer_id
	var config = ConfigFile.new()
	var result = config.load("user://configs.cfg")
	if result == OK:
		player_name = config.get_value("options", "player_name", StaticLoad.options["player_name"])
		name_label.text = player_name
		StaticLoad.online_peer_ids[player_peer_id] = StaticLoad.game.player
		var fov_zoom = 1+1.6*(int(config.get_value("options", "fov_zoom", StaticLoad.options["fov_zoom"]))/100.0)
		camera.zoom = Vector2(fov_zoom, fov_zoom)
		render_chunk = int(config.get_value("options", "render_chunk", StaticLoad.options["render_chunk"]))
		if render_chunk > StaticLoad.RENDER_CHUNK_MAX:
			render_chunk = StaticLoad.RENDER_CHUNK_MAX
		if render_chunk < StaticLoad.RENDER_CHUNK_MIN:
			render_chunk = StaticLoad.RENDER_CHUNK_MIN
	if not StaticLoad.is_muti_mode:
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
	
	for i in range(9):
		StaticLoad.game.item_grids[i].get_node("Icon").texture = load("res://Assets//Textures//Items//"+item_bar_names[i].to_lower()+".png") as Texture2D

	StaticLoad.game.init_inventory()
	
	if not StaticLoad.is_muti_mode:
		return
	StaticLoad.rpc("new_peer_broadcast", player_peer_id)
	
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

func broadcast_player_state_to_all():
	if not StaticLoad.online_peer_ids.has(1):
		rpc_id(1, "remote_update_player_state", player_state)
	for peer_id in StaticLoad.online_peer_ids:
		if peer_id != StaticLoad.multiplayer_peer.get_unique_id():
			rpc_id(peer_id, "remote_update_player_state", player_state)

func get_damage(damage):
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
		StaticLoad.game.sound_audio_manager.play_random_audio_at_position("player", "hurt", position)
		var tween2 = get_tree().create_tween()
		tween2.tween_method(set_shader_dissolve_intensity, -0.6, 0.6, StaticLoad.DISSOLVE_TIME)
	else:
		StaticLoad.game.sound_audio_manager.play_random_audio_at_position("damage", "hit", position)

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
			StaticLoad.game.sound_audio_manager.play_random_audio_at_position("damage", "fallbig", position)
		else:
			StaticLoad.game.sound_audio_manager.play_random_audio_at_position("damage", "fallsmall", position)
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
					StaticLoad.game.sound_audio_manager.play_random_audio_at_position("step", StaticLoad.block_types[block_id], position)
				elif move_state == "run":
					step_sound_timer = RUN_PERIOD
					StaticLoad.game.sound_audio_manager.play_random_audio_at_position("step", StaticLoad.block_types[block_id], position)
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

func update_animation_by_player_state(delta):
	if is_frozen:
		return
	if move_state == "run":
		player_animation.play("run")
	elif move_state == "walk":
		player_animation.play("walk")
	elif move_state == "idle":
		player_animation.play("idle")
	
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

func stop_player_move():
	last_is_down_pressed = false
	is_down_pressed = false
	last_is_jump_pressed = false
	is_jump_pressed = false
	player_animation.play("idle")
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
func init_player(peer_id, player_name, pos, face_state, is_flying, gamemode):
	self.player_peer_id = peer_id
	self.player_name = player_name
	self.name_label.text = player_name
	self.position = pos
	self.face_state = face_state
	self.is_flying = is_flying
	self.gamemode = gamemode
	if self.gamemode != "creative":
		self.is_flying = false
	update_player_face_rotation()
	
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
	#if StaticLoad.multiplayer.get_unique_id() == 1:
		#rpc_id(player_peer_id, "remote_check_player_position", position)

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
	
