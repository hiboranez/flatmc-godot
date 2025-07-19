extends Node

@onready var bgm_audio_player = $BgmAudioPlayer

var music_dict: Dictionary
var sound_dict: Dictionary

func _ready() -> void:
	if OS.has_feature("dedicated_server"):
		return
		
	var music_type_list = DirAccess.get_directories_at("res://assets/audios/music")
	for music_type in music_type_list:
		var music_dict_tmp = {}
		var music_name_list = DirAccess.get_files_at("res://assets/audios/music/"+music_type)
		for music_file_name in music_name_list:
			if music_file_name.contains(".import"):
				continue
			var splits = music_file_name.split(".")
			var music_name = splits[0]
			music_dict_tmp[music_name] = load("res://assets/audios/music/"+music_type+"/"+music_file_name) as AudioStream
		music_dict[music_type.to_lower()] = music_dict_tmp
	
	var sound_type_list = DirAccess.get_directories_at("res://assets/audios/sound")
	for sound_type in sound_type_list:
		var sound_dict_tmp = {}
		var sound_name_list = DirAccess.get_files_at("res://assets/audios/sound/"+sound_type)
		for sound_file_name in sound_name_list:
			if sound_file_name.contains(".import"):
				continue
			var splits = sound_file_name.split(".")
			var sound_name = splits[0]
			sound_dict_tmp[sound_name] = load("res://assets/audios/sound/"+sound_type+"/"+sound_file_name) as AudioStream
		sound_dict[sound_type.to_lower()] = sound_dict_tmp
	
	await get_tree().create_timer(0.5).timeout
	play_random_bgm()

func stop_bgm():
	bgm_audio_player.stop()

func refresh_bgm():
	bgm_audio_player.stop()
	await get_tree().create_timer(0.5).timeout
	play_random_bgm()

func play_random_bgm() -> void:
	var bgm_list = music_dict["classic_game"]
	if StaticLoad.is_in_game:
		if StaticLoad.is_new_music_on:
			var new_game_music_list = music_dict["classic_game"].values()
			new_game_music_list.append_array(music_dict["new_game_menu"].values())
			bgm_list = new_game_music_list
		else:
			bgm_list = music_dict["classic_game"].values()
	else:
		if StaticLoad.is_new_music_on:
			var new_game_music_list = music_dict["classic_menu"].values()
			new_game_music_list.append_array(music_dict["new_game_menu"].values())
			bgm_list = new_game_music_list
		else:
			bgm_list = music_dict["classic_menu"].values()
	if bgm_list.is_empty():
		return
	bgm_audio_player.stream = bgm_list[randi() % bgm_list.size()]
	bgm_audio_player.play()

func _on_bgm_audio_player_finished() -> void:
	play_random_bgm()

func play_static_audio(path):
	var audio_player = AudioStreamPlayer.new()
	var audio_dict = null
	var splits = path.split("/")
	if splits[0] == "music":
		audio_dict = music_dict
	elif splits[0] == "sound":
		audio_dict = sound_dict
	if audio_dict == null:
		return
	audio_player.stream = audio_dict[splits[1]][splits[2]]
	audio_player.connect("finished", _on_audio_finished.bind(audio_player))
	add_child(audio_player)
	audio_player.play()

func _on_audio_finished(audio_player) -> void:
	audio_player.queue_free()  # 删除实例以释放内存
