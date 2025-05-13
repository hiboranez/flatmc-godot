extends CharacterBody2D

@onready var animation_player = $AnimationPlayer
@onready var block_model = $SubViewportContainer/SubViewport/Block
@onready var item_model = $SubViewportContainer/SubViewport/Item
@onready var item_top_model = $SubViewportContainer/SubViewport/ItemTop
@onready var collide_area = $CollideArea
@onready var attract_area = $AttractArea

# 实体变量
var uuid = UUID.v4()
var entity_type = "item"
var item_name = "AIR"
var chunk_pos = Vector2i(0, 0)
var health: int = 20
var is_dead = false

# 子类变量
var expected_velocity = Vector2i(0, 0)
var item_model_type = "block"
var item_amount = 1
var attract_target = null
var no_collect_timer: float = 2
var state_dict = {}
var last_state_dict = {}
var changed_state_dict = {}

func _ready() -> void:
	update_state_dict()

func _process(delta: float) -> void:
	# 通过接收的数据同步更新
	move_and_slide()
	
	# 本地更新
	update_local_state_dict()
	update_local_changed_state_dict()
	update_local_gravity()
	update_local_attraction()
	update_local_no_collect_timer()
	update_local_air_resistance()

func update_state_dict():
	state_dict["position"] = position

func update_local_state_dict():
	if not StaticLoad.is_muti_mode:
		return
	if not StaticLoad.multiplayer.get_unique_id() == 1:
		return
	update_state_dict()

func update_local_changed_state_dict():
	if not StaticLoad.is_muti_mode:
		return
	if not StaticLoad.multiplayer.get_unique_id() == 1:
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
			tween.tween_property(self, "position", got_changed_state_dict[key], StaticLoad.spt)
		else:	
			self.set(key, got_changed_state_dict[key])

func update_local_air_resistance():
	if StaticLoad.is_muti_mode and StaticLoad.multiplayer.get_unique_id()!=1:
		return
	if abs(velocity.x) < 0.1:
		return
	var move_speed = StaticLoad.AIR_RESISTANCE/10.0
	velocity = GameCalculator.calculate_velocity_by_data(get_process_delta_time(), velocity, expected_velocity, move_speed, false, false)
	#var delta = get_process_delta_time()
	#if velocity.x > 0:
		#if velocity.x < StaticLoad.AIR_RESISTANCE*delta:
			#velocity.x = 0
		#else:
			#velocity.x -= StaticLoad.AIR_RESISTANCE*delta
	#else:
		#if velocity.x + StaticLoad.AIR_RESISTANCE*delta > 0:
			#velocity.x = 0
		#else:
			#velocity.x += StaticLoad.AIR_RESISTANCE*delta

func update_local_no_collect_timer():
	if StaticLoad.is_muti_mode and StaticLoad.multiplayer.get_unique_id()!=1:
		return
	if no_collect_timer > 0:
		no_collect_timer -= get_process_delta_time()
	elif no_collect_timer < 0:
		no_collect_timer = 0
		collide_area.monitoring = false
		attract_area.monitoring = false
		await get_tree().create_timer(0.001)
		collide_area.monitoring = true
		attract_area.monitoring = true
		
func update_local_attraction():
	if StaticLoad.is_muti_mode and StaticLoad.multiplayer.get_unique_id()!=1:
		return
	if attract_target != null:
		var distance = attract_target.position.x - position.x
		var movement = StaticLoad.ATTRACT_SPEED*get_process_delta_time()*(abs(60/distance))
		if movement > abs(distance):
			movement = abs(distance)
		if distance > 0:
			position += Vector2(movement, 0)
		else:
			position -= Vector2(movement, 0)

func update_local_gravity():
	if StaticLoad.is_muti_mode and StaticLoad.multiplayer.get_unique_id()!=1:
		return
	if not is_on_floor():
		velocity += get_gravity() * get_process_delta_time()

func init(args):
	uuid = args[0]
	item_name = args[1]
	position = args[2]
	item_amount = args[3]
	no_collect_timer = args[4]
	velocity.x = args[5]
	name = str(uuid)
	chunk_pos = StaticLoad.game.get_chunk_position(StaticLoad.game.tile_map_layer.local_to_map(position))
	if not StaticLoad.is_muti_mode or (StaticLoad.is_muti_mode and StaticLoad.multiplayer.get_unique_id() == 1):
		StaticLoad.game.loaded_chunks[str(chunk_pos[0])+"."+str(chunk_pos[1])].entity_list.append(uuid)
		StaticLoad.game.loaded_chunks[str(chunk_pos[0])+"."+str(chunk_pos[1])].is_to_save = true
	else:
		StaticLoad.rpc_id(1, "request_for_mark_revised_chunk", chunk_pos)
	refresh_model()
	if no_collect_timer == 0:
		for peer_id in StaticLoad.player_peer_dict:
			if abs(StaticLoad.player_peer_dict[peer_id].position.y - position.y) <= 10:
				if abs(StaticLoad.player_peer_dict[peer_id].position.x - position.x) <= 60:
					attract_target = StaticLoad.player_peer_dict[peer_id]
					break

func update_item(got_item_amount):
	item_amount = got_item_amount
	refresh_model()

func get_uuid():
	return uuid

func get_entity_type():
	return entity_type

func get_entity_name():
	return item_name

func get_chunk_pos():
	return chunk_pos

func get_health():
	return health

func get_is_dead():
	return is_dead

func refresh_model():
	if StaticLoad.block_ids.has(item_name) and StaticLoad.get_item_model_type_by_name(item_name) >= 3:
		item_model_type = "block"
		var block_material = load("res://Assets/Materials/BlockModel.tres").duplicate(true)
		var texture = load("res://Assets/ResourcePacks/"+StaticLoad.game.resource_pack+"/ModelBlocks/"+item_name.to_lower()+".png")
		if texture == null:
			block_model.visible = true
			return
		block_material.albedo_texture = texture
		block_model.get_node("Mesh").mesh.surface_set_material(0, block_material)
		if item_amount >= 2 and not StaticLoad.get_is_durable_by_name(item_name):
			block_model.get_node("Mesh2").visible = true
		block_model.visible = true
	else:
		item_model_type = "item"
		if item_name.contains("SPAWN_EGG"):
			var item_material = load("res://Assets/Materials/ItemModel.tres").duplicate(true)
			var texture = load("res://Assets/ResourcePacks/"+StaticLoad.game.resource_pack+"/Items/spawn_egg.png")
			item_material.albedo_texture = texture
			if texture == null:
				item_model.visible = true
				return
			item_model.get_node("Mesh").mesh.surface_set_material(0, item_material)
			var item_top_material = load("res://Assets/Materials/ItemModel.tres").duplicate(true)
			var texture_top = load("res://Assets/ResourcePacks/"+StaticLoad.game.resource_pack+"/Items/spawn_egg_overlay.png")
			item_top_material.albedo_texture = texture_top
			if texture_top == null:
				item_top_model.visible = true
				return
			item_top_model.get_node("Mesh").mesh.surface_set_material(0, item_top_material)
			if StaticLoad.spawn_egg_colors.has(item_name):
				var color_info = StaticLoad.spawn_egg_colors[item_name]
				item_material.albedo_color = Color.html(color_info[0])
				item_top_material.albedo_color = Color.html(color_info[1])
			if item_amount >= 2 and not StaticLoad.get_is_durable_by_name(item_name):
				item_model.get_node("Mesh2").visible = true
				item_top_model.get_node("Mesh2").visible = true
			item_model.visible = true
			item_top_model.visible = true
		else:
			var item_material = load("res://Assets/Materials/ItemModel.tres").duplicate(true)
			var texture = load("res://Assets/ResourcePacks/"+StaticLoad.game.resource_pack+"/Items/"+item_name.to_lower()+".png")
			item_material.albedo_texture = texture
			if texture == null:
				item_model.visible = true
				return
			item_model.get_node("Mesh").mesh.surface_set_material(0, item_material)
			if item_amount >= 2 and not StaticLoad.get_is_durable_by_name(item_name):
				item_model.get_node("Mesh2").visible = true
			item_model.visible = true

func on_body_attract_entered(body: Node) -> void:
	if not body.has_method("get_uuid"):
		return
	if body.get_uuid() == null:
		return
	if body.get_uuid() == self.get_uuid():
		return
	if no_collect_timer > 0:
		return
	if body.entity_type != "player":
		return
	attract_target = body

func on_body_attract_exited(body: Node) -> void:
	if not body.has_method("get_uuid"):
		return
	if body.get_uuid() == null:
		return
	if body.get_uuid() == self.get_uuid():
		return
	if no_collect_timer > 0:
		return
	if body.entity_type != "player":
		return
	if body == attract_target:
		attract_target = null

func on_body_collide_entered(body: Node) -> void:
	if not body.has_method("get_uuid"):
		return
	if body.get_uuid() == null:
		return
	if body.get_uuid() == uuid:
		return
	if not StaticLoad.is_muti_mode or (StaticLoad.is_muti_mode and StaticLoad.multiplayer.get_unique_id() == 1):
		if body.entity_type == "item":
			if body.item_name == self.item_name:
				if not StaticLoad.game.item_to_combine.has(body.get_uuid()):
					StaticLoad.game.item_to_combine[uuid] = body.get_uuid()
		elif body.entity_type == "player":
			if no_collect_timer > 0:
				return
			if body.if_get_item_left(item_name, item_amount, 0, 36) < item_amount:
				var left_amount = body.get_item([item_name, item_amount, 0, 36, true])
				if StaticLoad.is_muti_mode:
					StaticLoad.rpc_entity_func_by_uuid(body.get_uuid(), "get_item", [item_name, item_amount, 0, 36, true], "others", true)
				if left_amount > 0:
					item_amount = left_amount
					refresh_model()
					if StaticLoad.is_muti_mode:
						StaticLoad.rpc_entity_func_by_uuid(body.get_uuid(), "update_item", left_amount, "others", true)
				else:
					if StaticLoad.game.entities.find_key(self):
						StaticLoad.game.entities.erase(self)
					destroy_entity([])
					if StaticLoad.is_muti_mode:
						StaticLoad.rpc_entity_func_by_uuid(get_uuid(), "destroy_entity", [], "others", true)

func combine_item(target_item_uuid):
	if not StaticLoad.game.items.has_node(str(target_item_uuid)):
		return
	if StaticLoad.get_is_durable_by_name(item_name):
		return
	var target_item = StaticLoad.game.items.get_node(str(target_item_uuid))
	if target_item == null:
		return
	if item_amount+target_item.item_amount <= StaticLoad.get_max_amount_by_name(item_name):
		item_amount = item_amount+target_item.item_amount
		if item_amount+target_item.item_amount >= 2 and not StaticLoad.get_is_durable_by_name(item_name):
			if item_model_type == "block":
				block_model.get_node("Mesh2").visible = true
			elif item_model_type == "item":
				item_model.get_node("Mesh2").visible = true
				if item_name.contains("SPAWN_EGG"):
					item_top_model.get_node("Mesh2").visible = true
		velocity.x = (item_amount*velocity.x+target_item.item_amount*target_item.velocity.x)/(item_amount+target_item.item_amount)
		target_item.destroy_entity([])
		if StaticLoad.game.entities.find_key(target_item) != null:
			StaticLoad.game.entities.erase(target_item)
	else:
		item_amount = StaticLoad.get_max_amount_by_name(item_name)
		if item_model_type == "block" and not StaticLoad.get_is_durable_by_name(item_name):
			block_model.get_node("Mesh2").visible = true
		elif item_model_type == "item" and not StaticLoad.get_is_durable_by_name(item_name):
			item_model.get_node("Mesh2").visible = true
			if item_name.contains("SPAWN_EGG"):
				item_top_model.get_node("Mesh2").visible = true
		target_item.item_amount = item_amount+target_item.item_amount-StaticLoad.get_max_amount_by_name(item_name)
		if target_item.item_amount >= 2:
			if item_model_type == "block" and not StaticLoad.get_is_durable_by_name(item_name):
				block_model.get_node("Mesh2").visible = true
			elif item_model_type == "item" and not StaticLoad.get_is_durable_by_name(item_name):
				item_model.get_node("Mesh2").visible = true
				if item_name.contains("SPAWN_EGG"):
					item_top_model.get_node("Mesh2").visible = true
		else:
			if item_model_type == "block" and not StaticLoad.get_is_durable_by_name(item_name):
				block_model.get_node("Mesh2").visible = false
			elif item_model_type == "item" and not StaticLoad.get_is_durable_by_name(item_name):
				item_model.get_node("Mesh2").visible = false
				if item_name.contains("SPAWN_EGG"):
					item_top_model.get_node("Mesh2").visible = false

func destroy_entity(args):
	if not StaticLoad.is_muti_mode or (StaticLoad.is_muti_mode and StaticLoad.multiplayer.get_unique_id() == 1):
		if StaticLoad.game.loaded_chunks.has(str(chunk_pos[0])+"."+str(chunk_pos[1])):
			StaticLoad.game.loaded_chunks[str(chunk_pos[0])+"."+str(chunk_pos[1])].entity_list.erase(uuid)
	queue_free()
