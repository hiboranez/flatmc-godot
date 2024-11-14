extends AudioStreamPlayer

@onready var bgm1 = load("res://Assets//Sounds//Music//calm1.mp3") as AudioStream
@onready var bgm2 = load("res://Assets//Sounds//Music//calm2.mp3") as AudioStream
@onready var bgm3 = load("res://Assets//Sounds//Music//calm3.mp3") as AudioStream
@onready var bgm4 = load("res://Assets//Sounds//Music//hal1.mp3") as AudioStream
@onready var bgm5 = load("res://Assets//Sounds//Music//hal2.mp3") as AudioStream
@onready var bgm6 = load("res://Assets//Sounds//Music//hal3.mp3") as AudioStream
@onready var bgm7 = load("res://Assets//Sounds//Music//hal4.mp3") as AudioStream
@onready var bgm8 = load("res://Assets//Sounds//Music//nuance1.mp3") as AudioStream
@onready var bgm9 = load("res://Assets//Sounds//Music//nuance2.mp3") as AudioStream
@onready var bgm10 = load("res://Assets//Sounds//Music//piano1.mp3") as AudioStream

var bgm_list = []
var current_bgm = null

func _ready() -> void:
	bgm_list = [bgm1, bgm2, bgm3, bgm4, bgm5, bgm6, bgm7, bgm8, bgm9, bgm10]
	await get_tree().create_timer(0.5).timeout
	play_random_bgm()

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if not is_playing() and current_bgm:
		_on_AudioStreamPlayer2D_finished()

func _on_AudioStreamPlayer2D_finished() -> void:
	play_random_bgm()

func play_random_bgm() -> void:
	current_bgm = bgm_list[randi() % bgm_list.size()]
	stream = current_bgm
	play()
