extends Node2D
@onready var particle1 = $GPUParticles1
@onready var particle2 = $GPUParticles2
@onready var particle3 = $GPUParticles3
@onready var particle4 = $GPUParticles4
@onready var particle5 = $GPUParticles5

func init(got_position, type, item_name):
	position = got_position
	var texture
	if type == "item":
		texture = load("res://Assets/ResourcePacks/"+str(StaticLoad.game.resource_pack)+"/Items/"+item_name.to_lower()+".png") as Texture2D
	elif type == "block":
		texture = load("res://Assets/ResourcePacks/"+str(StaticLoad.game.resource_pack)+"/Blocks/"+item_name.to_lower()+".png") as Texture2D
		particle1.texture.set_region(Rect2(10, 1, 2, 2))
		particle2.texture.set_region(Rect2(4, 1, 2, 2))
		particle3.texture.set_region(Rect2(10, 7, 2, 2))
		particle4.texture.set_region(Rect2(4, 7, 2, 2))
		particle5.texture.set_region(Rect2(4, 7, 2, 2))
		position -= Vector2(0, 20)
	particle1.texture.atlas = texture
	particle2.texture.atlas = texture
	particle3.texture.atlas = texture
	particle4.texture.atlas = texture
	particle5.texture.atlas = texture
	particle1.emitting = true
	particle2.emitting = true
	particle3.emitting = true
	particle4.emitting = true
	particle5.emitting = true
	await get_tree().create_timer(3).timeout
	var tween = get_tree().create_tween()
	tween.tween_method(set_transparent_value, Color(1,1,1,1), Color(1,1,1,0), 1)
	await tween.finished
	queue_free()

func set_transparent_value(got_value):
	modulate = got_value
