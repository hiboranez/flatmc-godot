extends Node

@onready var bgm_audio_player = $BgmAudioPlayer

var bgm_volume: float = 1
var sound_volume: float = 1

var music_dict: Dictionary
var sound_dict: Dictionary

func get_resource_amount() -> int:
	var amount: int = 0
	var music_type_list = DirAccess.get_directories_at("res://assets/audios/music")
	for music_type in music_type_list:
		var music_name_list = DirAccess.get_files_at("res://assets/audios/music/"+music_type)
		for music_file_name in music_name_list:
			if music_file_name.contains(".import"):
				continue
			amount += 1
	
	var sound_type_list = DirAccess.get_directories_at("res://assets/audios/sound")
	for sound_type in sound_type_list:
		var sound_name_list = DirAccess.get_files_at("res://assets/audios/sound/"+sound_type)
		for sound_file_name in sound_name_list:
			if sound_file_name.contains(".import"):
				continue
			amount += 1
	return amount

func update_resource() -> void:
	var music_type_list = DirAccess.get_directories_at("res://assets/audios/music")
	for music_type in music_type_list:
		var music_dict_tmp = {}
		var music_name_list = DirAccess.get_files_at("res://assets/audios/music/"+music_type)
		for music_file_name in music_name_list:
			if music_file_name.contains(".import"):
				continue
			var splits = music_file_name.split(".")
			var music_name = splits[0]
			GameLoader.call_deferred("set_loading_info", "res://assets/audios/music/"+music_type+"/"+music_file_name)
			music_dict_tmp[music_name] = load("res://assets/audios/music/"+music_type+"/"+music_file_name) as AudioStream
			GameLoader.add_loaded_amount()
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
			GameLoader.call_deferred("set_loading_info", "res://assets/audios/sound/"+sound_type+"/"+sound_file_name)
			sound_dict_tmp[sound_name] = load("res://assets/audios/sound/"+sound_type+"/"+sound_file_name) as AudioStream
			GameLoader.add_loaded_amount()
		sound_dict[sound_type.to_lower()] = sound_dict_tmp

func stop_bgm():
	if bgm_audio_player.playing:
		bgm_audio_player.stop()

func refresh_bgm():
	stop_bgm()
	play_random_bgm()

func play_random_bgm() -> void:
	var bgm_list = music_dict["classic_game"]
	if StaticLoad.is_in_game:
		if SettingsManager.get_current_setting("new_music") == "on":
			var new_game_music_list = music_dict["classic_game"].values()
			new_game_music_list.append_array(music_dict["new_game_menu"].values())
			bgm_list = new_game_music_list
		else:
			bgm_list = music_dict["classic_game"].values()
	else:
		if SettingsManager.get_current_setting("new_music") == "on":
			var new_game_music_list = music_dict["classic_menu"].values()
			new_game_music_list.append_array(music_dict["new_game_menu"].values())
			bgm_list = new_game_music_list
		else:
			bgm_list = music_dict["classic_menu"].values()
	if bgm_list.is_empty():
		return
	bgm_audio_player.stream = bgm_list[randi() % bgm_list.size()]
	bgm_audio_player.play()

func set_bgm_volume(got_volume) -> void:
	if got_volume == 0 and bgm_audio_player.playing:
		stop_bgm()
	elif got_volume > 0 and not bgm_audio_player.playing:
		play_random_bgm()
	bgm_audio_player.volume_db = linear_to_db(got_volume)
	bgm_volume = got_volume

func set_sound_volume(got_volume) -> void:
	sound_volume = got_volume

func _on_bgm_audio_player_finished() -> void:
	play_random_bgm()

func play_static_audio(path):
	if sound_volume == 0:
		return
	var audio_player = AudioStreamPlayer.new()
	var audio_dict = null
	var splits = path.split("/")
	if splits[0] == "music":
		audio_dict = music_dict
	elif splits[0] == "sound":
		audio_dict = sound_dict
	if audio_dict == null:
		return
	audio_player.volume_db = linear_to_db(sound_volume)
	audio_player.stream = audio_dict[splits[1]][splits[2]]
	audio_player.connect("finished", _on_audio_finished.bind(audio_player))
	add_child(audio_player)
	audio_player.play()

func _on_audio_finished(audio_player) -> void:
	audio_player.queue_free()  # 删除实例以释放内存
