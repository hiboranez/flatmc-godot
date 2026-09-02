extends Node2D
@onready var particle1 = $GPUParticles1
@onready var particle2 = $GPUParticles2
@onready var particle3 = $GPUParticles3
@onready var particle4 = $GPUParticles4
@onready var particle5 = $GPUParticles5
@onready var particle6 = $GPUParticles6
@onready var particle7 = $GPUParticles7
@onready var particle8 = $GPUParticles8

func init(got_position):
	position = got_position
	particle1.emitting = true
	particle2.emitting = true
	particle3.emitting = true
	particle4.emitting = true
	particle5.emitting = true
	particle6.emitting = true
	particle7.emitting = true
	particle8.emitting = true
	await get_tree().create_timer(3).timeout
	var tween = get_tree().create_tween()
	tween.tween_method(set_transparent_value, Color(1,1,1,1), Color(1,1,1,0), 1)
	await tween.finished
	queue_free()

func set_transparent_value(got_value):
	modulate = got_value
