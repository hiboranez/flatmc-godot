extends CharacterBody2D

# 预加载
@onready var entity_model_mesh = $SubViewportContainer/SubViewport/Pig/Bones_Pig/Skeleton3D/Mob_Pig_001
@onready var animation_tree = $SubViewportContainer/SubViewport/AnimationTree
@onready var entity_sprite = $Sprite2D
@onready var entity_model = $SubViewportContainer/SubViewport/Pig
@onready var name_label = $Sprite2D/NameLable
@onready var up_area_collision_shape = $UpArea/CollisionShape2D
@onready var down_area_collision_shape = $DownArea/CollisionShape2D

# 实体变量
var uuid = UUID.v4()
var entity_type = "pig"
var entity_name: String
var chunk_pos = Vector2i(0, 0)
var expected_velocity = Vector2i(0, 0)
var is_dead = false

# 子类变量
var move_speed: float = 200
var jump_velocity: float = -550
var walk_period: float = 0.83
var run_period: float = 0.42
var refresh_target_timer: float = 5
var panic_timer: float = 0
var health: int = 20
var health_recover_timer: float = 10
var velocity_before_pause = velocity
var current_velocity = Vector2(0, 0)
var last_velocity = Vector2(0, 0)
var target_pos = Vector2i(0, 0)
var step_sound_timer: float = 0
var move_state = "idle"
var face_state: int = -1
var turn_state: float = 0
var is_pause = false
var is_frozen = false
var is_in_water = false
var is_flying = false
var is_up_area_colliding = false
var is_down_area_colliding = false
var is_top_area_colliding = false
var is_on_ladder = false
var hurt_tween
var animation_tree_parameters = {
	"walk": 0,
	"run": 0
}
var trigger_change_state_list = [
]
var state_dict = {}
var last_state_dict = {}
var changed_state_dict = {}
var only_server_change_state_dict = {}

func _ready():
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
	update_local_velocity()
	update_local_refresh_target_timer()
	update_local_is_on_ladder()
	update_local_gravity()
	update_local_move_by_data()
	update_local_state_dict()
	update_local_changed_state_dict()
	
	update_last_velocity()

func init(args):
	uuid = args[0]
	position = args[1]
	update_target_pos()

func update_sound_by_data():
	if abs(current_velocity.y) < StaticLoad.FLOAT_DELTA and last_velocity.y > 1100:
		if last_velocity.y > 1300:
			StaticLoad.game.sound_audio_manager.play_random_audio_at_position("damage", "fallbig", position, 1)
		else:
			StaticLoad.game.sound_audio_manager.play_random_audio_at_position("damage", "fallsmall", position, 1)
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
	
	var detect_size = 40
	if move_state == "run":
		detect_size = 80
	var half_detect_size = 30+(detect_size/2)
	up_area_collision_shape.shape.size.x = detect_size
	down_area_collision_shape.shape.size.x = detect_size
	if turn_state > 0:
		if up_area_collision_shape.position.x < 0:
			up_area_collision_shape.position.x = half_detect_size
		if down_area_collision_shape.position.x < 0:
			down_area_collision_shape.position.x = half_detect_size
	else:
		if up_area_collision_shape.position.x > 0:
			up_area_collision_shape.position.x = -half_detect_size
		if down_area_collision_shape.position.x > 0:
			down_area_collision_shape.position.x = -half_detect_size
	
	if abs(turn_state-face_state) > 0.01:
		update_entity_face_rotation()
		var turn_amplitude = delta/StaticLoad.TURN_TIME
		if turn_amplitude > 1:
			turn_amplitude = 1
		turn_state = turn_state*(1-turn_amplitude)+face_state*turn_amplitude
		if abs(turn_state-face_state)<0.01:
			turn_state = face_state
			update_entity_face_rotation()
	update_animation_tree()

func update_local_fall_damage_by_data():
	if StaticLoad.is_muti_mode and StaticLoad.multiplayer.get_unique_id() != 1:
		return
	#更新摔落
	if last_velocity.y > 1000 and not is_on_ladder:
		if abs(current_velocity.y) < StaticLoad.FLOAT_DELTA or current_velocity.y < 0:
			@warning_ignore("integer_division")
			var damage = (int(last_velocity.y)-1000)/50
			get_damage([damage, "down"])
			
			if StaticLoad.is_muti_mode:
				StaticLoad.rpc_entity_func_by_uuid(uuid, "get_damage", [damage, "down"], "others", true)

func update_local_health_recover():
	if StaticLoad.is_muti_mode and StaticLoad.multiplayer.get_unique_id() != 1:
		return
	if health >= 20:
		return
	if is_dead:
		return
	if health < 20:
		health_recover_timer -= get_process_delta_time()
	if health_recover_timer < -1.5:
		health += 1
		health_recover_timer = 0

func update_local_velocity():
	if StaticLoad.is_muti_mode and StaticLoad.multiplayer.get_unique_id() != 1:
		return
	var delta = get_process_delta_time()
	var mutiply_x = velocity.x * expected_velocity.x
	if mutiply_x >= 0:
		if abs(velocity.x) < abs(expected_velocity.x):
			velocity.x = expected_velocity.x
		elif expected_velocity.x == 0:
			var diff = abs(velocity.x)
			var max_diff = move_speed*delta*10
			if abs(velocity.x) >= max_diff:
				diff = max_diff
			if velocity.x * diff > 0:
				diff = -diff
			velocity += Vector2(diff, 0)
		elif abs(velocity.x) > abs(expected_velocity.x):
			var diff = velocity.x - expected_velocity.x
			var max_diff = 200*delta*20
			if abs(diff) >= max_diff:
				if diff < 0:
					diff = -max_diff
				else:
					diff = max_diff
			velocity += Vector2(-diff, 0)
	elif mutiply_x < 0:
		var diff = abs(velocity.x - expected_velocity.x)
		var max_diff = expected_velocity.x*delta*20
		if diff >= abs(max_diff):
			diff = abs(max_diff)
		if expected_velocity.x * diff < 0:
			diff = -diff
		velocity += Vector2(diff, 0)
	
	
	if is_flying or is_on_ladder:
		var mutiply_y = velocity.y * expected_velocity.y
		if mutiply_y >= 0:
			if abs(velocity.y) < abs(expected_velocity.y):
				velocity.y = expected_velocity.y
			elif expected_velocity.y == 0:
				var diff = abs(velocity.y)
				var max_diff = move_speed*delta*10
				if abs(velocity.y) >= max_diff:
					diff = max_diff
				if velocity.y * diff > 0:
					diff = -diff
				velocity += Vector2(0, diff)
			elif abs(velocity.y) > abs(expected_velocity.y):
				var diff = velocity.y - expected_velocity.y
				var max_diff = 200*delta*20
				if abs(diff) >= max_diff:
					if diff < 0:
						diff = -max_diff
					else:
						diff = max_diff
				velocity += Vector2(0, -diff)
		elif mutiply_y < 0:
			var diff = abs(velocity.y - expected_velocity.y)
			var max_diff = expected_velocity.y*delta*20
			if diff >= abs(max_diff):
				diff = abs(max_diff)
			if expected_velocity.y * diff < 0:
				diff = -diff
			velocity += Vector2(0, diff)
		
	#if impulse_list.is_empty():
		#return
	#for impulse in impulse_list.copy():
		#if impulse[0].length() <= 1:
			#impulse_list.erase(impulse)
			#continue
		#var accelerate = impulse[0]/impulse[1]
		#velocity += accelerate
		#impulse[0] -= accelerate
		#if impulse[0].x <= 1:
			#impulse[0].x = 0
		#if impulse[0].y <= 1:
			#impulse[0].y = 0

func update_target_pos():
	var rng = RandomNumberGenerator.new()
	var num1 = rng.randf()-0.5
	var num2 = rng.randf()-0.5
	target_pos = StaticLoad.game.tile_map_layer.local_to_map(position)+Vector2i(int(num1*20),int(num2*20))

func update_local_refresh_target_timer():
	if StaticLoad.is_muti_mode and StaticLoad.multiplayer.get_unique_id() != 1:
		return
	if panic_timer <= 0:
		panic_timer = 0
	elif panic_timer > 0:
		if move_state != "run":
			move_state = "run"
		panic_timer -= get_process_delta_time()
		return
	if refresh_target_timer <= 0:
		refresh_target_timer = 5
		update_target_pos()
	else:
		refresh_target_timer -= get_process_delta_time()
	

func update_local_is_on_ladder():
	if StaticLoad.is_muti_mode and StaticLoad.multiplayer.get_unique_id() != 1:
		return
	var foot_pos = position + Vector2(0, 23)
	var foot_block_pos = StaticLoad.game.tile_map_layer.local_to_map(foot_pos)
	var foot_block_id = StaticLoad.get_block_id_by_atlas_coords(StaticLoad.game.tile_map_layer.get_cell_atlas_coords(foot_block_pos))
	if StaticLoad.get_block_name_by_id(foot_block_id) == "LADDER":
		if not is_on_ladder:
			is_on_ladder = true
	elif is_on_ladder:
		is_on_ladder = false

func update_local_gravity():
	if StaticLoad.is_muti_mode and StaticLoad.multiplayer.get_unique_id() != 1:
		return
	if StaticLoad.is_muti_mode:
		var entity_block_pos = StaticLoad.game.tile_map_layer.local_to_map(position-Vector2(0,24))
		var chunk_pos_tmp = StaticLoad.game.get_chunk_position(entity_block_pos)
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
	if StaticLoad.is_muti_mode and StaticLoad.multiplayer.get_unique_id() != 1:
		return
	if is_frozen:
		if velocity.length() > StaticLoad.FLOAT_DELTA:
			velocity = Vector2(0, 0)
		return
	if is_dead:
		return
	var current_block_pos = StaticLoad.game.tile_map_layer.local_to_map(position)
	if current_block_pos[0] == target_pos[0]:
		if move_state != "idle":
			move_state = "idle"
			expected_velocity.x = 0
		return
	elif current_block_pos[0] != target_pos[0]:
		if current_block_pos[0] < target_pos[0] and face_state == -1:
			face_state = 1
		elif current_block_pos[0] > target_pos[0] and face_state == 1:
			face_state = -1
		if not is_down_area_colliding or (is_down_area_colliding and not is_up_area_colliding):
			if not is_down_area_colliding:
				if panic_timer > 0:
					move_state = "run"
				else:
					move_state = "walk"
			elif is_top_area_colliding:
				move_state = "idle"
		else:
			move_state = "idle"
	if move_state != "idle" and is_down_area_colliding and not is_up_area_colliding and not is_top_area_colliding:
		if not is_flying and is_on_floor():
			last_velocity = current_velocity
			current_velocity = velocity
			update_local_fall_damage_by_data()
			update_sound_by_data()
			if not is_dead:
				if velocity.y >= 0:
					velocity.y += jump_velocity
		elif is_flying:
			expected_velocity.y = jump_velocity * 0.7
	elif current_block_pos[1] < target_pos[1]:
		if is_flying:
			expected_velocity.y = jump_velocity * 0.7
		elif is_on_ladder:
			expected_velocity.y = -move_speed
	elif current_block_pos[1] > target_pos[1]:
		if is_flying:
			expected_velocity.y = -jump_velocity * 0.7
		elif is_on_ladder:
			expected_velocity.y = move_speed
	elif not is_flying and is_on_ladder:
		expected_velocity.y = 0
	
	if move_state == "run":
		if is_in_water:
			expected_velocity.x = face_state * move_speed
		else:
			expected_velocity.x = face_state * move_speed * 2
	elif move_state == "walk":
		if is_in_water:
			expected_velocity.x = face_state * move_speed * 0.5
		else:
			expected_velocity.x = face_state * move_speed
	elif move_state == "idle":
		expected_velocity.x = 0
	
	if velocity.length() > StaticLoad.FLOAT_DELTA:
		var entity_block_pos = StaticLoad.game.tile_map_layer.local_to_map(position)
		var block_id_down = StaticLoad.get_block_id_by_atlas_coords(StaticLoad.game.tile_map_layer.get_cell_atlas_coords(entity_block_pos))
		if not StaticLoad.get_is_untouchable_by_id(block_id_down):
			velocity = Vector2(0, 0)

func update_state_dict():
	state_dict["face_state"] = face_state
	state_dict["move_state"] = move_state
	state_dict["is_flying"] = is_flying
	state_dict["is_frozen"] = is_frozen
	state_dict["position"] = position
	state_dict["current_velocity"] = current_velocity
	state_dict["health"] = health

func update_local_state_dict():
	if not StaticLoad.is_muti_mode or StaticLoad.multiplayer.get_unique_id() != 1:
		return
	update_state_dict()

# 不会由客户端上传，仅会在服务端更新
func update_local_changed_state_dict():
	if not StaticLoad.is_muti_mode:
		return
	if StaticLoad.multiplayer.get_unique_id() != 1 and StaticLoad.multiplayer.get_unique_id() != 1:
		return
	for key in state_dict:
		if not last_state_dict.has(key) or last_state_dict[key] != state_dict[key]:
			last_state_dict[key] = state_dict[key]
			if StaticLoad.multiplayer.get_unique_id() == 1:
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
	#for key in changed_state_dict:	
		#if key == "render_chunk":
			#var render_chunk_tmp = changed_state_dict[key]
			#if render_chunk_tmp > StaticLoad.RENDER_CHUNK_MAX:
				#render_chunk_tmp = StaticLoad.RENDER_CHUNK_MAX
			#if render_chunk_tmp < StaticLoad.RENDER_CHUNK_MIN:
				#render_chunk_tmp = StaticLoad.RENDER_CHUNK_MIN
			#changed_state_dict[key] = render_chunk_tmp
			#is_need_resend = true
		#elif key == "position":
			#if position.distance_to(changed_state_dict[key]) > StaticLoad.POSITION_MAX_DIFFERENCE:
				#changed_state_dict[key] = position
				#is_need_resend = true
	if is_need_resend:
		StaticLoad.rpc_entity_func_by_uuid(uuid, "apply_changed_state_dict", changed_state_dict, "others", true)

func apply_changed_state_dict(got_changed_state_dict):
	for key in got_changed_state_dict.duplicate():
		if trigger_change_state_list.has(key):
			continue
		if key == "position":
			var tween = get_tree().create_tween()
			tween.tween_property(self, "position", got_changed_state_dict[key], 0.001)
		else:
			self.set(key, got_changed_state_dict[key])

func update_last_velocity():
	last_velocity = current_velocity

func update_current_velocity():
	if StaticLoad.is_muti_mode and StaticLoad.multiplayer.get_unique_id() != 1:
		return
	if velocity.x > StaticLoad.MAX_SPEED:
		velocity.x = StaticLoad.MAX_SPEED
	if velocity.y > StaticLoad.MAX_SPEED:
		velocity.y = StaticLoad.MAX_SPEED
	current_velocity = velocity

func update_entity_face_rotation():
	var current_rotation = entity_model.rotation_degrees
	var looking_at = Vector3(current_rotation.x, 90+turn_state*90*StaticLoad.TURN_STATE_SCALE_FACTOR, current_rotation.z)
	entity_model.rotation_degrees = looking_at

func set_name_label_modulate(color):
	name_label.modulate = color

func get_damage(args):
	var damage = args[0]
	var side = args[1]
	if side == "left":
		velocity += Vector2(500, -400)
	elif side == "right":
		velocity += Vector2(-500, -400)
	if damage > 0:
		health_recover_timer = StaticLoad.HEALTH_RECOVER_TIME
	var final_damage = damage
	if final_damage > StaticLoad.DEFAULT_PLAYER_HEALTH:
		final_damage = damage
	health -= final_damage
	panic_timer = 5
	var rng = RandomNumberGenerator.new()
	var num1 = rng.randf()+0.5
	if num1 > 1:
		num1 = 1
	var num2 = rng.randf()-0.5
	if side == "right":
		num1 = -num1
	target_pos = StaticLoad.game.tile_map_layer.local_to_map(position)+Vector2i(int(num1*50),int(num2*40))
	if health <= 0:
		if hurt_tween != null:
			hurt_tween.stop()
		die()
	else:
		hurt_tween = get_tree().create_tween()
		hurt_tween.tween_method(set_shader_blink_intensity, 0.6, 0, StaticLoad.HURT_TIME)
		StaticLoad.game.sound_audio_manager.play_random_audio_at_position("pig", "say", position, 1)

func set_z_rotation(got_rotation):
	entity_model.rotation.z = deg_to_rad(got_rotation)

func stop_move():
	move_state = "idle"
	expected_velocity.x = 0

func die():
	is_dead = true
	stop_move()
	set_shader_blink_intensity(0.6)
	var tween1 = get_tree().create_tween()
	tween1.tween_method(set_name_label_modulate, Color(1,1,1,1), Color(1,1,1,0), StaticLoad.DISSOLVE_TIME)
	StaticLoad.game.sound_audio_manager.play_random_audio_at_position("pig", "death", position, 1)
	var tween2 = get_tree().create_tween()
	tween2.tween_method(set_z_rotation, 0, 90, StaticLoad.DISSOLVE_TIME)
	await get_tree().create_timer(StaticLoad.DISSOLVE_TIME*3).timeout
	StaticLoad.game.summon_death_particle(position)
	queue_free()

func set_entity_model_skin_by_texture(got_skin_texture):
	var entity_material = load("res://Assets/Materials/Pig.tres").duplicate(true)
	entity_material.albedo_texture = got_skin_texture
	entity_model_mesh.mesh.surface_set_material(0, entity_material)

func set_shader_blink_intensity(value):
	entity_sprite.material.set_shader_parameter("blink_intensity", value)

func set_shader_dissolve_intensity(value):
	entity_sprite.material.set_shader_parameter("dissolve_intensity", value)

func set_shader_transparent_intensity(value):
	entity_sprite.material.set_shader_parameter("transparent_intensity", value)

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
	return entity_name

func get_chunk_pos():
	return chunk_pos

func get_is_dead():
	return is_dead
	
func destroy_entity(args):
	if not StaticLoad.is_muti_mode or (StaticLoad.is_muti_mode and StaticLoad.multiplayer.get_unique_id() == 1):
		if StaticLoad.game.loaded_chunks.has(str(chunk_pos[0])+"."+str(chunk_pos[1])):
			StaticLoad.game.loaded_chunks[str(chunk_pos[0])+"."+str(chunk_pos[1])].entity_list.erase(uuid)
	queue_free()

func _on_up_area_body_entered(body: Node2D) -> void:
	if body.name != "TileMapLayer":
		return
	is_up_area_colliding = true

func _on_up_area_body_exited(body: Node2D) -> void:
	if body.name != "TileMapLayer":
		return
	is_up_area_colliding = false

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
