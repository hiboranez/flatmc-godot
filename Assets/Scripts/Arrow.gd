extends CharacterBody2D

@onready var sprite_2d = $Sprite2D
@onready var collide_area = $CollideArea
@onready var fire_animated_sprite = $FireAnimatedSprite2D

# 实体变量
var uuid = UUID.v4()
var entity_type = "arrow"
var entity_name = str(uuid)
var chunk_pos = Vector2i(0, 0)
var last_pos = position
var health: int = 20
var is_dead = false
var is_frozen = false
var is_on_fire = false
var fire_lasting_timer: float = 0
var fire_damage_timer: float = 4

# 子类变量
var current_velocity = velocity
var shooter_type = "null"
var shooter_uuid = "null"
var shooter_name = "null"
var is_entity_hit = false
var is_undead_damage = true
var is_block_attached = false
var disappear_timer: float = 60.0
var expected_velocity = Vector2i(0, 0)
var state_dict = {}
var last_state_dict = {}
var changed_state_dict = {}

func _ready() -> void:
	update_state_dict()

func _process(delta: float) -> void:
	# 通过接收的数据同步更新
	move_and_slide()
	update_animation_by_data()
	# 仅在服务端的本地更新
	update_local_disappear_timer()
	update_current_velocity()
	update_local_fire_damage_by_data()
	# 本地更新
	update_local_state_dict()
	update_local_changed_state_dict()
	update_local_gravity()

func init(args):
	uuid = args[0]
	entity_name = args[1]
	position = args[2]
	velocity = args[3]
	current_velocity = args[4]
	sprite_2d.set_rotation_degrees(rad_to_deg(current_velocity.angle()))
	shooter_type = args[5]
	shooter_uuid = args[6]
	shooter_name = args[7]
	is_undead_damage = args[8]
	name = str(uuid)
	chunk_pos = StaticLoad.game.get_chunk_position(StaticLoad.game.tile_map_layer.local_to_map(position))
	if not StaticLoad.is_muti_mode or (StaticLoad.is_muti_mode and multiplayer.get_unique_id() == 1):
		if StaticLoad.game.loaded_chunks.has(str(chunk_pos[0])+"."+str(chunk_pos[1])):
			StaticLoad.game.loaded_chunks[str(chunk_pos[0])+"."+str(chunk_pos[1])].entity_list.append(uuid)
			StaticLoad.game.loaded_chunks[str(chunk_pos[0])+"."+str(chunk_pos[1])].is_to_save = true
	else:
		StaticLoad.rpc_id(1, "request_for_mark_revised_chunk", chunk_pos)

func update_current_velocity():
	if StaticLoad.is_muti_mode and multiplayer.get_unique_id() != 1:
		return
	if current_velocity.x != 0 and velocity.y == 0:
		velocity.x = 0
	if velocity.x != 0:
		current_velocity = velocity

func update_local_disappear_timer():
	if StaticLoad.is_muti_mode and multiplayer.get_unique_id() != 1:
		return
	if shooter_type == "player":
		return
	if disappear_timer > 0:
		disappear_timer -= get_process_delta_time()
	else:
		if StaticLoad.is_muti_mode:
			StaticLoad.rpc_entity_func_by_uuid(get_uuid(), "destroy_entity", [], "others", true)
		destroy_entity([])
	
func update_local_fire_damage_by_data():
	if StaticLoad.is_muti_mode and multiplayer.get_unique_id() != 1:
		return
	if fire_lasting_timer <= 0 and is_on_fire:
		is_on_fire = false
	if fire_lasting_timer > 0 and not is_on_fire:
		is_on_fire = true
		fire_damage_timer = 4
	if fire_lasting_timer > 0:
		fire_lasting_timer -= get_process_delta_time()
	elif fire_lasting_timer < 0:
		fire_lasting_timer = 0
	if fire_lasting_timer <= 0:
		return
	if fire_damage_timer > 0:
		fire_damage_timer -= get_process_delta_time()
	elif fire_damage_timer <= 0:
		if StaticLoad.is_muti_mode:
			StaticLoad.rpc_entity_func_by_uuid(get_uuid(), "destroy_entity", [], "others", true)
		destroy_entity([])
		

func update_animation_by_data():
	if current_velocity.length() > 0:
		if velocity.length() > 0 or (StaticLoad.is_muti_mode and multiplayer.get_unique_id() != 1):
			sprite_2d.set_rotation_degrees(rad_to_deg(current_velocity.angle()))
	if is_on_fire and not fire_animated_sprite.visible:
		fire_animated_sprite.visible = true
		if not fire_animated_sprite.is_playing():
			fire_animated_sprite.play()
	if not is_on_fire and fire_animated_sprite.visible:
		fire_animated_sprite.visible = false
		if fire_animated_sprite.is_playing():
			fire_animated_sprite.stop()

func update_state_dict():
	state_dict["position"] = position
	state_dict["is_on_fire"] = is_on_fire
	state_dict["current_velocity"] = current_velocity

func update_local_state_dict():
	if not StaticLoad.is_muti_mode:
		return
	if not multiplayer.get_unique_id() == 1:
		return
	update_state_dict()

func update_local_changed_state_dict():
	if not StaticLoad.is_muti_mode:
		return
	if not multiplayer.get_unique_id() == 1:
		return
	for key in state_dict:
		if not last_state_dict.has(key) or last_state_dict[key] != state_dict[key]:
			last_state_dict[key] = state_dict[key]
			changed_state_dict[key] = state_dict[key]

func rectify_changed_state_dict():
	for key in changed_state_dict:	
		if key == "position":
			if position.distance_to(changed_state_dict[key]) > StaticLoad.POSITION_MAX_DIFFERENCE:
				changed_state_dict[key] = position

func apply_changed_state_dict(got_changed_state_dict):
	for key in got_changed_state_dict:
		if key == "position":
			var tween = get_tree().create_tween()
			tween.tween_property(self, "position", got_changed_state_dict[key], StaticLoad.DISPATCH_DELTA_TIME)
		else:	
			self.set(key, got_changed_state_dict[key])

func update_local_gravity():
	if StaticLoad.is_muti_mode and multiplayer.get_unique_id()!=1:
		return
	if is_block_attached:
		return
	if is_frozen:
		return
	if not is_on_floor():
		velocity += get_gravity() * get_process_delta_time()

func get_uuid():
	return uuid

func get_entity_type():
	return entity_type

func get_entity_name():
	return entity_name

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

func destroy_entity(args):
	if not StaticLoad.is_muti_mode or (StaticLoad.is_muti_mode and multiplayer.get_unique_id() == 1):
		if StaticLoad.game.loaded_chunks.has(str(chunk_pos[0])+"."+str(chunk_pos[1])):
			StaticLoad.game.loaded_chunks[str(chunk_pos[0])+"."+str(chunk_pos[1])].entity_list.erase(uuid)
	queue_free()

func hit_block(args):
	StaticLoad.game.sound_audio_manager.play_random_audio_at_position("random", "bow_hit", position, 1)
	is_block_attached = true
	velocity = Vector2(0, 0)

func _on_collide_area_body_entered(body: Node2D) -> void:
	if StaticLoad.is_muti_mode and multiplayer.get_unique_id() != 1:
		return
	if is_entity_hit:
		return
	if body.name == "TileMapLayer":
		hit_block([])
		if StaticLoad.is_muti_mode:
			StaticLoad.rpc_entity_func_by_uuid(uuid, hit_block, [], "others", true)
	if not body.has_method("get_uuid"):
		return
	if body.get_uuid() == null:
		return
	if body.get_uuid() == uuid or body.get_entity_type() == "item" or body.get_entity_type() == "arrow":
		return
	if body.get_entity_type() == "player" and is_block_attached and shooter_type == "player":
		if body.if_get_item_left("ARROW", 1, 0, 36) == 0:
			body.get_item(["ARROW", 1, 0, 36, true])
			if StaticLoad.is_muti_mode:
				StaticLoad.rpc_entity_func_by_uuid(body.get_uuid(), "get_item", ["ARROW", 1, 0, 36, true], "others", true)
			if StaticLoad.game.entities.find_key(self):
				StaticLoad.game.entities.erase(self)
			if StaticLoad.is_muti_mode:
				StaticLoad.rpc_entity_func_by_uuid(get_uuid(), "destroy_entity", [], "others", true)
			destroy_entity([])
			return
	if body.get_entity_type() == "player" and body.gamemode == "creative":
		velocity = Vector2(0, 0)
		return
	if body.get_is_dead():
		return
	if is_block_attached or is_frozen:
		return
	if not is_undead_damage and StaticLoad.undead_mob_list.has(body.get_entity_type()):
		return
	var side = "left"
	if current_velocity.x < 0:
		side = "right"
	var damage = int(abs(current_velocity.length()) / 300)
	if shooter_type != "player":
		damage /= 3.0
	if damage <= 0:
		damage = 1
		return
	if body.get_entity_type() == "player":
		body.rpc_damage([damage, side, body.get_health(), "arrow_attack", shooter_type+"."+shooter_uuid+"."+shooter_name], true)
	body.get_damage([damage, side, body.get_health(), "arrow_attack", shooter_type+"."+shooter_uuid+"."+shooter_name])
	if is_on_fire and not body.get_is_on_fire():
		body.is_on_fire = true
		body.fire_lasting_timer = 8
	if shooter_type == "player":
		var player_tmp = StaticLoad.game.entities[shooter_uuid]
		if player_tmp != null:
			if player_tmp.player_peer_id == 1:
				player_tmp.play_successful_hit_audio([])
			else:
				StaticLoad.rpc_entity_func_by_uuid(shooter_uuid, "play_successful_hit_audio", [], [player_tmp.player_peer_id], true)
	is_entity_hit = true
	if StaticLoad.is_muti_mode:
		StaticLoad.rpc_entity_func_by_uuid(get_uuid(), "destroy_entity", [], "others", true)
	destroy_entity([])

func _on_collide_area_body_exited(body: Node2D) -> void:
	if StaticLoad.is_muti_mode and multiplayer.get_unique_id() != 1:
		return
	if body.name == "TileMapLayer":
		is_block_attached = false
