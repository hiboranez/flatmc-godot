extends AudioStreamPlayer

@onready var aria_math = load("res://Assets//Sounds//Music//ClassicGameMusic//aria_math.mp3") as AudioStream
@onready var biome_fest = load("res://Assets//Sounds//Music//ClassicGameMusic//biome_fest.mp3") as AudioStream
@onready var danny = load("res://Assets//Sounds//Music//ClassicGameMusic//danny.mp3") as AudioStream
@onready var dreiton = load("res://Assets//Sounds//Music//ClassicGameMusic//dreiton.mp3") as AudioStream
@onready var dry_hands = load("res://Assets//Sounds//Music//ClassicGameMusic//dry_hands.mp3") as AudioStream
@onready var haunt_muskie = load("res://Assets//Sounds//Music//ClassicGameMusic//haunt_muskie.mp3") as AudioStream
@onready var key = load("res://Assets//Sounds//Music//ClassicGameMusic//key.mp3") as AudioStream
@onready var living_mice = load("res://Assets//Sounds//Music//ClassicGameMusic//living_mice.mp3") as AudioStream
@onready var mice_on_venus = load("res://Assets//Sounds//Music//ClassicGameMusic//mice_on_venus.mp3") as AudioStream
@onready var minecraft = load("res://Assets//Sounds//Music//ClassicGameMusic//minecraft.mp3") as AudioStream
@onready var oxygene = load("res://Assets//Sounds//Music//ClassicGameMusic//oxygene.mp3") as AudioStream
@onready var subwoofer_lullaby = load("res://Assets//Sounds//Music//ClassicGameMusic//subwoofer_lullaby.mp3") as AudioStream
@onready var sweden = load("res://Assets//Sounds//Music//ClassicGameMusic//sweden.mp3") as AudioStream
@onready var taswell = load("res://Assets//Sounds//Music//ClassicGameMusic//taswell.mp3") as AudioStream
@onready var wet_hands = load("res://Assets//Sounds//Music//ClassicGameMusic//wet_hands.mp3") as AudioStream

@onready var beginning_2 = load("res://Assets//Sounds//Music//ClassicMenuMusic//beginning_2.mp3") as AudioStream
@onready var floating_trees = load("res://Assets//Sounds//Music//ClassicMenuMusic//floating_trees.mp3") as AudioStream
@onready var moog_city_2 = load("res://Assets//Sounds//Music//ClassicMenuMusic//moog_city_2.mp3") as AudioStream
@onready var mutation = load("res://Assets//Sounds//Music//ClassicMenuMusic//mutation.mp3") as AudioStream

@onready var a_familiar_room = load("res://Assets//Sounds//Music//NewGameMenuMusic//a_familiar_room.mp3") as AudioStream
@onready var aerie = load("res://Assets//Sounds//Music//NewGameMenuMusic//aerie.mp3") as AudioStream
@onready var bromeliad = load("res://Assets//Sounds//Music//NewGameMenuMusic//bromeliad.mp3") as AudioStream
@onready var deeper = load("res://Assets//Sounds//Music//NewGameMenuMusic//deeper.mp3") as AudioStream
@onready var echo_in_the_wind = load("res://Assets//Sounds//Music//NewGameMenuMusic//echo_in_the_wind.mp3") as AudioStream
@onready var eld_unknown = load("res://Assets//Sounds//Music//NewGameMenuMusic//eld_unknown.mp3") as AudioStream
@onready var endless = load("res://Assets//Sounds//Music//NewGameMenuMusic//endless.mp3") as AudioStream
@onready var featherfall = load("res://Assets//Sounds//Music//NewGameMenuMusic//featherfall.mp3") as AudioStream
@onready var firebugs = load("res://Assets//Sounds//Music//NewGameMenuMusic//firebugs.mp3") as AudioStream
@onready var floating_dream = load("res://Assets//Sounds//Music//NewGameMenuMusic//floating_dream.mp3") as AudioStream
@onready var infinite_amethyst = load("res://Assets//Sounds//Music//NewGameMenuMusic//infinite_amethyst.mp3") as AudioStream
@onready var komorebi = load("res://Assets//Sounds//Music//NewGameMenuMusic//komorebi.mp3") as AudioStream
@onready var labyrinthine = load("res://Assets//Sounds//Music//NewGameMenuMusic//labyrinthine.mp3") as AudioStream
@onready var left_to_bloom = load("res://Assets//Sounds//Music//NewGameMenuMusic//left_to_bloom.mp3") as AudioStream
@onready var one_more_day = load("res://Assets//Sounds//Music//NewGameMenuMusic//one_more_day.mp3") as AudioStream
@onready var pokopoko = load("res://Assets//Sounds//Music//NewGameMenuMusic//pokopoko.mp3") as AudioStream
@onready var puzzlebox = load("res://Assets//Sounds//Music//NewGameMenuMusic//puzzlebox.mp3") as AudioStream
@onready var rubedo = load("res://Assets//Sounds//Music//NewGameMenuMusic//rubedo.mp3") as AudioStream
@onready var shuniji = load("res://Assets//Sounds//Music//NewGameMenuMusic//shuniji.mp3") as AudioStream
@onready var stand_tall = load("res://Assets//Sounds//Music//NewGameMenuMusic//stand_tall.mp3") as AudioStream
@onready var watcher = load("res://Assets//Sounds//Music//NewGameMenuMusic//watcher.mp3") as AudioStream
@onready var wending = load("res://Assets//Sounds//Music//NewGameMenuMusic//wending.mp3") as AudioStream
@onready var yakusoku = load("res://Assets//Sounds//Music//NewGameMenuMusic//yakusoku.mp3") as AudioStream

var classic_game_music_list = []
var classic_menu_music_list = []
var new_game_music_list = []
var new_menu_music_list = []
var current_bgm = null

func _ready() -> void:
	if OS.has_feature("dedicated_server"):
		return
	classic_game_music_list = [aria_math, biome_fest, danny, dreiton,
	dry_hands, haunt_muskie, key, living_mice,
	mice_on_venus, minecraft, oxygene, subwoofer_lullaby,
	sweden, taswell, wet_hands]
	
	classic_menu_music_list = [beginning_2, floating_trees,
	moog_city_2, mutation]
	
	new_game_music_list = [aria_math, biome_fest, danny, dreiton,
	dry_hands, haunt_muskie, key, living_mice,
	mice_on_venus, minecraft, oxygene, subwoofer_lullaby,
	sweden, taswell, wet_hands, a_familiar_room, aerie, bromeliad,
	deeper, echo_in_the_wind, eld_unknown,
	endless, featherfall, firebugs, floating_dream,
	infinite_amethyst, komorebi, labyrinthine,
	left_to_bloom, one_more_day, pokopoko, puzzlebox,
	rubedo, shuniji, stand_tall, watcher, wending, yakusoku]
	
	new_menu_music_list = [beginning_2, floating_trees,
	moog_city_2, mutation, a_familiar_room, aerie, bromeliad,
	deeper, echo_in_the_wind, eld_unknown,
	endless, featherfall, firebugs, floating_dream,
	infinite_amethyst, komorebi, labyrinthine,
	left_to_bloom, one_more_day, pokopoko, puzzlebox,
	rubedo, shuniji, stand_tall, watcher, wending, yakusoku]
	#var classic_game_music_file_list = DirAccess.get_files_at("res://Assets//Sounds//Music//ClassicGameMusic")
	#var classic_game_music_file_list = ["aria_math.mp3", "aria_math.mp3.import", "biome_fest.mp3", "biome_fest.mp3.import", "danny.mp3", "danny.mp3.import", "dreiton.mp3", "dreiton.mp3.import", "dry_hands.mp3", "dry_hands.mp3.import", "haunt_muskie.mp3", "haunt_muskie.mp3.import", "key.mp3", "key.mp3.import", "living_mice.mp3", "living_mice.mp3.import", "mice_on_venus.mp3", "mice_on_venus.mp3.import", "minecraft.mp3", "minecraft.mp3.import", "oxygene.mp3", "oxygene.mp3.import", "subwoofer_lullaby.mp3", "subwoofer_lullaby.mp3.import", "sweden.mp3", "sweden.mp3.import", "taswell.mp3", "taswell.mp3.import", "wet_hands.mp3", "wet_hands.mp3.import"]
	#for music in classic_game_music_file_list:
		#if music.contains("import"):
			#continue
		#var music_file = load("res://Assets//Sounds//Music//ClassicGameMusic//"+music) as AudioStream
		#classic_game_music_list.append(music_file)
		#new_game_music_list.append(music_file)
	#var classic_menu_music_file_list = DirAccess.get_files_at("res://Assets//Sounds//Music//ClassicMenuMusic")
	#var classic_menu_music_file_list = ["beginning_2.mp3", "beginning_2.mp3.import", "floating_trees.mp3", "floating_trees.mp3.import", "moog_city_2.mp3", "moog_city_2.mp3.import", "mutation.mp3", "mutation.mp3.import"]
	#for music in classic_menu_music_file_list:
		#if music.contains("import"):
			#continue
		#var music_file = load("res://Assets//Sounds//Music//ClassicMenuMusic//"+music) as AudioStream
		#classic_menu_music_list.append(music_file)
		#new_menu_music_list.append(music_file)
	#var new_music_file_list = DirAccess.get_files_at("res://Assets//Sounds//Music//NewGameMenuMusic")
	#var new_music_file_list = ["a_familiar_room.mp3", "a_familiar_room.mp3.import", "aerie.mp3", "aerie.mp3.import", "bromeliad.mp3", "bromeliad.mp3.import", "crescent_dunes.mp3", "crescent_dunes.mp3.import", "deeper.mp3", "deeper.mp3.import", "echo_in_the_wind.mp3", "echo_in_the_wind.mp3.import", "eld_unknown.mp3", "eld_unknown.mp3.import", "endless.mp3", "endless.mp3.import", "featherfall.mp3", "featherfall.mp3.import", "firebugs.mp3", "firebugs.mp3.import", "floating_dream.mp3", "floating_dream.mp3.import", "infinite_amethyst.mp3", "infinite_amethyst.mp3.import", "komorebi.mp3", "komorebi.mp3.import", "labyrinthine.mp3", "labyrinthine.mp3.import", "left_to_bloom.mp3", "left_to_bloom.mp3.import", "one_more_day.mp3", "one_more_day.mp3.import", "pokopoko.mp3", "pokopoko.mp3.import", "puzzlebox.mp3", "puzzlebox.mp3.import", "rubedo.mp3", "rubedo.mp3.import", "shuniji.mp3", "shuniji.mp3.import", "stand_tall.mp3", "stand_tall.mp3.import", "watcher.mp3", "watcher.mp3.import", "wending.mp3", "wending.mp3.import", "yakusoku.mp3", "yakusoku.mp3.import"]
	#for music in new_music_file_list:
		#if music.contains("import"):
			#continue
		#var music_file = load("res://Assets//Sounds//Music//NewGameMenuMusic//"+music) as AudioStream
		#new_game_music_list.append(music_file)
		#new_menu_music_list.append(music_file)
	await get_tree().create_timer(0.5).timeout
	play_random_bgm()

#@warning_ignore("unused_parameter")
#func _process(delta: float) -> void:
	#await get_tree().create_timer(1).timeout
	#if not is_playing():
		#_on_AudioStreamPlayer2D_finished()

func _on_AudioStreamPlayer2D_finished() -> void:
	play_random_bgm()

func stop_bgm():
	#set_process(false)
	stop()

func refresh_bgm():
	#set_process(false)
	stop()
	await get_tree().create_timer(0.5).timeout
	play_random_bgm()
	#set_process(true)

func play_random_bgm() -> void:
	var bgm_list = classic_game_music_list
	if StaticLoad.is_in_game:
		if StaticLoad.is_new_music_on:
			bgm_list = new_game_music_list
		else:
			bgm_list = classic_game_music_list
	else:
		if StaticLoad.is_new_music_on:
			bgm_list = new_menu_music_list
		else:
			bgm_list = classic_menu_music_list
	if bgm_list.is_empty():
		return
	current_bgm = bgm_list[randi() % bgm_list.size()]
	stream = current_bgm
	play()
