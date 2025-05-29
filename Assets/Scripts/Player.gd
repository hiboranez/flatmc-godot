extends CharacterBody2D

# 预加载
@onready var player_model_mesh = $SubViewportContainer/SubViewport/PlayerModel/Root/Skeleton3D/Mesh
@onready var animation_tree = $SubViewportContainer/SubViewport/AnimationTree
@onready var player_sprite = $Sprite2D
@onready var player_model = $SubViewportContainer/SubViewport/PlayerModel
@onready var camera = $Camera2D
@onready var name_label = $Sprite2D/NameLable
@onready var item_in_hand = $SubViewportContainer/SubViewport/PlayerModel/Root/Skeleton3D/Hand/ItemInHand
@onready var sight_line = $SightLine2D
@onready var up_area_collision_shape = $UpArea/CollisionShape2D
@onready var down_area_collision_shape = $DownArea/CollisionShape2D
@onready var top_area_collision_shape = $TopArea/CollisionShape2D
@onready var attack_animation = $AttackAnimation
@onready var attack_area = $AttackArea
@onready var attack_area_collision_shape = $AttackArea/CollisionShape2D
@onready var ground_area_collision_shape = $GroundArea/CollisionShape2D
@onready var fire_animated_sprite = $FireAnimatedSprite2D

# 实体变量
var uuid = UUID.v4()
var entity_type = "player"
var player_name: String
var chunk_pos = Vector2i(0, 0)
var last_pos = position
var expected_velocity = Vector2(0, 0)
var health: int = 20
var is_dead = false
var is_frozen = false
var is_on_fire = false
var fire_lasting_timer: float = 0
var fire_damage_timer: float = 1

# 子类变量
var pull_amplify_factor: float = 1
var fire_damage_time: float = 1
var max_health: int = 20
var move_speed: float = 200
var jump_velocity: float = -550
var walk_period: float = 0.83
var run_period: float = 0.42
var dropped_item_speed: float = 1000
var arrow_shoot_speed = Vector2(2000, -1000)
var dropped_item_no_collect_time: float = 1
var render_chunk: int = 1
var player_peer_id: int
signal up_area_colliding_false
var sword_breaking_timer: float = 0
var health_recover_timer: float = 10
var gamemode: String = "survival"
var velocity_before_pause = velocity
var current_velocity = velocity
var last_velocity = Vector2(0, 0)
var selected_block_pos = Vector2i(0, 0)
var destroying_block_pos = Vector2i(0, 0)
var shoot_timer: float = 0
var last_shoot_timer: float = 0
var destroy_timer: float = 0
var attack_timer: float = 1
var attacking_decline_timer: float = 0
var attacking_damage: int = 0
var selected_item_grid: int = 0
var last_in_hand_item_name = "AIR"
var step_sound_timer: float = 0
var sneak_timer: float = 0
var move_state = "idle"
var face_state: int = -1
var turn_state: float = 0
var breaking_tool = "null"
var mouse_item_name = "AIR"
var mouse_item_amount = 0
var hurt_tween
var die_rotation_tween
var die_name_tween
var is_pulling = false
var is_jumping = false
var is_sneaking = false
var is_auto_jump = false
var is_jump_pressed = false
var last_is_jump_pressed = false
var is_down_pressed = false
var last_is_down_pressed = false
var is_other = false
var is_pause = false
var is_in_water = false
var is_flying = false
var is_punching = false
var is_up_area_colliding = false
var is_down_area_colliding = false
var is_top_area_colliding = false
var is_ground_area_colliding = false
var is_on_ladder = false
var animation_tree_parameters = {
	"walk": 0,
	"run": 0,
	"sneak": 0,
	"pull": 0,
}
var only_server_change_state_list = [
	"health", "attack_timer", 
	"attacking_decline_timer", "sword_breaking_timer",
	"attacking_damage", "is_frozen", "is_on_fire"
]
var trigger_change_state_list = [
	"is_punching", "set_block_list", "breaking_tool",
	"is_jumping", "farm_list", "inventory"
]
var state_dict = {}
var last_state_dict = {}
var changed_state_dict = {}
var only_server_change_state_dict = {}
var inventory_dict = {}
var farm_list = []
var set_block_list = []
var success_set_block_list = []
var attacking_list = []
var item_bar_names = StaticLoad.default_item_bar_names
var item_bar_amounts = StaticLoad.default_item_bar_amounts
var in_hand_item_name = "AIR"
var current_set_layer = "solid"
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
	update_local_fire_damage_by_data()
	update_local_health_recover()
	update_local_attack_timer()
	# 本地更新
	update_shoot_timer()
	update_local_fall_damage_by_data()
	update_local_velocity()
	update_local_gravity()
	update_local_is_on_ladder()
	update_local_set_block()
	update_local_move_by_data()
	update_local_item_in_hand()
	update_local_state_dict()
	update_local_changed_state_dict()
	upload_local_player_changed_state_dict()
	
	update_last_velocity()

func init_local(peer_id):
	position = Vector2i(0, -21)
	player_peer_id = peer_id
	var player_icon_instance = StaticLoad.player_icon_scene.instantiate()
	var config = ConfigFile.new()
	var result = config.load("user://configs.cfg")
	var skin_texture = load(StaticLoad.default_skin_path) as Texture2D
	player_icon_instance.get_node("UpSkin").texture.atlas = skin_texture
	if result == OK:
		player_name = config.get_value("options", "player_name", StaticLoad.options["player_name"])
		StaticLoad.game.player_icons[player_name] = player_icon_instance
		StaticLoad.game.mini_map_players.add_child(player_icon_instance)
		uuid = UUID.uuid_from_username(player_name)
		name_label.text = player_name
		StaticLoad.player_peer_dict[player_peer_id] = self
		var auto_jump_on = config.get_value("options", "auto_jump", StaticLoad.options["auto_jump"])
		if auto_jump_on == "on":
			is_auto_jump = true
		elif auto_jump_on == "off":
			is_auto_jump = false
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
		inventory_dict = calculate_inventory_dict([item_bar_names, item_bar_amounts, mouse_item_name, mouse_item_amount])
		if gamemode != "creative":
			is_flying = false
		if self.gamemode == "creative":
			StaticLoad.game.health_bar.visible = false
		update_player_face_rotation()
		StaticLoad.game.update_new_chunk(true)
	
	
	var mini_map_camera_zoom = StaticLoad.game.mini_map_camera.zoom[0]
	var player_icon_scale = StaticLoad.MINI_MAP_SCALE_FACTOR/mini_map_camera_zoom
	player_icon_instance.scale = Vector2(player_icon_scale, player_icon_scale)
	player_icon_instance.name = player_name
	
	
	if is_other:
		camera.queue_free()
	unfreeze()
	StaticLoad.game.update_game_details(true)
	StaticLoad.game.init_inventory()
	for i in range(9):
		if item_bar_names[i] == "AIR":
			continue
		StaticLoad.game.item_grids[i].get_node("ItemIcon").init_icon(item_bar_names[i].to_lower())
		var item_name = item_bar_names[i]
		var item_amount = item_bar_amounts[i]
		if StaticLoad.get_is_durable_by_name(item_name):
			StaticLoad.game.item_grids[i].get_node("Amount").text = ""
			StaticLoad.game.item_grids[i].get_node("Amount").visible = false
			var progress_bar = StaticLoad.game.item_grids[i].get_node("ProgressBar")
			progress_bar.max_value = StaticLoad.get_max_amount_by_name(item_name)
			progress_bar.value = item_amount
			StaticLoad.game.item_grids[i].get_node("ProgressBar").visible = true
		else:
			StaticLoad.game.item_grids[i].get_node("ProgressBar").visible = false
			if item_amount <= 1:
				StaticLoad.game.item_grids[i].get_node("Amount").text = ""
				StaticLoad.game.item_grids[i].get_node("Amount").visible = false
			else:
				StaticLoad.game.item_grids[i].get_node("Amount").text = str(item_amount)
				StaticLoad.game.item_grids[i].get_node("Amount").visible = true
	
	if not StaticLoad.is_muti_mode:
		return
	StaticLoad.rpc("create_new_peer_player", player_peer_id)

func update_local_is_on_ladder():
	var foot_pos = position + Vector2(0, 23)
	var foot_block_pos = StaticLoad.game.tile_map_layer.local_to_map(foot_pos)
	var foot_block_id = StaticLoad.get_block_id_by_atlas_coords(StaticLoad.game.tile_map_layer.get_cell_atlas_coords(foot_block_pos))
	if StaticLoad.get_block_name_by_id(foot_block_id) == "LADDER":
		if not is_on_ladder:
			is_on_ladder = true
	elif is_on_ladder:
		is_on_ladder = false

func update_sound_by_data():
	if abs(current_velocity.y) < StaticLoad.FLOAT_DELTA and last_velocity.y > 1100:
		if last_velocity.y > 1300:
			StaticLoad.game.sound_audio_manager.play_random_audio_at_position("damage", "fallbig", position, 1)
		else:
			StaticLoad.game.sound_audio_manager.play_random_audio_at_position("damage", "fallsmall", position, 1)
	if breaking_tool != "null":
		StaticLoad.game.sound_audio_manager.play_random_audio_at_position("random", "tool_break", position, 1)
		StaticLoad.game.summon_destroy_particle(position-Vector2(0,16), "item", breaking_tool)
		attack_timer = 0
		if StaticLoad.is_muti_mode and multiplayer.get_unique_id() == 1:
			if breaking_tool.contains("SWORD"):
				if breaking_tool.contains("GOLD"):
					sword_breaking_timer = 0.5
				else:
					sword_breaking_timer = 1
		if StaticLoad.is_muti_mode and multiplayer.get_unique_id() == player_peer_id:
			changed_state_dict["breaking_tool"] = breaking_tool
		breaking_tool = "null"
	if not is_flying and is_on_ladder:
		if step_sound_timer <= 0 and current_velocity.y != 0:
			step_sound_timer = walk_period
			StaticLoad.game.sound_audio_manager.play_random_audio_at_position("step", "ladder", position, 1)
	elif move_state != "idle":
		var block_pos = StaticLoad.game.tile_map_layer.local_to_map(position+Vector2(0, 30))
		var block_id = StaticLoad.get_block_id_by_atlas_coords(StaticLoad.game.tile_map_layer.get_cell_atlas_coords(block_pos))
		if step_sound_timer <= 0 and block_id != 0:
			if not StaticLoad.get_is_untouchable_by_id(block_id):
				if move_state == "walk":
					step_sound_timer = walk_period
					StaticLoad.game.sound_audio_manager.play_random_audio_at_position("step", StaticLoad.get_step_type_by_name(StaticLoad.get_block_name_by_id(block_id)), position, 1)
				elif move_state == "run":
					step_sound_timer = run_period
					StaticLoad.game.sound_audio_manager.play_random_audio_at_position("step", StaticLoad.get_step_type_by_name(StaticLoad.get_block_name_by_id(block_id)), position, 1)
	elif step_sound_timer > 0 and not is_sneaking and not is_pulling:
		step_sound_timer = 0
	if step_sound_timer > 0 and not is_sneaking and not is_pulling:
		step_sound_timer -= get_process_delta_time()

func update_animation_tree():
	animation_tree["parameters/Run/blend_amount"] = animation_tree_parameters["run"]
	animation_tree["parameters/Walk/blend_amount"] = animation_tree_parameters["walk"]
	animation_tree["parameters/Sneak/blend_amount"] = animation_tree_parameters["sneak"]
	animation_tree["parameters/Pull/blend_amount"] = animation_tree_parameters["pull"]*(1+(shoot_timer+0.0001)/6)*pull_amplify_factor

func update_animation_by_data():
	var delta = get_process_delta_time()
	if is_frozen or is_dead:
		return
	
	if is_sneaking:
		if sneak_timer < 0.75:
			sneak_timer += get_process_delta_time()
		else:
			sneak_timer = 0.75
	elif sneak_timer != 0:
		sneak_timer = 0
	
	if not StaticLoad.is_muti_mode or (StaticLoad.is_muti_mode and multiplayer.get_unique_id() == player_peer_id):
		if not StaticLoad.game.is_chat and not StaticLoad.game.is_inventory and not StaticLoad.game.is_pause and not StaticLoad.game.is_map and is_pulling:
			if move_state == "run":
				move_state = "walk"
	
	if not StaticLoad.is_muti_mode or (StaticLoad.is_muti_mode and multiplayer.get_unique_id() == player_peer_id):
		if not StaticLoad.game.is_chat and not StaticLoad.game.is_inventory and not StaticLoad.game.is_pause and not StaticLoad.game.is_map and Input.is_action_pressed("shift") and not is_sneaking:
			is_sneaking = true
			if move_state == "run":
				move_state = "walk"
		elif not Input.is_action_pressed("shift") and is_sneaking:
			is_sneaking = false
		
	if move_state == "run" and not is_sneaking and not is_pulling:
		animation_tree_parameters["run"] = lerpf(animation_tree_parameters["run"], 1, StaticLoad.BLEND_SPEED*delta)
		animation_tree_parameters["walk"] = lerpf(animation_tree_parameters["walk"], 0, StaticLoad.BLEND_SPEED*delta)
	elif move_state == "walk":
		animation_tree_parameters["run"] = lerpf(animation_tree_parameters["run"], 0, StaticLoad.BLEND_SPEED*delta)
		animation_tree_parameters["walk"] = lerpf(animation_tree_parameters["walk"], 1, StaticLoad.BLEND_SPEED*delta)
	elif move_state == "idle":
		animation_tree_parameters["run"] = lerpf(animation_tree_parameters["run"], 0, StaticLoad.BLEND_SPEED*delta)
		animation_tree_parameters["walk"] = lerpf(animation_tree_parameters["walk"], 0, StaticLoad.BLEND_SPEED*delta)
	
	if is_sneaking:
		animation_tree_parameters["sneak"] = lerpf(animation_tree_parameters["sneak"], 1.2, StaticLoad.BLEND_SPEED*delta*2)
	else:
		animation_tree_parameters["sneak"] = lerpf(animation_tree_parameters["sneak"], 0, StaticLoad.BLEND_SPEED*delta*2)
	
	if is_pulling:
		animation_tree_parameters["pull"] = lerpf(animation_tree_parameters["pull"], 1, StaticLoad.BLEND_SPEED*delta*2)
	else:
		animation_tree_parameters["pull"] = lerpf(animation_tree_parameters["pull"], 0, StaticLoad.BLEND_SPEED*delta*2)
	
	var name_invisible_value = sneak_timer-0.5
	if name_invisible_value < 0:
		name_invisible_value = 0
	set_name_label_modulate(Color(1,1,1,lerpf(1, 0, name_invisible_value/0.25)))
	
	if is_on_fire and not fire_animated_sprite.visible:
		fire_animated_sprite.visible = true
		if not fire_animated_sprite.is_playing():
			fire_animated_sprite.play()
	if not is_on_fire and fire_animated_sprite.visible:
		fire_animated_sprite.visible = false
		if fire_animated_sprite.is_playing():
			fire_animated_sprite.stop()
	
	var detect_size = 60
	if move_state == "run":
		detect_size = 120
	if is_sneaking or is_pulling:
		detect_size = 28
	var half_detect_size = detect_size/2
	up_area_collision_shape.shape.size.x = 60
	down_area_collision_shape.shape.size.x = detect_size
	top_area_collision_shape.shape.size.x = detect_size
	if turn_state > 0:
		if up_area_collision_shape.position.x < 0:
			up_area_collision_shape.position.x = 30
		if down_area_collision_shape.position.x < 0 or abs(down_area_collision_shape.position.x) != half_detect_size:
			down_area_collision_shape.position.x = half_detect_size
		if top_area_collision_shape.position.x < 0 or abs(top_area_collision_shape.position.x) != half_detect_size:
			top_area_collision_shape.position.x = half_detect_size
		if ground_area_collision_shape.position.x < 0:
			ground_area_collision_shape.position.x = 6
	else:
		if up_area_collision_shape.position.x > 0:
			up_area_collision_shape.position.x = -30
		if down_area_collision_shape.position.x > 0 or abs(down_area_collision_shape.position.x) != half_detect_size:
			down_area_collision_shape.position.x = -half_detect_size
		if top_area_collision_shape.position.x > 0 or abs(top_area_collision_shape.position.x) != half_detect_size:
			top_area_collision_shape.position.x = -half_detect_size
		if ground_area_collision_shape.position.x > 0:
			ground_area_collision_shape.position.x = -6
	
	if abs(turn_state-face_state) > 0.01:
		update_player_face_rotation()
		var turn_amplitude = delta/StaticLoad.TURN_TIME
		if turn_amplitude > 1:
			turn_amplitude = 1
		turn_state = turn_state*(1-turn_amplitude)+face_state*turn_amplitude
		if abs(turn_state-face_state)<0.01:
			turn_state = face_state
			update_player_face_rotation()
	if face_state > 0 and not attack_animation.flip_v:
		attack_animation.flip_v = true
		attack_animation.position.x = 72
		#attacking_decline_timer = 0
		attack_area_collision_shape.position.x = 66
	elif face_state < 0 and attack_animation.flip_v:
		attack_animation.flip_v = false
		attack_animation.position.x = -72
		#attacking_decline_timer = 0
		attack_area_collision_shape.position.x = -66
	if is_punching:
		if not animation_tree["parameters/Punch/active"]:
			animation_tree["parameters/Punch/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		if StaticLoad.tools_type.has(in_hand_item_name) and StaticLoad.tools_type[in_hand_item_name].has("sword"):
			var tool_info = StaticLoad.tools_type[in_hand_item_name]
			if not is_dead and StaticLoad.tools_type.has(in_hand_item_name) and tool_info.has("sword"):
				if attack_timer <= 0:
					if not StaticLoad.is_muti_mode or (StaticLoad.is_muti_mode and multiplayer.get_unique_id() == 1):
						attack()
				StaticLoad.game.sound_audio_manager.play_random_audio_at_position("player", "attack", position, 1)
				if not attack_animation.visible:
					attack_animation.visible = true
				attack_animation.play("sweep")
				attacking_decline_timer = 0.25
				if in_hand_item_name.contains("GOLD") and in_hand_item_name.contains("SWORD"):
					attack_timer = 0.5
				else:
					attack_timer = 1
		if StaticLoad.is_muti_mode and multiplayer.get_unique_id() == player_peer_id:
			changed_state_dict["is_punching"] = true
		is_punching = false
	update_animation_tree()
	if is_jumping:
		if not StaticLoad.is_muti_mode or (StaticLoad.is_muti_mode and multiplayer.get_unique_id() == player_peer_id):
			if not is_flying and is_on_floor():
				update_local_fall_damage_by_data()
				update_sound_by_data()
				if not is_dead:
					add_velocity(Vector2(0, jump_velocity))
					#if not StaticLoad.is_muti_mode or (StaticLoad.is_muti_mode and multiplayer.get_unique_id() == 1):
						#add_velocity(Vector2(0, jump_velocity))
					#if StaticLoad.is_muti_mode and multiplayer.get_unique_id() == player_peer_id:
						#changed_state_dict["is_jumping"] = true
		is_jumping = false

func add_velocity(delta_velocity):
	if delta_velocity.x != 0:
		var e_x = (velocity.x/abs(velocity.x+1e-9))*pow(velocity.x, 2)+(delta_velocity.x/abs(delta_velocity.x))*pow(delta_velocity.x, 2)
		velocity.x = (e_x/abs(e_x+1e-9))*sqrt(abs(e_x))
	if delta_velocity.y != 0:
		var e_y = (velocity.y/abs(velocity.y+1e-9))*pow(velocity.y, 2)+(delta_velocity.y/abs(delta_velocity.y))*pow(delta_velocity.y, 2)
		velocity.y = (e_y/abs(e_y+1e-9))*sqrt(abs(e_y))

func update_local_fire_damage_by_data():
	if StaticLoad.is_muti_mode and multiplayer.get_unique_id() != 1:
		return
	if fire_lasting_timer <= 0 and is_on_fire:
		is_on_fire = false
	if fire_lasting_timer > 0 and not is_on_fire:
		is_on_fire = true
		fire_damage_timer = fire_damage_time
	if fire_lasting_timer > 0:
		fire_lasting_timer -= get_process_delta_time()
	elif fire_lasting_timer < 0:
		fire_lasting_timer = 0
	if fire_lasting_timer <= 0:
		return
	if fire_damage_timer > 0:
		fire_damage_timer -= get_process_delta_time()
	elif fire_damage_timer <= 0:
		fire_damage_timer = fire_damage_time
		rpc_damage([1, "null", health, "fire", "self"], true)
		get_damage([1, "null", health, "fire", "self"])

func update_shoot_timer():
	if StaticLoad.is_muti_mode and multiplayer.get_unique_id() != player_peer_id:
		return
	if is_pulling:
		shoot_timer += get_process_delta_time()
	elif shoot_timer != 0:
		shoot_timer = 0
	
func update_local_fall_damage_by_data():
	if StaticLoad.is_muti_mode and multiplayer.get_unique_id() != player_peer_id:
		return
	#更新摔落
	if gamemode == "survival":
		if last_velocity.y > 1000 and not is_on_ladder:
			if abs(current_velocity.y) < StaticLoad.FLOAT_DELTA or current_velocity.y < 0:
				@warning_ignore("integer_division")
				var damage = (int(last_velocity.y)-1000)/50
				rpc_damage([damage, "down", health, "fall", "ground"], false)
				get_damage([damage, "down", health, "fall", "ground"])	
	update_last_velocity()

func update_local_health_recover():
	if StaticLoad.is_muti_mode and not multiplayer.get_unique_id() == 1:
		return
	if health >= 20:
		return
	if is_dead:
		return
	if gamemode == "creative":
		return
	if health < 20:
		health_recover_timer -= get_process_delta_time()
	if health_recover_timer < -1.5:
		health += 1
		health_recover_timer = 0

func update_local_attack_timer():
	if StaticLoad.is_muti_mode and multiplayer.get_unique_id() != 1:
		return
	if attacking_decline_timer > 0:
		attacking_decline_timer -= get_process_delta_time()
	elif attacking_decline_timer < 0:
		attacking_decline_timer = 0
		attacking_list.clear()
	if attack_timer > 0:
		attack_timer -= get_process_delta_time()
	elif attack_timer < 0:
		attack_timer = 0
	if last_in_hand_item_name != in_hand_item_name:
		if in_hand_item_name.contains("SWORD"):
			if in_hand_item_name.contains("GOLD"):
				attack_timer = 0.5
			else:
				attack_timer = 1
		last_in_hand_item_name = in_hand_item_name
	if sword_breaking_timer > 0:
		sword_breaking_timer -= get_process_delta_time()
	elif sword_breaking_timer < 0:
		sword_breaking_timer = 0

func update_local_velocity():
	if StaticLoad.is_muti_mode and multiplayer.get_unique_id() != player_peer_id:
		if velocity.length() > 0:
			velocity = Vector2(0, 0)
		return
	if is_frozen:
		if velocity.length() > StaticLoad.FLOAT_DELTA:
			velocity = Vector2(0, 0)
		if expected_velocity.length() > StaticLoad.FLOAT_DELTA:
			expected_velocity = Vector2(0, 0)
		return
	velocity = GameCalculator.calculate_velocity_by_data(get_process_delta_time(), velocity, expected_velocity, move_speed, is_flying, is_on_ladder)
	#var delta = get_process_delta_time()
	#var mutiply_x = velocity.x * expected_velocity.x
	#if mutiply_x >= 0:
		#if abs(velocity.x) < abs(expected_velocity.x):
			#velocity.x = expected_velocity.x
		#elif expected_velocity.x == 0:
			#var diff = abs(velocity.x)
			#var max_diff = move_speed*delta*10
			#if abs(velocity.x) >= max_diff:
				#diff = max_diff
			#if velocity.x * diff > 0:
				#diff = -diff
			#velocity += Vector2(diff, 0)
		#elif abs(velocity.x) > abs(expected_velocity.x):
			#var diff = velocity.x - expected_velocity.x
			#var max_diff = 200*delta*20
			#if abs(diff) >= max_diff:
				#if diff < 0:
					#diff = -max_diff
				#else:
					#diff = max_diff
			#velocity += Vector2(-diff, 0)
	#elif mutiply_x < 0:
		#var diff = abs(velocity.x - expected_velocity.x)
		#var max_diff = expected_velocity.x*delta*20
		#if diff >= abs(max_diff):
			#diff = abs(max_diff)
		#if expected_velocity.x * diff < 0:
			#diff = -diff
		#velocity += Vector2(diff, 0)
	#
	#
	#if is_flying or is_on_ladder:
		#var mutiply_y = velocity.y * expected_velocity.y
		#if mutiply_y >= 0:
			#if abs(velocity.y) < abs(expected_velocity.y):
				#velocity.y = expected_velocity.y
			#elif expected_velocity.y == 0:
				#var diff = abs(velocity.y)
				#var max_diff = move_speed*delta*10
				#if abs(velocity.y) >= max_diff:
					#diff = max_diff
				#if velocity.y * diff > 0:
					#diff = -diff
				#velocity += Vector2(0, diff)
			#elif abs(velocity.y) > abs(expected_velocity.y):
				#var diff = velocity.y - expected_velocity.y
				#var max_diff = 200*delta*20
				#if abs(diff) >= max_diff:
					#if diff < 0:
						#diff = -max_diff
					#else:
						#diff = max_diff
				#velocity += Vector2(0, -diff)
		#elif mutiply_y < 0:
			#var diff = abs(velocity.y - expected_velocity.y)
			#var max_diff = expected_velocity.y*delta*20
			#if diff >= abs(max_diff):
				#diff = abs(max_diff)
			#if expected_velocity.y * diff < 0:
				#diff = -diff
			#velocity += Vector2(0, diff)

func update_local_set_block():
	if not set_block_list.is_empty():
		for set_block_info in set_block_list.duplicate():
			var set_block_id = set_block_info[0]
			var set_block_pos = set_block_info[1]
			var set_block_layer = set_block_info[2]
			StaticLoad.game.set_block_list.append([Time.get_ticks_msec(), uuid, set_block_id, set_block_pos, set_block_layer, true])
			set_block_list.erase(set_block_info)
	if not success_set_block_list.is_empty() and multiplayer.get_unique_id() != 1:
		for set_block_info in success_set_block_list.duplicate():
			if changed_state_dict.has("set_block_list") and changed_state_dict["set_block_list"] is Array:
				changed_state_dict["set_block_list"].append(set_block_info)
			else:
				changed_state_dict["set_block_list"] = [set_block_info]
			success_set_block_list.erase(set_block_info)

func update_local_gravity():
	if StaticLoad.is_muti_mode and multiplayer.get_unique_id() != player_peer_id:
		#if not is_on_ladder and not is_flying and not is_on_floor() and abs(velocity.y) < 0.1:
			#velocity += get_gravity() * get_process_delta_time()
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
	if is_flying or is_frozen or is_on_ladder:
		return
	if not is_on_floor():
		velocity += get_gravity() * get_process_delta_time()

func update_local_move_by_data():
	if StaticLoad.is_muti_mode and multiplayer.get_unique_id() != player_peer_id:
		return
	if is_frozen:
		if velocity.length() > StaticLoad.FLOAT_DELTA:
			velocity = Vector2(0, 0)
		if expected_velocity.length() > StaticLoad.FLOAT_DELTA:
			expected_velocity = Vector2(0, 0)
		return
	if is_jump_pressed:
		if not is_flying and is_on_ladder:
			expected_velocity.y = -move_speed
		else:
			if not is_flying and is_on_floor():
				update_local_fall_damage_by_data()
				update_sound_by_data()
				if not is_dead:
					if velocity.y >= 0:
						is_jumping = true
			elif is_flying:
				expected_velocity.y = jump_velocity * 0.7
	elif not is_down_pressed and not is_flying and is_on_ladder:
		expected_velocity.y = 0
	if is_auto_jump:
		if not is_top_area_colliding and is_down_area_colliding and not is_up_area_colliding:
			if move_state != "idle":
				if not StaticLoad.is_muti_mode or StaticLoad.is_muti_mode and multiplayer.get_unique_id() == player_peer_id:
					if not is_flying and is_on_floor():
						if velocity.y >= 0:
							is_jumping = true
	if last_is_jump_pressed and not is_jump_pressed:
		if is_flying:
			expected_velocity.y = 0
	last_is_jump_pressed = is_jump_pressed
	
	if is_down_pressed:
		if is_flying:
			expected_velocity.y = -jump_velocity * 0.7
		elif is_on_ladder:
			expected_velocity.y = move_speed
	if last_is_down_pressed and not is_down_pressed:
		if is_flying:
			expected_velocity.y = 0
	last_is_down_pressed = is_down_pressed
	
	if is_sneaking:
		pull_amplify_factor = 1.3
	else:
		pull_amplify_factor = 1
	
	if move_state == "run":
		if is_in_water:
			expected_velocity.x = face_state * move_speed
		else:
			expected_velocity.x = face_state * move_speed * 2
	elif move_state == "walk":
		var current_move_rate = 1
		if is_sneaking or is_pulling:
			current_move_rate = 0.3
		if is_sneaking and not is_ground_area_colliding and is_on_floor():
			expected_velocity.x = 0
		elif is_in_water:
			expected_velocity.x = face_state * move_speed * 0.5 * current_move_rate
		else:
			expected_velocity.x = face_state * move_speed * current_move_rate
	elif move_state == "idle":
		expected_velocity.x = 0
	
	if velocity.length() > StaticLoad.FLOAT_DELTA:
		var player_block_pos = StaticLoad.game.tile_map_layer.local_to_map(position)
		var block_id_down = StaticLoad.get_block_id_by_atlas_coords(StaticLoad.game.tile_map_layer.get_cell_atlas_coords(player_block_pos))
		var block_id_up = StaticLoad.get_block_id_by_atlas_coords(StaticLoad.game.tile_map_layer.get_cell_atlas_coords(player_block_pos-Vector2i(0,1)))
		if not StaticLoad.get_is_untouchable_by_id(block_id_down):
			velocity = Vector2(0, 0)
		if not StaticLoad.get_is_untouchable_by_id(block_id_up):
			velocity = Vector2(0, 0)

func set_item_in_hand(got_item_name):
	var is_update_player_inventory = not StaticLoad.is_muti_mode or (StaticLoad.is_muti_mode and multiplayer.get_unique_id()==player_peer_id)
	item_in_hand.set_item_in_hand(got_item_name, is_update_player_inventory)


func update_local_item_in_hand():
	if StaticLoad.is_muti_mode and multiplayer.get_unique_id() != player_peer_id:
		return
	var in_hand_item_name_tmp = item_bar_names[selected_item_grid]
	if in_hand_item_name_tmp.contains("BOW"):
		if last_shoot_timer != shoot_timer:
			if shoot_timer == 0:
				set_item_in_hand("BOW")
				in_hand_item_name = "BOW"
			else:
				if shoot_timer > 2:
					shoot_timer = 2
				var stage = int(shoot_timer/0.666)-1
				if stage < 0:
					stage = 0
				if stage >= 3:
					stage = 2
				set_item_in_hand("BOW_PULLING_"+str(stage))
				in_hand_item_name = "BOW_PULLING_"+str(stage)
	if in_hand_item_name_tmp == in_hand_item_name:
		return
	if not in_hand_item_name.contains("BOW_PULLING"):
		in_hand_item_name = in_hand_item_name_tmp
	attacking_decline_timer = 0
	attacking_list.clear()
	attack_animation.stop()
	attack_animation.visible = false
	set_item_in_hand(in_hand_item_name)

func update_state_dict():
	state_dict["face_state"] = face_state
	state_dict["move_state"] = move_state
	state_dict["is_pulling"] = is_pulling
	state_dict["is_sneaking"] = is_sneaking
	state_dict["is_flying"] = is_flying
	state_dict["is_frozen"] = is_frozen
	state_dict["is_on_fire"] = is_on_fire
	state_dict["render_chunk"] = render_chunk
	state_dict["gamemode"] = gamemode
	state_dict["selected_block_pos"] = selected_block_pos
	state_dict["destroy_timer"] = destroy_timer
	state_dict["attack_timer"] = attack_timer
	state_dict["shoot_timer"] = shoot_timer
	state_dict["pull_amplify_factor"] = pull_amplify_factor
	state_dict["attacking_damage"] = attacking_damage
	state_dict["attacking_decline_timer"] = attacking_decline_timer
	state_dict["sword_breaking_timer"] = sword_breaking_timer
	state_dict["position"] = position
	state_dict["current_velocity"] = current_velocity
	state_dict["is_frozen"] = is_frozen
	state_dict["selected_item_grid"] = selected_item_grid
	state_dict["in_hand_item_name"] = in_hand_item_name
	state_dict["health"] = health
	state_dict["current_set_layer"] = current_set_layer

func update_local_state_dict():
	if not StaticLoad.is_muti_mode:
		return
	if not multiplayer.get_unique_id() == 1 and not multiplayer.get_unique_id() == player_peer_id:
		return
	update_state_dict()

# 由于only_server_change_state_list的限制
# 在该列表中的state是本不该由服务端更新的部分
# 但不会由客户端上传，仅会在服务端更新
func update_local_changed_state_dict():
	if not StaticLoad.is_muti_mode:
		return
	if not multiplayer.get_unique_id() == 1 and not multiplayer.get_unique_id() == player_peer_id:
		return
	for key in state_dict:
		if not last_state_dict.has(key) or last_state_dict[key] != state_dict[key]:
			# 客户端仅上传非only_server_change_state_list状态
			if not multiplayer.get_unique_id() == 1:
				if only_server_change_state_list.has(key):
					continue
			# 服务端仅更新only_server_change_state_list状态
			if multiplayer.get_unique_id() == 1 and not player_peer_id == 1:
				if not only_server_change_state_list.has(key):
					continue
			last_state_dict[key] = state_dict[key]
			if multiplayer.get_unique_id() == 1 and not player_peer_id == 1:
				only_server_change_state_dict[key] = state_dict[key]
			else:
				changed_state_dict[key] = state_dict[key]

func set_changed_state_dict(got_changed_state_dict):
	for key in got_changed_state_dict:
		if changed_state_dict.has(key) and changed_state_dict[key] is Array:
			changed_state_dict[key].append_array(got_changed_state_dict[key])
		elif changed_state_dict.has(key) and changed_state_dict[key] is Dictionary:
			changed_state_dict[key].merge(got_changed_state_dict[key], true)
		else:
			changed_state_dict[key] = got_changed_state_dict[key]

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
		elif key == "position":
			if position.distance_to(changed_state_dict[key]) > StaticLoad.POSITION_MAX_DIFFERENCE:
				changed_state_dict[key] = position
				is_need_resend = true
	if is_need_resend:
		StaticLoad.rpc_entity_func_by_uuid(uuid, "apply_changed_state_dict", changed_state_dict, [player_peer_id], true)

func apply_changed_state_dict(got_changed_state_dict):
	if got_changed_state_dict == null:
		return
	for key in got_changed_state_dict.duplicate():
		if trigger_change_state_list.has(key):
			if multiplayer.get_unique_id() == player_peer_id:
				continue
		if key == "position":
			var tween = get_tree().create_tween()
			tween.tween_property(self, "position", got_changed_state_dict[key], StaticLoad.DISPATCH_DELTA_TIME)
		elif key == "in_hand_item_name":
			in_hand_item_name = got_changed_state_dict[key]
			set_item_in_hand(in_hand_item_name)
		elif key == "set_block_list":
			for set_block_info in got_changed_state_dict[key]:
				set_block_list.append(set_block_info)
			changed_state_dict.erase(key)
		elif key == "inventory":
			if multiplayer.get_unique_id() == 1:
				var got_item_bar_names = got_changed_state_dict[key][0]
				var got_item_bar_amounts = got_changed_state_dict[key][1]
				var got_mouse_item_name = got_changed_state_dict[key][2]
				var got_mouse_item_amount = got_changed_state_dict[key][3]
				inventory_dict = calculate_inventory_dict([item_bar_names, item_bar_amounts, mouse_item_name, mouse_item_amount])
				var inventory_dict_tmp = calculate_inventory_dict([got_item_bar_names, got_item_bar_amounts, got_mouse_item_name, got_mouse_item_amount])
				var is_correct = true
				for item_name_tmp in inventory_dict_tmp:
					if not inventory_dict.has(item_name_tmp):
						is_correct = false
						break
					if inventory_dict[item_name_tmp] < inventory_dict_tmp[item_name_tmp]:
						is_correct = false
						break
				if is_correct or gamemode == "creative":
					item_bar_names = got_changed_state_dict[key][0]
					item_bar_amounts = got_changed_state_dict[key][1]
					mouse_item_name = got_changed_state_dict[key][2]
					mouse_item_amount = got_changed_state_dict[key][3]
					inventory_dict = inventory_dict_tmp
				else:
					StaticLoad.rpc_id(player_peer_id, "reply_for_update_player_inventory", item_bar_names, item_bar_amounts, mouse_item_name, mouse_item_amount)
				changed_state_dict.erase(key)
		else:
			self.set(key, got_changed_state_dict[key])

func calculate_inventory_dict(args):
	var item_bar_names_tmp = args[0]
	var item_bar_amounts_tmp = args[1]
	var mouse_item_name_tmp = args[2]
	var mouse_item_amount_tmp = args[3]
	var inventory_dict_tmp = {}
	for i in range(36):
		var item_name_tmp = item_bar_names_tmp[i]
		if item_name_tmp != "AIR":
			if inventory_dict_tmp.has(item_name_tmp):
				inventory_dict_tmp[item_name_tmp] += item_bar_amounts_tmp[i]
			else:
				inventory_dict_tmp[item_name_tmp] = item_bar_amounts_tmp[i]
	if mouse_item_name_tmp != "AIR":
		if inventory_dict_tmp.has(mouse_item_name_tmp):
			inventory_dict_tmp[mouse_item_name_tmp] += mouse_item_amount_tmp
		else:
			inventory_dict_tmp[mouse_item_name_tmp] = mouse_item_amount_tmp
	return inventory_dict_tmp

func upload_local_player_changed_state_dict():
	if not StaticLoad.is_muti_mode:
		return
	if multiplayer.get_unique_id() == 1:
		return
	if not multiplayer.get_unique_id() == player_peer_id:
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

func rpc_damage(args, is_on_server):
	if not StaticLoad.is_muti_mode:
		return
	if is_on_server:
		if multiplayer.get_unique_id() == 1:
			if player_peer_id == 1:
				var new_args = args.duplicate()
				new_args[1] = "null"
				StaticLoad.rpc_entity_func_by_uuid(uuid, "get_damage", new_args, "others", true)
			else:
				var new_args = args.duplicate()
				new_args[1] = "null"
				StaticLoad.rpc_entity_func_by_uuid(uuid, "get_damage", args, [player_peer_id], true)
				StaticLoad.rpc_entity_func_by_uuid(uuid, "get_damage", new_args, [player_peer_id], false)
	else:
		if player_peer_id == 1:
			var new_args = args.duplicate()
			new_args[1] = "null"
			StaticLoad.rpc_entity_func_by_uuid(uuid, "get_damage", new_args, "others", true)
		else:
			var new_args = args.duplicate()
			new_args[1] = "null"
			StaticLoad.rpc_entity_func_by_uuid(uuid, "get_damage", new_args, [player_peer_id], false)
		

func get_damage(args):
	var is_on_server = true
	var side = args[1]
	var got_health = args[2]
	health = got_health
	if is_dead:
		return
	var damage = args[0]
	var reason = args[3]
	var object = args[4]
	if side == "left":
		add_velocity(Vector2(500, -400))
	elif side == "right":
		add_velocity(Vector2(-500, -400))
	if damage > 0:
		health_recover_timer = StaticLoad.HEALTH_RECOVER_TIME
	var final_damage = damage
	if final_damage > StaticLoad.DEFAULT_PLAYER_HEALTH:
		final_damage = damage
	health -= final_damage
	if health <= 0:
		if hurt_tween != null:
			hurt_tween.stop()
		player_die(reason, object)
		set_shader_blink_intensity(0.6)
		die_name_tween = get_tree().create_tween()
		die_name_tween.tween_method(set_name_label_modulate, Color(1,1,1,1), Color(1,1,1,0), 0.25)
		StaticLoad.game.sound_audio_manager.play_random_audio_at_position("player", "hurt", position, 1)
		die_rotation_tween = get_tree().create_tween()
		die_rotation_tween.tween_method(set_z_rotation, 0, 90, StaticLoad.DISSOLVE_TIME)
	else:
		hurt_tween = get_tree().create_tween()
		hurt_tween.tween_method(set_shader_blink_intensity, 0.6, 0, StaticLoad.HURT_TIME)
		StaticLoad.game.sound_audio_manager.play_random_audio_at_position("damage", "hit", position, 1)

func set_z_rotation(got_rotation):
	player_model.rotation.z = deg_to_rad(got_rotation)

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
	var destroy_layer = current_set_layer
	var tile_map_layer_tmp = StaticLoad.game.tile_map_layer
	var chunk_pos = StaticLoad.game.get_chunk_position(block_pos)
	if not StaticLoad.game.loaded_chunks.has(str(chunk_pos[0])+"."+str(chunk_pos[1])):
		return false
	if destroy_layer == "back":
		var solid_block_id = StaticLoad.get_block_id_by_atlas_coords(StaticLoad.game.tile_map_layer.get_cell_atlas_coords(block_pos))
		if not StaticLoad.get_is_untouchable_by_id(solid_block_id):
			return false
		var block_id = StaticLoad.get_block_id_by_atlas_coords(StaticLoad.game.back_tile_map_layer.get_cell_atlas_coords(block_pos))
		if block_id == 0:
			return false
		if StaticLoad.game.back_tile_map_layer.get_cell_source_id(block_pos) != -1 and block_id != 0:
			set_block_list.append([0, block_pos, destroy_layer])
			is_punching = true
		else:
			return false
	elif destroy_layer == "solid":
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

func check_attached_block(block_pos, tile_map_layer_tmp):
	var chunk_pos_tmp
	var block_pos_tmp
	var is_attached_block = false
	for i in [1, -1]:
		block_pos_tmp = block_pos + Vector2i(i, 0)
		chunk_pos_tmp = StaticLoad.game.get_chunk_position(block_pos_tmp)
		if StaticLoad.game.loaded_chunks.has(str(chunk_pos_tmp[0])+"."+str(chunk_pos_tmp[1])):
			var block_id_tmp = StaticLoad.get_block_id_by_atlas_coords(tile_map_layer_tmp.get_cell_atlas_coords(block_pos_tmp))
			if block_id_tmp != 0:	
				is_attached_block = true
	for i in [1, -1]:
		block_pos_tmp = block_pos + Vector2i(0, i)
		chunk_pos_tmp = StaticLoad.game.get_chunk_position(block_pos_tmp)
		if StaticLoad.game.loaded_chunks.has(str(chunk_pos_tmp[0])+"."+str(chunk_pos_tmp[1])):
			var block_id_tmp = StaticLoad.get_block_id_by_atlas_coords(tile_map_layer_tmp.get_cell_atlas_coords(block_pos_tmp))
			if block_id_tmp != 0:	
				is_attached_block = true
	return is_attached_block

func place_block(block_pos):
	var place_layer = current_set_layer
	var chunk_pos = StaticLoad.game.get_chunk_position(block_pos)
	if not StaticLoad.game.loaded_chunks.has(str(chunk_pos[0])+"."+str(chunk_pos[1])):
		return false
	var selected_item_bar_name = item_bar_names[selected_item_grid]
	if selected_item_bar_name == "AIR":
		return false
	var tool_type = StaticLoad.get_tools_type_by_name(selected_item_bar_name)
	if tool_type.has("hoe"):
		if place_layer == "back":
			return false
		var up_block_pos = block_pos + Vector2i(0, -1)
		var up_chunk_pos = StaticLoad.game.get_chunk_position(up_block_pos)
		if not StaticLoad.game.loaded_chunks.has(str(up_chunk_pos[0])+"."+str(up_chunk_pos[1])):
			return false
		var up_block_id = StaticLoad.get_block_id_by_atlas_coords(StaticLoad.game.tile_map_layer.get_cell_atlas_coords(up_block_pos))
		if up_block_id != 0 and not StaticLoad.get_is_transparent_by_id(up_block_id):
			return false
		var local_block_id = StaticLoad.get_block_id_by_atlas_coords(StaticLoad.game.tile_map_layer.get_cell_atlas_coords(block_pos))
		if StaticLoad.get_block_name_by_id(local_block_id) == "GRASS_BLOCK":
			#var sound_pos = StaticLoad.game.tile_map_layer.map_to_local(block_pos)+Vector2(0, 25)
			#StaticLoad.game.sound_audio_manager.play_random_audio_at_position("item", "hoe_still", sound_pos, 1)
			#StaticLoad.game.set_block(block_pos, StaticLoad.get_block_id_by_name("FARM_LAND"), "solid", true)
			set_block_list.append([StaticLoad.get_block_id_by_name("FARM_LAND"), block_pos, "solid"])
			#if StaticLoad.is_muti_mode and multiplayer.get_unique_id() == 1:
				#StaticLoad.rpc("set_block", [block_pos, StaticLoad.get_block_id_by_name("FARM_LAND"), "solid", true])
			#wear_and_update_in_hand_tool(1)
			#var rng = RandomNumberGenerator.new()
			#var num = rng.randf()
			#if num > 0.7:
				#var item_pos = StaticLoad.game.tile_map_layer.map_to_local(block_pos)-Vector2(0, 25)
				#var summon_item_args = ["item", "SEEDS_WHEAT", item_pos, 1, 0, 0, UUID.v4()]
				#if StaticLoad.is_muti_mode:
					#if multiplayer.get_unique_id() == 1:
						#StaticLoad.create_entity(summon_item_args)
						#StaticLoad.rpc("create_entity", summon_item_args)
				#else:
					#StaticLoad.create_entity(summon_item_args)
			is_punching = true
			return true
		elif StaticLoad.get_block_name_by_id(local_block_id) == "DIRT":
			#var sound_pos = StaticLoad.game.tile_map_layer.map_to_local(block_pos)+Vector2(0, 25)
			set_block_list.append([StaticLoad.get_block_id_by_name("FARM_LAND"), block_pos, "solid"])
			#StaticLoad.game.sound_audio_manager.play_random_audio_at_position("item", "hoe_still", sound_pos, 1)
			#StaticLoad.game.set_block(block_pos, StaticLoad.get_block_id_by_name("FARM_LAND"), "solid", true)
			#if StaticLoad.is_muti_mode and multiplayer.get_unique_id() == 1:
				#StaticLoad.rpc("set_block", [block_pos, StaticLoad.get_block_id_by_name("FARM_LAND"), "solid", true])
			is_punching = true
			return true
		else:
			is_punching = true
			return false
	var final_item_name = StaticLoad.get_final_place_name_by_name(selected_item_bar_name)
	var block_id = StaticLoad.get_block_id_by_name(final_item_name)
	var tile_map_layer_tmp = StaticLoad.game.tile_map_layer
	if place_layer == "back":
		tile_map_layer_tmp = StaticLoad.game.back_tile_map_layer
	if not StaticLoad.game.check_place_block_state(block_pos, block_id, current_set_layer):
		return false
	if gamemode != "creative" and current_set_layer == "solid":
		if not check_attached_block(block_pos, tile_map_layer_tmp) and StaticLoad.get_is_clingling_by_name(StaticLoad.get_block_name_by_id(block_id)) != "all" and StaticLoad.get_is_clingling_by_name(StaticLoad.get_block_name_by_id(block_id)) != "back":
			return false
	if tile_map_layer_tmp.get_cell_source_id(block_pos) == -1 and StaticLoad.game.no_reach_tile_map_layer.get_cell_source_id(block_pos) == -1 and StaticLoad.block_ids.has(final_item_name):
		if place_layer == "back":
			var solid_block_id = StaticLoad.get_block_id_by_atlas_coords(StaticLoad.game.tile_map_layer.get_cell_atlas_coords(block_pos))
			if StaticLoad.get_is_untouchable_by_id(solid_block_id):
				set_block_list.append([block_id, block_pos, place_layer])
				is_punching = true
				return true
		elif place_layer == "solid":
			set_block_list.append([block_id, block_pos, place_layer])
			is_punching = true
			return true
	return false

func wear_inventory_amount(args):
	var sort = args[0]
	var damage = args[1]
	item_bar_amounts[sort] -= damage
	if item_bar_amounts[sort] <= 0:
		if StaticLoad.is_muti_mode and multiplayer.get_unique_id() == player_peer_id:
			if item_bar_names[sort] != "AIR":
				breaking_tool = item_bar_names[sort]
		item_bar_names[sort] = "AIR"
		item_bar_amounts[sort] = 0
	if not StaticLoad.is_muti_mode or (StaticLoad.is_muti_mode and multiplayer.get_unique_id() == player_peer_id):
		StaticLoad.game.refresh_item_grid(sort)

func server_breaking_tool(got_breaking_tool):
	StaticLoad.game.sound_audio_manager.play_random_audio_at_position("random", "tool_break", position, 1)
	StaticLoad.game.summon_destroy_particle(position-Vector2(0,16), "item", got_breaking_tool)
	attack_timer = 0
	if StaticLoad.is_muti_mode and multiplayer.get_unique_id() == 1:
		if breaking_tool.contains("SWORD"):
			if breaking_tool.contains("GOLD"):
				sword_breaking_timer = 0.5
			else:
				sword_breaking_timer = 1

func wear_and_update_in_hand_tool(damage, is_on_server):
	#if not StaticLoad.is_muti_mode or (StaticLoad.is_muti_mode and multiplayer.get_unique_id() == player_peer_id):
	if not StaticLoad.tools_type.has(in_hand_item_name):
		return
	item_bar_amounts[selected_item_grid] -= damage
	if item_bar_amounts[selected_item_grid] <= 0:
		if in_hand_item_name.contains("SWORD"):
			if in_hand_item_name.contains("GOLD"):
				sword_breaking_timer = 0.5
			else:
				sword_breaking_timer = 1
		breaking_tool = in_hand_item_name
		#if StaticLoad.is_muti_mode and multiplayer.get_unique_id() == 1 and is_on_server:
			#StaticLoad.rpc_entity_func_by_uuid(uuid, "server_breaking_tool", in_hand_item_name, "others", true)
		item_bar_names[selected_item_grid] = "AIR"
		item_bar_amounts[selected_item_grid] = 0
	if is_on_server and StaticLoad.is_muti_mode:
		if multiplayer.get_unique_id() == 1:
			StaticLoad.rpc_entity_func_by_uuid(uuid, "wear_inventory_amount", [selected_item_grid, damage], [player_peer_id], true)
	elif not is_on_server and StaticLoad.is_muti_mode:
		if multiplayer.get_unique_id() == player_peer_id:
			if multiplayer.get_unique_id() != 1:
				StaticLoad.rpc_entity_func_by_uuid(uuid, "wear_inventory_amount", [selected_item_grid, damage], [player_peer_id], false)
	if not StaticLoad.is_muti_mode or (StaticLoad.is_muti_mode and multiplayer.get_unique_id() == player_peer_id):
		StaticLoad.game.refresh_item_grid(selected_item_grid)

func get_death_messgae(reason, object):
	var text = ""
	if reason == "fall":
		text = player_name+tr("DEATH_FALL")
	elif reason == "player_attack":
		text = player_name+tr("DEATH_PLAYER_KILL_1")+object+tr("DEATH_PLAYER_KILL_2")
	elif reason == "zombie_attack":
		text = player_name+tr("DEATH_ZOMBIE_KILL")
	elif reason == "arrow_attack":
		var splits = object.split(".")
		if splits[0] == "player":
			text = player_name+tr("DEATH_PLAYER_ARROW_KILL_1")+splits[2]+tr("DEATH_PLAYER_ARROW_KILL_2")
		elif splits[0] == "skeleton":
			text = player_name+tr("DEATH_SKELETON_ARROW_KILL")
	return text

func display_death_message(args):
	var reason = args[0]
	var object = args[1]
	var text = get_death_messgae(reason, object)
	if text != "":
			StaticLoad.game.broadcast_to_all(text, "light_sky_blue")

func player_die(reason, object):
	is_dead = true
	attacking_decline_timer = 0
	stop_move()
	update_animation_by_data()
	if not StaticLoad.is_muti_mode or (StaticLoad.is_muti_mode and multiplayer.get_unique_id() == 1):
		var text = get_death_messgae(reason, object)
		if text != "":
			StaticLoad.game.broadcast_to_all(text, "light_sky_blue")
			if StaticLoad.is_muti_mode:
				StaticLoad.rpc_entity_func_by_uuid(uuid, "display_death_message", [reason, object], "others", true)
	if is_other:
		return
	for button in StaticLoad.game.death_ui_flow_container.get_children():
		button.disabled = true
	StaticLoad.game.die_no_press_timer = 1
	if StaticLoad.game.is_pause:
		StaticLoad.game.pause_ui.visible = false
		StaticLoad.game.is_pause = false
	if StaticLoad.game.is_inventory:
		StaticLoad.game.inventory_ui.visible = false
		StaticLoad.game.is_inventory = false
	if StaticLoad.game.is_chat:
		StaticLoad.game.chat_message_out.visible = true
		StaticLoad.game.chat_panel.visible = false
		StaticLoad.game.is_chat = false
	if StaticLoad.game.is_map:
		StaticLoad.game.mini_map.set_anchors_preset(Control.PRESET_TOP_RIGHT)
		StaticLoad.game.mini_map.size = Vector2(270, 270)
		StaticLoad.game.mini_map.position = Vector2(get_viewport_rect().size[0]-270, 0)
		StaticLoad.game.is_map = false
		StaticLoad.game.item_bar_panel.visible = true
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
				if StaticLoad.is_dedicated_server or (StaticLoad.is_muti_mode and multiplayer.get_unique_id() == 1):
					position = Vector2i(x*50+25, -y*50+50)
				var tween2 = get_tree().create_tween()
				tween2.tween_method(set_shader_dissolve_intensity, -0.6, 0.6, StaticLoad.TELEPORT_TIME/2.0)
				#var tween1 = get_tree().create_tween()
				#tween1.tween_method(set_shader_blink_intensity, 0.0, -1.0, StaticLoad.TELEPORT_TIME/2.0)
				#var tween2 = get_tree().create_tween()
				#tween2.tween_method(set_shader_transparent_intensity, 0.0, 1.0, StaticLoad.TELEPORT_TIME/2.0)
				var tween3 = get_tree().create_tween()
				tween3.tween_method(set_name_label_modulate, Color(1,1,1,1), Color(1,1,1,0), StaticLoad.TELEPORT_TIME/2.0)
				await tween3.finished
				freeze()
				position = Vector2i(x*50+25, -y*50+50-24)
				var in_chunk_pos = StaticLoad.game.get_chunk_position(StaticLoad.game.tile_map_layer.local_to_map(position))
				while(not StaticLoad.game.loaded_chunks.has(str(in_chunk_pos[0])+"."+str(in_chunk_pos[1]))):
					await get_tree().process_frame
				unfreeze()
				var tween4 = get_tree().create_tween()
				tween4.tween_method(set_shader_dissolve_intensity, 0.6, -0.6, StaticLoad.TELEPORT_TIME/2.0)
				#var tween4 = get_tree().create_tween()
				#tween4.tween_method(set_shader_transparent_intensity, 1.0, 0.0, StaticLoad.TELEPORT_TIME/2.0)
				var tween5 = get_tree().create_tween()
				tween5.tween_method(set_name_label_modulate, Color(1,1,1,0), Color(1,1,1,1), StaticLoad.TELEPORT_TIME/2.0)
				#var tween6 = get_tree().create_tween()
				#tween6.tween_method(set_shader_blink_intensity, -1.0, 0.0, StaticLoad.TELEPORT_TIME/2.0)
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
	var list = GameCalculator.get_item(item_name, amount, search_begin, search_size, PackedStringArray(item_bar_names), PackedInt32Array(item_bar_amounts), StaticLoad.get_is_durable_by_name(item_name), StaticLoad.get_max_amount_by_name(item_name), selected_item_grid)
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
	if not StaticLoad.is_muti_mode or (StaticLoad.is_muti_mode and player_peer_id == multiplayer.get_unique_id()):
		if StaticLoad.game.is_inventory:
			StaticLoad.game.append_process_refresh("refresh_inventory")
		if list[0] < amount and item_bar_names[selected_item_grid] != "AIR" and list[1]:
			StaticLoad.game.append_process_refresh("refresh_item_name_label")
		if list[0] < amount:
			StaticLoad.game.append_process_refresh("refresh_item_grid")
	return list[0]

# 玩家拾取掉落物，返回未被拾取的数量
func if_get_item_left(got_item_name: String, amount: int, search_begin: int, search_size: int) -> int:
	return GameCalculator.if_get_item_left(got_item_name, amount, search_begin, search_size, PackedStringArray(item_bar_names), PackedInt32Array(item_bar_amounts), StaticLoad.get_is_durable_by_name(got_item_name), StaticLoad.get_max_amount_by_name(got_item_name))
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

func shoot_arrow():
	if not in_hand_item_name.contains("BOW"):
		return
	var stage = int(shoot_timer/0.667)
	if stage >= 3:
		stage = 2
	var shoot_speed = arrow_shoot_speed
	shoot_speed[0] *= face_state
	shoot_speed = lerp(Vector2(0, 0), shoot_speed, shoot_timer/2)
	var lift_dist = lerp(-30, -55, shoot_timer/2)
	var arrow_uuid = UUID.v4()
	var arrow_args = [arrow_uuid, str(arrow_uuid), position+Vector2(face_state*30,lift_dist), shoot_speed, shoot_speed, "player", uuid, player_name, false]
	StaticLoad.game.sound_audio_manager.play_random_audio_at_position("random", "bow_shoot", position, 1)
	if StaticLoad.is_muti_mode:
		if multiplayer.get_unique_id() == 1:
			summon_arrow(arrow_args)
			StaticLoad.rpc_entity_func_by_uuid(uuid, "summon_arrow", arrow_args, "others", true)
		else:
			StaticLoad.rpc_entity_func_by_uuid(uuid, "summon_arrow", arrow_args, [1], false)
	else:
		summon_arrow(arrow_args)

func summon_arrow(args):
	if StaticLoad.is_muti_mode and not multiplayer.get_unique_id() == 1:
		args[3] = Vector2(0, 0)
	var arrow = StaticLoad.arrow_scene.instantiate()
	StaticLoad.game.arrows.add_child(arrow)
	arrow.init(args)
	StaticLoad.game.entities[arrow.get_uuid()] = arrow

func drop_item(item_name, item_amount):
	if item_name == "AIR":
		return
	var x_velocity = face_state*dropped_item_speed
	var summon_item_args = [item_name, position-Vector2(0,30), item_amount, x_velocity, dropped_item_no_collect_time, UUID.v4()]
	if StaticLoad.is_muti_mode:
		if multiplayer.get_unique_id() == 1:
			summon_item(summon_item_args)
			StaticLoad.rpc_entity_func_by_uuid(uuid, "summon_item", summon_item_args, "others", true)
		else:
			StaticLoad.rpc_entity_func_by_uuid(uuid, "summon_item", summon_item_args, [1], false)
	else:
		summon_item(summon_item_args)

func create_entity(args):
	StaticLoad.create_entity(args)

func summon_item(args):
	var droppped_item_name = args[0]
	var pos = args[1]
	var amount = args[2]
	var x_velocity = args[3]
	if StaticLoad.is_muti_mode and not multiplayer.get_unique_id() == 1:
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
	expected_velocity.x = 0

func respawn(is_animation = true):
	if die_rotation_tween != null:
		die_rotation_tween.stop()
	if die_name_tween != null:
		die_name_tween.stop()
	set_z_rotation(0)
	set_shader_blink_intensity(0)
	attack_timer = 0.5
	freeze()
	position = Vector2(0, -24)
	if not StaticLoad.is_muti_mode or (StaticLoad.is_muti_mode and multiplayer.get_unique_id() == player_peer_id):
		if StaticLoad.is_on_mobile_platform:
			Input.emulate_mouse_from_touch = false
		StaticLoad.game.death_ui.visible = false
		StaticLoad.game.is_input_frozen = false
		StaticLoad.game.move_input_list.clear()
		stop_move()
	var in_chunk_pos = StaticLoad.game.get_chunk_position(StaticLoad.game.tile_map_layer.local_to_map(position))
	while(not StaticLoad.game.loaded_chunks.has(str(in_chunk_pos[0])+"."+str(in_chunk_pos[1]))):
		if not is_animation:
			break
		await get_tree().process_frame
	health = 20
	is_dead = false
	if is_animation:
		var tween1 = get_tree().create_tween()
		tween1.tween_method(set_name_label_modulate, Color(1,1,1,0), Color(1,1,1,1), StaticLoad.DISSOLVE_TIME)
		var tween2 = get_tree().create_tween()
		tween2.tween_method(set_shader_dissolve_intensity, 0.6, -0.6, StaticLoad.DISSOLVE_TIME)
	unfreeze()

func check_wear_sword():
	if attacking_list.size() == 1:
		if gamemode != "creative":
			wear_and_update_in_hand_tool(1, true)

func attack():
	if StaticLoad.is_muti_mode and multiplayer.get_unique_id() != 1:
		return
	var tool_info = StaticLoad.tools_type[in_hand_item_name]
	if not is_dead and StaticLoad.tools_type.has(in_hand_item_name) and tool_info.has("sword"):
		attacking_list.clear()
		if not is_up_area_colliding:
			attacking_damage = tool_info["sword"]
			for body in attack_area.get_overlapping_bodies():
				if not body.has_method("get_uuid"):
					continue
				if body.get_uuid() == null:
					continue
				if body.get_uuid() == uuid or body.get_entity_type() == "item" or body.get_entity_type() == "arrow":
					continue
				if body.get_entity_type() == "player" and body.gamemode == "creative":
					continue
				if body.get_is_dead():
					continue
				if attacking_list.has(body):
					continue
				var side = "left"
				if body.position.x < position.x:
					side = "right"
				if body.get_entity_type() == "player":
					body.rpc_damage([attacking_damage, side, body.get_health(), "player_attack", player_name], true)
				body.get_damage([attacking_damage, side, body.get_health(), "player_attack", player_name])
				attacking_list.append(body)
				check_wear_sword()

func set_name_label_modulate(color):
	name_label.modulate = color

func play_successful_hit_audio(args):
	if StaticLoad.is_muti_mode and multiplayer.get_unique_id() != player_peer_id:
		return
	StaticLoad.game.sound_audio_manager.play_random_audio_at_position("random", "successful_hit", position, 1)

func leave_server_and_destroy():
	var tween1 = get_tree().create_tween()
	tween1.tween_method(set_shader_dissolve_intensity, -0.6, 0.6, StaticLoad.TELEPORT_TIME/2.0)
	#var tween1 = get_tree().create_tween()
	#tween1.tween_method(set_shader_blink_intensity, 0.0, -1.0, StaticLoad.TELEPORT_TIME/2.0)
	#var tween2 = get_tree().create_tween()
	#tween2.tween_method(set_shader_transparent_intensity, 0.0, 1.0, StaticLoad.TELEPORT_TIME/2.0)
	var tween3 = get_tree().create_tween()
	tween3.tween_method(set_name_label_modulate, Color(1,1,1,1), Color(1,1,1,0), StaticLoad.TELEPORT_TIME/2.0)
	await tween3.finished
	self.queue_free()

func init_remote(got_data):
	player_peer_id = got_data[0]
	player_name = got_data[1]
	name_label.text = player_name
	if StaticLoad.is_muti_mode and multiplayer.get_unique_id() == player_peer_id:
		pass
	else:
		var player_icon_instance = StaticLoad.player_icon_scene.instantiate()
		StaticLoad.game.player_icons[player_name] = player_icon_instance
		StaticLoad.game.mini_map_players.add_child(player_icon_instance)
		var mini_map_camera_zoom = StaticLoad.game.mini_map_camera.zoom[0]
		var player_icon_scale = StaticLoad.MINI_MAP_SCALE_FACTOR/mini_map_camera_zoom
		player_icon_instance.scale = Vector2(player_icon_scale, player_icon_scale)
		player_icon_instance.name = player_name
	apply_changed_state_dict(got_data[2])
	uuid = UUID.uuid_from_username(player_name)
	if gamemode != "creative":
		is_flying = false
	update_player_face_rotation()
	StaticLoad.game.entities[uuid] = self
	
	if player_peer_id == multiplayer.get_unique_id():
		if self.gamemode == "creative":
			StaticLoad.game.health_bar.visible = false
	StaticLoad.player_peer_dict[player_peer_id] = StaticLoad.game.players.get_node(str(player_peer_id))
	StaticLoad.game.update_new_chunk(true)
	StaticLoad.game.update_game_details()
	unfreeze()
	if player_peer_id == multiplayer.get_unique_id():
		return
	
	if multiplayer.get_unique_id() == 1:
		return
	if not StaticLoad.game.online_ui_vbox_container.has_node(str(player_peer_id)):
		var online_info_instance = StaticLoad.online_info_scene.instantiate()
		StaticLoad.game.online_ui_vbox_container.add_child(online_info_instance)
		online_info_instance.name = str(player_peer_id)
		online_info_instance.player_name.text = self.player_name
		#var online_info = StaticLoad.game.online_ui_vbox_container.get_node(str(peer_id))
		await get_tree().create_timer(0.5).timeout
		StaticLoad.rpc_id(1, "request_for_ping", multiplayer.get_unique_id(), player_peer_id)

func set_player_model_skin_by_texture_buffer(got_skin_texture_buffer):
	var player_material = load("res://Assets/Materials/PlayerSkin.tres").duplicate(true)
	var skin_texture_image = Image.new()
	skin_texture_image.load_png_from_buffer(got_skin_texture_buffer)
	player_material.albedo_texture = ImageTexture.create_from_image(skin_texture_image)
	player_model_mesh.mesh.surface_set_material(0, player_material)
	if StaticLoad.game.player_icons.has(player_name):
		StaticLoad.game.player_icons[player_name].texture.atlas = ImageTexture.create_from_image(skin_texture_image)
		StaticLoad.game.player_icons[player_name].get_node("UpSkin").texture.atlas = ImageTexture.create_from_image(skin_texture_image)
	if not StaticLoad.is_muti_mode or player_peer_id == multiplayer.get_unique_id():
		StaticLoad.game.inventory_player_model_mesh.mesh.surface_set_material(0, player_material)

func set_player_model_skin_by_texture(got_skin_texture):
	var player_material = load("res://Assets/Materials/PlayerSkin.tres").duplicate(true)
	player_material.albedo_texture = got_skin_texture
	player_model_mesh.mesh.surface_set_material(0, player_material)
	if StaticLoad.game.player_icons.has(player_name):
		StaticLoad.game.player_icons[player_name].texture.atlas = got_skin_texture
		StaticLoad.game.player_icons[player_name].get_node("UpSkin").texture.atlas = got_skin_texture
	if not StaticLoad.is_muti_mode or player_peer_id == multiplayer.get_unique_id():
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

func get_uuid():
	return uuid

func get_entity_type():
	return entity_type

func get_entity_name():
	return player_name

func get_chunk_pos():
	return chunk_pos

func get_last_pos():
	return last_pos

func get_health():
	return health

func get_is_dead():
	return is_dead

func get_is_frozen():
	return is_frozen

func freeze():
	velocity = Vector2(0, 0)
	is_frozen = true

func unfreeze():
	velocity = Vector2(0, 0)
	is_frozen = false

func get_is_on_fire():
	return is_on_fire

func get_fire_lasting_timer():
	return fire_lasting_timer

func get_fire_damage_timer():
	return fire_damage_timer

func _on_up_area_body_entered(body: Node2D) -> void:
	if body.name != "TileMapLayer":
		return
	is_up_area_colliding = true

func _on_up_area_body_exited(body: Node2D) -> void:
	if body.name != "TileMapLayer":
		return
	is_up_area_colliding = false
	up_area_colliding_false.emit()

func _on_down_area_body_entered(body: Node2D) -> void:
	if body.name != "TileMapLayer":
		return
	is_down_area_colliding = true

func _on_down_area_body_exited(body: Node2D) -> void:
	if body.name != "TileMapLayer":
		return
	is_down_area_colliding = false

func _on_top_area_body_entered(body: Node2D) -> void:
	if body.name != "TileMapLayer":
		return
	is_top_area_colliding = true

func _on_top_area_body_exited(body: Node2D) -> void:
	if body.name != "TileMapLayer":
		return
	is_top_area_colliding = false

func _on_attack_area_body_entered(body: Node2D) -> void:
	if attacking_decline_timer > 0 and not is_dead:
		if not is_up_area_colliding:
			var damage = attacking_damage
			if not body.has_method("get_uuid"):
				return
			if body.get_uuid() == null:
				return
			if body.get_uuid() == uuid or body.get_entity_type() == "item" or body.get_entity_type() == "arrow":
				return
			if body.get_entity_type() == "player" and body.gamemode == "creative":
				return
			if body.get_is_dead():
				return
			if attacking_list.has(body):
				return
			var side = "left"
			if face_state < 0:
				side = "right"
			if body.get_entity_type() == "player":
				body.rpc_damage([damage, side, body.get_health(), "player_attack", player_name], true)
			body.get_damage([damage, side, body.get_health(), "player_attack", player_name])
			attacking_list.append(body)
			check_wear_sword()
		else:
			await up_area_colliding_false
			if attacking_decline_timer > 0:
				var damage = attacking_damage
				if not body.has_method("get_uuid"):
					return
				if body.get_uuid() == null:
					return
				if body.get_uuid() == uuid or body.get_entity_type() == "item" or body.get_entity_type() == "arrow":
					return
				if body.get_entity_type() == "player" and body.gamemode == "creative":
					return
				if body.get_is_dead():
					return
				if attacking_list.has(body):
					return
				var side = "left"
				if face_state < 0:
					side = "right"
				if body.get_entity_type() == "player":
					body.rpc_damage([damage, side, body.get_health(), "player_attack", player_name], true)
				body.get_damage([damage, side, body.get_health(), "player_attack", player_name])
				attacking_list.append(body)
				check_wear_sword()
			
func _on_ground_area_body_entered(body: Node2D) -> void:
	if body.name != "TileMapLayer":
		return
	is_ground_area_colliding = true

func _on_ground_area_body_exited(body: Node2D) -> void:
	if body.name != "TileMapLayer":
		return
	is_ground_area_colliding = false
