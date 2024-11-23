extends CharacterBody2D

const MOVE_SPEED = 200.0
const JUMP_VELOCITY = -550.0
const WALK_PERIOD = 0.83
const RUN_PERIOD = 0.42

var player_peer_id: int
var player_name: String
var is_jump_pressed: bool = false
var last_is_jump_pressed: bool = false
var is_down_pressed: bool = false
var last_is_down_pressed: bool = false
var is_other: bool = false
var is_frozen: bool = false
var is_dead: bool = false
var is_in_water: bool = false
var is_flying: bool = false
var move_state: String = "stand"
var face_state: int = -1
var selected_item_grid: int = 0
var item_bar_names = []
var last_y_velocity = 0.0
var step_sound_timer = 0.0
var refresh_timer = 0.0
var turn_state: float = -1
var player_state = {
	"face_state": StaticLoad.DEFAULT_PLAYER_FACE_STATE,
	"move_state": "idle",
	"is_jump_pressed": false,
	"is_down_pressed": false,
	"is_flying": false
	}

@onready var player_animation = $SubViewportContainer/SubViewport/AnimationPlayer
@onready var player_sprite = $Sprite2D
@onready var player_model = $SubViewportContainer/SubViewport/PlayerModel
@onready var camera = $Camera2D
@onready var name_label = $Sprite2D/NameLable

func _ready():
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
	update_gravity(delta)
	update_move_by_player_state(delta)
	move_and_slide()
	update_player_sound(delta)
	
	if not StaticLoad.is_muti_mode:
		return
	update_refresh_timer(delta)

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
		update_player_rotation()
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
	is_frozen = true
	$CollisionShape2D.disabled = true
	self.visible = false

func unfreeze_player():
	is_frozen = false
	$CollisionShape2D.disabled = false
	self.visible = true

func update_player_state():
	player_state["face_state"] = face_state
	player_state["move_state"] = move_state
	player_state["is_jump_pressed"] = is_jump_pressed
	player_state["is_down_pressed"] = is_down_pressed
	player_state["is_flying"] = is_flying

func broadcast_player_state_to_all():
	if not StaticLoad.online_peer_ids.has(1):
		rpc_id(1, "remote_update_player_state", face_state, move_state, is_jump_pressed, is_down_pressed, is_flying)
	for peer_id in StaticLoad.online_peer_ids:
		if peer_id != StaticLoad.multiplayer_peer.get_unique_id():
			rpc_id(peer_id, "remote_update_player_state", face_state, move_state, is_jump_pressed, is_down_pressed, is_flying)

func update_refresh_timer(delta):
	if refresh_timer >= 0:
		refresh_timer -= delta

func update_player_sound(delta):
	var current_y_velocity = velocity.y
	if current_y_velocity == 0 and last_y_velocity > 1100:
		if last_y_velocity > 1300:
			StaticLoad.game.sound_audio_manager.play_random_audio_at_position("damage", "fallbig", position)
		else:
			StaticLoad.game.sound_audio_manager.play_random_audio_at_position("damage", "fallsmall", position)
	last_y_velocity = current_y_velocity
	
	if move_state != "idle":
		var block_pos = StaticLoad.game.tile_map_layer.local_to_map(position+Vector2(0, 5))
		var block_id = StaticLoad.get_block_id_by_atlas_coords(StaticLoad.game.tile_map_layer.get_cell_atlas_coords(block_pos))
		if step_sound_timer <= 0 and block_id != 0:
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
	if is_flying or is_frozen:
		return
	if not is_on_floor():
		velocity += get_gravity() * delta

func update_move_by_player_state(delta):
	if is_frozen:
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
	
	if abs(turn_state-face_state) > 0.01:
		update_player_rotation()
		var turn_amplitude = delta/StaticLoad.TURN_TIME
		if turn_amplitude > 1:
			turn_amplitude = 1
		turn_state = turn_state*(1-turn_amplitude)+face_state*turn_amplitude
		if abs(turn_state-face_state)<0.01:
			turn_state = face_state
	
	if move_state == "run":
		player_animation.play("run")
		if is_in_water:
			velocity.x = face_state * MOVE_SPEED
		else:
			velocity.x = face_state * MOVE_SPEED * 2
	elif move_state == "walk":
		player_animation.play("walk")
		if is_in_water:
			velocity.x = face_state * MOVE_SPEED * 0.5
		else:
			velocity.x = face_state * MOVE_SPEED
	elif move_state == "stand":
		player_animation.play("idle")
		velocity.x = 0

func update_player_rotation():
	var looking_at = Vector3(0, 90+turn_state*90*StaticLoad.TURN_STATE_SCALE_FACTOR, 0)
	player_model.rotation_degrees = looking_at

func send_message(message: String):
	var player_name_mesage =  "<"+player_name+">  "+message
	StaticLoad.game.broadcast_to_all(player_name_mesage)
	if StaticLoad.is_dedicated_server:
		print("["+StaticLoad.get_time_string(false)+" INFO]: "+"<"+player_name+"> "+message)

func send_command(command: String):
	var splits = command.split(" ")
	if StaticLoad.is_dedicated_server:
		print("["+StaticLoad.get_time_string(false)+" INFO]: "+"<"+player_name+"> "+command)
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
				StaticLoad.game.is_chunk_updating = false
				position = Vector2i(x*50+25, -y*50+50)
				StaticLoad.game.is_chunk_updating = true
				StaticLoad.game.broadcast_to_person(player_name, tr("TELEPORT_INFO_1")+player_name+tr("TELEPORT_INFO_2")+"x="+str(x)+", y="+str(y), "chartreuse")
		else:
			StaticLoad.game.broadcast_to_person(player_name, tr("USAGE")+" : "+StaticLoad.commands["/tp"], "gold")
	else:
		StaticLoad.game.broadcast_to_person(player_name, tr("UNKNOWN_COMMAND"), "pink")

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

@rpc("any_peer", "call_local", "reliable", 1)
@warning_ignore("shadowed_variable")
func broadcast_join_game(player_name):
	StaticLoad.game.broadcast_to_all(player_name+tr("JOINED_GAME"), "gold")
	if StaticLoad.is_dedicated_server:
		print("["+StaticLoad.get_time_string(false)+" INFO]: "+player_name+" joined the game")

@rpc("any_peer", "call_local", "reliable", 1)
@warning_ignore("shadowed_variable")
func init_player(peer_id, player_name, pos, face_state, is_flying):
	self.player_name = player_name
	self.name_label.text = player_name
	self.position = pos
	self.face_state = face_state
	self.is_flying = is_flying
	self.unfreeze_player()
	update_player_rotation()
	
	StaticLoad.online_peer_ids[peer_id] = StaticLoad.game.players.get_node(str(peer_id))
	StaticLoad.game.update_new_chunk(true)
	StaticLoad.game.update_details()
	
	if peer_id == StaticLoad.multiplayer.get_unique_id():
		return
	
	var player_icon_instance = StaticLoad.player_icon_scene.instantiate()
	var mini_map_camera_zoom = StaticLoad.game.mini_map_camera.zoom[0]
	var player_icon_scale = StaticLoad.MINI_MAP_SCALE_FACTOR/mini_map_camera_zoom
	player_icon_instance.scale = Vector2(player_icon_scale, player_icon_scale)
	player_icon_instance.name = player_name
	StaticLoad.game.player_icons[player_name] = player_icon_instance
	StaticLoad.game.mini_map_players.add_child(player_icon_instance)

@rpc("authority", "call_remote", "reliable", 1)
@warning_ignore("shadowed_variable")
func refresh_player(pos, face_state, move_state, is_flying):
	self.global_position = pos
	self.face_state = face_state
	self.move_state = move_state
	self.is_flying = is_flying

@rpc("authority", "call_remote", "unreliable", 1)
func remote_check_player_position(pos):
	if position.distance_to(pos) >= StaticLoad.POSITION_MAX_DIFFERENCE:
		position = pos

@rpc("any_peer", "call_remote", "unreliable", 1)
func remote_stop_player_move():
	stop_player_move()

@rpc("any_peer", "call_remote", "unreliable", 1)
@warning_ignore("shadowed_variable")
func remote_update_player_state(face_state, move_state, is_jump_pressed, is_down_pressed, is_flying):
	self.face_state = face_state
	self.move_state = move_state
	self.is_jump_pressed = is_jump_pressed
	self.is_down_pressed = is_down_pressed
	self.is_flying = is_flying
	self.refresh_timer = StaticLoad.REFRESH_TIME

@rpc("any_peer", "call_remote", "reliable", 1)
func remote_update_message(peer_id, message):
	StaticLoad.online_peer_ids[peer_id].send_message(message)

@rpc("any_peer", "call_remote", "reliable", 1)
func remote_update_command(peer_id, command):
	StaticLoad.online_peer_ids[peer_id].send_command(command)
	
