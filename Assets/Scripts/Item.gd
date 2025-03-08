extends CharacterBody2D

@onready var animation_player = $AnimationPlayer
@onready var block_model = $SubViewportContainer/SubViewport/Block
@onready var item_model = $SubViewportContainer/SubViewport/Item
@onready var collide_area = $CollideArea
@onready var attract_area = $AttractArea

var uuid = UUID.v4()
var entity_type = "item"
var item_model_type = "block"
var item_name = "AIR"
var item_amount = 1
var attract_target = null
var no_collect_timer: float = StaticLoad.DEFAULT_NO_COLLECT_TIME

func _process(delta: float) -> void:
	move_and_slide()
	if StaticLoad.is_muti_mode and StaticLoad.multiplayer.get_unique_id()!=1:
		return
	if StaticLoad.is_muti_mode and StaticLoad.multiplayer.get_unique_id()==1:
		rpc("remote_update_position", position)
	update_gravity(delta)
	update_attraction(delta)
	update_no_collect_timer(delta)
	update_air_resistance(delta)

func update_air_resistance(delta):
	if abs(velocity.x) < 0.1:
		return
	if velocity.x > 0:
		if velocity.x < StaticLoad.AIR_RESISTANCE*delta:
			velocity.x = 0
		else:
			velocity.x -= StaticLoad.AIR_RESISTANCE*delta
	else:
		if velocity.x + StaticLoad.AIR_RESISTANCE*delta > 0:
			velocity.x = 0
		else:
			velocity.x += StaticLoad.AIR_RESISTANCE*delta

func update_no_collect_timer(delta):
	if no_collect_timer > 0:
		no_collect_timer -= delta
	elif no_collect_timer < 0:
		no_collect_timer = 0
		collide_area.monitoring = false
		attract_area.monitoring = false
		await get_tree().create_timer(0.001)
		collide_area.monitoring = true
		attract_area.monitoring = true
		
func update_attraction(delta):
	if attract_target != null:
		var distance = attract_target.position.x - position.x
		var movement = StaticLoad.ATTRACT_SPEED*delta*(abs(60/distance))
		if movement > abs(distance):
			movement = abs(distance)
		if distance > 0:
			position += Vector2(movement, 0)
		else:
			position -= Vector2(movement, 0)

func update_gravity(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta

func init(item_name, item_pos, item_amount, no_collect_time):
	self.name = str(uuid)
	self.item_name = item_name
	self.item_amount = item_amount
	self.no_collect_timer = no_collect_time
	position = item_pos
	refresh_model()
	if no_collect_timer == 0:
		for peer_id in StaticLoad.online_peer_ids:
			if abs(StaticLoad.online_peer_ids[peer_id].position.y - position.y) <= 10:
				if abs(StaticLoad.online_peer_ids[peer_id].position.x - position.x) <= 60:
					attract_target = StaticLoad.online_peer_ids[peer_id]
					break

func get_uuid():
	return uuid

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
		if item_amount >= 2:
			block_model.get_node("Mesh2").visible = true
		block_model.visible = true
	else:
		item_model_type = "item"
		var item_material = load("res://Assets/Materials/ItemModel.tres").duplicate(true)
		var texture = load("res://Assets/ResourcePacks/"+StaticLoad.game.resource_pack+"/Items/"+item_name.to_lower()+".png")
		item_material.albedo_texture = texture
		if texture == null:
			item_model.visible = true
			return
		item_model.get_node("Mesh").mesh.surface_set_material(0, item_material)
		if item_amount >= 2:
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
	if body.get_uuid() == self.get_uuid():
		return
	if not StaticLoad.is_muti_mode or (StaticLoad.is_muti_mode and StaticLoad.multiplayer.get_unique_id() == 1):
		if body.entity_type == "item":
			if body.item_name == self.item_name:
				if not StaticLoad.game.item_to_combine.has(body.get_uuid()):
					StaticLoad.game.item_to_combine[get_uuid()] = body.get_uuid()
		elif body.entity_type == "player":
			if no_collect_timer > 0:
				return
			if body.if_get_item_left(item_name, item_amount, 0, 36) < item_amount:
				var left_amount = body.get_item(item_name, item_amount, 0, 36, true)
				if not StaticLoad.is_muti_mode or (StaticLoad.is_muti_mode and StaticLoad.multiplayer_peer.get_unique_id()==body.player_peer_id):
					StaticLoad.game.refresh_item_grid(body.selected_item_grid)
					StaticLoad.game.refresh_inventory()
				body.switch_item_in_hand()
				if StaticLoad.is_muti_mode:
					body.rpc("remote_get_item", item_name, item_amount, 0, 36, true)
				if left_amount > 0:
					item_amount = left_amount
					refresh_model()
					if StaticLoad.is_muti_mode:
						rpc("remote_update_item", left_amount)
				else:
					queue_free()
					if StaticLoad.game.entities.find_key(self) != null:
						StaticLoad.game.entities.erase(self)
					if StaticLoad.is_muti_mode:
						rpc("remote_destroy")

func combine_item(target_item_uuid):
	var target_item = StaticLoad.game.items.get_node(str(target_item_uuid))
	if target_item == null:
		return
	if item_amount+target_item.item_amount <= StaticLoad.get_max_amount_by_name(item_name):
		item_amount = item_amount+target_item.item_amount
		if item_amount+target_item.item_amount >= 2:
			if item_model_type == "block":
				block_model.get_node("Mesh2").visible = true
			elif item_model_type == "item":
				item_model.get_node("Mesh2").visible = true
		velocity.x = (item_amount*velocity.x+target_item.item_amount*target_item.velocity.x)/(item_amount+target_item.item_amount)
		target_item.queue_free()
		if StaticLoad.game.entities.find_key(target_item) != null:
			StaticLoad.game.entities.erase(target_item)
	else:
		item_amount = StaticLoad.get_max_amount_by_name(item_name)
		if item_model_type == "block":
			block_model.get_node("Mesh2").visible = true
		elif item_model_type == "item":
			item_model.get_node("Mesh2").visible = true
		target_item.item_amount = item_amount+target_item.item_amount-StaticLoad.get_max_amount_by_name(item_name)
		if target_item.item_amount >= 2:
			if item_model_type == "block":
				block_model.get_node("Mesh2").visible = true
			elif item_model_type == "item":
				item_model.get_node("Mesh2").visible = true
		else:
			if item_model_type == "block":
				block_model.get_node("Mesh2").visible = false
			elif item_model_type == "item":
				item_model.get_node("Mesh2").visible = false

@rpc("authority", "call_remote", "reliable", 1)
func remote_combine_item(target_item_uuid):
	combine_item(target_item_uuid)

@rpc("authority", "call_remote", "reliable", 1)
func remote_destroy():
	queue_free()

@rpc("authority", "call_remote", "reliable", 1)
func remote_update_item(new_amount):
	item_amount = new_amount
	refresh_model()

@rpc("authority", "call_remote", "reliable", 1)
func remote_update_position(new_position):
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", new_position, StaticLoad.REFRESH_DELTA_TIME)
