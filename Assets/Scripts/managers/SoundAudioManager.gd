extends Node2D

@onready var select = load("res://Assets//Sounds//GUI//select.mp3") as AudioStream
@onready var toast = load("res://Assets//Sounds//GUI//toast.wav") as AudioStream
@onready var pop = load("res://Assets//Sounds//Player//pop.mp3") as AudioStream
@onready var hurt = load("res://Assets//Sounds//Player//hurt.mp3") as AudioStream
@onready var hit1 = load("res://Assets//Sounds//Damage//hit1.mp3") as AudioStream
@onready var hit2 = load("res://Assets//Sounds//Damage//hit2.mp3") as AudioStream
@onready var hit3 = load("res://Assets//Sounds//Damage//hit3.mp3") as AudioStream
@onready var dig_cloth1 = load("res://Assets//Sounds//Dig//cloth1.mp3") as AudioStream
@onready var dig_cloth2 = load("res://Assets//Sounds//Dig//cloth2.mp3") as AudioStream
@onready var dig_cloth3 = load("res://Assets//Sounds//Dig//cloth3.mp3") as AudioStream
@onready var dig_cloth4 = load("res://Assets//Sounds//Dig//cloth4.mp3") as AudioStream
@onready var dig_grass1 = load("res://Assets//Sounds//Dig//grass1.mp3") as AudioStream
@onready var dig_grass2 = load("res://Assets//Sounds//Dig//grass2.mp3") as AudioStream
@onready var dig_grass3 = load("res://Assets//Sounds//Dig//grass3.mp3") as AudioStream
@onready var dig_grass4 = load("res://Assets//Sounds//Dig//grass4.mp3") as AudioStream
@onready var dig_gravel1 = load("res://Assets//Sounds//Dig//gravel1.mp3") as AudioStream
@onready var dig_gravel2 = load("res://Assets//Sounds//Dig//gravel2.mp3") as AudioStream
@onready var dig_gravel3 = load("res://Assets//Sounds//Dig//gravel3.mp3") as AudioStream
@onready var dig_gravel4 = load("res://Assets//Sounds//Dig//gravel4.mp3") as AudioStream
@onready var dig_sand1 = load("res://Assets//Sounds//Dig//sand1.mp3") as AudioStream
@onready var dig_sand2 = load("res://Assets//Sounds//Dig//sand2.mp3") as AudioStream
@onready var dig_sand3 = load("res://Assets//Sounds//Dig//sand3.mp3") as AudioStream
@onready var dig_sand4 = load("res://Assets//Sounds//Dig//sand4.mp3") as AudioStream
@onready var dig_snow1 = load("res://Assets//Sounds//Dig//snow1.mp3") as AudioStream
@onready var dig_snow2 = load("res://Assets//Sounds//Dig//snow2.mp3") as AudioStream
@onready var dig_snow3 = load("res://Assets//Sounds//Dig//snow3.mp3") as AudioStream
@onready var dig_snow4 = load("res://Assets//Sounds//Dig//snow4.mp3") as AudioStream
@onready var dig_stone1 = load("res://Assets//Sounds//Dig//stone1.mp3") as AudioStream
@onready var dig_stone2 = load("res://Assets//Sounds//Dig//stone2.mp3") as AudioStream
@onready var dig_stone3 = load("res://Assets//Sounds//Dig//stone3.mp3") as AudioStream
@onready var dig_stone4 = load("res://Assets//Sounds//Dig//stone4.mp3") as AudioStream
@onready var dig_wood1 = load("res://Assets//Sounds//Dig//wood1.mp3") as AudioStream
@onready var dig_wood2 = load("res://Assets//Sounds//Dig//wood2.mp3") as AudioStream
@onready var dig_wood3 = load("res://Assets//Sounds//Dig//wood3.mp3") as AudioStream
@onready var dig_glass1 = load("res://Assets//Sounds//Random//glass1.mp3") as AudioStream
@onready var dig_glass2 = load("res://Assets//Sounds//Random//glass2.mp3") as AudioStream
@onready var dig_glass3 = load("res://Assets//Sounds//Random//glass3.mp3") as AudioStream
@onready var dig_wood4 = load("res://Assets//Sounds//Dig//wood4.mp3") as AudioStream
@onready var step_cloth1 = load("res://Assets//Sounds//Step//cloth1.mp3") as AudioStream
@onready var step_cloth2 = load("res://Assets//Sounds//Step//cloth2.mp3") as AudioStream
@onready var step_cloth3 = load("res://Assets//Sounds//Step//cloth3.mp3") as AudioStream
@onready var step_cloth4 = load("res://Assets//Sounds//Step//cloth4.mp3") as AudioStream
@onready var step_grass1 = load("res://Assets//Sounds//Step//grass1.mp3") as AudioStream
@onready var step_grass2 = load("res://Assets//Sounds//Step//grass2.mp3") as AudioStream
@onready var step_grass3 = load("res://Assets//Sounds//Step//grass3.mp3") as AudioStream
@onready var step_grass4 = load("res://Assets//Sounds//Step//grass4.mp3") as AudioStream
@onready var step_grass5 = load("res://Assets//Sounds//Step//grass5.mp3") as AudioStream
@onready var step_grass6 = load("res://Assets//Sounds//Step//grass6.mp3") as AudioStream
@onready var step_gravel1 = load("res://Assets//Sounds//Step//gravel1.mp3") as AudioStream
@onready var step_gravel2 = load("res://Assets//Sounds//Step//gravel2.mp3") as AudioStream
@onready var step_gravel3 = load("res://Assets//Sounds//Step//gravel3.mp3") as AudioStream
@onready var step_gravel4 = load("res://Assets//Sounds//Step//gravel4.mp3") as AudioStream
@onready var step_ladder1 = load("res://Assets//Sounds//Step//ladder1.mp3") as AudioStream
@onready var step_ladder2 = load("res://Assets//Sounds//Step//ladder2.mp3") as AudioStream
@onready var step_ladder3 = load("res://Assets//Sounds//Step//ladder3.mp3") as AudioStream
@onready var step_ladder4 = load("res://Assets//Sounds//Step//ladder4.mp3") as AudioStream
@onready var step_ladder5 = load("res://Assets//Sounds//Step//ladder5.mp3") as AudioStream
@onready var step_sand1 = load("res://Assets//Sounds//Step//sand1.mp3") as AudioStream
@onready var step_sand2 = load("res://Assets//Sounds//Step//sand2.mp3") as AudioStream
@onready var step_sand3 = load("res://Assets//Sounds//Step//sand3.mp3") as AudioStream
@onready var step_sand4 = load("res://Assets//Sounds//Step//sand4.mp3") as AudioStream
@onready var step_sand5 = load("res://Assets//Sounds//Step//sand5.mp3") as AudioStream
@onready var step_snow1 = load("res://Assets//Sounds//Step//snow1.mp3") as AudioStream
@onready var step_snow2 = load("res://Assets//Sounds//Step//snow2.mp3") as AudioStream
@onready var step_snow3 = load("res://Assets//Sounds//Step//snow3.mp3") as AudioStream
@onready var step_snow4 = load("res://Assets//Sounds//Step//snow4.mp3") as AudioStream
@onready var step_stone1 = load("res://Assets//Sounds//Step//stone1.mp3") as AudioStream
@onready var step_stone2 = load("res://Assets//Sounds//Step//stone2.mp3") as AudioStream
@onready var step_stone3 = load("res://Assets//Sounds//Step//stone3.mp3") as AudioStream
@onready var step_stone4 = load("res://Assets//Sounds//Step//stone4.mp3") as AudioStream
@onready var step_stone5 = load("res://Assets//Sounds//Step//stone5.mp3") as AudioStream
@onready var step_stone6 = load("res://Assets//Sounds//Step//stone6.mp3") as AudioStream
@onready var step_wood1 = load("res://Assets//Sounds//Step//wood1.mp3") as AudioStream
@onready var step_wood2 = load("res://Assets//Sounds//Step//wood2.mp3") as AudioStream
@onready var step_wood3 = load("res://Assets//Sounds//Step//wood3.mp3") as AudioStream
@onready var step_wood4 = load("res://Assets//Sounds//Step//wood4.mp3") as AudioStream
@onready var step_wood5 = load("res://Assets//Sounds//Step//wood5.mp3") as AudioStream
@onready var step_wood6 = load("res://Assets//Sounds//Step//wood6.mp3") as AudioStream
@onready var fall_small = load("res://Assets//Sounds//Damage//fallsmall.mp3") as AudioStream
@onready var fall_big = load("res://Assets//Sounds//Damage//fallbig.mp3") as AudioStream
@onready var hoe_till1 = load("res://Assets/Sounds/Item/Hoe/hoe_till1.mp3") as AudioStream
@onready var hoe_till2 = load("res://Assets/Sounds/Item/Hoe/hoe_till2.mp3") as AudioStream
@onready var hoe_till3 = load("res://Assets/Sounds/Item/Hoe/hoe_till3.mp3") as AudioStream
@onready var hoe_till4 = load("res://Assets/Sounds/Item/Hoe/hoe_till4.mp3") as AudioStream
@onready var tool_break = load("res://Assets/Sounds/Random/tool_break.mp3") as AudioStream
@onready var player_attack = load("res://Assets/Sounds/Player/attack.mp3") as AudioStream
@onready var pig_death = load("res://Assets/Sounds/Pig/death.mp3") as AudioStream
@onready var pig_say1 = load("res://Assets/Sounds/Pig/say1.mp3") as AudioStream
@onready var pig_say2 = load("res://Assets/Sounds/Pig/say2.mp3") as AudioStream
@onready var pig_say3 = load("res://Assets/Sounds/Pig/say3.mp3") as AudioStream
@onready var chicken_hurt1 = load("res://Assets/Sounds/Chicken/hurt1.mp3") as AudioStream
@onready var chicken_hurt2 = load("res://Assets/Sounds/Chicken/hurt2.mp3") as AudioStream
@onready var chicken_plop = load("res://Assets/Sounds/Chicken/plop.mp3") as AudioStream
@onready var chicken_say1 = load("res://Assets/Sounds/Chicken/say1.mp3") as AudioStream
@onready var chicken_say2 = load("res://Assets/Sounds/Chicken/say2.mp3") as AudioStream
@onready var chicken_say3 = load("res://Assets/Sounds/Chicken/say3.mp3") as AudioStream
@onready var cow_hurt1_classic = load("res://Assets/Sounds/Cow/hurt1classic.ogg") as AudioStream
@onready var cow_hurt2_classic = load("res://Assets/Sounds/Cow/hurt2classic.ogg") as AudioStream
@onready var cow_hurt3_classic = load("res://Assets/Sounds/Cow/hurt3classic.ogg") as AudioStream
@onready var cow_say1_classic = load("res://Assets/Sounds/Cow/say1classic.ogg") as AudioStream
@onready var cow_say2_classic = load("res://Assets/Sounds/Cow/say2classic.ogg") as AudioStream
@onready var cow_say3_classic = load("res://Assets/Sounds/Cow/say3classic.ogg") as AudioStream
@onready var cow_say4_classic = load("res://Assets/Sounds/Cow/say4classic.ogg") as AudioStream
@onready var sheep_say1_classic = load("res://Assets/Sounds/Sheep/say1classic.ogg") as AudioStream
@onready var sheep_say2_classic = load("res://Assets/Sounds/Sheep/say2classic.ogg") as AudioStream
@onready var sheep_say3_classic = load("res://Assets/Sounds/Sheep/say3classic.ogg") as AudioStream
@onready var zombie_hurt1 = load("res://Assets/Sounds/Zombie/hurt1.mp3") as AudioStream
@onready var zombie_hurt2 = load("res://Assets/Sounds/Zombie/hurt2.mp3") as AudioStream
@onready var zombie_death = load("res://Assets/Sounds/Zombie/death.mp3") as AudioStream
@onready var zombie_say1 = load("res://Assets/Sounds/Zombie/say1.mp3") as AudioStream
@onready var zombie_say2 = load("res://Assets/Sounds/Zombie/say2.mp3") as AudioStream
@onready var zombie_say3 = load("res://Assets/Sounds/Zombie/say3.mp3") as AudioStream
@onready var skeleton_hurt1 = load("res://Assets/Sounds/Skeleton/hurt1.ogg") as AudioStream
@onready var skeleton_hurt2 = load("res://Assets/Sounds/Skeleton/hurt2.ogg") as AudioStream
@onready var skeleton_hurt3 = load("res://Assets/Sounds/Skeleton/hurt3.ogg") as AudioStream
@onready var skeleton_hurt4 = load("res://Assets/Sounds/Skeleton/hurt4.ogg") as AudioStream
@onready var skeleton_death = load("res://Assets/Sounds/Skeleton/death.ogg") as AudioStream
@onready var skeleton_say1 = load("res://Assets/Sounds/Skeleton/say1.ogg") as AudioStream
@onready var skeleton_say2 = load("res://Assets/Sounds/Skeleton/say2.ogg") as AudioStream
@onready var skeleton_say3 = load("res://Assets/Sounds/Skeleton/say3.ogg") as AudioStream
@onready var bow_shoot = load("res://Assets/Sounds/Random/bow.mp3") as AudioStream
@onready var bow_hit1 = load("res://Assets/Sounds/Random/bowhit1.mp3") as AudioStream
@onready var bow_hit2 = load("res://Assets/Sounds/Random/bowhit2.mp3") as AudioStream
@onready var bow_hit3 = load("res://Assets/Sounds/Random/bowhit3.mp3") as AudioStream
@onready var bow_hit4 = load("res://Assets/Sounds/Random/bowhit4.mp3") as AudioStream
@onready var successful_hit = load("res://Assets/Sounds/Random/successful_hit.mp3") as AudioStream
@onready var eat1 = load("res://Assets/Sounds/Random/eat1.mp3") as AudioStream
@onready var eat2 = load("res://Assets/Sounds/Random/eat2.mp3") as AudioStream
@onready var eat3 = load("res://Assets/Sounds/Random/eat3.mp3") as AudioStream
@onready var burp = load("res://Assets/Sounds/Random/burp.mp3") as AudioStream

var volume_db = 0
var dig_cloth_sound_list = []
var dig_grass_sound_list = []
var dig_gravel_sound_list = []
var dig_sand_sound_list = []
var dig_snow_sound_list = []
var dig_stone_sound_list = []
var dig_wood_sound_list = []
var dig_glass_sound_list = []
var step_cloth_sound_list = []
var step_grass_sound_list = []
var step_gravel_sound_list = []
var step_ladder_sound_list = []
var step_sand_sound_list = []
var step_snow_sound_list = []
var step_stone_sound_list = []
var step_wood_sound_list = []
var damage_fallsmall_sound_list = []
var damage_fallbig_sound_list = []
var tool_break_sound_list = []
var hurt_sound_list = []
var hit_sound_list = []
var hoe_still_sound_list = []
var player_attack_sound_list = []
var pig_death_sound_list = []
var pig_say_sound_list = []
var chicken_plop_sound_list = []
var chicken_hurt_sound_list = []
var chicken_say_sound_list = []
var cow_hurt_sound_list = []
var cow_say_sound_list = []
var sheep_say_sound_list = []
var zombie_hurt_sound_list = []
var zombie_death_sound_list = []
var zombie_say_sound_list = []
var skeleton_hurt_sound_list = []
var skeleton_death_sound_list = []
var skeleton_say_sound_list = []
var bow_shoot_sound_list = []
var bow_hit_sound_list = []
var successful_hit_sound_list = []
var eat_sound_list = []
var burp_sound_list = []

func _ready() -> void:
	dig_cloth_sound_list = [dig_cloth1, dig_cloth2, dig_cloth3, dig_cloth4]
	dig_grass_sound_list = [dig_grass1, dig_grass2, dig_grass3, dig_grass4]
	dig_gravel_sound_list = [dig_gravel1, dig_gravel2, dig_gravel3, dig_gravel4]
	dig_sand_sound_list = [dig_sand1, dig_sand2, dig_sand3, dig_sand4]
	dig_snow_sound_list = [dig_snow1, dig_snow2, dig_snow3, dig_snow4]
	dig_stone_sound_list = [dig_stone1, dig_stone2, dig_stone3, dig_stone4]
	dig_wood_sound_list = [dig_wood1, dig_wood2, dig_wood3, dig_wood4]
	dig_glass_sound_list = [dig_glass1, dig_glass2, dig_glass3]
		
	step_cloth_sound_list = [step_cloth1, step_cloth2, step_cloth3, step_cloth4]
	step_grass_sound_list = [step_grass1, step_grass2, step_grass3, step_grass4, step_grass5, step_grass6]
	step_gravel_sound_list = [step_gravel1, step_gravel2, step_gravel3, step_gravel4]
	step_ladder_sound_list = [step_ladder1, step_ladder2, step_ladder3, step_ladder4, step_ladder5]
	step_sand_sound_list = [step_sand1, step_sand2, step_sand3, step_sand4, step_sand5]
	step_snow_sound_list = [step_snow1, step_snow2, step_snow3, step_snow4]
	step_stone_sound_list = [step_stone1, step_stone2, step_stone3, step_stone4, step_stone5, step_stone6]
	step_wood_sound_list = [step_wood1, step_wood2, step_wood3, step_wood4, step_wood5, step_wood6]
	
	damage_fallsmall_sound_list = [fall_small]
	damage_fallbig_sound_list = [fall_big]
	tool_break_sound_list = [tool_break]
	hurt_sound_list = [hurt]
	hit_sound_list = [hit1, hit2, hit3]
	hoe_still_sound_list = [hoe_till1, hoe_till2, hoe_till3, hoe_till4]
	player_attack_sound_list = [player_attack]
	pig_death_sound_list = [pig_death]
	pig_say_sound_list = [pig_say1, pig_say2, pig_say3]
	chicken_plop_sound_list = [chicken_plop]
	chicken_hurt_sound_list = [chicken_hurt1, chicken_hurt2]
	chicken_say_sound_list = [chicken_say1, chicken_say2, chicken_say3]
	cow_hurt_sound_list = [cow_hurt1_classic, cow_hurt2_classic, cow_hurt3_classic]
	cow_say_sound_list = [cow_say1_classic, cow_say2_classic, cow_say3_classic, cow_say4_classic]
	sheep_say_sound_list = [sheep_say1_classic, sheep_say2_classic, sheep_say3_classic]
	zombie_hurt_sound_list = [zombie_hurt1, zombie_hurt2]
	zombie_death_sound_list = [zombie_death]
	zombie_say_sound_list = [zombie_say1, zombie_say2, zombie_say3]
	skeleton_hurt_sound_list = [skeleton_hurt1, skeleton_hurt2, skeleton_hurt3, skeleton_hurt4]
	skeleton_death_sound_list = [skeleton_death]
	skeleton_say_sound_list = [skeleton_say1, skeleton_say2, skeleton_say3]
	bow_shoot_sound_list = [bow_shoot]
	bow_hit_sound_list = [bow_hit1, bow_hit2, bow_hit3, bow_hit4]
	successful_hit_sound_list = [successful_hit]
	eat_sound_list = [eat1, eat2, eat3]
	burp_sound_list = [burp]

func play_audio_static(type, sub_type):
	var audio_player = AudioStreamPlayer.new()
	audio_player.volume_db = volume_db
	if type == "gui":
		if sub_type == "select":
			audio_player.stream = select
		if sub_type == "toast":
			audio_player.stream = toast
	elif type == "player":
		if sub_type == "pop":
			audio_player.stream = pop
	audio_player.connect("finished", _on_audio_finished.bind(audio_player))
	add_child(audio_player)
	audio_player.play()

func play_random_audio_at_position(type, sub_type, sound_position: Vector2, pitch_scale: float) -> void:
	var sound_list = []
	if type == "dig":
		if sub_type == "cloth":
			sound_list = dig_cloth_sound_list
		elif sub_type == "grass":
			sound_list = dig_grass_sound_list
		elif sub_type == "gravel":
			sound_list = dig_gravel_sound_list
		elif sub_type == "sand":
			sound_list = dig_sand_sound_list
		elif sub_type == "snow":
			sound_list = dig_snow_sound_list
		elif sub_type == "stone":
			sound_list = dig_stone_sound_list
		elif sub_type == "wood":
			sound_list = dig_wood_sound_list
		elif sub_type == "glass":
			sound_list = dig_glass_sound_list
	elif type == "damage":
		if sub_type == "fallsmall":
			sound_list = damage_fallsmall_sound_list
		elif sub_type == "fallbig":
			sound_list = damage_fallbig_sound_list
		elif sub_type == "hit":
			sound_list = hit_sound_list
	elif type == "player":
		if sub_type == "hurt":
			sound_list = hurt_sound_list
		elif sub_type == "attack":
			sound_list = player_attack_sound_list
	elif type == "pig":
		if sub_type == "death":
			sound_list = pig_death_sound_list
		elif sub_type == "say":
			sound_list = pig_say_sound_list
	elif type == "cow":
		if sub_type == "hurt":
			sound_list = cow_hurt_sound_list
		elif sub_type == "say":
			sound_list = cow_say_sound_list
	elif type == "sheep":
		if sub_type == "say":
			sound_list = sheep_say_sound_list
	elif type == "chicken":
		if sub_type == "hurt":
			sound_list = chicken_hurt_sound_list
		elif sub_type == "say":
			sound_list = chicken_say_sound_list
		elif sub_type == "plop":
			sound_list = chicken_plop_sound_list
	elif type == "zombie":
		if sub_type == "say":
			sound_list = zombie_say_sound_list
		elif sub_type == "hurt":
			sound_list = zombie_hurt_sound_list
		elif sub_type == "death":
			sound_list = zombie_death_sound_list
	elif type == "skeleton":
		if sub_type == "say":
			sound_list = skeleton_say_sound_list
		elif sub_type == "hurt":
			sound_list = skeleton_hurt_sound_list
		elif sub_type == "death":
			sound_list = skeleton_death_sound_list
	elif type == "item":
		if sub_type == "hoe_still":
			sound_list = hoe_still_sound_list
	elif type == "random":
		if sub_type == "burp":
			sound_list = burp_sound_list
		if sub_type == "eat":
			sound_list = eat_sound_list
		if sub_type == "tool_break":
			sound_list = tool_break_sound_list
		if sub_type == "bow_shoot":
			sound_list = bow_shoot_sound_list
		if sub_type == "bow_hit":
			sound_list = bow_hit_sound_list
		if sub_type == "successful_hit":
			sound_list = successful_hit_sound_list
	elif type == "step":
		if sub_type == "cloth":
			sound_list = step_cloth_sound_list
		elif sub_type == "grass":
			sound_list = step_grass_sound_list
		elif sub_type == "gravel":
			sound_list = step_gravel_sound_list
		elif sub_type == "ladder":
			sound_list = step_ladder_sound_list
		elif sub_type == "sand":
			sound_list = step_sand_sound_list
		elif sub_type == "snow":
			sound_list = step_snow_sound_list
		elif sub_type == "stone":
			sound_list = step_stone_sound_list
		elif sub_type == "wood":
			sound_list = step_wood_sound_list
		elif sub_type == "glass":
			sound_list = step_stone_sound_list
	if sound_list.is_empty():
		return
	var sound = sound_list[randi() % sound_list.size()]
	play_audio_at_position(sound, sound_position, pitch_scale)
	
func play_audio_at_position(audio:AudioStream ,sound_position: Vector2, pitch_scale: float) -> void:
	var audio_player = AudioStreamPlayer2D.new()
	audio_player.pitch_scale = pitch_scale
	audio_player.stream = audio
	audio_player.position = sound_position
	audio_player.panning_strength = 3
	audio_player.volume_db = volume_db
	audio_player.connect("finished", _on_audio_finished.bind(audio_player))
	add_child(audio_player)
	audio_player.play()

func _on_audio_finished(audio_player) -> void:
	audio_player.queue_free()  # 删除实例以释放内存
